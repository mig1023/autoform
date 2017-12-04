package VCS::Site::autoinfopage;
use strict;

use VCS::Vars;
use Data::Dumper;
use Imager::QRCode;

sub new
# //////////////////////////////////////////////////
{
	my ( $class, $pclass, $vars ) = @_;
	my $self = bless {}, $pclass;
	$self->{ 'VCS::Vars' } = $vars;
	return $self;
}

sub autoinfopage
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	$self->{ vars } = $self->{ af }->{ vars };
	
	$self->{ vars }->{'session'}->{'login'} = 'website';
		
	my $action = lc( $self->{ vars }->getparam('action') );
	$action =~ s/[^a-z]//g;
	
	return $self->print_appointment() if $action eq 'print';
	
	return $self->get_infopage( $task, $id, $template );
}

sub get_infopage
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $app_info = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT CreatedApp, AppNum as new_app_num, AppDate as new_app_date,
		TimeslotID as new_app_timeslot,	CenterID as new_app_branch, VName as new_app_vname
		FROM AutoToken
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		JOIN VisaTypes ON Appointments.VType = VisaTypes.ID
		WHERE Token = ?", $self->{ af }->{ token }
	)->[0];

	$app_info->{ new_app_date } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
	
	$app_info->{ new_app_num } =~ s!(\d{3})(\d{4})(\d{2})(\d{2})(\d{4})!$1/$2/$3/$4/$5!;
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	$self->{ af }->correct_values( \$app_info );

	my $app_list = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppData.ID, AppData.FName, AppData.LName, AppData.BirthDate
		FROM AutoToken 
		JOIN AppData ON AppData.AppID = AutoToken.CreatedApp
		WHERE Token = ?", $self->{ af }->{ token }
	);
	
	$_->{ 'BirthDate' } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/ for @$app_list;
	
	my $qrcode_file_name = "qrcode_" . $self->{ af }->{ token } . ".png";
	my $qrcode_file = $self->{ autoform }->{ qrcode }->{ file_folder } . $qrcode_file_name;
	
	unless ( -e $qrcode_file ) {
	
		my $qrcode = Imager::QRCode->new(
			size          => 4,
			margin        => 0,
			version       => 1,
			level         => 'M',
			casesensitive => 1,
			lightcolor    => Imager::Color->new( 255, 255, 255 ),
			darkcolor     => Imager::Color->new( 0, 0, 0 ),
		);

		my $img = $qrcode->plot(
			$self->{ vars }->getform( 'fullhost' ) .$self->{ autoform }->{ paths }->{ addr } .
			'?t=' . $self->{ af }->{ token } . ( $self->{ af }->{ lang } ? '&lang=' . $self->{ af }->{ lang } : '' )
		);
		
		$img->write( file => $qrcode_file );
	}
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar(@_) },
		'title' 	=> 1,
		'app_info'	=> $app_info,
		'app_list'	=> $app_list,
		'token' 	=> $self->{ af }->{ token },
		'addr' 		=> $self->{ vars }->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr },
		'qrcode'	=> $self->{ vars }->getform('fullhost') . '/files/' . $qrcode_file_name,
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub print_appointment
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ af }->{ token }
	);

	my $appointment = VCS::Docs::appointments->new( 'VCS::Docs::appointments', $self->{ vars } );
	
	my $report = VCS::Reports::reports->new( 'VCS::Reports::reports', $self->{ vars } );
	
	$report->printReport( $appointment->createPDF( $app_id ), 'pdf', "appointment" );
	
	$self->{ vars }->get_system->redirect( 
		$self->{ vars }->getform( 'fullhost' ) .$self->{ autoform }->{ paths }->{ addr } .
		'?t=' . $self->{ af }->{ token } . ( $self->{ af }->{ lang } ? '&lang=' . $self->{ af }->{ lang } : '' )
	);
}

1;
