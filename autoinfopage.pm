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
	
	$self->{ $_ } = $self->{ af }->{ $_ } for ( 'vars', 'token' );
	
	$self->{ vars }->{'session'}->{'login'} = 'website';
		
	my $action = lc( $self->{ vars }->getparam('action') );
	$action =~ s/[^a-z_]//g;
	
	return $self->print_appointment() if $action eq 'print';
	
	return $self->print_appdata() if $action eq 'print_a';

	return $self->reschedule( $task, $id, $template ) if $action eq 'reschedule';
	
	return $self->cancel( $task, $id, $template ) if $action eq 'cancel';
	
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
		WHERE Token = ?", $self->{ token }
	)->[0];

	$app_info->{ new_app_date } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
	
	$app_info->{ new_app_num } =~ s!(\d{3})(\d{4})(\d{2})(\d{2})(\d{4})!$1/$2/$3/$4/$5!;
	
	$self->{ af }->correct_values( \$app_info );

	my $app_list = $self->get_app_list();
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar(@_) },
		'title' 	=> 1,
		'app_info'	=> $app_info,
		'app_list'	=> $app_list,
		'token' 	=> $self->{ token },
		'addr' 		=> $self->{ vars }->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr },
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub print_appointment
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
	);

	my $appointment = VCS::Docs::appointments->new( 'VCS::Docs::appointments', $self->{ vars } );
	
	my $report = VCS::Reports::reports->new( 'VCS::Reports::reports', $self->{ vars } );
	
	$report->printReport( $appointment->createPDF( $app_id ), 'pdf', "appointment" );
}

sub print_appdata
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $appdata = lc( $self->{ vars }->getparam( 'appdata' ) );
	
	$appdata =~ s/[^0-9]//g;

	return $self->redirect() unless $self->check_existing_id_in_token( $appdata );

	my $print = VCS::Docs::docs->new( 'VCS::Docs::docs', $self->{ vars } );
	
	$self->{ vars }->setparam( 'appid', $appdata );
	
	$print->print_anketa();
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
		$self->set_new_appdate( $new );
		
		return $self->redirect();
	}
	
	my $appinfo_for_timeslots = $self->get_same_info_for_timeslots_from_app();

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar(@_) },
		'title' 	=> 2,
		'appinfo'	=> $appinfo_for_timeslots,
		'token' 	=> $self->{ token },
		'addr' 		=> $self->{ vars }->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr },
		'vcs_tools' 	=> $self->{ autoform }->{ paths }->{ addr_vcs },
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub cancel
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $app_list = $self->get_app_list();

	my $ncount_correction = 0;
	
	for my $app ( @$app_list ) {

		next unless $self->{ vars }->getparam( 'cancel' . $app->{ ID } );
	
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE AppData SET Status = 2 WHERE ID = ?", {}, $app->{ ID }
		);

		$ncount_correction = 1;
	}
	
	if ( $ncount_correction ) {
	
		my $list_after_cancel = $self->get_app_list();
		
		my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
			SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
		);
		
		my $ncount = scalar @$list_after_cancel;
		
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE Appointments SET NCount = ? WHERE ID = ?", {},
			$ncount, $app_id
		);
		
		if ( $ncount < 1 ) {

			my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
				SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
			);

			$self->{ af }->query( 'query', __LINE__, "
				UPDATE Appointments SET Status = 2 WHERE ID = ?", {},
				$app_id
			);
		}
		
		return $self->redirect();
	}
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar(@_) },
		'title' 	=> 3,
		'app_list'	=> $app_list,
		'token' 	=> $self->{ token },
		'addr' 		=> $self->{ vars }->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr },
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
			WHERE Token = ?", $self->{ token }
		);
	
	$app->{ fdate_iso } = $app->{ fdate };
	
	$_ =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/ for ( $app->{ fdate }, $app->{ appdate });

	return $app;
}

sub get_app_list
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app_list = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppData.ID, AppData.AppID, AppData.FName, AppData.LName, AppData.BirthDate
		FROM AutoToken 
		JOIN AppData ON AppData.AppID = AutoToken.CreatedApp
		WHERE Token = ? AND AppData.Status = 1", $self->{ token }
	);

	$_->{ 'BirthDate' } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/ for @$app_list;

	return $app_list;
}

sub set_new_appdate
# //////////////////////////////////////////////////
{
	my ( $self, $new ) = @_;

	$new->{ app_date } =~ s/(\d\d)\.(\d\d)\.(\d\d\d\d)/$3-$2-$1/;
	
	# my $time_start = $self->{ af }->time_interval_calculate();

	$self->{ af }->query( 'query', __LINE__, "
		LOCK TABLES Appointments WRITE, AutoToken READ"
	);
	
	my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
	);
	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE Appointments SET AppDate = ?, TimeslotID = ? WHERE ID = ?", {}, 
		$new->{ app_date }, $new->{ timeslot }, $app_id
	);
	
	$self->{ af }->query( 'query', __LINE__, "UNLOCK TABLES");

	# my $milliseconds = $self->{ af }->time_interval_calculate( $time_start );
	# warn 'lock (line ' . __LINE__ . ") - $milliseconds ms";
	
	return $app_id;
}

sub check_existing_id_in_token
# //////////////////////////////////////////////////
{
	my ( $self, $appdata_id ) = @_;
	
	my $exist = 0;
	
	my $list_of_app_in_token = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppData.ID
		FROM AutoToken 
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		JOIN AppData ON Appointments.ID = AppData.AppID
		WHERE Token = ?", $self->{ token }
	);

	for my $app ( @$list_of_app_in_token ) {
		$exist = 1 if ( $app->{ID} == $appdata_id );
	}
	
	return $exist;
}

sub redirect
# //////////////////////////////////////////////////
{
	my $self = shift;

	return $self->{ af }->redirect(
		'?t=' . $self->{ token } . ( $self->{ af }->{ lang } ? '&lang=' . $self->{ af }->{ lang } : '' ) 
	);
}
	
1;
