package VCS::Site::autoinfopage;
use strict;

use VCS::Vars;
use Data::Dumper;
use Date::Calc;
use JSON;

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
	my ( $self, $task, $id, $template, $entry ) = @_;
		
	$self->{ $_ } = $self->{ af }->{ $_ } for ( 'vars', 'token' );
	
	$self->{ vars }->{ session }->{ login } = 'website';
		
	my $_ = $self->{ vars }->getparam( 'action' );
	
	s/[^a-z_]//g;
	
	return $self->print_appointment() if /^print$/i;
	
	return $self->print_appdata() if /^print_a$/i;
	
	return autoinfopage_entry ( @_ ) if $entry;

	return reschedule( @_ ) if /^reschedule$/i;
	
	return cancel( @_ ) if /^cancel$/i;
	
	return get_infopage( @_ );
}

sub autoinfopage_entry
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $param = {};
	
	for ( "action", "appnum", "passnum" ) {
	
		$param->{ $_ } = $self->{ vars }->getparam( $_ ) || undef;
		
		$param->{ $_ } =~ s/[^0-9]//g;
	}

	if ( $param->{ action } and ( !$param->{ appnum } or !$param->{ passnum } or $self->{ af }->check_captcha() ) ) {
	
		return $self->{ af }->redirect( 'no_field' );
	}
	elsif ( $param->{ action } ) {

		my $appdata = $self->{ af }->query( 'selallkeys', __LINE__, "
			SELECT Token, AppData.PassNum as passnum
			FROM AutoToken
			JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
			JOIN AppData ON Appointments.ID = AppData.AppID
			WHERE AppNum = ?", $param->{ appnum }
		);

		for my $app ( @$appdata ) {

			return $self->{ af }->redirect( $app->{ Token } ) if $app->{ passnum } eq $param->{ passnum };
		}
			
		return $self->{ af }->redirect( 'no_app' );
	}
	
	my $key = $self->{ autoform }->{ captcha }->{ public_key };
			
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq' 	=> sub { return $self->{ vars }->getLangSesVar(@_) },
		'addr' 		=> $self->{ vars }->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'widget_api'	=> $self->{ autoform }->{ captcha }->{ widget_api },
		'json_options'	=> to_json( { sitekey => $key, theme => 'light' }, $self->{ json_options } || {} ),
	};
	$template->process( 'autoform_info_entry.tt2', $tvars );
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

	my $center_msk = ( $app_info->{ new_app_branch } == 1 ? 1 : 0 );

	$self->{ af }->correct_values( \$app_info );

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar(@_) },
		'title' 	=> 1,
		'app_info'	=> $app_info,
		'app_list'	=> $self->get_app_list(),
		'map_in_page' 	=> $self->{ af }->get_geo_info( 'app_already_created' ),
		'token' 	=> $self->{ token },
		'center_msk'	=> $center_msk,
		'vcs_tools' 	=> $self->{ af }->{ paths }->{ addr_vcs },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
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

	return $self->{ af }->redirect( 'current' ) unless $self->check_existing_id_in_token( $appdata );

	my $print = VCS::Docs::docs->new( 'VCS::Docs::docs', $self->{ vars } );
	
	$self->{ vars }->setparam( 'appid', $appdata );
	
	$print->print_anketa();
}

sub reschedule
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $new = {};

	my $id_or_error;
	
	my $appinfo_for_timeslots = $self->get_same_info_for_timeslots_from_app();

	$new->{ $_ } = $self->{ vars }->getparam( $_ ) for ( 'appdate', 'apptime' );

	if (
		$new->{ apptime } =~ /^\d+$/
		and
		$new->{ appdate } =~ /\d\d\.\d\d\.\d\d\d\d/
	) {

		$appinfo_for_timeslots->{ $_  } = $new->{ appdate } for ( 'appdate', 'appdate_iso' );

		$appinfo_for_timeslots->{ appdate_iso } =~ s/(\d\d)\.(\d\d)\.(\d\d\d\d)/$3-$2-$1/;

		if (
			$new->{ apptime } > 0
			and
			$self->check_timeslots_already_full( $appinfo_for_timeslots, $new->{ apptime } )
			and
			Date::Calc::check_date( $3, $2, $1 )
		) {

			$id_or_error = $self->set_new_appdate( $new );
			
			return $self->{ af }->redirect( 'current' ) if $id_or_error =~ /^\d+$/;
		}

	}

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar(@_) },
		'title' 	=> 2,
		'appinfo'	=> $appinfo_for_timeslots,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'vcs_tools' 	=> $self->{ autoform }->{ paths }->{ addr_vcs },
		'error'		=> $id_or_error,
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
		
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE Appointments SET Status = 2 WHERE ID = ?", {}, $app_id
		) if $ncount < 1;
		
		return $self->{ af }->redirect( 'current' );
	}
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar(@_) },
		'title' 	=> 3,
		'app_list'	=> $app_list,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
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
	
	for ( 'fdate', 'appdate' ) {
	
		$app->{ $_ . '_iso' } = $app->{ $_ };
		
		$app->{ $_ } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
	}

	return $app;
}

sub check_timeslots_already_full
# //////////////////////////////
{
	my ( $self, $app, $timeslot ) = @_;

	my $appobj = VCS::Docs::appointments->new( 'VCS::Docs::appointments', $self->{ vars } );

	my $timeslots = $appobj->get_timeslots_arr( $app->{ center }, $app->{ persons }, $app->{ appdate_iso } );

	for ( @$timeslots ) {

		return 1 if $_->{id} == $timeslot;
	}
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


	my $appid = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
	);

	my ( $newnum, $new_app_id );

	my $urgent = VCS::Site::newapps::getUrgent( $self, $new->{ fdate }, $new->{ app_date }, $new->{ center } );

	my $docobj = VCS::Docs::docs->new( 'VCS::Docs::docs', $self->{ vars } );

	my $error = $docobj->reschApp( $appid, $urgent, \$newnum, \$new_app_id );

	$self->{ af }->query( 'query', __LINE__, "
		UPDATE AutoToken SET CreatedApp = ? WHERE Token = ?", {},
		$new_app_id, $self->{ token }
	) unless $error;

	return ( $error ? $error : $new_app_id );
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
	
1;
