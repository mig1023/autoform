package VCS::Site::autoinfopage;
use strict;

use VCS::Vars;
use Data::Dumper;
use Imager::QRCode;
use Date::Calc;

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
	
	return $self->do_reschedule( $task, $id, $template ) if $action eq 'do_reschedule';
	
	return $self->reschedule( $task, $id, $template ) if $action eq 'reschedule';
	
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
}

sub reschedule
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $new = {};
	
	$new->{ $_ } = $self->{ vars }->getparam( $_ ) for ( 'app_date', 'timeslot' );
	
	if (
		$new->{ timeslot } =~ /^\d+$/
		and
		$new->{ app_date } =~ /(\d\d)\.(\d\d)\.(\d\d\d\d)/
		and
		Date::Calc::check_date( $3, $2, $1 )
	) {
	
		$new->{ app_date } =~ s/(\d\d)\.(\d\d)\.(\d\d\d\d)/$3-$2-$1/;
		
		# my $time_start = $self->time_interval_calculate();
	
		$self->{ af }->query( 'query', __LINE__, "
			LOCK TABLES Appointments WRITE, AutoToken READ"
		);
		
		my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
			SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ af }->{ token }
		);
		
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE Appointments SET AppDate = ?, TimeslotID = ? WHERE ID = ?", {}, 
			$new->{ app_date }, $new->{ timeslot }, $app_id
		);
		
		$self->{ af }->query( 'query', __LINE__, "UNLOCK TABLES");
	
		# my $milliseconds = $self->time_interval_calculate( $time_start );
		# warn 'lock (line ' . __LINE__ . ") - $milliseconds ms"; 
		
		return $self->{ af }->redirect( 
			'?t=' . $self->{ af }->{ token } . ( $self->{ af }->{ lang } ? '&lang=' . $self->{ af }->{ lang } : '' ) 
		);
	}
	
	my $appinfo_for_timeslots = $self->get_same_info_for_timeslots_from_app();

	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar(@_) },
		'title' 	=> 2,
		'appinfo'	=> $appinfo_for_timeslots,
		'token' 	=> $self->{ af }->{ token },
		'addr' 		=> $self->{ vars }->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr },
		'vcs_tools' 	=> $self->{ autoform }->{ paths }->{ addr_vcs },
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub get_same_info_for_timeslots_from_app
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app = {};

	( $app->{ persons }, $app->{ center }, $app->{ fdate }, $app->{ timeslot }, $app->{ appdate } ) = 
		$self->{ af }->query( 'sel1', __LINE__, "
			SELECT count(AppData.ID), CenterID, SDate, TimeslotID, AppDate
			FROM AutoToken 
			JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
			JOIN AppData ON AppData.AppID = Appointments.ID
			WHERE Token = ?", $self->{ af }->{ token }
		);
	
	$app->{ fdate_iso } = $app->{ fdate };
	
	$_ =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/ for ( $app->{ fdate }, $app->{ appdate });

	return $app;
}

1;
