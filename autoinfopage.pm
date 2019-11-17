package VCS::Site::autoinfopage;
use strict;

use VCS::Vars;
use VCS::Site::autodata;

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
	
	$self->{ vars }->{ session }->{ langid } = $self->{ vars }->getparam( 'lang' )
		if $self->{ vars }->getparam( 'lang' ) =~ /^(en|it)$/i ;
		
	$_ = $self->{ vars }->getparam( 'action' );
	
	s/[^a-z_]//g;
	
	return $self->print_appointment() if /^print$/i;
	
	return $self->print_appdata() if /^print_a$/i;
	
	return autoinfopage_entry( @_ ) if $entry;
	
	return edit( @_ ) if /^(edit|save_edit_app)$/i;
	
	return edited( @_ ) if /^(edited)$/i;

	return reschedule( @_ ) if /^reschedule$/i;
	
	return rescheduled( @_ ) if /^rescheduled$/i;
	
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
		
		$param->{ $_ } =~ s/[^A-Za-z0-9]//g;
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
		
			my $passnum = $app->{ passnum };

			return $self->{ af }->redirect( $app->{ Token } ) if $param->{ passnum } =~ /^$passnum$/i;
		}
			
		return $self->{ af }->redirect( 'no_app' );
	}
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq' 	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'addr' 		=> $self->{ vars }->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'widget_api'	=> $self->{ autoform }->{ captcha }->{ widget_api },
		'public_key'	=> $self->{ autoform }->{ captcha }->{ public_key },
	};
	$template->process( 'autoform_info_entry.tt2', $tvars );
}

sub get_infopage
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my $app_info = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT CreatedApp, AppNum as new_app_num, AppDate as new_app_date,
		TimeslotID as new_app_timeslot,	CenterID as new_app_branch, VName as new_app_vname, category
		FROM AutoToken
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		JOIN VisaTypes ON Appointments.VType = VisaTypes.ID
		WHERE Token = ?", $self->{ token }
	)->[0];

	my @new_date = split( /\-/, $app_info->{ new_app_date } );
	
	my $months = VCS::Site::autodata::get_months();
	
	$app_info->{ new_app_date } = [ $new_date[2], $months->{ $new_date[1] }, $new_date[0] ];
	
	$app_info->{ new_app_num } =~ s!(\d{3})(\d{4})(\d{2})(\d{2})(\d{4})!$1/$2/$3/$4/$5!;

	my $center_msk = ( $app_info->{ new_app_branch } == 1 ? 1 : 0 );

	$self->{ af }->correct_values( \$app_info );
	
	$app_info->{ new_app_timeslot } =~ s/\s.+//g;

	$self->{ vars }->get_system->pheader( $self->{ vars } );

	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 1,
		'yandex_key'	=> $self->{ autoform }->{ yandex_map }->{ api_key },
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

	return $self->{ af }->redirect( 'current' ) unless $self->{ af }->check_existing_id_in_token( $appdata, "finished" );

	my $print = VCS::Docs::docs->new( 'VCS::Docs::docs', $self->{ vars } );
	
	$self->{ vars }->setparam( 'appid', $appdata );
	
	$print->print_anketa();
}

sub param_disassembler
# //////////////////////////////////////////////////
{
	my ( $self, $line, $param_type, $only_num  ) = @_;

	my @param_var = split( /\|/, $line );

	my $param = {};
	
	my $param_num = -1;

	for ( 0..$#param_var ) {
	
		$param->{ $param_type . ( $_ + 1 ) } = $param_var[ $_ ];
		
		$param_num = $_ if $param_var[ $_ ] == 1;
	};

	return ( $only_num ? $param_num + 1 : $param );
}

sub param_assembler
# //////////////////////////////////////////////////
{
	my ( $self, $param_type, $param_len, $only_num ) = @_;
	
	my $param = '';

	$param .= (
		( $only_num ?
			$self->{ vars }->getparam( $param_type ) == $_
			:
			$self->{ vars }->getparam( $param_type . $_ )
		) ? 1 : 0
	) . '|' for ( 1..$param_len );

	$param =~ s/\|$//;
	
	return $param;
}

sub edit
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $editable_fields = $self->{ af }->init_add_param( { page => $self->get_editable_fields() }, { param => 1 } )->{ page };

	my $app_data = $self->{ vars }->getparam( 'appdata' ) || 0;
	
	$app_data =~ s/[^\d]+//;
	
	$app_data = 0 unless $self->{ af }->check_existing_id_in_token( $app_data, "finished" );
	
	my $tables_ids = { 'AppData' => $app_data };
	
	my $action_type = $self->{ vars }->getparam( 'action' );
	
	my $last_error = '';
	
	if ( $action_type eq "save_edit_app" ) {
	
		$last_error = $self->{ af }->check_data_from_form( undef, $editable_fields, $tables_ids );
		
		if ( !$last_error ) {
		
			$self->{ vars }->setparam( 'edt_mezzi', $self->param_assembler( "mezzi", 7 ) );
			$self->{ vars }->setparam( 'edt_purpose', $self->param_assembler( "edt_purpose", 17, "only_num" ) );
			
			$self->{ af }->save_data_from_form( undef, $tables_ids, "finished", $editable_fields );
		
			return $self->{ af }->redirect( $self->{ token }.'&action=edited' )
		}
	}
	
	my $all_values = $self->{ af }->get_all_values( undef, $tables_ids, "finished", $editable_fields );
	
	$all_values->{ edt_mezzi } = $self->param_disassembler( $all_values->{ edt_mezzi }, "mezzi" );
	$all_values->{ edt_purpose } = $self->param_disassembler( $all_values->{ edt_purpose }, "edt_purpose", "only_num" );
	
	my $content = '';

	for my $element ( @$editable_fields ) {
	
		$content .= $self->{ af }->get_html_line( $element, $all_values );
	}
	
	my ( $special, $js_rules ) = $self->{ af }->get_specials_of_element( $editable_fields );
	
	my $symbols_error = VCS::Site::autodata::get_symbols_error();
	
	$symbols_error->{ $_ } = $self->{ af}->lang( $symbols_error->{ $_ } ) for keys %$symbols_error;
	
	for ( "'", "\\" ) {
	
		$symbols_error->{ "\\$_" } = $symbols_error->{ "$_" };
		
		delete $symbols_error->{ "$_" };
	}

	
	my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
	);

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'content_text' 	=> $content,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'special'	=> $special,
		'app_data'	=> $app_data,
		'app_id'	=> $app_id,
		'js_rules'	=> $js_rules,
		'js_symbols'	=> $symbols_error,
		'js_errors'	=> map { $self->{ af }->lang( $_ ) } VCS::Site::autodata::get_text_error(),
	};
	
	( $tvars->{ last_error_name }, $tvars->{ last_error_text } ) = split( /\|/, $last_error );
	
	$template->process( 'autoform_edit.tt2', $tvars );
}

sub get_editable_fields
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $center = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CenterID	FROM Appointments
		JOIN AutoToken ON Appointments.ID = AutoToken.CreatedApp
		WHERE Token = ?", $self->{ token }
	);
	
	return VCS::Site::autodata_type_c_spb::get_content_edit_rules_hash()
		if VCS::Site::autodata::this_is_spb_center( $center );
	
	return VCS::Site::autodata_type_c::get_content_edit_rules_hash()
}

sub edited
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 5,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'vcs_tools' 	=> $self->{ autoform }->{ paths }->{ addr_vcs },
	};
	$template->process( 'autoform_info.tt2', $tvars );
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
			
			return $self->{ af }->redirect( $self->{ token }.'&action=rescheduled' ) if $id_or_error =~ /^\d+$/;
		}

	}

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 2,
		'appinfo'	=> $appinfo_for_timeslots,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'vcs_tools' 	=> $self->{ autoform }->{ paths }->{ addr_vcs },
		'error'		=> $id_or_error,
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub rescheduled
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $app_info = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppDate as new_app_date,	TimeslotID as new_app_timeslot
		FROM AutoToken
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		WHERE Token = ?", $self->{ token }
	)->[0];
	
	my @new_date = split( /\-/, $app_info->{ new_app_date } );
	
	my $months = VCS::Site::autodata::get_months();
	
	$app_info->{ new_app_date } = [ $new_date[2], $months->{ $new_date[1] }, $new_date[0] ];
	
	$self->{ af }->correct_values( \$app_info );
	
	$app_info->{ new_app_timeslot } =~ s/\s.+//g;

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'app_info'	=> $app_info,
		'title' 	=> 4,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
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
		
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE Appointments SET Status = 2 WHERE ID = ?", {}, $app_id
		) if $ncount < 1;
		
		return $self->{ af }->redirect( ( $ncount < 1 ) ? 'canceled' : 'current' );
	}
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
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
	
1;
