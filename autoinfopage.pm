package VCS::Site::autoinfopage;
use strict;

use VCS::Vars;
use VCS::Site::autodata;
use VCS::Site::autopayment;
use VCS::Site::autosms;

use Data::Dumper;
use Date::Calc;
use JSON;
use LWP::UserAgent;

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

	my $lang_param = $self->{ vars }->getparam( 'lang' ) || 'ru';

	$self->{ vars }->{ session }->{ langid } = $lang_param if $lang_param =~ /^(ru|en|it)$/i ;

	$_ = $self->{ vars }->getparam( 'action' );
	
	s/[^a-z_]//g;
	
	my ( $online_app_status ) = get_remote_status( $self );
	
	return online_app( @_ ) if /^online_app$/i;
	
	return online_app_foxstatus( @_ ) if /^foxstatus$/i;
	
	return online_app_servstatus( @_ ) if /^servstatus$/i;
	
	return online_app_smstatus( @_ ) if /^smstatus$/i;
	
	return online_cancel( @_ ) if /^online_cancel$/i;
	
	return online_consular_fee( @_ ) if /^online_consular_fee$/i;
	
	return online_addr_proxy( @_ ) if /^online_addr_proxy$/i;
	
	return online_app( @_ ) if ( $online_app_status > 0 ) and ( $online_app_status <= 12 );
	
	return $self->print_appointment() if /^print$/i;
	
	return $self->print_appdata() if /^print_a$/i;
	
	return autoinfopage_entry( @_ ) if $entry;
	
	return edit( @_ ) if /^(edit|save_edit_app)$/i;
	
	return edited( @_ ) if /^edited$/i;

	return reschedule( @_ ) if /^reschedule$/i;
	
	return rescheduled( @_ ) if /^rescheduled$/i;
	
	return cancel( @_ ) if /^cancel$/i;
	
	return close_check( @_ ) if /^close_check$/i;
	
	return offline_app( @_ ) if /^offline_app$/i;
	
	return offline_apped( @_ ) if /^offline_apped$/i;
	
	return get_infopage( @_ );
}

sub get_remote_status
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my ( $remote_status, $remote_id, $order_num ) = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT RemoteStatus, AutoRemote.ID, FoxID
		FROM AutoRemote
		JOIN AutoToken ON AutoToken.CreatedApp = AutoRemote.AppID
		WHERE Token = ?", $self->{ token }
	);
	
	return ( $remote_status, $remote_id, $order_num );
}

sub set_remote_status
# //////////////////////////////////////////////////
{
	my ( $self, $new_status ) = @_;
		
	my ( $remote_status, $remote_id ) = get_remote_status( $self );

	if ( $remote_id and ( $remote_status == $new_status ) ) {
		
		return;
	}
	elsif ( $remote_id ) {
		
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE AutoRemote SET RemoteStatus = ? WHERE ID = ?", {}, $new_status, $remote_id
		);
	}
	else {
		
		my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
			SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
		);
		
		$self->{ af }->query( 'query', __LINE__, "
			INSERT INTO AutoRemote (AppID, RemoteStatus) VALUES (?, ?)", {},
			 $app_id, $new_status
		);		
	}
}

sub online_cancel
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
		
	my ( undef, $remote_id ) = get_remote_status( $self );

	$self->{ af }->query( 'query', __LINE__, "
		DELETE FROM AutoRemote WHERE ID = ?", {}, $remote_id
	);

	return $self->{ af }->redirect( $self->{ token } );	
}

sub online_addr_proxy
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
		
	my $addr = $self->{ vars }->getparam( "addr" ) || "";
	
	my $config = VCS::Site::autodata::get_settings();

	my $response = LWP::UserAgent->new( timeout => 30 )->get( $config->{ fox }->{ addr } . $addr );
	
	$self->{ vars }->get_system->pheaderJSON( $self->{ vars } );

	print $response->decoded_content;
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
			SELECT Appointments.ID as appid, Token, AppData.PassNum as passnum
			FROM Appointments 
			JOIN AppData ON Appointments.ID = AppData.AppID
			LEFT JOIN AutoToken ON AutoToken.CreatedApp = Appointments.ID
			WHERE AppNum = ? AND
			Appointments.Status != 2 AND Appointments.Status != 3", $param->{ appnum }
		);

		for my $app ( @$appdata ) {
		
			my $passnum = $app->{ passnum };

			next unless $param->{ passnum } =~ /^$passnum$/i; 

			if ( ( $app->{ Token } =~ /^[0-9a-z\-]+$/ ) and ( length( $app->{ Token } ) == 64 ) ) {

				return $self->{ af }->redirect( $app->{ Token } )
			}
			else {
				my $new_token = $self->{ af }->token_generation();

				$self->{ af }->query( 'query', __LINE__, "
					UPDATE AutoToken SET CreatedApp = ?, Finished = 1 WHERE Token = ?", {}, $app->{ appid }, $new_token
				);

				return $self->{ af }->redirect( $new_token );
			}
		}
			
		return $self->{ af }->redirect( 'no_app' );
	}
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq' 	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'addr' 		=> $self->{ autoform }->{ paths }->{ addr },
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
		SELECT ServiceType, CreatedApp, AppNum as new_app_num, AppDate as new_app_date,
		TimeslotID as new_app_timeslot,	CenterID as new_app_branch, VName as new_app_vname,
		category, Appointments.Status as app_status, Appointments.VType
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
	
	my ( $app_list, $title );
	
	my $not_checked_yet = 1;

	if ( $app_info->{ ServiceType } <= 1 ) {
		
		$app_list = $self->get_app_list();
		
		$title = 1;
	}
	else {
		$app_list = $self->get_app_file_list_by_token( $self->{ token }, $app_info->{ VType } );
		
		$title = ( $app_info->{ ServiceType } == 2 ? 6 : 1 );
		
		for my $app ( keys %$app_list ) {
			$not_checked_yet = 0 if $app_list->{ $app }->{ checked_already } == 1;
		}
	}

	my $closed_app = ( $app_info->{ app_status } == 12 ? 1 : 0 );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> $title,
		'yandex_key'	=> $self->{ autoform }->{ yandex_map }->{ api_key },
		'app_info'	=> $app_info,
		'app_list'	=> $app_list,
		'map_in_page' 	=> $self->{ af }->get_geo_info( 'app_already_created' ),
		'token' 	=> $self->{ token },
		'center_msk'	=> $center_msk,
		'vcs_tools' 	=> $self->{ af }->{ paths }->{ addr_vcs },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
		'max_size'	=> $self->{ autoform }->{ general }->{ max_file_upload_size },
		'closed_app'	=> $closed_app,
		'not_checked_yet' => $not_checked_yet,
	};
	
	my ( $online_status, undef, $order_num ) = get_remote_status( $self );
	
	$tvars->{ fox_status } = VCS::Site::autopayment::fox_status( $self, $order_num ) if $online_status == 7;
	
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
	
	my $lang_in_link = $self->{ vars }->{ session }->{ langid } || 'ru';

	$print->print_anketa( $lang_in_link );
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
			$self->{ vars }->setparam( 'edt_prevvisa', $self->{ vars }->getparam( "edt_prevvisa" ) - 1 );
			
			$self->{ af }->save_data_from_form( undef, $tables_ids, "finished", $editable_fields );
		
			return $self->{ af }->redirect( $self->{ token }.'&action=edited' )
		}
	}
	
	my $all_values = $self->{ af }->get_all_values( undef, $tables_ids, "finished", $editable_fields );
	
	$all_values->{ edt_mezzi } = $self->param_disassembler( $all_values->{ edt_mezzi }, "mezzi" );
	$all_values->{ edt_purpose } = $self->param_disassembler( $all_values->{ edt_purpose }, "edt_purpose", "only_num" );
	
	$all_values->{ edt_prevvisa } += 1;
	
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
	
	my $saving = ( $action_type eq "save_edit_app" ? " (сохранение)" : "" );
	$self->{ af }->log( "autoinfo_edit", "редактирование appid $app_id, appdata $app_data$saving", $app_id );

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
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
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
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub reschedule
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $new = {};
	
	my $date_pseudo_element = VCS::Site::autodata::get_app_date_pseudo_element();
	
	my $id_or_error = undef;
	
	my $appinfo_for_timeslots = $self->get_same_info_for_timeslots_from_app();

	$new->{ $_ } = $self->{ vars }->getparam( $_ ) for ( 'appdate', 'apptime' );

	if (
		$new->{ apptime } =~ /^\d+$/
		and
		$new->{ appdate } =~ /\d\d\.\d\d\.\d\d\d\d/
	) {

		$appinfo_for_timeslots->{ $_  } = $new->{ appdate } for ( 'appdate', 'appdate_iso' );

		$appinfo_for_timeslots->{ appdate_iso } =~ s/(\d\d)\.(\d\d)\.(\d\d\d\d)/$3-$2-$1/;
		
		$id_or_error = $self->{ af }->check_logic( $date_pseudo_element, $appinfo_for_timeslots, 'edt' );
		
		if ( $id_or_error ) {
		
			my @array = split( /\|/, $id_or_error );
			
			$id_or_error = $array[1];
		}
		
		if (
			!$id_or_error
			and
			$new->{ apptime } > 0
			and
			$self->check_timeslots_already_full( $appinfo_for_timeslots, $new->{ apptime } )
			and
			Date::Calc::check_date( $3, $2, $1 )
		) {
			
			my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
				SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
			);

			$self->{ af }->log(
				"autoinfo_resch", "перенос записи на " . $new->{ appdate } . " таймслот " . $new->{ apptime }, $app_id
			);

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
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
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
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub online_order
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $config = VCS::Site::autodata::get_settings();

	my $data = {
		'login' => $config->{ fox }->{ login }, 
		'password' => $config->{ fox }->{ password },
		'department' => 'Документы для визы',
		'urgency' => $config->{ fox }->{ urgency },
		'typeOfCargo' => $config->{ fox }->{ cargo },
		'cargoDescription' => $config->{ fox }->{ description },
		
		'payer' => 1,
		'paymentMethod' => 2,
		'withReturn' => 'true',
		'weight' => '0.5',
		'cargoPackageQty' => '1',
		
		'senderInfo' => $config->{ fox }->{ senderInfo },
		'recipient' => $config->{ fox }->{ recipient },
		'recipientIndex' => $config->{ fox }->{ recipientIndex },
		'recipientOfficial' => $config->{ fox }->{ recipientOfficial },
		'recipientAddress' => $config->{ fox }->{ recipientAddress },
		'recipientPhone' => $config->{ fox }->{ recipientPhone },
		'recipientEMail' => $config->{ fox }->{ recipientEMail },
		'recipientInfo' => $config->{ fox }->{ recipientInfo },
	};
	
	for ( 'date', 'contactPerson', 'comment', 'sender',
			'senderIndex', 'senderAddress', 'senderPhone', 'senderEMail' ) {
				
		$data->{ $_ } = $self->{ vars }->getparam( $_ ) || "";
		$data->{ $_ } =~ s/[^A-Za-zАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя0-9\s\-\?\!\@\_\.\,\:\"\\\/\(\)№_]/./g;
	}
	
	$data->{ senderOfficial } = $data->{ sender };
	$data->{ contactPerson } = $data->{ sender };

	my $response = LWP::UserAgent->new( timeout => 30 )->post( $config->{ fox }->{ order }, $data );

	my $errorInfoTMP = JSON->new->pretty->decode( $response->{ _content } );
	my $errorInfo = $errorInfoTMP->{ errorInfo };

	return ( undef, $errorInfo ) unless $response->is_success;
	
	my $order = JSON->new->pretty->decode( $response->decoded_content );

	return ( $order->{ number }, $errorInfo, $data->{ senderAddress } );
}

sub offline_check_params
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $checks = [
		{ name => 'date', field => "Дата передачи документов" },
		{ name => 'sender', field => "ФИО отправителя" },
		{ name => 'senderPhone', field => "Контактный телефон" },
		{ name => 'senderEMail', field => "Контактный email" },
		{ name => 'comment', field => "Комментарий к доставкев" },
	];
	
	for ( @$checks ) {
				
		my $param = $self->{ vars }->getparam( $_->{ name } );
		
		return $self->{ af }->lang( "Поле '" ) . $_->{ field } . $self->{ af }->lang( "' должно быть заполнено" )
			if !$param and ( $_->{ name } ne "comment" );
		
		return $self->{ af }->lang( "В поле '" ) . $_->{ field } . $self->{ af }->lang( "' введены недопустимые символы" )
			if $param =~ /[^A-Za-zАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя0-9\s\-\@\?\!\_\.\,\:\"\\\/\(\)№_]/;
	}
	
	my $date = $self->{ vars }->getparam( 'date' );
	
	my ( $start_date, $end_date ) = $self->get_min_max_date();
	
	return $self->{ af }->lang( "Указана дата до начала допустимого периода" )
		if ( $self->{ vars }->get_system->cmp_date( $start_date, $date ) < 0 );
		
	return $self->{ af }->lang( "Указана дата после окончания допустимого периода" )
		if ( $self->{ vars }->get_system->cmp_date( $end_date, $date ) > 0 );
}

sub offline_check_consular
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $consular = $self->{ vars }->getparam( "concil_data" ) || "";
	
	( undef, undef, my $concil ) = $self->calc_concil();
	
	my $concils = {};
	
	$concils->{ $_->{ ID } } = $_->{ ConcilPayCode } for @$concil;
	
	my @consulars = split( /\|/, $consular );
	
	my $codes = {};
	
	for ( @consulars ) {

		my @id_and_number = split( /:/, $_ );
		
		my $number = $id_and_number[1];
		
		$number =~ s/[^0-9]//g;
		
		return undef unless $number;
		
		return undef unless length( $number ) == 12;
		
		return undef unless $number =~ /^202/;
		
		$codes->{ $id_and_number[0] } = $number;
	}

	for ( keys %$concils ) {

		next if $concils->{ $_ } == 6;

		next if $codes->{ $_ };

		return undef;
	}
	
	$consular =~ s/[^0-9\:\|]//g;
	$consular =~ s/\|$//;
	
	return $consular;
}

sub online_status_change
# //////////////////////////////////////////////////
{
	my ( $self, $new_status ) = @_;
	
	set_remote_status( $self, $new_status );
	
	$self->{ af }->redirect( $self->{ token } );
}

sub online_app
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my ( $online_status, undef, $order_num ) = get_remote_status( $self );
	
	my $concil = [];
	
	my ( $service_fee, $concil_fee, $service_count, $service_price, $sms_price, $sms_phone,
		$sms_code, $concil_free, $concil_full_free ) = ( 0, 0, 0, 0, 0, 0, 0, 0, 0 );		
	my ( $service_type, $start_date, $end_date ) = ( undef, undef, undef );
	my ( $payment, $error, $err_target ) = ( undef, undef, undef );

	unless ( $online_status > 0 ) {
		
		set_remote_status( $self, 1 );
		$online_status = 1;
	}
	
	if ( $online_status == 1 ) {
		
		( $sms_price, undef ) = $self->{ af }->get_payment_price( "sms" );
		
		( $service_fee, undef ) = $self->{ af }->get_payment_price( "service" );
		
		( $concil_fee, undef ) = $self->{ af }->get_payment_price( "concil" );
	
		return online_status_change( $self, 2 )
			if $self->{ vars }->getparam( 'appdata' ) eq 'confirm_app_start';
	}
	elsif ( $online_status == 2 ) {
		
		return online_status_change( $self, 3 )
			if $self->{ vars }->getparam( 'appdata' ) eq 'confirm_agreement';
	}
	elsif ( $online_status == 3 ) {
		
		return online_status_change( $self, 5 )
			if $self->{ vars }->getparam( 'appdata' ) eq 'confirm_insurance';
			
		return online_status_change( $self, 4 )
			if $self->{ vars }->getparam( 'appdata' ) eq 'need_insurance';
	}
	elsif ( $online_status == 4 ) {
	
		return online_status_change( $self, 5 )
			if $self->{ vars }->getparam( 'appdata' ) eq 'confirm_insurance';
	}
	elsif ( $online_status == 5 ) {
		
		( $concil_free, $concil_full_free, $concil ) = $self->calc_concil();
		
		$service_type = $self->{ af }->get_payment_price( "vtype_only" );
	
		if ( $self->{ vars }->getparam( 'appdata' ) eq 'consular_pay' ) {		
			
			return online_status_change( $self, 6 ) if $concil_full_free;
			
			my $consular_number = offline_check_consular( $self );
			
			if ( !$consular_number ) {
				
				$error = $self->{ af }->lang( "Проверьте правильность ввода номера квитанции консульского сбора" );
			}
			else {
				my ( undef , $remote_id ) = get_remote_status( $self );
				
				$self->{ af }->query( 'query', __LINE__, "
					UPDATE AutoRemote SET BankID = ? WHERE ID = ?", {}, $consular_number, $remote_id
				);
				
				return online_status_change( $self, 6 );
			}
		}
	}
	elsif ( $online_status == 6 ) {
	
		( $sms_price, my $app_id ) = $self->{ af }->get_payment_price( "sms" );
		
		$payment = $self->{ af }->payment_prepare( $app_id, 'sms' );
		
		return online_status_change( $self, 7 )
			if $self->{ vars }->getparam( 'appdata' ) eq 'skip_sms_pay';
			
		if ( $self->{ vars }->getparam( 'appdata' ) eq 'sms_pay' ) {
			
			my ( $pay_status_ok, $payment_error ) = $self->{ af }->payment_check( "sms", $service_count );
			
			if ( $pay_status_ok ) {
				
				$self->{ af }->query( 'query', __LINE__, "
					UPDATE Appointments SET Appointments.SMS = 1
					JOIN AutoToken ON Appointments.ID = AutoToken.CreatedApp
					WHERE Token = ?", {}, $self->{ token }
				);
			
				return online_status_change( $self, 7 );
			}
			else {
				$error = $self->{ af }->lang( "Ошибка оплаты:" ) .  $payment_error;
			}
		}
	}
	elsif ( $online_status == 7 ) {
	
		( $service_fee, $service_price, $service_type, $service_count, my $app_id ) =
			$self->{ af }->get_payment_price( "service" );
		
		$payment = $self->{ af }->payment_prepare( $app_id, 'service' );

		if ( $self->{ vars }->getparam( 'appdata' ) eq 'service_pay' ) {

			my ( $pay_status_ok, $payment_error ) = $self->{ af }->payment_check( "service", $service_count );
			
			if ( $pay_status_ok ) {
			
				return online_status_change( $self, 8 );
			}
			else {
				$error = $self->{ af }->lang( "Ошибка оплаты:" ) .  $payment_error;
			}
		}
	}
	elsif ( $online_status == 8 ) {
	
		$sms_phone = VCS::Site::autosms::get_phone_for_sms( $self );
		
		$sms_code = VCS::Site::autosms::get_code_for_sms( $self, $sms_phone );
		
		$sms_phone =~ s/(\d)(\d\d\d)(\d\d\d)(\d\d)(\d\d)/$1 ($2) $3-$4-$5/;
	
		if ( $self->{ vars }->getparam( 'appdata' ) eq 'sms_signed' ) {
			
			my $code = $self->{ vars }->getparam( 'digital_signature' ) || undef;
			
			if ( VCS::Site::autosms::code_from_sms_is_ok( $self, $code ) ) {
			
				create_online_appointment( $self );
			
				return online_status_change( $self, 9 );
			}
			else {
				$error = $self->{ af }->lang( "Проверьте правильность введёного номера SMS" );
			}
		}
	}
	elsif ( $online_status == 9 ) {
		
		return online_status_change( $self, 10 )
			if $self->{ vars }->getparam( 'appdata' ) eq 'confirm_loaded';
	}
	elsif ( $online_status == 10 ) {

		( $start_date, $end_date ) = $self->get_min_max_date();
		
		$error = offline_check_params( $self ) if $self->{ vars }->getparam( 'appdata' ) eq 'order';
		
		if ( !$error and ( $self->{ vars }->getparam( 'appdata' ) eq 'order' ) ) {
			
			( $order_num, $error, my $address ) = $self->online_order();
			
			if ( !$error ) {
				
				my ( undef , $remote_id ) = get_remote_status( $self );
		
				$self->{ af }->query( 'query', __LINE__, "
					UPDATE AutoRemote SET FoxID = ?, FoxAddress = ? WHERE ID = ?", {},
					$order_num, $address, $remote_id
				);
				
				return online_status_change( $self, 11 );
			}
		}
	}
	
	elsif ( $online_status == 12 ) {
	
		return online_status_change( $self, 13 )
			if $self->{ vars }->getparam( 'appdata' ) eq 'confirm_app_end';
	}
		
	my $progress = $self->{ af }->get_progressbar( $online_status, VCS::Site::autodata::get_remote_progressline() );
		
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 9,
		'progress'	=> $progress,
		'token' 	=> $self->{ token },
		'concil_url'	=> $self->{ autoform }->{ concil }->{ payment },
		'addr_url'	=> $self->{ autoform }->{ fox }->{ addr },
		'calc_url'	=> $self->{ autoform }->{ fox }->{ calc },
		'fox_pay_url'	=> $self->{ autoform }->{ fox }->{ pay },
		'urgency' 	=> $self->{ autoform }->{ fox }->{ urgency }, 
		'cargo' 	=> $self->{ autoform }->{ fox }->{ cargo },
		'login' 	=> $self->{ autoform }->{ fox }->{ login },
		'pass' 		=> $self->{ autoform }->{ fox }->{ password },
		'service' 	=> $self->{ autoform }->{ fox }->{ service },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'vcs_tools' 	=> $self->{ autoform }->{ paths }->{ addr_vcs },
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
	};
	
	$tvars->{ start_date } = $start_date;
	$tvars->{ end_date } = $end_date;
	$tvars->{ online_status } = $online_status;
	
	$tvars->{ err } = $error if $error;
	
	$tvars->{ payment } = $payment if $payment;
	
	$tvars->{ order_num } = $order_num if $order_num;
	$tvars->{ online_status } = $online_status if $online_status;
	$tvars->{ sms_phone } = $sms_phone if $sms_phone;
	$tvars->{ sms_code } = $sms_code if $sms_code;
	$tvars->{ service_price } = $service_price if $service_price;
	$tvars->{ service_fee } = $service_fee if $service_fee;
	$tvars->{ concil_fee } = $concil_fee if $concil_fee;
	$tvars->{ concil_free } = $concil_free if $concil_free;
	$tvars->{ concil_full_free } = $concil_full_free if $concil_full_free;
	$tvars->{ service_type } = $service_type if $service_type;

	$tvars->{ service_count } = $service_count if $service_count;
	$tvars->{ sms_price } = $sms_price if $sms_price;
	$tvars->{ concil } = $concil if $concil;
	
	$template->process( 'autoform_info.tt2', $tvars );
}

sub get_min_max_date
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $collect_days = $self->{ af }->get_collect_date();
	
	my $fly_date = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT SDate FROM Appointments
		JOIN AutoToken ON Appointments.ID = AutoToken.CreatedApp
		WHERE Token = ?", $self->{ token }
	);
			
	my ( $year, $month, $day ) = Date::Calc::Add_Delta_Days( split( /\-/, $fly_date ), ( $collect_days * -1 ) );
	
	my ( undef, undef, undef, $current_day, $current_mon, $current_year ) = localtime( time );
	
	$current_year += 1900;
	$current_mon += 1;
	
	my ( $max_year, $max_month, $max_day ) = Date::Calc::Add_Delta_Days( $current_year, $current_mon, $current_day, 14 );
	
	( $current_year, $current_mon, $current_day ) = Date::Calc::Add_Delta_Days( $current_year, $current_mon, $current_day, 1 );
	
	for ( $day, $month, $current_day, $current_mon, $max_month, $max_day ) {
		
		$_ = "0$_" if $_ < 10;
	};
	
	( $year, $month, $day ) = ( $max_year, $max_month, $max_day)
		if $self->{ vars }->get_system->cmp_date( "$year-$month-$day", "$max_year-$max_month-$max_day") < 0;
		
	my $start_date = "$current_day.$current_mon.$current_year";
	
	my $end_date = "$day.$month.$year";
	
	return ( $start_date, $end_date );
}

sub calc_concil
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $concil_types = VCS::Site::autodata::get_concil_types();

	my $concil = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppData.ID, AppData.FName, AppData.LName, ConcilOnlinePay FROM AppData
		JOIN Appointments ON AppData.AppID = Appointments.ID
		JOIN AutoToken ON Appointments.ID = AutoToken.CreatedApp
		WHERE Token = ?", $self->{ token }
	);
	
	my $concil_free = 0;
	my $concil_full_free = 1;
	my $persons = [];
	
	for ( @$concil ) {

		$concil_full_free = 0 unless $_->{ ConcilOnlinePay } == 6;
		$concil_free = 1 if $_->{ ConcilOnlinePay } == 6;
		
		$_->{ ConcilPayCode } = $_->{ ConcilOnlinePay };
		
		if ( ( $_->{ ConcilOnlinePay } > 0 ) and ( $_->{ ConcilOnlinePay } != 6 ) ) {
			
			$_->{ ConcilOnlinePay } = $concil_types->{ $_->{ ConcilOnlinePay } } . $self->{ af }->lang( " евро" );
		}
		else {
			$_->{ ConcilOnlinePay } = $self->{ af }->lang( "не должен платить сбор" );
		}
	}

	return ( $concil_free, $concil_full_free, $concil );
}

sub create_online_appointment
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
	);

	$self->{ af }->log(
		"autoinfo_remote", "удалённая запись после проверки документов", $app_id
	);
	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE Appointments SET Status = 13, AppDate = now(), CenterID = 47 WHERE ID = ?", {}, $app_id
	);
	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE AutoToken SET ServiceType = 3 WHERE Token = ?", {}, $self->{ token }
	);
}

sub online_app_foxstatus
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my ( undef, undef, $order_num ) = get_remote_status( $self );
	
	my $payment_ok = VCS::Site::autopayment::fox_pay_status( $self, $order_num );
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	print ( $payment_ok ? "ok" : "error" );	
}

sub online_app_servstatus
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	( undef, undef, undef, undef, my $count ) = $self->{ af }->get_payment_price( $self, "service" );

	my ( $pay_status_ok, $payment_error ) = $self->{ af }->payment_check( "service", $count );

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	print ( $pay_status_ok ? "ok" : "error" );	
}

sub online_app_smstatus
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my ( $pay_status_ok, $payment_error ) = $self->{ af }->payment_check( "sms" );

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	print ( $pay_status_ok ? "ok" : "error" );	
}

sub online_consular_fee
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	set_remote_status( $self, 12 );
	
	$self->{ af }->redirect( $self->{ token } );
}

sub offline_app
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $new = {};
	
	my $date_pseudo_element = VCS::Site::autodata::get_app_date_pseudo_element();

	my $id_or_error = undef;
	
	my $appinfo_for_timeslots = $self->get_same_info_for_timeslots_from_app();

	$new->{ $_ } = $self->{ vars }->getparam( $_ ) for ( 'appdate', 'apptime', 'center' );

	if (
		$new->{ center } =~ /^\d+$/
		and
		$new->{ apptime } =~ /^\d+$/
		and
		$new->{ appdate } =~ /\d\d\.\d\d\.\d\d\d\d/
	) {

		$appinfo_for_timeslots->{ $_  } = $new->{ appdate } for ( 'appdate', 'appdate_iso' );

		$appinfo_for_timeslots->{ appdate_iso } =~ s/(\d\d)\.(\d\d)\.(\d\d\d\d)/$3-$2-$1/;
		
		$appinfo_for_timeslots->{ apptime } = $new->{ apptime };
		
		$appinfo_for_timeslots->{ center } = $new->{ center };
		
		$id_or_error = $self->{ af }->check_logic( $date_pseudo_element, $appinfo_for_timeslots, 'edt' );
		
		if ( $id_or_error ) {

			my @array = split( /\|/, $id_or_error );
			
			$id_or_error = $array[1];
		}
	
		if (
			!$id_or_error
			and
			$new->{ apptime } > 0
			and
			$self->check_timeslots_already_full( $appinfo_for_timeslots, $new->{ apptime } )
			and
			Date::Calc::check_date( $3, $2, $1 )
		) {
		
			my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
				SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
			);

			$self->{ af }->log(
				"autoinfo_resch", "запись оффлайн после проверки " . $new->{ appdate } . " таймслот " . $new->{ apptime }, $app_id
			);
			
			$self->{ af }->query( 'query', __LINE__, "
				UPDATE Appointments SET Status = 12, CenterID = ? WHERE ID = ?", {}, $new->{ center }, $app_id
			);

			$id_or_error = $self->set_new_appdate_for_checkdoc_transform( $appinfo_for_timeslots );

			if ( $id_or_error =~ /^\d+$/ ) {
				
				$self->{ af }->query( 'query', __LINE__, "
					INSERT INTO Appointments_tranform (Type, OldID, NewID) VALUES ('checkdoc-to-offine', ?, ?)", {},
					$app_id, $id_or_error
				);		
			}
			
			return $self->{ af }->redirect( $self->{ token }.'&action=offline_apped' );
		}
	}

	my $centers = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT ID FROM Branches WHERE Display = 1 AND isDeleted = 0"
	);

	$_->{ name } = $self->{ af }->lang( "mobname" . $_->{ ID } ) for @$centers;

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 7,
		'appinfo'	=> $appinfo_for_timeslots,
		'centers'	=> $centers,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'vcs_tools' 	=> $self->{ autoform }->{ paths }->{ addr_vcs },
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
		'error'		=> $id_or_error,
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub set_new_appdate_for_checkdoc_transform
# //////////////////////////////////////////////////
{
	my ( $self, $new ) = @_;

	my ( $appid, $ncount ) = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp, NCount FROM AutoToken
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		WHERE Token = ?", $self->{ token }
	);

	my ( $newnum, $new_app_id );

	my $urgent = VCS::Site::newapps::getUrgent( $self, $new->{ fdate }, $new->{ app_date }, $new->{ center } );
	
	$self->{ af }->query( 'query', __LINE__, "LOCK TABLES AutoToken WRITE, Appointments WRITE, AppData READ, Branches READ, Timeslots READ, TimeData READ, TimeSlotOverrides READ" );
	
	my $error1 = VCS::Docs::appointments->check_appdate( $self->{ vars }, $new->{ appdate_iso }, $new->{ center }, 0);
	
	my $error2 = VCS::Docs::appointments->check_apptime( $self->{ vars }, $new->{ appdate_iso }, $new->{ center },  $new->{ apptime }, $urgent, $ncount,0);
	
	my $maxnum = VCS::Docs::appointments->getLastAppNum( $self->{ vars }, $new->{ center }, $new->{ appdate_iso } );
	
	if ( !$error1 and !$error2 ) {
		
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE Appointments SET AppDate = ?, AppNum = ?, Status = 1, TimeslotID = ? WHERE ID = ?", {},
			$new->{ appdate_iso }, $maxnum, $new->{ apptime }, $appid
		);
		
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE AutoToken SET ServiceType = 4 WHERE Token = ?", {}, $self->{ token }
		);
	}
	
	$self->{ af }->query( 'query', __LINE__, "UNLOCK TABLES" );

	return ( !$error1 and !$error2 ? $error1 : $new_app_id );
}

sub offline_apped
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $app_info = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppDate as new_app_date,	TimeslotID as new_app_timeslot, CenterID as new_app_branch
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
		'title' 	=> 8,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'vcs_tools' 	=> $self->{ autoform }->{ paths }->{ addr_vcs },
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub close_check
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
	);

	$self->{ vars }->get_system->log_action( $self->{ vars }, "checkdoc", "Завершено обслуживание", $app_id );
	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE Appointments SET Status = 12 WHERE ID = ?", {}, $app_id
	);
	
	$self->{ af }->redirect( $self->{ token } );
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

		$self->{ vars }->get_system->log_action( $self->{ vars }, "autoinfo_cancel", "отмена записи", $app_id );
		
		$self->{ af }->log( "autoinfo_cancel", "отмена записи", $app_id );
		
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
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub get_same_info_for_timeslots_from_app
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app = {};

	( $app->{ persons }, $app->{ center }, $app->{ fdate }, $app->{ timeslot },
			$app->{ appdate }, $app->{ AppData }, $app->{ Appointments }, $app->{ vtype } ) = 
		$self->{ af }->query( 'sel1', __LINE__, "
			SELECT count(AppData.ID), CenterID, SDate, TimeslotID,
			Appointments.AppDate, AppData.ID, Appointments.ID AS AppID, VType
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
	
	return 0;
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

sub get_app_file_list_by_token
# //////////////////////////////////////////////////
{
	my ( $self, $token, $visa_type ) = @_;
	
	my $app_list = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppData.ID, DocUploaded.ID as DocID, AppData.FName, AppData.LName, AppData.BirthDate,
		DocUploaded.DocType, DocUploaded.Name, DocUploaded.Ext, DocUploaded.CheckStatus,
		Token, AppData.ConcilOnlinePay, AppData.CheckDocComment
		FROM AutoToken 
		JOIN AppData ON AppData.AppID = AutoToken.CreatedApp
		JOIN DocUploaded ON DocUploaded.AppDataID = AppData.ID
		WHERE Token = ? AND AppData.Status = 1", $token
	);

	$_->{ 'BirthDate' } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/ for @$app_list;
	
	my $doc_types_list_all = VCS::Site::autodata::get_doc_list();
	
	my $doc_types_list = $doc_types_list_all->{ $visa_type };

	my %doc_types = map { $_->{ id } => $_->{ title } } @$doc_types_list;
	
	my $doc_comments_tmp = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT DocID, CommentText, CommentDate, DocUploadedComment.Login
		FROM AutoToken 
		JOIN AppData ON AppData.AppID = AutoToken.CreatedApp
		JOIN DocUploaded ON DocUploaded.AppDataID = AppData.ID
		JOIN DocUploadedComment ON DocUploaded.ID = DocUploadedComment.DocID
		WHERE Token = ? AND AppData.Status = 1", $token
	);

	my $doc_upload_log = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT DocID, LogDate, LogText
		FROM AutoToken
		JOIN AppData ON AppData.AppID = AutoToken.CreatedApp
		JOIN DocUploadedLog ON AppData.ID = DocUploadedLog.AppID
		WHERE Token = ?", $token
	);
	
	my $logs = {};
	
	for ( @$doc_upload_log ) {
		
		$logs->{ $_->{ DocID } } = {} unless ref( $logs->{ $_->{ DocID } } ) eq 'HASH';
		
		$logs->{ $_->{ DocID } }->{ $_->{ LogDate } } = $_->{ LogText };
	}
	
	my $doc_comments = {};

	for ( @$doc_comments_tmp ) {
		
		unless ( exists $doc_comments->{ $_->{ DocID } } ) {

			$doc_comments->{ $_->{ DocID } } = [];

			if ( ref( $logs->{ $_->{ DocID } } ) eq 'HASH' ) {

				for my $date ( keys %{ $logs->{ $_->{ DocID } } } ) {

					push( @{ $doc_comments->{ $_->{ DocID } } },
						{
							text => $logs->{ $_->{ DocID } }->{ $date },
							date => $date,
							login => 'website',
							log => 1
						}
					);
				}
			}
		}		
		
		$_->{ CommentText } =~ s/\n/<br>/g;
		
		push( @{ $doc_comments->{ $_->{ DocID } } }, { text => $_->{ CommentText }, date => $_->{ CommentDate }, login => $_->{ Login } } );
	}
	
	for my $doc ( keys %$doc_comments ) {
		
		my @new_ord_comments = sort { $a->{ date } cmp $b->{ date } } @{ $doc_comments->{ $doc } };
		
		$doc_comments->{ $doc } = \@new_ord_comments;
	}

	my $doc_list = {};

	for my $app ( @$app_list ) {
		
		my $file = {};

		$file->{ $_ } = $app->{ $_ } for ( 'DocType', 'Name', 'Ext', 'CheckStatus', 'DocID' );
		
		$file->{ file_ord } = $app->{ DocType }; 		

		$file->{ TypeStr } = $doc_types{ $file->{ DocType } }; 
	
		$file->{ comments } = $doc_comments->{ $app->{ DocID } };
	
		$file->{ no_file_yet } = ( $file->{ Name } ? 0 : 1 );
		
		if ( exists $doc_list->{ $app->{ ID } } ) {
			
			push( @{ $doc_list->{ $app->{ ID } }->{ files }->{ $file->{ DocType } } }, $file );
		}
		else {
			$doc_list->{ $app->{ ID } } = {};
			
			$doc_list->{ $app->{ ID } }->{ $_ } = $app->{ $_ }
				for ( 'FName', 'LName', 'BirthDate', 'Token', 'ConcilOnlinePay', 'CheckDocComment' );

			$doc_list->{ $app->{ ID } }->{ files } = {};
			
			$doc_list->{ $app->{ ID } }->{ files }->{ $file->{ DocType } } = [ $file ];
		}
	}
		
	my $visa_type = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT VType FROM AutoToken
		JOIN Appointments ON Appointments.ID = AutoToken.CreatedApp
		WHERE Token = ?", $token
	);
	
	for my $empty ( @$doc_types_list ) {
		
		next unless $empty->{ optional };
		
		for my $app ( keys %$doc_list ) {
			
			next if exists $doc_list->{ $app }->{ files }->{ $empty->{ id } };
			
			$doc_list->{ $app }->{ files }->{ $empty->{ id } } = [];
			
			my $file = {};
			
			$file->{ file_ord } = $empty->{ id }; 

			$file->{ DocID } = "empty_" . $empty->{ id };
			
			$file->{ DocType } = $empty->{ id }; 

			$file->{ TypeStr } = $empty->{ title };
			
			$file->{ empty } = 1;
			
			push( @{ $doc_list->{ $app }->{ files }->{ $empty->{ id } } }, $file );
		}
	}
	
	my $tmp_id = 9999;
		
	for my $app ( keys %$doc_list ) {
		
		if ( exists $doc_list->{ $app }->{ files }->{ $tmp_id } ) {
			
			$doc_list->{ $app }->{ files }->{ $tmp_id }->[ 0 ]->{ TypeStr } = $self->{ af }->lang( "Анкета (генерируется автоматически)" );
			
			$doc_list->{ $app }->{ files }->{ $tmp_id }->[ 0 ]->{ form_auto } = 1;
			
			$doc_list->{ $app }->{ files }->{ $tmp_id }->[ 0 ]->{ file_ord } = $tmp_id; 
		}
		else {
			my $file = {};
						
			$file->{ file_ord } = $tmp_id; 

			$file->{ DocID } = "empty_$tmp_id";
			
			$file->{ DocType } = $tmp_id; 

			$file->{ TypeStr } = $self->{ af }->lang( "Анкета (генерируется автоматически)" );
			
			$file->{ form_auto } = 1;
			
			push( @{ $doc_list->{ $app }->{ files }->{ $tmp_id } }, $file );
		}
	}
	
	my $checked_already = 0;

	for my $app ( keys %$doc_list ) {
	
		for my $doc_type ( keys %{ $doc_list->{ $app }->{ files } } ) {
		
			for my $file ( @{ $doc_list->{ $app }->{ files }->{ $doc_type } } ) {
			
				$file->{ multiple } = 1 if @{ $doc_list->{ $app }->{ files }->{ $doc_type } } > 1;

				$checked_already = 1 if !$checked_already and $file->{ CheckStatus } > 0;
			};
		};
		
		my @files = sort { $a->[0]->{ file_ord } <=> $b->[0]->{ file_ord } } values %{ $doc_list->{ $app }->{ files } };
			
		$doc_list->{ $app }->{ files } = \@files;
		
		$doc_list->{ $app }->{ checked_already } = $checked_already;
	};

	return $doc_list;
}
	
1;
