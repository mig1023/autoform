package VCS::Site::autoform;
use strict;

use VCS::Vars;
use VCS::Site::autodata;
use VCS::Site::autodata_type_c;
use VCS::Site::autodata_type_c_spb;
use VCS::Site::autodata_type_d;
use VCS::Site::automobile_api;
use VCS::Site::autoinfopage;

use Data::Dumper;
use Date::Calc qw/Add_Delta_Days/;
use Time::HiRes qw[gettimeofday tv_interval];
use Time::Piece;
use POSIX;
use JSON;
use HTTP::Tiny;
use Encode qw(decode encode);
use Math::Random::Secure qw(irand); 

sub new
# //////////////////////////////////////////////////
{
	my ( $class, $pclass, $vars ) = @_;
	
	my $self = bless {}, $pclass;
	
	$self->{ 'VCS::Vars' } = $vars;
	
	return $self;
}

sub getContent 
# //////////////////////////////////////////////////
{

	my ( $self ) = @_;
	
	$_ = @_[2];
	
	$self->{ vars } = $self->{ 'VCS::Vars' };
	
	return if $self->{ vars }->af->softban_block( $self->{ vars }, $ENV{ HTTP_X_REAL_IP }, 'only_ban_test' );
	
	return $self->availability_responder() if /^availability_responder$/i;
	
	$self->{ autoform } = VCS::Site::autodata::get_settings();

	return autoform( @_ ) if /^index$/i;
	
	return get_pcode( @_ ) if /^findpcode$/i;
	
	return autoinfopage( @_, 'entry' ) if /^info$/i;
	
	return mobile_end( @_ ) if /^mobile_end$/i;
	
	return $self->redirect();
}

sub get_content_rules
# //////////////////////////////////////////////////
{
	my ( $self, $current_page, $full, $need_to_init ) = @_;

	my ( $center ) = $self->get_app_visa_and_center();
		
	my $content = $self->get_content_rules_hash_opt();

	my $keys_in_current_page = {};
	my $new_content = {};
	
	my $page_order = 0;
	
	for my $page ( sort { $content->{ $a }->[ 0 ]->{ page_ord } <=> $content->{ $b }->[ 0 ]->{ page_ord } } keys %$content ) {
		
		my $page_ord = ++$page_order;
		
		$new_content->{ $page_ord } = $content->{ $page };
		
		if ( $current_page == $page_ord ) {

			for ( 'persons_in_page', 'collect_date', 'param', 'ussr_or_rf_first',
				'primetime_spb_price', 'primetime_price' ) {
			
				$keys_in_current_page->{ $_ } = ( $new_content->{ $page_ord }->[ 0 ]->{ $_ } ? 1 : 0 );
			}
		}
		
		if ( !$full && $content->{ $page }->[ 0 ]->{ replacer } ) {
		
			$new_content->{ $page_ord } = $content->{ $page }->[ 0 ]->{ replacer };
		}
		elsif ( !$full ) {
		
			delete $new_content->{ $page_ord }->[ 0 ];
			
			@{ $new_content->{ $page_ord } } = grep defined, @{ $new_content->{ $page_ord } };
		}
		else {
			$new_content->{ $page_ord }->[ 0 ]->{ page_name } = $page;
		}
	}

	$content = ( $need_to_init ? $self->init_add_param( $new_content, $keys_in_current_page ) : $new_content );
	
	return $content if !$current_page;
	
	return scalar( keys %$content ) if $current_page =~ /^length$/i;
	
	return $content->{ $current_page };
}

sub get_step_by_id
# //////////////////////////////////////////////////
{
	my ( $self, $page_id ) = @_;
	
	return $page_id if $page_id < 1000;
	
	my $page_content = $self->get_content_rules( undef, 'full' );
	
	for my $page ( keys %$page_content ) {
	
		return $page if $page_content->{ $page }->[ 0 ]->{ page_db_id } eq $page_id;
	}
	
	return 0;
}

sub get_id_by_step
# //////////////////////////////////////////////////
{
	my ( $self, $step ) = @_;
	
	my $page_content = $self->get_content_rules( undef, 'full' );

	my $id_page = $page_content->{ $step }->[ 0 ]->{ page_db_id };
	
	return $id_page;
}

sub get_content_rules_hash_opt
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my ( $center, $visa_category ) = $self->get_app_visa_and_center();
		
	return VCS::Site::autodata_type_d::get_content_rules_hash() if $visa_category eq 'D';

	return VCS::Site::autodata_type_c_spb::get_content_rules_hash() if VCS::Site::autodata::this_is_spb_center( $center );

	return VCS::Site::autodata_type_c::get_content_rules_hash();
}

sub availability_responder
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	print "all-is-ok";
}

sub get_app_visa_and_center
# //////////////////////////////////////////////////
{
	my $self = shift;

	return ( 1, 'C' ) if !$self->{ token };

	my $app_data = {};
	
	$app_data->{ $_ } = $self->cached( 'autoform_' . $self->{ token } . '_' . $_ ) for ( 'vtype', 'center' );
		
	if ( !$app_data->{ vtype } or !$app_data->{ center } ) {
		
		( $app_data->{ center }, $app_data->{ vtype } ) = $self->query( 'sel1', __LINE__, "
			SELECT CenterID, VType
			FROM AutoAppointments
			JOIN AutoToken ON AutoAppointments.ID = AutoToken.AutoAppID
			WHERE Token = ?", $self->{ token }
		);

		for ( 'vtype', 'center' ) {

			$app_data->{ $_ } = 'X' unless $app_data->{ $_ };

			$self->cached( 'autoform_' . $self->{ token } . '_' . $_, $app_data->{ $_ } );
		}
	}

	for ( 'vtype', 'center' ) {
		
		$app_data->{ $_ } = undef if $app_data->{ $_ } eq 'X';
	}
	
	return ( $app_data->{ center }, 'C' ) if !$app_data->{ vtype };
	
	my $visa_categories = $self->get_all_visa_categories();

	return ( $app_data->{ center }, $visa_categories->{ $app_data->{ vtype } } );
}

sub get_all_visa_categories
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $category = $self->cached( 'autoform_all_vtypes' );
		
	if ( !$category  ) {

		$category = {};

		my $all_visas = $self->query( 'selallkeys', __LINE__, "
			SELECT ID, Category FROM VisaTypes"
		);

		$category->{ $_->{ ID } } = $_->{ Category } for @$all_visas;

		$self->cached( 'autoform_all_vtypes', $category );
	}

	return $category;
}

sub autoform
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my ( $step, $page_content, $template_file, $title, $progress, $appid, $last_error, $js_rules );

	my $special = {};

	my $javascript_check = 'need_to_check';
	
	my $lang = lc( $self->param( 'lang' ) );
	
	$self->{ lang } = ( $lang =~ /^(en|it)$/i ? $lang : 'ru' );

	for ( 'scanner', 'biometric_data' ) {
	
		$self->{ biometric_data } = 'yes' if lc( $self->param( $_ ) ) eq 'yes';
	}

	( $self->{ token }, my $finished, my $doc_status ) = $self->get_token_and_create_new_form_if_need();

	return $self->get_mobile_api() if $self->param( 'mobile_api' );
	
	return $self->autoinfopage( $task, $id, $template ) if $finished and !$doc_status and $self->{ token } !~ /^\d\d$/;

	if ( $finished and $doc_status and $self->{ token } !~ /^\d\d$/ ) {
	
		( $title, $page_content, $template_file ) = $self->doc_status();
	}
	elsif ( $self->{ token } =~ /^\d\d$/ ) {
	
		( $title, $page_content, $template_file ) = $self->get_page_error( $self->{ token } );
	}
	elsif ( $self->param( 'script' ) ) {
	
		$javascript_check = undef;
		
		( $title, $page_content, $template_file ) = $self->get_page_error( 0 );
	}
	else {
		( $step, $title, $page_content, $last_error, $template_file, $special, $progress, $appid, $js_rules ) = 
			$self->get_autoform_content();
	}

	my $symbols_error = VCS::Site::autodata::get_symbols_error();
	
	$symbols_error->{ $_ } = $self->lang( $symbols_error->{ $_ } ) for keys %$symbols_error;
	
	for ( "'", "\\" ) {
	
		$symbols_error->{ "\\$_" } = $symbols_error->{ "$_" };
		
		delete $symbols_error->{ "$_" };
	}
	
	$self->mod_last_error_date( $self->param( 'last_error_return' ) ) if $self->param( 'last_error_return' );

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $current_table_id = $self->get_current_table_id(); 


	my $max_app = $self->query( 'sel1', __LINE__, "
		SELECT NCount FROM AutoAppointments WHERE ID = ?", $current_table_id->{ AutoAppointments }
	);

	my $tvars = {
		'langreq' 		=> sub { return $self->lang( @_ ) },
		'title' 		=> $title,
		'content_text' 		=> $page_content,
		'token' 		=> $self->{ token },
		'appid' 		=> $appid,
		'step' 			=> $step,
		'min_step' 		=> 1,
		'max_step' 		=> $self->get_content_rules( 'length' ),
		'max_applicants' 	=> $max_app,
		'addr' 			=> $self->{ autoform }->{ paths }->{ addr },
		'static'		=> $self->{ autoform }->{ paths }->{ static },
		'special' 		=> $special,
		'vcs_tools' 		=> $self->{ autoform }->{ paths }->{ addr_vcs },
		'progress' 		=> $progress,
		
		'lang_in_link' 		=> $self->{ lang },
		'js_rules'		=> $js_rules,
		'js_symbols'		=> $symbols_error,
		'js_errors'		=> map { $self->lang( $_ ) } VCS::Site::autodata::get_text_error(),
		'javascript_check' 	=> $javascript_check,
	};
	
	my ( $all, $max ) = $self->get_current_apps();
	
	$tvars->{ app_all } = $all || 0;
	$tvars->{ app_max } = $max || 0;
	
	$tvars->{ biometric_data } = ( $self->{ biometric_data } ? 'yes' : 0 );
	$tvars->{ mobile_app } = ( $self->param( 'mobile_app' ) ? 1 : 0 );
	$tvars->{ error_page } = ( $page_content eq '' ? 'error' : '' );

	$tvars->{ urgent_allowed } = $self->urgent_allowed( $special );

	( $tvars->{ last_error_name }, $tvars->{ last_error_text } ) = split( /\|/, $last_error );
	
	$tvars->{ appinfo } = $self->get_same_info_for_timeslots()
		if ( 
			( ( ref( $special->{ timeslots } ) eq 'ARRAY' ) and ( @{ $special->{ timeslots } } > 0 ) )
			or
			( ( ref( $special->{ post_index } ) eq 'ARRAY' ) and ( @{ $special->{ post_index } } > 0 ) )
		);

	$tvars->{ map_type } = $self->{ vars }->getConfig( 'general' )->{ maps_type };
		
	for ( 'in', 'out' ) {
		$tvars->{ "include_name_$_" } = $special->{ "include_$_" } if $special->{ "include_$_" };
	}

	$template->process( $template_file, $tvars );
}

sub urgent_allowed
# //////////////////////////////////////////////////
{
	my ( $self, $special ) = @_;

	return 0 unless $special->{ timeslots } and @{ $special->{ timeslots } };

	my $allow = 1;
	
	my $apps = $self->query( 'selallkeys', __LINE__, "
		SELECT Citizenship
		FROM AutoToken
		JOIN AutoAppData ON AutoAppData.AppID = AutoToken.AutoAppID
		WHERE Token = ?", $self->{ token }
	);
	
	for ( @$apps ) {
	
		$allow = 0 if $_->{ Citizenship } != 70;
	}
	
	my ( undef, $category ) = $self->get_app_visa_and_center();
	
	$allow = 0 if $category ne 'C';
	
	return $allow;
}

sub get_current_apps
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $all = $self->query( 'sel1', __LINE__, "
		SELECT COUNT(AutoAppData.ID) FROM AutoToken
		JOIN AutoAppData ON AutoToken.AutoAppID = AutoAppData.AppID
		WHERE Token = ?", $self->{ token }
	);
	
	my $max = $self->query( 'sel1', __LINE__, "
		SELECT NCount FROM AutoToken
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		WHERE Token = ?", $self->{ token }
	);
	
	$all = 0 unless $all;
	$max = 0 unless $max;
	
	return ( $all, $max );
}

sub mod_last_error_date
# //////////////////////////////////////////////////
{
	my ( $self, $last_error ) = @_;
	
	$last_error =~ s/[^A-Za-zАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя0-9\s\-\.\,\:\"\(\)№_]/!/g;
	
	return $self->query( 'query', __LINE__, "
		UPDATE AutoToken SET LastError = ? WHERE Token = ?", {},
		$last_error, $self->{ token }
	);
}

sub get_mobile_api
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;

	my $api_response = VCS::Site::automobile_api::get_mobile_api( $self, $token );

	$self->{ vars }->get_system->pheaderJSON( $self->{ vars } );
	
	return if ref( $api_response ) != /^(HASH|ARRAY)$/;
	
	print JSON->new->pretty->encode( $api_response );
}

sub autoinfopage
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template, $entry ) = @_;

	my $autoinfopage = VCS::Site::autoinfopage->new('VCS::Site::autoinfopage', $self->{ vars } );
	
	$autoinfopage->{ autoform } = VCS::Site::autodata::get_settings();
	
	$autoinfopage->{ af } = $self;
	
	$autoinfopage->autoinfopage( $task, $id, $template, $entry );
}

sub mobile_end
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	return $self->redirect();
}
	
sub get_same_info_for_timeslots
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app = {};

	( $app->{ persons }, $app->{ center }, $app->{ fdate }, $app->{ timeslot }, 
			$app->{ appdate }, $app->{ urgent } ) = $self->query( 'sel1', __LINE__, "
		SELECT count(AutoAppData.ID), CenterID, SDate, TimeslotID, AppDate, Urgent
		FROM AutoToken 
		JOIN AutoAppData ON AutoToken.AutoAppID = AutoAppData.AppID
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		WHERE Token = ?", $self->{ token }
	);
	
	$app->{ fdate_iso } = $app->{ fdate };
	
	$app->{ fdate } = $self->date_format( $app->{ fdate } );

	return $app;
}

sub get_geo_info
# //////////////////////////////////////////////////
{
	my ( $self, $app_already_created ) = @_;
	
	my $from_app =
		"JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		JOIN Branches ON Appointments.CenterID = Branches.ID";
	
	my $from_autoapp =
		"JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN Branches ON AutoAppointments.CenterID = Branches.ID";
	
	my $join = ( $app_already_created ? $from_app : $from_autoapp );

	my ( $center, $addr ) = $self->query( 'sel1', __LINE__, "
		SELECT CenterID, BAddr FROM AutoToken $join WHERE Token = ?", $self->{ token }
	);
	
	my $maps_type = $self->{ vars }->getConfig( 'general' )->{ maps_type };
	
	if ( $maps_type eq 'geo' ) {
	
		my $branches = VCS::Site::autodata::get_geo_branches();
		
		$addr =~ s/\r?\n/<br>/g;
		
		$branches->{ $center }->[ 2 ] = $addr;

		return $branches->{ $center };
	}
	else {
	
		my $branches = VCS::Site::autodata::get_embedded_maps();
		
		return $branches->{ $center };
	}
}

sub get_lang_if_exist
# //////////////////////////////////////////////////
{
	my ( $self, $line, $static_key, $dynamic_key ) = @_;
	
	my $lang_version = $self->lang( $static_key . $dynamic_key ) || $line;

	$line = $lang_version unless $lang_version =~ /^$static_key/;
	
	return $line;
}

sub init_add_param
# //////////////////////////////////////////////////
{
	my ( $self, $content_rules, $keys ) = @_;
	
	my $info_from_db = undef;
	my $ussr_first = 0;
	my $primetime_price = 0;
	
	if ( $keys->{ param } ) {
	
		$info_from_db = $self->cached( 'autoform_addparam' );
		
		if ( !$info_from_db ) {
		
			my $info_from_sql = {
				'[centers_from_db]' => 'SELECT ID, BName FROM Branches WHERE Display = 1 AND isDeleted = 0',
				'[visas_from_db]' => 'SELECT ID, VName FROM VisaTypes WHERE OnSite = 1',
				'[brh_countries]' => 'SELECT ID, EnglishName, Ex, MemberOfEU FROM Countries',
				'[schengen_provincies]' => 'SELECT ID, Name FROM SchengenProvinces',
			};
			
			for ( keys %$info_from_sql ) {
			
				$info_from_db->{ $_ } = $self->query( 'selall', __LINE__, $info_from_sql->{ $_ } );
			}
			
			my $add_eu_countries = [
				[ 37, "BULGARIA" ],
				[ 47, "CYPRUS" ],
				[ 104, "IRELAND" ],
				[ 201, "THE UNITED KINGDOM OF GREAT BRITAIN AND NORTHERN IRELAND" ],
				[ 215, "ROMANIA" ],
			];

			for ( @{ $info_from_db->{ '[brh_countries]' } } ) {
			
				push( @{ $info_from_db->{ '[prevcitizenship_countries]' } }, $_ );
				
				push( @{ $info_from_db->{ '[citizenship_countries]' } }, $_ ) if $_->[ 2 ] == 0;
				
				push( @{ $info_from_db->{ '[first_countries]' } }, $_ ) if $_->[ 3 ] == 1;
			}
			
			for ( @{ $info_from_db->{ '[first_countries]' } }, @$add_eu_countries ) {
			
				push( @{ $info_from_db->{ '[eu_countries]' } }, $_ );
			}

			$self->cached( 'autoform_addparam', $info_from_db );
		}
		
		$_->[ 1 ] = $self->get_lang_if_exist( $_->[ 1 ], 'mobname', $_->[ 0 ] )
			for @{ $info_from_db->{ '[centers_from_db]' } };
	
		$_->[ 1 ] = $self->get_lang_if_exist( $_->[ 1 ], 'visaname', $_->[ 0 ] )
			for @{ $info_from_db->{ '[visas_from_db]' } };
	}
	
	if ( $self->{ token } and $keys->{ persons_in_page } ) {

		my $app_person_in_app = $self->query( 'selallkeys', __LINE__, "
			SELECT AutoAppData.ID as ID, CONCAT(RFName, ' ', RLName, ', ', BirthDate) as person,
			birthdate, CURRENT_DATE() as currentdate
			FROM AutoToken 
			JOIN AutoAppData ON AutoToken.AutoAppID = AutoAppData.AppID
			WHERE AutoToken.Token = ?", $self->{ token }
		);

		for my $person ( @$app_person_in_app ) {
		
			$person->{ person } = $self->date_format( $person->{ person } );
			
			next if ( $self->age( $person->{ birthdate }, $person->{ currentdate } ) < 
					$self->{ autoform }->{ age }->{ age_for_agreements } );

			push ( @{ $info_from_db->{ '[persons_in_app]' } }, [ $person->{ ID }, $person->{ person } ] );
		};
			
		push( @{ $info_from_db->{ '[persons_in_app]' } }, [ -1, $self->lang('на доверенное лицо') ] );
	}
	
	if ( $self->{ token } and $keys->{ ussr_or_rf_first } ) {
	
		my $birthdate = $self->query( 'sel1', __LINE__, "
			SELECT DATEDIFF(AutoAppData.BirthDate, '1991-12-26')
			FROM AutoAppData
			JOIN AutoToken ON AutoAppData.ID = AutoToken.AutoAppDataID 
			WHERE AutoToken.Token = ?", $self->{ token }
		);
	
		$ussr_first = 1 if $birthdate < 0;
	}
	
	if ( $keys->{ primetime_price } ) {
	
		$primetime_price = $self->query( 'sel1', __LINE__, "
			SELECT Price FROM PriceRate
			JOIN ServicesPriceRates ON PriceRate.ID = PriceRateID
			WHERE BranchID = 41 AND RDate <= curdate() AND ServicesPriceRates.ServiceID = 2
			ORDER by PriceRate.ID DESC LIMIT 1"
		);
	}
	
	if ( $keys->{ primetime_spb_price } ) {
	
		$primetime_price = $self->query( 'sel1', __LINE__, "
			SELECT Price FROM PriceRate
			JOIN ServicesPriceRates ON PriceRate.ID = PriceRateID
			WHERE BranchID = 43 AND RDate <= curdate() AND ServicesPriceRates.ServiceID = 3
			ORDER by PriceRate.ID DESC LIMIT 1"
		);
	}
	
	if (
		$keys->{ param }
		or
		$keys->{ collect_date }
		or
		$keys->{ persons_in_page }
		or
		$keys->{ ussr_or_rf_first }
		or
		$keys->{ primetime_price }
		or
		$keys->{ primetime_spb_price }
	) {
	
		for my $page ( keys %$content_rules ) {
		
			next if $content_rules->{ $page } =~ /^\[/;
			
			for my $element ( @{ $content_rules->{ $page } } ) {

				if ( ref( $element->{ param } ) ne 'HASH' ) {
				
					my $param_array = $info_from_db->{ $element->{ param } };
					
					$element->{ param } = {};
					
					$element->{ param }->{ $_->[ 0 ] } = $_->[ 1 ] for ( @$param_array );
				}
				
				if ( exists $element->{ check_logic } and $self->{ token } and $keys->{ collect_date } ) {
				
					for ( @{ $element->{ check_logic } } ) {
					
						$_->{ offset } = $self->get_collect_date()	
							if $_->{ offset } =~ /\[collect_date_offset\]/;
					}
				}
				
				if ( $element->{ name } =~ /^(brhcountry|prev_сitizenship)$/ ) {
				
					$element->{ first_elements } = '272, 70' if $ussr_first;
				}
				
				if (
					( $keys->{ primetime_price } or $keys->{ primetime_spb_price } )
					and
					$element->{ label } =~ /\[primetime_price\]/
				) {
					$element->{ label } =~ s/\[primetime_price\]/$primetime_price/;
				}
			}
		}
	}

	return $content_rules;
}	

sub get_collect_date
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $collect_dates = $self->cached( 'autoform_collectdates' );
		
	if ( !$collect_dates ) {
	
		my $collect_dates_array = $self->query( 'selallkeys', __LINE__, "
			SELECT ID, CollectDate, cdSimpl, cdUrgent, cdCatD
			FROM Branches where isDeleted = 0 and Display = 1"
		);
		$collect_dates = {};
		
		for my $date ( @$collect_dates_array ) {

			$collect_dates->{ $date->{ ID } }->{ $_ } = $date->{ $_ }
				for ( 'CollectDate', 'cdSimpl', 'cdUrgent', 'cdCatD' );
		}

		$self->cached( 'autoform_collectdates', $collect_dates );
	}
	
	my ( $center_id, $category ) = $self->get_app_visa_and_center();

	$collect_dates = $collect_dates->{ $center_id };

	return 0 unless $collect_dates->{ CollectDate };
	
	return $collect_dates->{ cdCatD } if $category eq 'D';
	
	return ( $collect_dates->{ cdUrgent } ? $collect_dates->{ cdUrgent } : $collect_dates->{ cdSimpl } );
}

sub get_token
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $token = lc( $self->param('t') );

	$token =~ s/[^0-9a-z\-_]//g;

	return $token;
}

sub get_token_and_create_new_form_if_need
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $token = $self->get_token();
	
	return '02' if $token eq 'no_app';
	
	return '03' if $token eq 'no_field';

	return '05' if $token eq 'canceled';
	
	return '06' if $self->{ autoform }->{ general }->{ technical_work };

	return $self->token_generation() if $token eq '';
	
	if ( length( $token ) == 24 ) {
	
		my $doc_id = $self->param('doc') || undef;
		
		$doc_id =~ s/[^0-9]//g;
	
		my $found_docpack = $self->query( 'sel1', __LINE__, "
			SELECT DocPack.ID FROM DocPack
			JOIN DocPackOptional ON DocPack.ID = DocPackOptional.DocPackID
			WHERE FeedbackKey = ?", $token
		) || undef;
		
		return '01' if ( !$found_docpack or ( $doc_id and ( $doc_id != $found_docpack ) ) );
	
		return ( $token, 'finished', 'docstatus' );
	}
	
	my ( $token_exist, $finished, $deleted, $app ) = $self->query( 'sel1', __LINE__, "
		SELECT ID, Finished, Deleted, CreatedApp FROM AutoToken WHERE Token = ?", $token
	);

	return '01' if ( length( $token ) != 64 ) or ( $token !~ /^t/i );
	
	return '02' if $deleted;
	
	my $token_expired = $self->query( 'sel1', __LINE__, "
		SELECT ID FROM AutoToken_expired WHERE Token = ?", $token
	);
	
	return '04' if $token_expired;

	return '02' unless $token_exist;
	
	return $token unless $finished;
	
	my $status = $self->query( 'sel1', __LINE__, "
		SELECT Status FROM Appointments WHERE ID = ?", $app
	);
	
	return ( $token, $finished, 'docstatus' ) if $status == 4;
	
	return ( ( $status == 1 ? $token : '02' ), $finished );
}

sub create_clear_form
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	$self->query( 'query', __LINE__, "
		INSERT INTO AutoAppointments (RDate, Login, Draft) VALUES (now(), ?, 1)", {}, 
		$self->{ vars }->get_session->{'login'}
	);
		
	my $app_id = $self->query( 'sel1', __LINE__, "
		SELECT last_insert_id()"
	) || 0;
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET AutoAppID = ?, StartDate = now(), LastIP = ? WHERE Token = ?", {}, 
		$app_id, $ENV{ HTTP_X_REAL_IP }, $self->{ token }
	);
}
	
sub token_generation
# //////////////////////////////////////////////////
{
	my $self = shift;

	my ( $token_existing, $token_existed_before, $token ) = ( 1, 0, 't' );
	
	$self->query( 'query', __LINE__, "LOCK TABLES AutoToken WRITE, AutoToken_expired READ" );
	
	$self->query( 'query', __LINE__, "
		INSERT INTO AutoToken (
		AutoAppID, AutoAppDataID, AutoSchengenAppDataID, Step, LastError, Finished, Draft, StartDate, LastIP) 
		VALUES (0, 0, 0, ?, '', 0, 0, now(), ?)", {}, $self->get_id_by_step( 1 ), $ENV{ HTTP_X_REAL_IP }
	);
	
	my $appid = $self->query( 'sel1', __LINE__, "SELECT last_insert_id()" ) || 0;
	
	my $appidcode = "-$appid-";

	my @alph = split( //, '0123456789abcdefghigklmnopqrstuvwxyz' );

	do {
		$token = 't';
		
		$token .= $alph[ int( irand( 36 ) ) ] for ( 1..63 );
	
		substr( $token, 10, length( $appidcode ) ) = $appidcode;
			
		$token_existing = $self->query( 'sel1', __LINE__, "
			SELECT ID FROM AutoToken WHERE Token = ?", $token
		) || 0;
		
		$token_existed_before = $self->query( 'sel1', __LINE__, "
			SELECT ID FROM AutoToken_expired WHERE Token = ?", $token
		) || 0;
				
	} while ( $token_existing || $token_existed_before );
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET Token = ? WHERE ID = ?", {}, $token, $appid
	);

	$self->query( 'query', __LINE__, "UNLOCK TABLES");	
	
	return $token;
}

sub doc_status
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my ( $status, $shipping ) = ( 0, 0 );
	
	if ( length( $self->{ token } ) == 24 ) {
	
		( $status, $shipping ) = $self->query( 'sel1', __LINE__, "
			SELECT PStatus, DocPack.Shipping
			FROM DocPack
			JOIN DocPackOptional ON DocPack.ID = DocPackOptional.DocPackID
			WHERE FeedbackKey = ?", $self->{ token }
		);
	}
	else {
		( $status, $shipping ) = $self->query( 'sel1', __LINE__, "
			SELECT PStatus, DocPack.Shipping
			FROM AutoToken
			JOIN Appointments ON Appointments.ID = AutoToken.CreatedApp
			JOIN DocPack ON DocPack.ID = Appointments.PacketID
			WHERE Token = ?", $self->{ token }
		);
	}
	
	my $public_status = {
		7  => 0,
		8  => 3,
		9  => 3,
		10 => 2,
		11 => 2,
		12 => 3,
		13 => 3,
		14 => 3,
	};
	
	$status = $public_status->{ $status } if exists $public_status->{ $status };
	
	my $doc_progressbar = VCS::Site::autodata::get_docstatus_progress();
	
	if ( !$shipping ) {
	
		splice( @$doc_progressbar, 5, 1 );
		
		$status -= 1 if $status > 4;
	}

	my $progress = $self->get_progressbar( $status, $doc_progressbar );
	
	return ( undef, $progress, 'autoform_docstatus.tt2' );
}

sub get_page_error
# //////////////////////////////////////////////////
{
	my ( $self, $error_num ) = @_;
	
	my $error_type = VCS::Site::autodata::get_page_error();
	
	my $title = ( $error_num =~ /^0?(5|6)$/ ? '' : $self->lang( 'ошибка: ' ) ) . $self->lang( $error_type->[ $error_num ] );
	
	return ( "<center>$title</center>", undef, 'autoform.tt2' );
}

sub get_autoform_content
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my ( $last_error, $title );
	
	my ( $id_page, $app_id ) = $self->query( 'sel1', __LINE__, "
		SELECT Step, AutoAppID FROM AutoToken WHERE Token = ?", $self->{ token }
	);
	
	my $step = $self->get_step_by_id( $id_page );

	my $action = lc( $self->param('action') );
	$action =~ s/[^a-z]//g;
	
	my $appdata_id = $self->param('person');
	$appdata_id =~ s/[^0-9]//g;
	
	my $appnum = undef;
	my $appid = undef;
	
	my $min_step = 1;
	my $max_step = $self->get_content_rules( 'length' );
	
	$step = $min_step if $step < $min_step;
	$step = $max_step if $step > $max_step;

	$step = $self->get_back( $step ) if ( $action eq 'back' ) and ( $step > 1 );
	
	( $step, $last_error, $appnum, $appid ) = $self->get_forward( $step )
		if ( $action eq 'forward' ) and ( $step < $max_step );

	$step = $self->get_edit( $step, $appdata_id ) if ( $action eq 'edit' ) and $appdata_id;
	
	$self->get_delete( $appdata_id ) if ( $action eq 'delapp' ) and $appdata_id;
	
	$step = $self->get_add( $app_id ) if $action eq 'addapp';
	
	( $step, $last_error ) = $self->check_all_is_prepared( $last_error ) if $action eq 'tofinish';
	
	$step = $self->set_step_by_content( '[list_of_applicants]' ) if $action eq 'tolist';
	
	my $page = $self->get_content_rules( $step, 'full' );
	
	my $back = ( $action eq 'back' ? 'back' : '' );
	
	if ( !$last_error and ( exists $page->[ 0 ]->{ relation } ) ) {
	
		( $step, $page ) = $self->check_relation( $step, $page, $back );
	}
	
	if ( $step == $self->get_step_by_content( '[app_finish]') ) {
	
		$step = $self->get_step_by_content( 'back_to_appdata' );
		$page = $self->get_content_rules( $step, 'full' );
		
		$self->set_step( $step );
	}
		
	if ( $page !~ /\[/ ) {
	
		$title = $self->lang( $page->[ 0 ]->{ page_name } );
		
		if ( $page->[ 0 ]->{ all_app_in_title } ) {

			my ( $all, $max ) = $self->get_current_apps();
			
			$title .= " ( $all / $max )" if $max;
		}
	}
	
	$self->copy_unpersonal_information() if $page->[ 0 ]->{ copy_from_other_applicants };

	my ( $content, $template ) = $self->get_html_page( $step, $appnum );

	my $progress = $self->get_progressbar( $page->[ 0 ]->{ progress }, $self->get_progressbar_hash_opt() );
	
	my ( $special, $js_check ) = $self->get_specials_of_element( $self->get_content_rules( $step ) );
	
	return ( $step, $title, $content, $last_error, $template, $special, $progress, $appid, $js_check );
}

sub check_all_is_prepared
# //////////////////////////////////////////////////
{
	my ( $self, $last_error ) = @_;

	my $app_status = $self->check_all_app_finished_and_not_empty();

	my ( $pass_already, undef, $pass_double ) = $self->check_passnum_already_in_pending();

	return ( $self->set_step_by_content( '[app_finish]', 'next' ), $last_error )
		if !$app_status and !$pass_already and !$pass_double;

	my $step = $self->set_step_by_content( '[list_of_applicants]' );
	
	return ( $step, $self->text_error( 27, { 'name' => 'applist' }, undef, $pass_double ) ) if $pass_double;

	return ( $step, $self->text_error( $app_status, { 'name' => 'applist' }, undef ) ) if $app_status;
	
	return ( $step, $self->text_error( 24, { 'name' => 'applist' }, undef ) );
}

sub check_relation
# //////////////////////////////////////////////////
{
	my ( $self, $step, $page, $moonwalk ) = @_;

	my $skip_this_page;
	
	my $at_least_one_page_skipped = 0;
	
	my $current_table_id = $self->get_current_table_id(); 
	
	do {
		$skip_this_page = 0;

		for my $relation ( keys %{ $page->[ 0 ]->{ relation } } ) {
		
			$skip_this_page += $self->skip_page_by_relation( $relation, $page->[ 0 ]->{ relation }->{ $relation } );
		}
		
		if ( $skip_this_page ) {

			$at_least_one_page_skipped = 1;
			
			$step += ( $moonwalk ? -1 : 1 );
			
			$page = $self->get_content_rules( $step, 'full' );

			my $current_table_id = $self->get_current_table_id(); 
			
			if ( $step == $self->get_step_by_content( '[app_finish]' ) ) {
			
				$self->set_current_app_finished( $current_table_id );
			}
		}
	
	} while ( $skip_this_page );

	$self->set_step( $step ) if $at_least_one_page_skipped;
	
	return ( $step, $page );
}

sub skip_page_by_relation
# //////////////////////////////////////////////////
{
	my ( $self, $condition, $relation ) = @_;
	
	return ( $self->citizenship_check_fail( $relation->{ value } ) ? 1 : 0 ) if $condition =~ /^only_if_citizenship$/;
	
	my $current_table_id = $self->get_current_table_id(); 
	
	my $value = $self->query( 'sel1', __LINE__, "
		SELECT $relation->{name} FROM Auto$relation->{table} WHERE ID = ?",
		$current_table_id->{ 'Auto' . $relation->{table} }
	);

	return $self->skip_by_condition( $value, $relation->{ value }, $condition ); 
}

sub skip_by_condition
# //////////////////////////////////////////////////
{
	my ( $self, $value, $relation, $condition ) = @_;

	my %relation = map { $_ => 1 } split( /,\s?/, $relation );

	return 1 if $condition =~ /^only_if_younger(_\d+)?$/ and ( $self->age( $value, localtime->ymd ) >= $relation );

	return 1 if $condition =~ /^only_if_not(_\d+)?$/ and exists $relation{ $value };
	
	return 1 if $condition =~ /^only_if(_\d+)?$/ and !exists $relation{ $value };
	
	return 0;
}

sub citizenship_check_fail
# //////////////////////////////////////////////////
{
	my ( $self, $value ) = @_;
	
	my %citizenship = map { $_ => 1 } split( /,\s?/, $value );

	my $applicants = $self->query( 'selallkeys', __LINE__, "
		SELECT Citizenship FROM AutoAppData
		JOIN AutoToken ON AutoAppData.AppID = AutoToken.AutoAppID
		WHERE Token = ?", $self->{ token }
	);
	
	for ( @$applicants ) {
	
		return 1 if !exists $citizenship{ $_->{ Citizenship } };
	}
	
	return 0;
}

sub get_forward
# //////////////////////////////////////////////////
{
	my ( $self, $step ) = @_;
	
	my $current_table_id = $self->get_current_table_id();
	
	if ( !$current_table_id->{ AutoAppointments } ) {
	
		$self->create_clear_form( $self->param( 'center' ) );
		
		$current_table_id = $self->get_current_table_id();
	}
	
	$self->save_data_from_form( $step, $current_table_id );
	
	$self->mod_last_change_date();
	
	my $last_error = $self->check_data_from_form( $step );
	
	my ( $appnum, $appid ) = ( undef, undef );
	
	( $last_error, $step ) = $self->check_timeslots_already_full_or_not_actual( $step )
		if ( !$last_error and ( ( $step + 1 ) == $self->get_content_rules( 'length' ) ) );
	
	( $last_error, $step ) = $self->check_mutex_for_creation( $step )
		if ( !$last_error and ( ( $step + 1 ) == $self->get_content_rules( 'length' ) ) );

	if ( $last_error ) {
	
		my @last_error = split( /\|/, $last_error );

		my $id_page = $self->get_id_by_step( $step );

		$self->query( 'query', __LINE__, "
			UPDATE AutoToken SET Step = ?, LastError = ? WHERE Token = ?", {}, 
			$id_page, "$last_error[1] ($last_error[0], step $step/id $id_page)", $self->{ token }
		);
		
	} else {

		$step += 1;

		$self->set_step( $step );
		
		$self->set_current_app_finished( $current_table_id )
			if $step == $self->get_step_by_content( '[app_finish]');

		( $appid, $appnum ) = $self->set_appointment_finished()
			if $step == $self->get_content_rules( 'length' );
	}

	return ( $step, $last_error, $appnum, $appid );
}

sub set_current_app_finished
# //////////////////////////////////////////////////
{
	my ( $self, $tables_id ) = @_;
	
	my ( $vtype, $center ) = $self->query( 'sel1', __LINE__, "
		SELECT VType, CenterID FROM AutoAppointments WHERE ID = ?", $tables_id->{ AutoAppointments }
	);

	return $self->query( 'query', __LINE__, "
		UPDATE AutoAppData SET FinishedVType = ?, FinishedCenter = ? WHERE ID = ?", {},
		$vtype, $center, $tables_id->{ AutoAppData }
	);
}

sub set_appointment_finished
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my ( $new_appid, $ncount, $appnum, $error ) = $self->create_new_appointment();
	
	if ( $error ) {
	
		$self->query( 'query', __LINE__, "
			UPDATE AutoToken SET EndDate = NULL, Finished = 0, CreatedApp = NULL, Step = ?
			WHERE Token = ?", {}, $self->get_id_by_step( 1 ), $self->{ token }
		);
	
		return $self->redirect( 'current' );
	}

	$appnum =~ s!(\d{3})(\d{4})(\d{2})(\d{2})(\d{4})!$1/$2/$3/$4/$5!;

	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET EndDate = now(), Finished = 1, CreatedApp = ? WHERE Token = ?", {}, 
		$new_appid, $self->{ token }
	);

	$self->query( 'query', __LINE__, "
		UPDATE Appointments SET RDate = now(), Login = 'website', Draft = 0, NCount = ? 
		WHERE ID = ?", {}, $ncount, $new_appid
	);
	
	$self->send_app_confirm( $appnum, $new_appid );
		
	return ( $new_appid, $appnum );
}

sub check_mutex_for_creation
# //////////////////////////////////////////////////
{
	my ( $self, $step ) = @_;
	
	my $mutex_error = $self->mutex_fail();
	
	return ( '', $step ) unless $mutex_error;
	
	$step = $self->get_step_by_content( 'back_to_appdata' );
	 
	return ( $self->text_error( $mutex_error, { name => 'applist' } ), $step );
}

sub check_timeslots_already_full_or_not_actual
# //////////////////////////////////////////////////
{
	my ( $self, $step ) = @_;
	
	my $app = $self->get_same_info_for_timeslots();

	my $appobj = VCS::Docs::appointments->new( 'VCS::Docs::appointments', $self->{ vars } );
	
	my $timeslots = $appobj->get_timeslots_arr(
		$app->{ center }, $app->{ persons }, $app->{ appdate }, 0, $app->{ urgent }
	);

	for ( @$timeslots ) {

		return ( '', $step ) if $_->{id} == $app->{ timeslot };
	}

	$step = $self->get_step_by_content( 'back_to_appdate' );
	 
	return ( $self->text_error( 20, { name => 'timeslot' } ), $step );
}

sub get_step_by_content
# //////////////////////////////////////////////////
{
	my ( $self, $content, $next ) = @_;
	
	my $page_content = $self->get_content_rules();
	
	my $page_content_full = $self->get_content_rules( undef, 'full' );
	
	my $step;

	for my $page ( keys %$page_content ) {
	
		$step = $page if (
		
			( $page_content->{ $page } eq $content )
			or
			( $page_content_full->{ $page }->[ 0 ]->{ goto_link } eq $content )
		);
	}

	$step++ if $next;

	return $step;
}

sub set_step
# //////////////////////////////////////////////////
{
	my ( $self, $step ) = @_;

	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET Step = ? WHERE Token = ?", {},
		$self->get_id_by_step( $step ), $self->{ token }
	);
}

sub set_step_by_content
# //////////////////////////////////////////////////
{
	my ( $self, $content, $next ) = @_;

	my $step = $self->get_step_by_content( $content, $next );

	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET Step = ? WHERE Token = ?", {},
		$self->get_id_by_step( $step ), $self->{ token }
	);

	return $step;
}

sub get_edit
# //////////////////////////////////////////////////
{
	my ( $self, $step, $appdata_id ) = @_;
	
	if ( $self->check_existing_id_in_token( $appdata_id ) ) {
		
		$step = $self->get_step_by_content( '[list_of_applicants]', 'next');
		
		my ( $sch_id, $spb_id, $ext_id ) = $self->query( 'sel1', __LINE__, "
			SELECT SchengenAppDataID, AutoSpbAlterAppData.ID, AutoSchengenExtData.ID
			FROM AutoAppData
			JOIN AutoSpbAlterAppData ON AutoSpbAlterAppData.AppDataID = AutoAppData.ID
			LEFT JOIN AutoSchengenExtData ON AutoSchengenExtData.AppDataID = AutoAppData.ID
			WHERE AutoAppData.ID = ?", $appdata_id
		);

		$ext_id = 0 unless $ext_id;

		$self->query( 'query', __LINE__, "
			UPDATE AutoToken SET Step = ?, AutoAppDataID = ?, AutoSpbDataID = ?,
			AutoSchengenAppDataID = ?, AutoSchengenExtID = ?
			WHERE Token = ?", {}, 
			$self->get_id_by_step( $step ), $appdata_id, $spb_id, $sch_id, $ext_id, $self->{ token }
		);

		$self->query( 'query', __LINE__, "
			UPDATE AutoAppData SET FinishedVType = 0, FinishedCenter = 0 WHERE ID = ?", {}, $appdata_id
		);
		
		$self->mod_last_change_date();
	}
	
	return $step;
}

sub get_delete
# //////////////////////////////////////////////////
{
	my ( $self, $appdata_id ) = @_;
	
	my $result = 0;
	
	if ( $self->check_existing_id_in_token( $appdata_id ) ) {
	
		my $sch_id = $self->query( 'sel1', __LINE__, "
			SELECT SchengenAppDataID FROM AutoAppData WHERE ID = ?", $appdata_id
		);
	
		$result += $self->query( 'query', __LINE__, "
			DELETE FROM AutoAppData WHERE ID = ?", {}, $appdata_id
		);
		
		$result += $self->query( 'query', __LINE__, "
			DELETE FROM AutoSchengenAppData WHERE ID = ?", {}, $sch_id
		);
		
		$result += $self->query( 'query', __LINE__, "DELETE FROM $_ WHERE AppDataID = ?", {}, $appdata_id )
			for ( 'AutoSpbAlterAppData', 'AutoSchengenExtData' );
			
		$self->mod_last_change_date();
	}
	
	return $result;
}

sub check_existing_id_in_token
# //////////////////////////////////////////////////
{
	my ( $self, $appdata_id, $finished ) = @_;
	
	my $exist = 0;

	my ( $auto, $created ) = ( $finished eq 'finished' ? ( '', 'CreatedApp' ) : ( 'Auto', 'AutoAppID' ) );

	my $list_of_app_in_token = $self->query( 'selallkeys', __LINE__, "
		SELECT $auto" . "AppData.ID FROM AutoToken 
		JOIN $auto" . "AppData ON AutoToken.$created = $auto". "AppData.AppID
		WHERE Token = ?", $self->{ token }
	);
	
	for my $app ( @$list_of_app_in_token ) {
	
		$exist = 1 if ( $app->{ID} == $appdata_id );
	}
	
	return $exist;
}

sub get_homologous_series
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $all_rules = $self->get_content_rules( undef, 'full' );
	
	my $all_factor = {
		CenterID => [],
		VisaPurpose => [],
	};
	
	for my $page ( keys %$all_rules ) {
	
		for my $element ( @{ $all_rules->{ $page } } ) {
		
			for my $relation ( keys %{ $element->{ relation } } ) {
			
				for my $factor ( keys %$all_factor ) {
		
					if ( $element->{ relation }->{ $relation }->{ name } eq $factor ) {
					
						my @tmp = split( /\s?,\s?/, $element->{ relation }->{ $relation }->{ value } );
						
						push( @{ $all_factor->{ $factor } }, $_ ) for @tmp;
					}
				}
			}
		}
	}

	for my $factor ( keys %$all_factor ) {
	
		my %tmp = map { $_ => 1 } @{ $all_factor->{ $factor } };
	
		$all_factor->{ $factor } = \%tmp;
	}

	return $all_factor;
}

sub type_change_fail
# //////////////////////////////////////////////////
{
	my ( $self, $app ) = @_;

	my $category = $self->get_all_visa_categories();

	return 1 if (
		$category->{ $app->{ VType } } eq 'C'
		and
		$category->{ $app->{ FinishedVType } } eq 'D'
	);

	return 0;
}

sub homology_fail
# //////////////////////////////////////////////////
{
	my ( $self, $app, $homologous_series ) = @_;

	return 4 unless $app->{ FinishedVType } and $app->{ FinishedCenter };
	
	my $old_visa_not_h = $homologous_series->{ VisaPurpose }->{ $app->{ FinishedVType } };
	my $new_visa_not_h = $homologous_series->{ VisaPurpose }->{ $app->{ VType } };
	my $old_center_not_h = $homologous_series->{ CenterID }->{ $app->{ FinishedCenter } };
	my $new_center_not_h = $homologous_series->{ CenterID }->{ $app->{ CenterID } };
	
	return 19 if $self->type_change_fail( $app );

	return 19 if (
		( $app->{ FinishedVType } != $app->{ VType } )
		and
		( $old_visa_not_h or $new_visa_not_h )
	);

	return 22 if (
		( $app->{ FinishedCenter } != $app->{ CenterID } )
		and
		( $old_center_not_h or $new_center_not_h )
	);

	return undef;
}

sub check_all_app_finished_and_not_empty
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $allfinished = $self->query( 'selallkeys',  __LINE__, "
		SELECT FinishedVType, FinishedCenter, VType, CenterID
		FROM AutoAppData
		JOIN AutoAppointments ON AutoAppointments.ID = AutoAppData.AppID
		JOIN AutoToken ON AutoAppointments.ID = AutoToken.AutoAppID
		WHERE Token = ?", $self->{ token }
	);
	
	my $all_factor = $self->get_homologous_series();

	for ( @$allfinished ) {
	
		my $fail = $self->homology_fail( $_, $all_factor );

		return $fail if $fail;
	}
	
	return 5 if @$allfinished < 1;
	
	return 0;
}

sub get_add
# //////////////////////////////////////////////////
{
	my ( $self, $app_id ) = @_;
	
	$self->query( 'query', __LINE__, "
		INSERT INTO AutoSchengenAppData (HostDataCity) VALUES (NULL)"
	);
		
	my $sch_id = $self->query( 'sel1', __LINE__, "SELECT last_insert_id()" ) || 0;
	
	$self->query( 'query', __LINE__, "
		INSERT INTO AutoAppData (AnkDate, AppID, SchengenAppDataID, VisaNum)
		VALUES (now(), ?, ?, 2)", {}, 
		$app_id, $sch_id
	);
	
	my $appdata_id = $self->query( 'sel1', __LINE__, "SELECT last_insert_id()" ) || 0;

	$self->query( 'query', __LINE__, "
		INSERT INTO AutoSpbAlterAppData (AppDataID) VALUES (?)", {},
		$appdata_id
	);
		
	my $spb_id = $self->query( 'sel1', __LINE__, "SELECT last_insert_id()" ) || 0;
	
	$self->query( 'query', __LINE__, "
		INSERT INTO AutoSchengenExtData (AppDataID) VALUES (?)", {},
		$appdata_id
	);
		
	my $ext_id = $self->query( 'sel1', __LINE__, "SELECT last_insert_id()" ) || 0;
	
	my $step = $self->get_step_by_content( '[list_of_applicants]', 'next' );
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET Step = ?, AutoAppDataID = ?, AutoSchengenAppDataID = ?, AutoSpbDataID = ?, AutoSchengenExtID = ?
		WHERE Token = ?", {}, 
		$self->get_id_by_step( $step ), $appdata_id, $sch_id, $spb_id, $ext_id, $self->{ token }
	);
	
	$self->mod_last_change_date();
	
	return $step;
}

sub copy_unpersonal_information
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $app = $self->query( 'selallkeys', __LINE__, "
		SELECT AutoAppID, AutoAppData.ID, SchengenAppDataID,
		AutoSpbAlterAppData.ID as SpbID, Copypasta, VisaPurpose
		FROM AutoToken
		JOIN AutoAppData ON AutoToken.AutoAppDataID = AutoAppData.ID
		JOIN AutoSpbAlterAppData ON AppDataID = AutoAppData.ID
		WHERE Token = ?", $self->{ token }
	)->[ 0 ];

	return if $app->{ Copypasta };

	my $copy_ids = {
		'AppData' => { target => $app->{ ID } },
		'SchengenAppData' => { target => $app->{ SchengenAppDataID } },
		'SpbAlterAppData' => { target => $app->{ SpbID } },
	};	

	$self->copy_information( $self->find_source( $copy_ids, $app->{ AutoAppID }, $app->{ VisaPurpose } ) );
}

sub find_source
# //////////////////////////////////////////////////
{
	my ( $self, $tables_id, $app_id, $visa_purpose ) = @_;

	my $all_applicants = $self->query( 'selallkeys', __LINE__, "
		SELECT AutoAppData.ID, SchengenAppDataID, AutoSpbAlterAppData.ID as SpbID
		FROM AutoAppData
		JOIN AutoSpbAlterAppData ON AppDataID = AutoAppData.ID
		WHERE AppID = ? AND AutoAppData.ID <> ? AND VisaPurpose = ?
		ORDER BY AutoAppData.ID",
		$app_id, $tables_id->{ AppData }->{ target }, $visa_purpose
	)->[ 0 ];

	return undef unless $all_applicants->{ ID }; 
	
	$tables_id->{ AppData }->{ source } = $all_applicants->{ ID };

	$tables_id->{ SchengenAppData }->{ source } = $all_applicants->{ SchengenAppDataID };
	
	$tables_id->{ SpbAlterAppData }->{ source } = $all_applicants->{ SpbID };	

	return $tables_id;
}

sub copy_information
# //////////////////////////////////////////////////
{
	my ( $self, $tables_id ) = @_;

	return unless $tables_id;

	my $all_elements = $self->get_content_rules();
	
	my $copy_tables = {};

	for my $page ( keys %$all_elements ) {
	
		my $elements = $all_elements->{ $page };
		
		next if $elements =~ /\[/;
		
		for my $element ( @$elements ) {
	
			next unless $element->{ special } =~ /copy_from_other_applicants/;
			
			my $table = $element->{ db }->{ table };
			
			$copy_tables->{ $table } = {} unless ref( $copy_tables->{ $table } ) eq 'HASH';
			
			$copy_tables->{ $table }->{ $element->{ db }->{ name } } = 1;
		}
	}

	for my $table ( keys %$copy_tables ) {

		next if !$tables_id->{ $table }->{ target } or !$tables_id->{ $table }->{ source };

		my $request = '';
		
		my $send = '';
	
		for my $row ( keys %{ $copy_tables->{ $table } } ) {
		
			$request .= "$row, ";
			
			$send .=  "$row = ?, ";
		}
		$_ =~ s/,\s$// for ( $request, $send );

		my @values = $self->query( 'sel1', __LINE__, "
			SELECT $request FROM Auto$table WHERE ID = ?", $tables_id->{ $table }->{ source }
		);

		$self->query( 'query', __LINE__, "
			UPDATE Auto$table SET $send WHERE ID = ?", {}, @values, $tables_id->{ $table }->{ target }
		);
	}
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoAppData SET Copypasta = 1 WHERE ID = ?", {}, $tables_id->{ AppData }->{ target }
	);
}

sub get_back
# //////////////////////////////////////////////////
{
	my ( $self, $step ) = @_;
	
	$self->save_data_from_form( $step, $self->get_current_table_id() );
	$self->mod_last_change_date();
	
	$step--;
		
	if ( $step == $self->get_step_by_content( '[app_finish]' ) ) {
	
		$step = $self->set_step_by_content( '[list_of_applicants]' );
	}
	
	$self->set_step( $step );
	
	return $step;
}

sub get_html_page
# //////////////////////////////////////////////////
{
	my ( $self, $step, $appnum ) = @_;
	
	my $content = '';
	
	my $template = 'autoform.tt2';
	
	my $page_content = $self->get_content_rules( $step, undef, 'init' );

	return $self->get_list_of_app() if $page_content eq '[list_of_applicants]';
	
	my $current_values = $self->get_all_values( $step, $self->get_current_table_id() );

	$self->correct_values( \$current_values, $appnum );
	
	for my $element ( @$page_content ) {
	
		$content .= $self->get_html_line( $element, $current_values );
	}
	
	return ( $content, $template );
}

sub correct_values
# //////////////////////////////////////////////////
{
	my ( $self, $current_values, $appnum ) = @_;

	$$current_values->{ 'new_app_num' } = $appnum if $appnum;

	if ( exists $$current_values->{ 'new_app_branch' } ) {
	
		$$current_values->{ 'new_app_branch' } = $self->query( 'sel1', __LINE__, "
			SELECT BName FROM Branches WHERE ID = ?", $$current_values->{ 'new_app_branch' }
		);
	};
	
	if ( exists $$current_values->{ 'new_app_timedate' } ) {

		$$current_values->{ 'new_app_timedate' } = $self->query( 'sel1', __LINE__, "
			SELECT AppDate
			FROM AutoAppointments 
			JOIN AutoToken ON AutoAppointments.ID = AutoToken.AutoAppID
			WHERE AutoToken.Token = ?", $self->{ token }
		);

		$$current_values->{ 'new_app_timedate' } = $self->date_format( $$current_values->{ 'new_app_timedate' } );
	}
	
	if ( exists $$current_values->{ 'new_app_timeslot' } ) {
	
		my $start = $self->query( 'sel1', __LINE__, "
			SELECT TStart FROM TimeData WHERE SlotID = ?", $$current_values->{ 'new_app_timeslot' }
		);
		
		$$current_values->{ 'new_app_timeslot' } = $self->{ vars }->get_system->time_to_str( $start );	
	}
	
	return $$current_values;
}

sub get_list_of_app
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $content = $self->query( 'selallkeys', __LINE__, "
		SELECT AutoAppData.ID, AutoAppData.FName, AutoAppData.LName, 
		BirthDate, FinishedVType, FinishedCenter, VType, CenterID 
		FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
		WHERE Token = ?", $self->{ token }
	);
	
	my $link = $self->query( 'selallkeys', __LINE__, "
		SELECT LinkSended, AutoAppointments.EMail
		FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		WHERE Token = ?", $self->{ token }
	)->[ 0 ];

	$self->send_link( $link->{ EMail } ) unless $link->{ LinkSended } or !$link->{ EMail };
	
	if ( scalar(@$content) < 1 ) {
	
		$content->[ 0 ]->{ ID } = 'X';
		
	} else {

		my $all_factor = $self->get_homologous_series();

		for my $app ( @$content ) {

			$app->{ BirthDate } = $self->date_format( $app->{ BirthDate } );

			$app->{ Finished } = $self->homology_fail( $app, $all_factor ) || 0;
		}
	}

	return ( $content, 'autoform_list.tt2' );
}

sub get_specials_of_element
# //////////////////////////////////////////////////
{
	my ( $self, $page_content ) = @_;
	
	return if $page_content =~ /^\[/;
	
	my $special = {
		datepicker 	=> [],
		mask		=> [],
		full_mask	=> [],
		nearest_date	=> [],
		timeslots	=> [],
		post_index	=> [],
		captcha		=> [],
		include_in	=> [],
		include_out	=> [],
		no_copypast	=> [],
		min_date 	=> [],
		phone_correct	=> [],
		multiple_select	=> [],
	};

	my $js_rules = [];
	
	for my $element ( @$page_content ) {

		for my $spec_type ( keys %$special ) {
		
			push( @{ $special->{ $spec_type } }, $element->{ name } ) if $element->{ special } =~ /$spec_type/;
		}
		
		push( @{ $special->{ full_mask } }, [ $element->{ name }, $element->{ mask } ] )
			if exists $element->{ mask };

		push( @{ $special->{ captcha } }, $self->get_captcha_id() )
			if $element->{ type } eq 'captcha';
		
		push( @{ $special->{ "include_" . $element->{ place } } }, $element->{ template } )
			if $element->{ type } eq 'include';
		
		push( @{ $special->{ min_date } }, { name => $element->{ name }, min => $element->{ minimal_date } } )
			if $element->{ minimal_date };
			
		push( @{ $special->{ multiple_select } }, [ $element->{ name } ] )
			if exists $element->{ multiple_select };

		next unless $element->{ check };
			
		my $js_rule = {};
		
		$js_rule->{ $_ } = $element->{ $_ } for ( 'name', 'type', 'label', 'check' );

		$js_rule->{ label } = $element->{ label_for } unless $element->{ label };

		$js_rule->{ label } = $self->lang( $js_rule->{ label } );
	
		$js_rule->{ check } =~ s/\\/\\\\/g;

		$js_rule->{ check } =~ s/'/\\'/g;
		
		push( @$js_rules, $js_rule );
	}

	return ( $special, $js_rules );
}

sub get_html_line
# //////////////////////////////////////////////////
{
	my ( $self, $element, $values ) = @_;

	return $self->get_html_for_element( 'free_line' ) if $element->{ type } eq 'free_line';
	
	return $self->get_html_for_element( 'free_line' )
		if ( $element->{ type } eq 'biometric_data' ) and $self->{ biometric_data } ne 'yes';
	
	my $content = $self->get_html_for_element( 'start_line' );
	
	if ( $element->{ type } eq 'text' ) {
	
		$content .= $self->get_html_for_element(
			'text', $element->{ name }, $element->{ label }, undef, $element->{ font }
		);
		$content .= $self->get_html_for_element( 'end_line' );
	
		return $content;
	}
	
	my $label_for_need = ( $element->{ label_for } ? 
		$self->get_html_for_element( 'label_for', $element->{ name }, $element->{ label_for } ) : '' );
	
	my $current_value = $values->{ $element->{name} };

	if ( $element->{ db }->{ name } eq 'complex' ) {
	
		for my $sub_value ( keys %{ $element->{ param } } ) {
		
			$current_value->{ $sub_value } = $values->{ $sub_value };
		}
	}
	
	my $label_text = $self->get_cell(
		$self->get_html_for_element( 'label', 'text_' . $element->{ name }, $element->{ label } ), $element->{ example }
	);
	
	$label_text = '' if $element->{ full_line } or $element->{ type } eq 'captcha';

	$content .= $label_text .
		$self->get_cell(
			$self->get_html_for_element(
				$element->{ type }, $element->{ name }, $current_value, $element->{ param }, 
				$element->{ uniq_code }, $element->{ first_elements },
				$self->check_comments_alter_version( $element->{ comment } ),
				$element->{ check }, $element
			) . $label_for_need, undef, ( $element->{ type } eq 'input' ? 'bottom' : undef ),
			'width="280px"' . ( $element->{ full_line } ? ' colspan=2' : '' )
		);
	
	$content .= $self->get_html_for_element( 'end_line' );
	
	$content .= $self->get_html_for_element( 'example', $element->{name}, $element->{example} )
		if $element->{ example } ne '';

	return $content;
}

sub get_cell
# //////////////////////////////////////////////////
{
	my ( $self, $element, $rowspan, $bottom, $width_fix ) = @_;
	
	my $start_cell = $self->get_html_for_element(
		'start_cell', undef, undef, undef,
		( $rowspan eq '' ? $bottom : 'rowspan=2 valign=top' ) . ( $width_fix ? " $width_fix" : '' )
	);
	
	return $start_cell . $element . $self->get_html_for_element( 'end_cell' );
}

sub get_progressbar
# //////////////////////////////////////////////////
{
	my ( $self, $current_progress, $progress_line ) = @_;
	
	my ( $line, $content );
	
	my $big_element = 0;
	
	for ( 1..$#$progress_line ) {
		
		my $past_current_future = 'current';
		$past_current_future = 'past' if $_ < $current_progress;
		$past_current_future = 'future' if $_ > $current_progress;
		
		my $add_el = ( $_ == 1 ? 1 : ( $_ == $#$progress_line ? 2 : 0 ) ); # 1 - first, 2 - last
		
		$big_element++ if $progress_line->[ $_ ]->{ big };
	
		$line .= $self->get_html_for_element(
			'progress', $big_element, $progress_line->[ $_ ]->{ name }, $past_current_future,
			$add_el, $progress_line->[ $_ ]->{ big }
		);
				
		$content .= $self->get_html_for_element(
			'stages', undef, $progress_line->[ $_ ]->{ name }, $past_current_future,
			undef, $progress_line->[ $_ ]->{ big }
		);
	}
	
	return $line . $self->get_html_for_element( 'end_line' ) . $self->get_html_for_element( 'start_line' ) . $content;
}

sub get_progressbar_hash_opt
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my ( $center, $visa_category ) = $self->get_app_visa_and_center();
		
	return VCS::Site::autodata_type_d::get_progressline() if $visa_category eq 'D';
	
	return VCS::Site::autodata_type_c_spb::get_progressline() if VCS::Site::autodata::this_is_spb_center( $center );

	return VCS::Site::autodata_type_c::get_progressline();
}

sub get_html_for_element
# //////////////////////////////////////////////////
{
	my ( $self, $type, $name, $value_original, $param, $uniq_code, $first_elements, $comment, $check, $element ) = @_;

	my $value = ( $type eq 'input' ? $value_original : $self->lang( $value_original ) );
	my $param = $self->lang( $param );
	my $comment = $self->lang( $comment );
	my $example = $self->lang( 'пример' );
	
	my $elements = VCS::Site::autodata::get_html_elements();

	my $content = $elements->{ $type };

	if ( ( $type ne 'm_select' ) and ( ref( $value ) eq 'ARRAY' ) ) {
	
		my $value_line = '';
		
		$value_line .= "$_<br>" for @$value;
		
		$value = $value_line;
	}
	
	$value =~ s/"/&quot;/g unless $type =~ /^(label_for|text)$/;
	
	$comment .= $self->add_rules_format( $check ) if $type =~ /^input$/;
	
	if ( ( $type eq 'progress' ) and ( !$first_elements ) ) {
		$content =~ s/\[name\]//gi;
		$content =~ s/\[title\]/$value/gi;
	}
	else {
		$content =~ s/\[name\]/$name/gi;
		$content =~ s/\[title\]//gi;
	}
	
	if ( ( $type eq 'stages' ) and ( !$first_elements ) ) {
	
		$content =~ s/\[progress_stage\]//gi;
	}
	else {
		$content =~ s/\[progress_stage\]/$value/gi;
	}

	$content =~ s/\[value\]/$value/gi;
	$content =~ s/\[comment\]/$comment/gi;
	$content =~ s/\[example\]/$example/gi;
	
	if ( ( $type eq 'checkbox' ) or ( $type eq 'disclaimer' ) ) {
	
		$content =~ s/\[checked\]/checked/gi if $value_original;
		$content =~ s/\s\[checked\]//gi;

		my $close = $self->lang( 'закрыть' );
		
		$content =~ s/\[close\]/$close/gi;
	}
	
	if ( $type =~ /^(m_)?select$/ ) {
	
		my $list = '';

		for my $opt ( $self->resort_with_first_elements( $param, $first_elements ) ) {
			
			my $selected = '';
			
			if ( $type eq 'm_select' ) {
			
				my @value_for_selected = split( /,/, $value_original );
				
				for ( @value_for_selected ) {
				
					$selected = 'selected' if $opt =~ /^$_$/i;
				}
			}
			else {
				my $value_for_selected = $value_original;
			
				$value_for_selected =~ s/$_/$_/g for ('\/', '\(', '\)' );
				
				$selected = ( $opt =~ /^$value_for_selected$/i ? 'selected' : '' );
			}
			
			$selected = 'selected disabled' if $opt eq $element->{ required_element };
			
			$list .= '<option ' . $selected . ' value="' . $opt . '">' . 
			( $param->{ $opt } ? $param->{ $opt } : '--- ' . $self->lang( "выберите" ) . ' ---' ) .
			'</option>'; 
		}
		
		if ( $type eq 'm_select' ) {
		
			my $holder = '--- ' . $self->lang( "выберите" ) . ' ---';
			
			$content =~ s/\[holder\]/$holder/i;
		}

		$content =~ s/\[u\]\>/data-timeslot="$value_original">/i if $name eq 'timeslot';
		$content =~ s/\[options\]/$list/gi;
	}
	
	if ( $type eq 'radiolist' ) {
	
		my $list = '';
		my $uniq_id = 0;

		for my $opt ( sort { $a <=> $b } keys %$param ) {

			my $checked = ( $value_original eq $opt ? 'checked' : '' );
			
			$uniq_id++;
			$list .= '<input type="radio" name="' . $name . '" value="' . $opt . '" ' .
				$checked . ' title="' . $comment . '" id="'.$name.$uniq_id.'">' .
				'<label for="'.$name.$uniq_id.'">'.$param->{ $opt }.'</label><br>';
		}
		$content =~ s/\[options\]/$list/gi;
		
	}
	
	if ( $type eq 'checklist' ) {

		my $list = '';

		for my $opt ( sort { $a cmp $b } keys %$param ) {
		
			my $checked = ( $value->{ $opt } ? 'checked' : '' );
			
			my $text = $self->lang( $param->{ $opt }->{ label_for } );
			
			$list .= '<input type="checkbox" value="' . $opt . '" name="' . $opt .
				'" title="' . $comment . '" id="' . $opt . '" ' . $checked . '>'.
				'<label for="' . $opt . '">&nbsp;' . $text . '</label><br>';
		}
		$content =~ s/\[options\]/$list/gi;
	}
	
	if ( $type eq 'captcha' ) {
	
		return undef if $self->this_is_inner_ip();
	
		my $key = $self->{ autoform }->{ captcha }->{ public_key };
		
		my $widget_api = $self->{ autoform }->{ captcha }->{ widget_api };
		
		my $captch_id = $self->get_captcha_id();
		
		my $lang = $self->{ 'lang' } || 'ru';
		
		$content =~ s/\[captch_id\]/$captch_id/gi;
		
		$content =~ s/\[widget_api\]/$widget_api/gi;
		
		$content =~ s/\[public_key\]/$key/gi;
		
		$content =~ s/\[lang\]/$lang/gi;
	}
	
	
	if ( $type eq 'progress' ) {
		
		my $form = ( $first_elements ? 'big' : 'ltl' ) . '_progr pr_' . $param;
			
		my $background_image = {
			0 => {
				'past' => 'red_red',
				'current' => 'red_gray',
				'future' => 'gray_gray',
			},
			1 => {
				'past' => 'white_red',
				'current' => 'white_gray',
				'future' => 'white_gray',
			},
			2 => {
				'past' => 'red_white',
				'current' => 'red_white',
				'future' => 'gray_white',
			},
		};
		
		my $back = $background_image->{ $uniq_code }->{ $param };
				
		$content =~ s/\[format\]/$form/;
		$content =~ s/\[file\]/$back/;
	}
	
	if ( $type eq 'info' ) {
	
		$value = '—' if !$value;
		$content =~ s/\[text\]/$value/;
	}
	
	$content =~ s/\[text\]/$comment/ if $type eq 'biometric_data';
	
	if ( $uniq_code ) {
	
		$content = $self->add_css_class( $content, 'bold_text') if $uniq_code eq 'bold';
			
		$content = $self->add_css_class( $content, 'bottom') if $uniq_code eq 'bottom';
		
		$uniq_code = '' if $uniq_code =~ /^(bold|bottom)$/;
		
		$content =~ s/\[u\]/$uniq_code/gi;
	}
	else {
		$content =~ s/\s\[u\]\>/>/gi;
	}
	
	if ( ( $type eq 'input' ) and ( ( $check !~ /^z/ ) ) ) {
	
		$content = $self->add_css_class( $content, 'optional_field');
	}

	return $content;
}

sub get_captcha_id
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $key = $self->{ autoform }->{ captcha }->{ public_key };

	return 'recaptcha_' . substr( $key, 0, 10 );
}

sub get_letter_rules_lang_ver
# //////////////////////////////////////////////////
{
	my ( $self, $lang, $rules ) = @_;
	
	my $letters = '';
	
	if ( $self->{ 'lang' } eq 'it' ) {
	
		$letters .= $self->lang( 'буквы ' ) if $rules =~ /Ё/ or $rules =~ /W/;
		$letters .= $self->lang( 'английские ' ) if $rules =~ /W/;
		$letters .= $self->lang( 'и ' ) if $rules =~ /Ё/ and $rules =~ /W/;
		$letters .= $self->lang( 'русские ' ) if $rules =~ /Ё/;
	}
	else {
		$letters .= $self->lang( 'русские ' ) if $rules =~ /Ё/;
		$letters .= $self->lang( 'и ' ) if $rules =~ /Ё/ and $rules =~ /W/;
		$letters .= $self->lang( 'английские ' ) if $rules =~ /W/;
		$letters .= $self->lang( 'буквы, ' ) if $rules =~ /Ё/ or $rules =~ /W/;
	}
	
	return $letters;
}

sub add_rules_format
# //////////////////////////////////////////////////
{
	my ( $self, $rules ) = @_;

	my $format_add_string = $self->get_html_for_element( 'new_and_bold',
		$self->lang( ( $rules =~ /z/ ? 'Обязательное' : 'Необязательное' ) . ' поле' ) 
	);
	
	if ( $rules =~ /D/ ) {
	
		$format_add_string .= $self->get_html_for_element( 'new_line' ) . 
			$self->lang( 'В поле вводится дата в формате ДД.ММ.ГГГГ' );
			
		$rules = undef;
	}
	else {
		$format_add_string .= $self->get_html_for_element( 'new_line' ) .
			$self->lang( 'В поле допустимо вводить ' );
	}
	
	$format_add_string .= $self->get_letter_rules_lang_ver( $self->{ 'lang' }, $rules );
	
	$format_add_string .= $self->lang( 'цифры, ' ) if $rules =~ /N/;
	
	$rules =~ s/(\s|\n|z|W|Ё|N|'|\))//g;
		
	if ( $rules ) {
	
		my @symbols = split( /\\/, $rules );
		
		my $symbols_help = VCS::Site::autodata::get_symbols_help();
		
		$format_add_string .= $self->lang( 'а также символы' );
		
		for ( 1..$#symbols ) {
			
			if ( exists $symbols_help->{ $symbols[ $_ ] } ) {
			
				$format_add_string .= ' ' . $self->lang( $symbols_help->{ $symbols[ $_ ] } ) . ',';
			}
			elsif ( $symbols[ $_ ] ne '' ) {
			
				$format_add_string .= " $symbols[ $_ ],"; 
			}			
		}		
	}
	
	$format_add_string =~ s/\s?,\s?$//;
		
	return $format_add_string;
}

sub check_comments_alter_version
# //////////////////////////////////////////////////
{
	my ( $self, $comment ) = @_;
	
	return $comment unless ref( $comment ) eq 'HASH';
	
	my ( $current_center ) = $self->get_app_visa_and_center();

	for ( keys %$comment ) {
	
		my %centers = map { $_ => 1 } split( /,/, $_ );
		
		return $comment->{ $_ } if exists $centers{ $current_center };
	}
}

sub add_css_class
# //////////////////////////////////////////////////
{
	my ( $self, $html, $new_class ) = @_;
	
	if ( $html =~ /\sclass="([^"]*)"/i ) {
	
		my $classes = "$1 $new_class";
		
		$html =~ s/\sclass="[^"]*"/ class="$classes"/i;
	}
	else {
		$html =~ s/^\s*(\<[^\s]+\s)/$1class="$new_class" /;
	}
	
	return $html;
}

sub resort_with_first_elements
# //////////////////////////////////////////////////
{
	my ( $self, $country_hash, $first_elements ) = @_;

	return sort { $country_hash->{ $a } cmp $country_hash->{ $b } } keys %$country_hash
		if !$first_elements;	
	
	my @first_elements = split( /,/, $first_elements );

	my @array_with_first_elements = ();
	
	for my $first ( @first_elements ) {
	
		$first =~ s/^\s+|\s+$//g;
		
		if ( $first eq 'default_free' ) {
		
			push( @array_with_first_elements, 0 );
		}
		else {
			for my $elem (keys %$country_hash) {
			
				push( @array_with_first_elements, $first ) if $elem == $first;
			}
		}
	}
	
	my %first_elements = map { $_ => 1 } @first_elements; 
	
	for my $e ( sort { $country_hash->{ $a } cmp $country_hash->{ $b } } keys %$country_hash ) {
	
		push( @array_with_first_elements, $e ) if !exists $first_elements{ $e };
	}

	return @array_with_first_elements;
}

sub save_data_from_form
# //////////////////////////////////////////////////
{
	my ( $self, $step, $table_id, $app_finished, $content ) = @_;

	my $content_rules = ( $app_finished ? $content : $self->get_content_rules( $step ) );
	
	my $request_tables = $self->get_names_db_for_save_or_get( $content_rules, 'save', $app_finished );

	for my $table ( keys %$request_tables ) {
		
		next if ( $app_finished ne "finished" ) and !$table_id->{ $table };
		
		next if $table eq 'alternative_data_source';
	
		my $request = '';
		my @values = ();
	
		for my $row ( keys %{ $request_tables->{ $table } } ) {
		
			$request .=  "$row = ?, ";
			
			my $value = $self->param( $request_tables->{ $table }->{ $row } );
		
			push ( @values, $self->encode_data_for_db( $content_rules, $request_tables->{ $table }->{ $row }, $value ) );
			
			$self->change_current_appdata( $value, $table_id ) if ( $app_finished ne "finished" ) and ( $row eq 'PersonForAgreements' );
		}
		$request =~ s/,\s$//;		

		$self->query( 'query', __LINE__, "
			UPDATE $table SET $request WHERE ID = ?", {}, @values, $table_id->{ $table }
		);
	}
	
	$self->check_special_in_rules_for_save( $step, $table_id ) if $app_finished ne "finished";
}

sub change_current_appdata
# //////////////////////////////////////////////////
{
	my ( $self, $new_app_id, $table_id ) = @_;

	return $self->query( 'query', __LINE__, "
		UPDATE AutoToken SET AutoAppDataID = ? WHERE ID = ?", {}, $new_app_id, $table_id->{ AutoToken }
	);
}

sub check_special_in_rules_for_save
# //////////////////////////////////////////////////
{
	my ( $self, $step, $table_id ) = @_;
	
	my $elements = $self->get_content_rules( $step );
	
	return if $elements =~ /\[/;
	
	for my $element ( @$elements ) {
	
		if ( $element->{ special } =~ /save_info_about_hastdatatype/ ) {
			
			my $visa_type = $self->query( 'sel1', __LINE__, "
				SELECT VisaPurpose FROM AutoAppData WHERE ID = ?", $table_id->{ AutoAppData }
			);

			$self->query( 'query', __LINE__, "
				UPDATE AutoSchengenAppData SET HostDataType = 'S' WHERE ID = ?", {},
				$table_id->{ AutoSchengenAppData }
				
			) unless $visa_type == 1;
		}
		elsif ( $element->{ special } =~ /cach_this_value/ ) {
		
			my $key = 'autoform_' . $self->{ token } . '_' . $element->{ name };

			$self->cached( $key, $self->param( $element->{ name } ) );
		}
		elsif ( $element->{ special } =~ /save_urgent_info/ ) {
		
			my $urgent = ( $self->param( 'urgent_slots' ) ? 1 : 0 );
			
			$self->query( 'query', __LINE__, "
				UPDATE AutoAppointments SET Urgent = ? WHERE ID = ?", {},
				$urgent, $table_id->{ AutoAppointments }
			);
		}
	}
}

sub get_all_values
# //////////////////////////////////////////////////
{
	my ( $self, $step, $table_id, $app_finished, $content ) = @_;

	my $all_values = {};
	
	my $request_tables = $self->get_names_db_for_save_or_get(
		( $app_finished ? $content : $self->get_content_rules( $step ) ), undef, $app_finished
	);

	for my $table ( keys %$request_tables ) {

		next if !$table_id->{ $table };
		
		next if $table eq 'alternative_data_source';

		my $request = join( ',', keys %{ $request_tables->{ $table } } );

		my $result = $self->query( 'selallkeys', __LINE__, "
			SELECT $request FROM $table WHERE ID = ?", $table_id->{ $table }
		)->[ 0 ];

		for my $value ( keys %$result ) {
		
			$all_values->{ $request_tables->{ $table }->{ $value } } =
				$self->decode_data_from_db( $step, $request_tables->{ $table }->{ $value }, $result->{ $value } );
		}
	}

	my $alt = $request_tables->{ alternative_data_source };
	
	if ( $alt ) {

		for my $field ( keys %{ $alt } ) {
		
			if ( !$all_values->{ $field } ) {
			
				my $alt_value = $self->query( 'sel1', __LINE__, "
					SELECT $alt->{ $field }->{ field } FROM $alt->{ $field }->{ table } WHERE ID = ?", 
					$table_id->{ $alt->{ $field }->{ table } }
				);

				$all_values->{ $field } = $self->decode_data_from_db( $step, $alt->{ $field }->{ field }, $alt_value );
			}
		}
	}

	return $all_values;
}

sub get_prepare_line
# //////////////////////////////////////////////////
{
	my ( $self, $line, $element ) = @_;
	
	if ( ( $element->{ type } eq 'm_select' ) and ( ref( $line ) eq 'ARRAY' ) ) {
	
		my $new_line = '';
	
		$new_line .= "$_," for @$line;
		
		$new_line =~ s/,$//;

		return $new_line;
	}
	else {
		$line =~ s/^\s+|\s+$//g;
		
		$line =~ s/\xc2\xa0/\x20/g;
	}

	return $line;
}

sub decode_data_from_db
# //////////////////////////////////////////////////
{
	my ( $self, $step, $element_name, $value ) = @_;

	$value = $self->date_format( $value );
	
	$value = '' if ( $value eq '00.00.0000' );

	return $value;
}

sub encode_data_for_db
# //////////////////////////////////////////////////
{
	my ( $self, $content_rules, $element_name, $value ) = @_;

	my $element = $self->get_element_by_name( $content_rules, $element_name );
	
	$value = $self->get_prepare_line( $value, $element );
	
	$value = ( ( $value eq $element_name ) ? 1 : 0 )
		if $element->{ type } =~ /checkbox|disclaimer|checklist/ and $element->{ name } ne 'edt_mezzi';
	
	$value = $self->{ vars }->get_system->to_upper_case( $value ) if $element->{ format } eq 'capslock';
	
	$value = $self->{ vars }->get_system->to_upper_case_first( $value ) if $element->{ format } eq 'capitalized';
	
	$value = $self->date_format( $value, 'to_iso' );
	
	return $value;
}

sub get_element_by_name
# //////////////////////////////////////////////////
{
	my ( $self, $page_content, $element_name ) = @_;
	
	for my $element_search ( @$page_content ) {
	
		return $element_search if $element_search->{ name } eq $element_name;
		
		if ( $element_search->{ db }->{ name } eq 'complex' ) {
		
			for my $sub_element ( keys %{ $element_search->{ param } } ) {
			
				return $element_search if $sub_element eq $element_name;
			}
		};
	};
}

sub get_names_db_for_save_or_get
# //////////////////////////////////////////////////
{
	my ( $self, $page_content, $save_or_get, $app_finished ) = @_;
	
	my $request_tables = {};
	
	my $alt_data_source = {};

	return if $page_content =~ /^\[/;
	
	if ( ref( $page_content ) eq 'HASH' ) {
	
		my $allpages_content = [];
	
		for my $page ( keys %$page_content ) {
		
			next if $page_content->{ $page } =~ /^\[/;
			
			push( @$allpages_content, $_ ) for @{ $page_content->{ $page } };
		}
		
		$page_content = $allpages_content;
	}

	for my $element (@$page_content) {

		next if ( $element->{ type } eq 'info' ) and ( $save_or_get eq 'save' );
		
		next if ref( $element->{ db } ) ne 'HASH';

		my $prefix = ( $element->{ db }->{ table } !~ /^Auto/i ? 'Auto' : '' );
		
		$prefix = '' if $app_finished eq 'finished';

		if ( $element->{ db }->{ name } eq 'complex' ) {
		
			for my $sub_element ( keys %{ $element->{ param } } ) {
			
				$request_tables->{ $prefix . $element->{ db }->{ table } }->{ $element->{ param }->{ $sub_element }->{ db } } = 
					$sub_element;
			}
		}
		else { 
			$request_tables->{ $prefix . $element->{ db }->{ table } }->{ $element->{ db }->{ name } } = $element->{ name };
			
			if ( $element->{ load_if_free_field } ) {
			
				$alt_data_source->{ $element->{ name } }->{ table } = $prefix . $element->{ load_if_free_field }->{ table };
				
				$alt_data_source->{ $element->{ name } }->{ field } = $element->{ load_if_free_field }->{ name };
			}
		}
	}
	
	$request_tables->{ alternative_data_source } = $alt_data_source;

	return $request_tables;
}

sub get_current_table_id
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $tables_id = {};

	my $tables_controled_by_AutoToken = VCS::Site::autodata::get_tables_controled_by_AutoToken();

	my @tables_list = ( 'AutoToken', keys %$tables_controled_by_AutoToken );
	
	my $request_tables = 'ID, ' . join( ', ', values %$tables_controled_by_AutoToken );
	
	my @ids = $self->query( 'sel1', __LINE__, "
		SELECT $request_tables FROM AutoToken WHERE Token = ?", $self->{ token }
	);

	my $max_index = scalar( keys %$tables_controled_by_AutoToken );
	
	for my $id ( 0..$max_index ) {
	
		$tables_id->{ $tables_list[ $id ] } = $ids[ $id ];
	};
	
	return $tables_id;
}

sub check_data_from_db
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $table_id = $self->get_current_table_id();
	
	my $rules = $self->get_content_db_rules( 'check' );
	
	for my $table ( keys %$rules ) {
		
		my $auto_table = 'Auto' . $table;
		
		next if !$table_id->{ $auto_table };
		
		for ( keys %{ $rules->{ $table } } ) {
		
			delete $rules->{ $table }->{ $_ } unless $rules->{ $table }->{ $_ };
		}
		
		next if !( scalar keys %{ $rules->{ $table } } );

		my $request = join( ',', keys %{ $rules->{ $table } } );
		
		my $where_id = "ID = " . $table_id->{ $auto_table };
		
		$where_id = "AppID = " . $table_id->{ 'AutoAppointments' } if $auto_table eq 'AutoAppData';
		
		my $data = $self->query( 'selallkeys', __LINE__, "
			SELECT $request FROM $auto_table WHERE $where_id"
		);

		for my $app ( @$data ) {
		
			for my $field ( keys %{ $app } ) {
		
				return 25 if (
					( $rules->{ $table }->{ $field } eq 'not_empty')
					&&
					( !$app->{ $field } or $app->{ $field } eq '0000-00-00' )
				);
			}
		}
	}
	
	return 0;
}

sub check_data_from_form
# //////////////////////////////////////////////////
{
	my ( $self, $step, $content, $tables_ids_edt ) = @_;
	
	my $page_content = ( $content ? $content : $self->get_content_rules( $step, undef, 'init' ) );
	
	my $tables_id = ( $tables_ids_edt ? $tables_ids_edt : $self->get_current_table_id() );

	return if $page_content =~ /^\[/;
	
	my $first_error = '';
	
	for my $element ( @$page_content ) {

		last if $first_error;
		
		$first_error = $self->check_diff_types( $element ) if $element->{ check };

		$first_error = $self->check_captcha() if $element->{ type } =~ /captcha/;

		$first_error = $self->check_logic( $element, $tables_id, ( $tables_ids_edt ? 1 : 0 ) )
			if !$first_error and $element->{ check_logic };
	}
	
	return $first_error;
}

sub check_diff_types
# //////////////////////////////////////////////////
{
	my ( $self, $element ) = @_;
	
	return $self->check_chkbox( $element ) if $element->{type} =~ /checkbox|disclaimer/;

	return $self->check_checklist( $element ) if $element->{type} =~ /checklist/;

	return $self->check_param( $element );
}

sub check_checklist
# //////////////////////////////////////////////////
{
	my ( $self, $element ) = @_;
	
	my $at_least_one = 0;
	
	for my $field ( keys %{ $element->{ param } } ) {
	
		$at_least_one += ( $self->param( $field ) ? 1 : 0 );
	}
	
	return $self->text_error( 11, $element )
		if ( ( $element->{ check } =~ /at_least_one/ ) and ( $at_least_one == 0 ) );
}

sub check_chkbox
# //////////////////////////////////////////////////
{
	my ( $self, $element ) = @_;
	
	my $value = $self->param( $element->{ name } );
	
	return $self->text_error( 3, $element ) if ( ( $element->{ check } =~ /true/ ) and ( $value eq '' ) );
}

sub check_param
# //////////////////////////////////////////////////
{
	my ( $self, $element ) = @_;

	my $value = $self->param( $element->{ name } );
	my $rules = $element->{ check };

	$value = $self->get_prepare_line( $value, $element );
	
	return $self->text_error( 30, $element )
		if ( $element->{ example_not_for_copy } and $element->{ example } ne '' ) and ( $value eq $element->{ example } ); 

	return $self->text_error( 0, $element )
		if ( $rules =~ /z/ ) and ( ( $value eq '' ) or ( $value eq '0' ) );
			
	return if $rules eq 'z';

	if ( $rules =~ /D/ ) {
	
		$rules =~ s/(z|D)//g;
		
		return $self->text_error( 1, $element ) if ( !( $value =~ /$rules/ ) and ( $value ne '' ) );
		
		$value =~ /(\d\d)\.(\d\d)\.(\d\d\d\d)/;
	
		return $self->text_error( 1, $element )
			if ( Date::Calc::check_date( $3, $2, $1 ) == 0  and ( $value ne '' ) );
	}
	else {
		my $regexp = '';
		
		$regexp .= 'A-Za-z' if $rules =~ /W/; 
		$regexp .= 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя' if $rules =~ /Ё/;
		$regexp .= '0-9' if $rules =~ /N/;
	
		$rules =~ s/(z|W|Ё|N)//g;
		
		my $revers_regexp = '[' . $regexp . $rules . ']';
		$regexp = '[^' . $regexp . $rules . ']';

		if ( ( $value =~ /$regexp/ ) and ( $value ne '' ) ) {
		
			$value =~ s/$revers_regexp//gi;

			return $self->text_error( 2, $element, $value );
		}
	}
}

sub check_captcha
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	return undef if $self->this_is_inner_ip();
	
	my $response = $self->param( 'g-recaptcha-response' ) || '';
	
	my $request = HTTP::Tiny->new();

	my $result = $request->post_form(
		$self->{ autoform }->{ captcha }->{ verify_api },
		{ 
			secret => $self->{ autoform }->{ captcha }->{ private_key }, 
			response  => $response
		}
	);

	if ( $result->{ success } ) {
	
		return if decode_json( $result->{ content } )->{ success };
	}
	return 'captha_div' . $self->text_error( 18 );
}

sub check_logic
# //////////////////////////////////////////////////
{
	my ( $self, $element, $tables_id, $finished ) = @_;

	my $value = $self->param( $element->{ name } );
	my $error = 0;
	
	$value =~ s/^\s+|\s+$//g;
	
	my $prefix = ( $finished ? '' : 'Auto' );

	for my $rule ( @{ $element->{ check_logic } } ) {
	
		if ( $rule->{ condition } =~ /^equal$/ ) {
			
			my $related_value = $self->query( 'sel1', __LINE__, "
				SELECT $rule->{name} FROM $prefix$rule->{table} WHERE ID = ?",
				$tables_id->{ $prefix.$rule->{table} }
			);

			return $self->text_error( 26, $element, undef, $rule->{ error }, undef, $rule->{ full_error } )
				if lc( $related_value ) ne lc( $value );
		}

		if ( $rule->{ condition } =~ /^(equal|now)_or_(later|earlier)$/ ) {
		
			$value = $self->date_format( $value, 'to_iso' );

			my $datediff = $self->get_datediff(
				$value, $rule, $tables_id, ( $rule->{ condition } =~ /^equal/ ? 1 : 0 ), $prefix
			);

			my $offset = ( $rule->{ offset } ? $rule->{ offset } : 0 );
			
			$error = 6 if (
				(
					( $datediff < $offset )
					or
					( ( $datediff == $offset ) and $rule->{ equality_is_also_fail } )
				)
				and
				( $rule->{ condition } =~ /later$/ )
			);

			$error = 8 if (
				(
					( $datediff > $offset )
					or
					( ( $datediff == $offset ) and $rule->{ equality_is_also_fail } )
				)
				and
				( $rule->{ condition } =~ /earlier$/ )
			);

			$error = 12 if ( $error and $rule->{ condition } =~ /^now/ );
			
			$error++ if ( $offset and ( $error == 6 or $error == 8 ) );
			$error = 23 if ( $offset < -1 and $error == 9 );
			
			$offset *= -1 if $offset < 0;

			return $self->text_error(
				$error, $element, undef, $rule->{ error }, $offset, $rule->{ full_error }
				
			) if $error;
		}
		
		if ( $rule->{ condition } =~ /^not_beyond_than$/ ) {
		
			$value = $self->date_format( $value, 'to_iso' );

			my $datediff = $self->get_datediff( $value, $rule, $tables_id, 'use_date', $prefix );

			return $self->text_error(
				23, $element, undef, $rule->{ error }, $rule->{ offset }, $rule->{ full_error }
			) if (
				( ( $datediff > 0 ) and ( $datediff >= $rule->{ offset } ) )
				or
				( ( $datediff < 0 ) and ( $datediff <= ( $rule->{ offset } * -1 ) ) )
			);
		}
		
		if ( $rule->{ condition } =~ /^not_closer_than(_in_spb)?(_from_now)?$/ ) {
		
			my ( $spb, $from_now ) = ( $1, $2 );

			$value = $self->date_format( $value, 'to_iso' );
			
			$value = sprintf( "%04d-%02d-%02d",
				( Date::Calc::Add_Delta_YMD( split( /-/, $value  ), 0, 3, 1 ) )
				
			) if $spb;
			
			
			my $datediff = $self->get_datediff( $value, $rule, $tables_id, ( $from_now ? 0 : 1 ), $prefix );

			return $self->text_error(
				23, $element, undef, $rule->{ error }, $rule->{ offset }, $rule->{ full_error }
			) if (
				( ( $datediff < $rule->{ offset } ) and ( $rule->{ offset } >= 0  ) and !$spb )
				or
				( ( $datediff > $rule->{ offset } ) and ( $rule->{ offset } < 0  ) and !$spb )
				or
				( ( $datediff >= 0 ) and $spb )
			);
		}
		
		if ( $rule->{ condition } =~ /^younger_than$/ ) {
			
			my $app = $self->query( 'selallkeys', __LINE__, "
				SELECT birthdate, CURRENT_DATE() as currentdate
				FROM " . $prefix . "AppData WHERE ID = ?", $tables_id->{ AutoAppData }
			)->[ 0 ];
			
			return $self->text_error( 21, $element, undef, $rule->{ offset } ) 
				if ( 
					( $self->age( $app->{ birthdate }, $app->{ currentdate } ) >= $rule->{ offset } )
					and
					!(
						( $element->{ type } eq 'checkbox' )
						and
						( $value eq '' )
					)
				);
		}
		
		if ( $rule->{ condition } =~ /^unique_in_pending$/ ) {
			
			my $isChild = $self->query( 'sel1', __LINE__, "
				SELECT isChild
				FROM AutoToken
				JOIN AutoAppData ON AutoToken.AutoAppDataID = AutoAppData.ID
				WHERE Token = ?", $self->{ token }
			);
			
			if ( !$isChild ) {
		
				my $id_in_db = $self->query( 'sel1', __LINE__, "
					SELECT COUNT(ID) FROM $rule->{table}
					WHERE Status = 1 AND isChild = 0 AND $rule->{name} = ?", $value
				);

				return $self->text_error( 10, $element ) if $id_in_db;
			}
		}
		
		if ( $rule->{ condition } =~ /^free_only_if(_not)?(_eq)?$/ ) {
			
			my ( $not, $eq ) = ( $1, $2 );
	
			my $field_in_db = $self->query( 'sel1', __LINE__, "
				SELECT $rule->{name} FROM $prefix$rule->{table} WHERE ID = ?", 
				$tables_id->{ $prefix.$rule->{table} }
			);
			
			my @err_param = ( $element, undef, $rule->{ error }, undef, $rule->{ full_error } );

			if ( $eq ) {
				
				my $eq_find = 0;
	
				for my $val ( split /;/, $rule->{ values } ) {
				
					s/(^\s+|\s+$)//g for ( $val, $field_in_db );
				
					$eq_find = 1 if lc( $val ) eq lc( $field_in_db );
				}

				return $self->text_error( 14, @err_param ) if !$value and $eq_find and $not;
			
				return $self->text_error( 13, @err_param ) if !$value and !$eq_find and !$not;
			}
			else {
				return $self->text_error( 14, @err_param ) if $field_in_db and !$value and $not;

				return $self->text_error( 13, @err_param ) if !$not and !( $field_in_db or $value );
			}
		}
		
		if ( $rule->{ condition } =~ /^existing_postcode$/ and $value ) {
			
			my ( $postcode_id, undef ) = $self->get_postcode_id( $value );
			
			return $self->text_error( 15, $element ) unless ( $postcode_id );
		}

		if ( $rule->{ condition } =~ /^length_strict$/ and $value ) {
			
			return $self->text_error( 1, $element, undef, undef, undef, $rule->{ full_error } )
				if length( $value ) != $rule->{ length };
		}
		
		if ( $rule->{ condition } =~ /^this_is_email$/ and $value ) {
			
			return $self->text_error( 16, $element )
				if $value !~ /^([a-z0-9_-]+\.)*[a-z0-9_-]+@[a-z0-9_-]+(\.[a-z0-9_-]+)*\.[a-z]{2,6}$/i;
		}
		
		if ( $rule->{ condition } =~ /^email_not_blocked$/ and $value ) {
		
			my ( $center ) = $self->get_app_visa_and_center();

			my $blocket_emails = VCS::Site::autodata::get_blocked_emails();
			
			for my $m ( @$blocket_emails ) {
				
				my %check = map { $_ => 1 } @{ $m->{ emails } };
				next unless exists $check{ $value };
				
				%check = map { $_ => 1 } @{ $m->{ for_centers } };
				next unless exists $check{ $center } or @{ $m->{ for_centers } } == 0;
				
				return $self->text_error( 16 + ( $m->{ show_truth } ? 1 : 0 ) , $element ); 
			};
		}
		
		if ( $rule->{ condition } =~ /^english_only_for_not_rf_citizen$/ and $value ) {
			
			my $citizenship = $self->query( 'sel1', __LINE__, "
				SELECT Citizenship FROM " . $prefix . "AppData WHERE ID = ?", 
				$tables_id->{ $prefix.'AppData' }
			);

			return $self->text_error( 1, $element, undef, undef, undef, $rule->{ full_error } )
				if ( $citizenship == 70 ) and $value =~ /[A-Za-z]/i;
		}

		if ( $rule->{ condition } =~ /^rf_pass_format$/ and $value ) {

			my $citizenship = $self->query( 'sel1', __LINE__, "
				SELECT Citizenship FROM " . $prefix . "AppData WHERE ID = ?", 
				$tables_id->{ $prefix.'AppData' }
			);

			return $self->text_error( undef, $element, undef, undef, undef, $rule->{ full_error } )
				if ( $citizenship == 70 ) and $value !~ /^[0-9]{9}$/i;
		}
		
		if ( $rule->{ condition } =~ /^(more|less)_than$/ ) {
			
			my $type = $1;
			
			my $error_type = ( $type eq 'more' ? 29 : 28 );
			
			return $self->text_error( $error_type, $element, undef, $rule->{ offset } ) 
				if (
					( ( $type eq 'more' ) and ( $value < $rule->{ offset } ) )
					or
				 	( ( $type eq 'less' ) and ( $value > $rule->{ offset } ) )
				);
		}
	}
}

sub get_datediff
# //////////////////////////////////////////////////
{
	my ( $self, $value, $rule, $tables_id, $use_date, $prefix ) = @_;

	return $self->query( 'sel1', __LINE__, "
		SELECT DATEDIFF( ?, $rule->{name} ) FROM $prefix$rule->{table} WHERE ID = ?",
		$value, $tables_id->{ $prefix.$rule->{table} }
		
	) if $use_date;

	return $self->query( 'sel1', __LINE__, "
		SELECT DATEDIFF( ?,  now() )", $value
	);
}

sub get_postcode_id
# //////////////////////////////////////////////////
{
	my ( $self, $value ) = @_;
	
	my ( $index, $city ) = split( /,/, $value );
	
	s/^\s+|\s+$//g for ( $index, $city );
	
	my $postcode_in_db = $self->query( 'sel1', __LINE__, "
		SELECT ID FROM DHL_Cities WHERE PCode = ? AND RName = ?", 
		$index, $city
	);
	
	return ( $postcode_in_db, $city );
}

sub split_and_clarify
# //////////////////////////////////////////////////
{
	my ( $self, $symbols ) = @_;

	$symbols = decode( 'utf8', $symbols );

	my $symbol_err = VCS::Site::autodata::get_symbols_error();
	
	$symbol_err->{ $_ } = $self->lang( $symbol_err->{ $_ } ) for keys %$symbol_err;
		
	$symbol_err->{ '\\\\' } = $symbol_err->{ '\\' };

	my %symbols = map { $_ => 1 } split( //, $symbols );

	my $symbols_clear = {};

	$symbols_clear->{ decode( 'utf8', $symbol_err->{ $_ } ) || $_ } = 1 for ( keys %symbols );
	
	$symbols = join( ', ', sort { $a cmp $b } keys %$symbols_clear );
	
	$symbols =~ s/,\s$//;
	
	$symbols =~ s/'/\\'/g ;

	$symbols = encode( 'utf8', $symbols );

	return $symbols;
}

sub text_error
# //////////////////////////////////////////////////
{
	my ( $self, $error_code, $element, $incorrect_symbols, $relation, $offset, $full_error ) = @_;
	
	my $text = VCS::Site::autodata::get_text_error();

	if ( !defined($element) ) {
		return "|" . $self->lang( $text->[$error_code] );
	}
	
	my $name_of_element = $self->lang(
		$element->{label} ? $element->{label} : ( 
			$element->{label_for} ? $element->{label_for } : $element->{name}
		)
	);

	$relation = $self->lang( $relation );
	
	my $current_error = $self->lang( $full_error ? $full_error : $text->[ $error_code ] );
	
	$current_error =~ s/\[name\]/$name_of_element/;
	
	$current_error =~ s/\[relation\]/$relation/;
	
	$offset = $self->offset_calc( abs $offset ) if $offset;
	
	$current_error =~ s/\[offset\]/$offset/;
	
	$incorrect_symbols = $self->split_and_clarify( $incorrect_symbols ) if $incorrect_symbols;
	
	my $text_error = "$element->{name}|$current_error";

	$text_error .= ": $incorrect_symbols" if $error_code == 2;
	
	return $text_error;	
}

sub offset_calc
# //////////////////////////////////////////////////
{
	my ( $self, $offset ) = @_;

	if ( $offset >= 365 ) {
	
		$offset = floor( $offset / 365 );
		
		$offset =~ /(\d)?(\d)/;
		
		if ( $1 == 1 ) {
			$offset .= $self->lang( " лет" );
		}
		elsif ( $2 == 1 ) {
			$offset .= $self->lang( " год" );
		}
		elsif ( ( $2 >= 2 ) and ( $2 <= 4 ) ) {
			$offset .= $self->lang( " года" );
		}
		else {
			$offset .= $self->lang( " лет" );
		}
	}
	elsif ( $offset >= 60 ) {
	
		$offset = floor( $offset / 30 );
		
		if ( ( $offset >= 2 ) and ( $offset <= 4) ) {
			$offset .= $self->lang( " месяца" );
		}
		else {
			$offset .= $self->lang( " месяцев" );
		}
	}
	else {
		$offset =~ /(\d)?(\d)/;
		
		if ( ( $1 == 1 ) or ( $2 == 0 ) or ( $2 >= 5 ) ) {
			$offset .= $self->lang( " дней" );
		}
		elsif ( ( $2 >= 2 ) and ( $2 <= 4) ) {
			$offset .= $self->lang( " дня" );
		}
		else {
			$offset .= $self->lang( " день" );
		}
	}
	
	return $offset;
}

sub mod_last_change_date
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	return $self->query( 'query', __LINE__, "
		UPDATE AutoToken SET LastChange = now(), LastIP = ? WHERE Token = ?", {},
		$ENV{ HTTP_X_REAL_IP }, $self->{ token }
	);
}

sub get_app_version
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $version = VCS::Site::autodata::get_app_version_list();
	
	return $version->[ 2 ] if $self->param( 'mobile_app' );

	return $version->[ 1 ] if $self->param( 'mobile_ver' );

	return $version->[ 0 ];
}

sub create_new_appointment
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $info_for_contract = "from_db";
	
	my $tables_transfered_id = $self->get_current_table_id();

	my $db_rules = $self->get_content_db_rules();

	my $ver = $self->get_app_version();

	my $data_for_contract = $self->query( 'selallkeys', __LINE__, "
		SELECT CenterID, PersonForAgreements
		FROM AutoToken
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		WHERE Token = ?", $self->{ token }
	)->[ 0 ];
	
	if ( $data_for_contract->{ PersonForAgreements } != -1 ) {
	
		$info_for_contract = $self->query( 'selallkeys', __LINE__, "
			SELECT RLName as LName, RFName as FName, RMName as MName, RPassNum as PassNum, 
			RPWhen as PassDate, RPWhere as PassWhom, AppPhone as Phone, RAddress as Address 
			FROM AutoAppData WHERE ID = ?", $data_for_contract->{ PersonForAgreements }
		)->[ 0 ];
	}

	# my $time_start = $self->time_interval_calculate();
	
	$self->query( 'query', __LINE__, "
		LOCK TABLES
		AutoAppointments READ, Appointments WRITE, AutoAppData READ, AppData WRITE,
		AutoSchengenAppData READ, SchengenAppData WRITE, AutoSpbAlterAppData READ,
		SpbAlterAppData WRITE, AutoSchengenExtData READ, Countries READ"
	);
	
	my $new_appid = $self->create_table(
		'AutoAppointments', 'Appointments', $tables_transfered_id->{ AutoAppointments },
		$db_rules, undef, undef, $info_for_contract, undef, $ver
	);
	
	if ( !$new_appid ) {
	
		$self->query( 'query', __LINE__, "UNLOCK TABLES");
		
		return ( 0, 0, 0, "new appointment error" );
	}

	my $allapp = $self->query( 'selallkeys', __LINE__, "
		SELECT AutoAppData.ID, SchengenAppDataID, AutoSpbAlterAppData.ID as SpbID
		FROM AutoAppData
		JOIN AutoSpbAlterAppData ON AutoSpbAlterAppData.AppDataID = AutoAppData.ID
		WHERE AppID = ?", 
		$tables_transfered_id->{ 'AutoAppointments' }
	);
	
	for my $app ( @$allapp ) {
		
		my $sch_appid = $self->create_table(
			'AutoSchengenAppData', 'SchengenAppData', $app->{ SchengenAppDataID }, $db_rules
		);
		
		my $appid = $self->create_table(
			'AutoAppData', 'AppData', $app->{ ID }, $db_rules, $new_appid, $sch_appid, undef,
			$data_for_contract->{ CenterID }, undef, $app->{ SchengenAppDataID }
		);
		
		$self->create_table(
			'AutoSpbAlterAppData', 'SpbAlterAppData', $app->{ SpbID }, $db_rules, $appid
		);
	}
	
	$self->query( 'query', __LINE__, "UNLOCK TABLES");
	
	# my $milliseconds = $self->time_interval_calculate( $time_start );
	# warn 'lock (line ' . __LINE__ . ") - $milliseconds ms"; 
	
	my $appnum = $self->query( 'sel1', __LINE__, "
		SELECT AppNum FROM Appointments WHERE ID = ?", $new_appid
	);

	return ( $new_appid, scalar @$allapp, $appnum );
}

sub create_table
# //////////////////////////////////////////////////
{
	my ( $self, $autoname, $name, $transfered_id, $db_rules, $new_appid, $sch_appid,
		$info_for_contract, $center, $ver, $sch_auto ) = @_;

	my $hash = $self->get_hash_table( $autoname, 'ID', $transfered_id );

	$hash = $self->mod_hash(
		$hash, $name, $db_rules, $new_appid, $sch_appid, $info_for_contract, $center, $ver, $sch_auto
	);

	return $self->insert_hash_table( $name, $hash );
}

sub mod_hash
# //////////////////////////////////////////////////
{
	my ( $self, $hash, $table_name, $db_rules, $appid, $schappid, $info_for_contract,
		$center, $ver, $sch_auto ) = @_;

	for my $column ( keys %$hash ) {

		if ( $db_rules->{ $table_name }->{ $column } eq 'nope') {
			delete $hash->{ $column };
		}
	};
	
	$hash = $self->visapurpose_assembler( $hash ) if exists $hash->{ VisaPurpose };
	
	$hash = $self->mezzi_assembler( $hash ) if exists $hash->{ Mezzi1 };
	
	if ( $hash->{ ShIndex } ) {
	
		$hash->{ Shipping } = 1;
		$hash->{ ShAddress } = $hash->{ ShIndex } . ", " . $hash->{ ShAddress };
	}
	
	$hash->{ SMS } = 1 if $hash->{ Mobile };
	$hash->{ AppID } = $appid if $appid;
	$hash->{ SchengenAppDataID } = $schappid if $schappid;
	$hash->{ Status } = 1 if exists $hash->{ Status };
	
	if ( $table_name eq 'AppData' ) {
	
		my $schengen_data = $self->get_hash_table( 'AutoSchengenAppData', 'ID', $sch_auto );
		
		if ( $schengen_data->{ HostDataType } eq 'P' ) {
		
			$hash->{ Hotels } = $schengen_data->{ HostDataName } . ' ' . $schengen_data->{ HostDataDenomination };
	
			$hash->{ HotelAdresses } = join( ', ', ($schengen_data->{ HostDataCity },
				$schengen_data->{ HostDataAddress }, $schengen_data->{ HostDataEmail }
			) );
			
			$hash->{ HotelPhone } = $schengen_data->{ HostDataPhoneNumber };
		}
		
		$hash->{ NRes } = ( $hash->{ Citizenship } == 70 ? 0 : 1 ) ;
		
		$hash->{ CountryLive } = ( $hash->{ NRes } ? 1 : 0 );
		
		$hash->{ PrevVisa }--;
		
		if ( VCS::Site::autodata::this_is_spb_center( $center ) ) {
		
			$hash->{ Countries } = 133; 
		
			my $spb_hash = $self->get_hash_table( 'AutoSpbAlterAppData', 'AppDataID', $hash->{ ID } );

			$hash->{ WorkOrg } = join( ', ', (
				$spb_hash->{ JobName }, $spb_hash->{ JobCity }, $spb_hash->{ JobAddr }, $spb_hash->{ JobPhone }
			) );
	
			$hash->{ FullAddress } = join( ', ', (
				$spb_hash->{ HomeCity }, $spb_hash->{ HomeAddr }, $spb_hash->{ HomeEmail }
			) );
					
			$hash->{ HotelAdresses } = join( ', ', (
				$spb_hash->{ HotelPostCode }, $spb_hash->{ HotelCity }, $spb_hash->{ HotelStreet }, $spb_hash->{ HotelHouse }
			) ) unless $hash->{ HotelAdresses };
		
			unless ( $hash->{ Hotels } ) {
			
				$hash->{ Hotels } = $spb_hash->{ HotelName } || '';
			}
		}
		else {
			my $ext_data = $self->get_hash_table( 'AutoSchengenExtData', 'AppDataID', $hash->{ ID } );
	
			$ext_data->{ AppEMail } = $hash->{ AppEMail };
			
			$hash->{ SchengenJSON } = JSON->new->pretty->encode( $ext_data );
			
			$hash->{ FullAddress } = join( ', ', (
				$ext_data->{ HomeCity }, $ext_data->{ HomeAddress },
				$ext_data->{ HomePostal }, $hash->{ AppEMail }
			) );
			
			if ( $ext_data->{ Occupation } eq 'ALTRE PROFESSIONI' ) {
			
				$hash->{ ProfActivity } = $hash->{ ProfActivity } || 'ALTRE PROFESSIONI';
			}
			else {
				$hash->{ ProfActivity } = $ext_data->{ Occupation } || $hash->{ ProfActivity } || 'ALTRE PROFESSIONI';
			}

			$hash->{ WorkOrg } = join( ', ', (
				$ext_data->{ JobName }, $ext_data->{ JobCity }, $ext_data->{ JobAddress },
				$ext_data->{ JobPostal }, $ext_data->{ JobPhone }, $ext_data->{ JobEmail }
			) );
			
			$hash->{ KinderData } = join( ' ', (
				$ext_data->{ MotherName }, $ext_data->{ MotherSurname },
				$self->countries( $ext_data->{ MotherCitizenship } ), ', ',
				$ext_data->{ FatherName }, $ext_data->{ FatherSurname },
				$self->countries( $ext_data->{ FatherCitizenship } ), 
			) );
			
			$hash->{ KinderData } =~ s/^\s*,\s*$//;
			
			$hash->{ ACopmanyPerson } = join( ' ', ( $ext_data->{ InvitName }, $ext_data->{ InvitSurname }	) );

			if ( ( $schengen_data->{ HostDataType } =~ /^(H|S)$/i ) && ( $ext_data->{ HotelAddress } !~ /^\s*$/ ) ) {

				$hash->{ HotelAdresses } = $ext_data->{ HotelCity } if $ext_data->{ HotelCity };
				$hash->{ HotelAdresses } .= ', ' if $ext_data->{ HotelCity } and $ext_data->{ HotelAddress };
				$hash->{ HotelAdresses } .= $ext_data->{ HotelAddress } if $ext_data->{ HotelAddress };
			}
		}
	}

	if ( $table_name eq 'Appointments' ) {
	
		my $appointments = VCS::Docs::appointments->new('VCS::Docs::appointments', $self->{ vars } );
		
		$hash->{ AppNum } = $appointments->getLastAppNum( $self->{ vars }, $hash->{ CenterID }, $hash->{ AppDate } );
		
		$hash->{ OfficeToReceive } = ( $hash->{ OfficeToReceive } == 2 ? 39 : undef ) ;
		
		$hash->{ Notes } = $ver;
		
		if ( ref( $info_for_contract ) eq 'HASH' ) {

			$hash->{ dwhom } = 0;
		
			$hash->{ $_ } = $info_for_contract->{ $_ } for ( keys %$info_for_contract );
		}
		else {
			$hash->{ dwhom } = 1;
		}
	}
	
	delete $hash->{ $_ } for ( 'ShIndex', 'ID', 'FinishedVType', 'FinishedCenter', 'AppEMail',
		'AppDataID', 'PrimetimeAlert', 'Copypasta' );
		
	return $hash;
}

sub countries
# //////////////////////////////////////////////////
{
	my ( $self, $number ) = @_;
	
	return $self->query( 'sel1', __LINE__, "
		SELECT Name FROM Countries WHERE ID = ?", $number
	);
}

sub visapurpose_assembler
# //////////////////////////////////////////////////
{
	my ( $self, $hash ) = @_;

	my $visa = '';

	for ( 1..17 ) {
		$visa .= ( $_ > 1 ? '|' : '' ) . ( $hash->{ VisaPurpose } == $_ ? '1' : '0' );
	};

	$hash->{ VisaPurpose } = $visa;

	return $hash;
}

sub mezzi_assembler
# //////////////////////////////////////////////////
{
	my ( $self, $hash ) = @_;

	my $mezzi = '';
	
	for ( 1..7 ) {

		$mezzi .= ( $_ > 1 ? '|' : '' ) . ( $hash->{ 'Mezzi' . $_ } == 1 ? '1' : '0' );
		
		delete $hash->{ 'Mezzi' . $_ };
	};

	$hash->{ Mezzi } = $mezzi;
	
	return $hash;
}

sub get_content_db_rules
# //////////////////////////////////////////////////
{
	my ( $self, $type ) = @_;
	
	my $content = $self->get_content_rules();
	
	my $db_rules = {};

	for my $page ( keys %$content ) {
		
		next if ( $content->{$page} =~ /\[/ );
		
		for my $element ( @{ $content->{$page} } ) {
		
			next if ( !defined $element->{db}->{table} or $element->{db}->{name} eq 'complex' );
			
			$db_rules->{ $element->{db}->{table} }->{ $element->{db}->{name} } = 
				( $type eq 'check' ? $element->{ complete_check } : $element->{db}->{transfer} );
		}
	}
	return $db_rules;
}

sub get_hash_table
# //////////////////////////////////////////////////
{
	my ( $self, $table_name, $field, $table_id ) = @_;
	
	my $hash_table = $self->query( 'selallkeys', __LINE__, "
		SELECT * FROM $table_name WHERE $field = ?", $table_id
	)->[ 0 ];
	
	return $hash_table;
}

sub insert_hash_table
# //////////////////////////////////////////////////
{
	my ( $self, $table_name, $hash ) = @_;
	
	my @request_values = ();
	
	my $request_columns = join( ',', keys %$hash );

	my $request_values = join( ',', split( //, '?' x keys %$hash ) );
	
	push( @request_values, $hash->{ $_ } ) for keys %$hash;
	
	$self->query( 'query', __LINE__, "
		INSERT INTO $table_name($request_columns) VALUES ($request_values)", {}, @request_values
	);
	
	my $current_id = $self->query( 'sel1', __LINE__, 
		"SELECT last_insert_id()"
	) || 0;

	return $current_id;
}

sub get_pcode
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my $request = $self->param( 'name_startsWith' ) || '';
	my $request_limit = $self->param( 'maxRows' ) || 20;
	my $callback = $self->param( 'callback' ) || "";
	my $center = $self->param( 'center' ) || 1;
	
	$request =~ s/[^0-9A-Za-zАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя]//g;
	
	$_ =~ s/[^0-9]//g for ( $request_limit, $center );
	
	$request_limit = 20 if ( $request_limit eq '' ) or ( $request_limit == 0 ) or ( $request_limit > 100 );

	my $finded_pcode = [];
	
	if ( $request ne '' ) {
	
		my $all_pcode = $self->cached( 'autoform_allpcode' );
		
		if ( !$all_pcode ) {

			$all_pcode = $self->query( 'selallkeys', __LINE__, "
				SELECT DHL_Cities.ID, CName, RName, DHL_Cities.PCode, DHL_Cities.isDefault, DPrice, Branches.ID as Center
				FROM DHL_Cities 
				JOIN DHL_Prices ON DHL_Prices.PCode = DHL_Cities.ID
				JOIN Branches ON DHL_Prices.SenderID = Branches.SenderID
				WHERE DHL_Cities.isDeleted=0 AND RateID = (
					SELECT MAX(ID) FROM DHL_Rates WHERE RDate <= curdate()
				) AND DPrice > 0
				ORDER BY CName, DHL_Cities.isDefault DESC, DHL_Cities.PCode"
			);
			
			$self->cached( 'autoform_allpcode', $all_pcode );
		}
	
		my $limit = 0;

		for ( @$all_pcode ) {
			if (
				( $_->{ Center } == $center ) and (	
					( ( $request =~ /[^0-9]/ ) and ( ( $_->{ CName } =~ /^$request/ or $_->{ RName } =~ /^$request/ ) ) )
					or 	
					( ( $request =~ /^[0-9]+$/ ) and ( $_->{ PCode } =~ /^$request/ ) )
				)	
			) {
				push( @$finded_pcode, $_ );
				
				$limit++;
				
				last if $limit >= $request_limit;
			};
		}

		for my $rk ( @$finded_pcode ) {
		
			$rk->{ CName } = $self->{ vars }->get_system->converttext(
				$rk->{ RName } ne '' ?  $rk->{ RName } : $rk->{ CName } 
			);
		}
	}

	$self->{ vars }->get_system->pheaderJSON( $self->{ vars } );
	
	my $tvars = {
		'alist'		=> $finded_pcode,
		'callback'	=> $callback
	};
	
	$template->process( 'autoform_pcode.tt2', $tvars );
}

sub send_link
# //////////////////////////////////////////////////
{
	my ( $self, $email ) = @_;
	
	my $subject = $self->lang( 'Вы начали запись на подачу документов на визу' );
	
	my $htmls = VCS::Site::autodata::get_link_text();
	
	my $body;
	
	my $token_with_lang = $self->{ token } . '&lang=' . ( $self->{ 'lang' } || 'ru' );
	
	for my $html ( sort { $a <=> $b } keys %$htmls ) {
		
		$htmls->{ $html } =~ s/\[token\]/$token_with_lang/;
		
		$body .= $self->lang( $htmls->{ $html } );
	}
	
	$self->{ vars }->get_system->send_mail( $self->{ vars }, $email, $subject, $body, 1 );

	return $self->query( 'query', __LINE__, "
		UPDATE AutoToken SET LinkSended = now() WHERE Token = ?", {}, $self->{ token }
	);
}

sub send_app_confirm
# //////////////////////////////////////////////////
{
	my ( $self, $appnumber, $appid ) = @_; 
	
	$appnumber = $self->{ vars }->get_system->appnum_to_str( $appnumber );
	
	my $replacer = {
		app_num		=> $appnumber,
		app_id		=> $appid,
		app_token	=> $self->{ token },
	};
	
	my ( $app_list, undef ) = $self->get_list_of_app();
	
	for ( @$app_list ) {
		$replacer->{ app_list } .= $_->{ FName } . ' ' . $_->{ LName } . '<br>';
	}
	$replacer->{ app_list } =~ s/\<br\>$//;
	
	my $lang_local = VCS::Site::autodata::get_appointment_text();
	
	$lang_local->{ $_ } = $self->lang( $lang_local->{ $_ } ) for keys %$lang_local;

	my $subject = $lang_local->{ subject } . ", #$appnumber";
	
	my $conf = $self->{ autoform }->{ confirm };
	
	my $html = $self->get_file_content( $conf->{ tt } );

	my $data = $self->query( 'selallkeys', __LINE__, "
		SELECT EMail, CenterID, TimeslotID, AppDate, dwhom, FName, LName, MName, Category
		FROM Appointments
		JOIN VisaTypes ON Appointments.VType = VisaTypes.ID
		WHERE Appointments.ID = ?
		ORDER BY Appointments.ID DESC LIMIT 1", $appid
	)->[ 0 ];
	
	$replacer->{ branch_addr } = $self->lang( 'Address-' . $data->{ CenterID } );
	
	$replacer->{ branch_addr } = $self->query( 'sel1', __LINE__, "
		SELECT BAddr FROM Branches WHERE ID = ?", $data->{ CenterID }
		
	) if $replacer->{ branch_addr } eq 'Address-' . $data->{ CenterID };

	
	$replacer->{ branch_addr } = $self->{ vars }->get_system->converttext( $replacer->{ branch_addr } );
	
	$replacer->{ branch_addr } =~ s/_?(x005F|x000D)_?//g;
	
	my ( $tstart, $tend ) = $self->query( 'sel1', __LINE__, "
		SELECT TStart, TEnd FROM TimeData WHERE SlotID = ?", $data->{ TimeslotID }
	);
		
	my @date_sp = split( /\-/, $data->{ AppDate } );

	my $months = VCS::Site::autodata::get_months();

	$replacer->{ date_time } = 
		$date_sp[ 2 ] . ' ' . $self->lang( $months->{ $date_sp[ 1 ] } ) . ' ' . $date_sp[ 0 ] . ', ' . 
		$self->{ vars }->get_system->time_to_str( $tstart );
	
	$replacer->{ app_person } = ( !$data->{ dwhom } ? '<b>' . $lang_local->{ pers } .'</b>' : 
		$lang_local->{ by_the_doc } . ' <b>' . 
		$data->{ LName } . ' ' . $data->{ FName } . ' ' .  $data->{ MName } . '</b>' 
	);
	
	my $spb_center = ( VCS::Site::autodata::this_is_spb_center( $data->{ CenterID } ) ? "spb_" : "" );
	
	$replacer->{ link_image } = $conf->{ link_image };
	$replacer->{ link_site } = $conf->{ link_site };
	$replacer->{ app_email } = $conf->{ $spb_center . "html_email" };
	$replacer->{ app_website } = $conf->{ html_website };
	
	my $elements = VCS::Site::autodata::get_html_elements();
	my $edit_app_button = ( $data->{ Category } eq "C" ? $elements->{ edit_app_button } : "" );
	
	$html =~ s/\[%edit_app_button%\]/$edit_app_button/;

	for ( keys %$replacer ) {
		$html =~ s/\[%$_%\]/$replacer->{ $_ }/g;
	}
	
	for ( keys %$lang_local ) {
		$html =~ s/\[%$_%\]/$lang_local->{ $_ }/g;
	};
	
	$self->{ vars }->{'session'}->{'login'} = 'website';
	
	my $agreem = $self->get_file_content( $conf->{ pers_data } );
	
	my $atach = {
		0 => {
			'filename'	=> "Appointment.pdf", 
			'data'		=> VCS::Docs::appointments->new( 'VCS::Docs::appointments', $self->{ vars } )->createPDF( $appid ), 
			'ContentType'	=> 'application/pdf',
		},
		1 => {
			'filename'	=> "Согласие.pdf", 
			'data'		=> $agreem, 
			'ContentType'	=> 'application/pdf',
		}
	};
	
	$self->{ vars }->get_system->send_mail( $self->{ vars }, $data->{ EMail }, $subject, $html, 1, $atach );
}

sub get_file_content
# //////////////////////////////////////////////////
{
	my $self = shift;

	undef $/;
	
	open( my $file, '<', shift ) or return;
	
	my $content = <$file>;
	
	close $file;
	
	return $content;
}

sub age
# //////////////////////////////////////////////////
{
	my ( $self, $birth_date, $current_date ) = @_; 
	
	return 99 if ( 
		$birth_date !~ /^\d{4}\-\d{2}\-\d{2}$/
		or 
		$current_date !~ /^\d{4}\-\d{2}\-\d{2}$/
	);
	
	my $age_free_days = $self->{ vars }->getConfig( 'general' )->{ age_free_days } + 0;

	my ( $birth_year, $birth_month, $birth_day ) = split( /\-/, $birth_date ); 
	
	my ( $year, $month, $day ) = Add_Delta_Days( split( /\-/, $current_date ), $age_free_days );
	
	my $age = $year - $birth_year;
	
	$age-- unless sprintf( "%02d%02d", $month, $day ) >= sprintf( "%02d%02d", $birth_month, $birth_day );
		
	$age = 0 if $age < 0;

	return $age;
}

sub lang
# //////////////////////////////////////////////////
{
	my ( $self, $text, $lang_param ) = @_;

	return if !$text;

	my $vocabulary = $self->{ vars }->{ 'VCS::Resources' }->{ 'list' };

	my $lang = ( $lang_param ? $lang_param : $self->{ 'lang' } );

	if ( ref( $text ) ne 'HASH' ) {
	
		return $vocabulary->{ $text }->{ $lang } || $text;
	}
	
	for ( keys %$text ) {

		next if !$text->{ $_ };
	
		$text->{ $_ } = $vocabulary->{ $text->{ $_ } }->{ $lang } || $text->{ $_ };
	}
	
	return $text;
}

sub cached
# //////////////////////////////////////////////////
{
	my ( $self, $name, $save ) = @_;
	
	return $self->{ vars }->get_memd->set(
		$name, $save, $self->{ autoform }->{ memcached }->{ memcached_exptime }
	) if $save;
	
	return $self->{ vars }->get_memd->get( $name );
}

sub check_passnum_already_in_pending
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $pass_list = [];
	
	my $pass_double = undef;
	
	my $pass_doubles = {};

	my $app_data = $self->query( 'selallkeys', __LINE__, "
		SELECT AutoAppData.PassNum, isChild
		FROM AutoToken
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
		WHERE Token = ?", $self->{ token }
	);

	for ( @$app_data ) {
	
		unless ( $_->{ isChild } ) {
		
			push( @$pass_list, $_->{ PassNum } );
			
			$pass_doubles->{ $_->{ PassNum } } += 1;
		}
	}
	
	for ( keys %$pass_doubles ) {
			
		$pass_double = $_ if $pass_doubles->{ $_ } > 1;
	}
	
	my $pass_line = join( "','", @$pass_list );

	my $pass_already = $self->query( 'sel1', __LINE__, "
		SELECT COUNT(ID) FROM AppData
		WHERE PassNum IN ('$pass_line') AND Status = 1 AND isChild = 0"
	);

	$pass_already = undef unless $pass_already;

	return ( $pass_already, $pass_list, $pass_double );
}

sub this_is_inner_ip
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my %inner_ip_list_h = map { $_ => 1 } @{ VCS::Site::autodata::get_inner_ip() };

	return 1 if $inner_ip_list_h{ $ENV{ HTTP_X_REAL_IP } }; 
	
	return 0;
}	
	
sub mutex_fail
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app_status = $self->check_all_app_finished_and_not_empty();
	
	return $app_status if $app_status;
	
	my $fail_in_data = $self->check_data_from_db();
	
	return 25 if $fail_in_data;
	
	my ( $pass_already, $pass_list, $pass_double ) = $self->check_passnum_already_in_pending();

	return 27 if $pass_double;
	
	return 24 if $pass_already;
		
	for ( @$pass_list ) {
	
		return 24 unless $self->{ vars }->get_memd->add(
			"autoform_pass$_", $_, $self->{ autoform }->{ memcached }->{ mutex_exptime }
		);
	}
}

sub time_interval_calculate
# //////////////////////////////////////////////////
{
	my ( $self, $interval_start ) = @_;
	
	return [ gettimeofday() ] unless $interval_start;
	
	return tv_interval( $interval_start ) * 1000;
}

sub date_format
# //////////////////////////////////////////////////
{
	my ( $self, $date, $format ) = @_;
	
	$date =~ s/^([0-9]{2})\.([0-9]{2})\.([0-9]{4})$/$3-$2-$1/;
	
	return $date if $format eq 'to_iso';
	
	$date =~ s/^([0-9]{4})\-([0-9]{2})\-([0-9]{2})$/$3.$2.$1/;
	
	return $date;
}

sub redirect
# //////////////////////////////////////////////////
{
	my ( $self, $target ) = @_;
	
	my $token = ( $target eq 'current' ? $self->{ token } : $target );
	
	my $param = ( $token ? '?t=' . $token : '' );
	
	$param .= ( $self->{ lang } ? ( $param ? '&' : '?' ) . 'lang=' . $self->{ lang } : '' );
	
	$self->{ vars }->get_system->redirect( $self->{ autoform }->{ paths }->{ addr } . $param );
}

sub param
# //////////////////////////////////////////////////
{
	my ( $self, $param_name ) = @_;
	
	my $param = $self->{ vars }->getparam( $param_name );

	return $param unless $self->{ autoform }->{ general }->{ anti_injection };

	return if !$param;
	
	my $check_list = {
	
		'js-injection' => [
		
			'<\s*script',
			'<\s*img\s+.*src\s*=',
		],
		
		'sql-injection' => [
		
			'(\d+)\s*(\'|")\s*(AND|OR)\s*(\d+)\s*=\s*\4',
			'\s*\d+\s*(\'|")\s*;\s*(select|update|drop|insert)',
			'(^|\s)union\s+select\s',
		],
		
		'sql-query' => [
		
			'(^|\s)select(\s.*\s|\*)from\s',
			'update\s+(low_priority|ignore)?.*\sset\s',
			'insert\s+(low_priority|delayed|ignore|into)?.*\s(set|values)',
			'drop\s+(low_priority|quick)?\s*(table|database)\s',
			'delete\s+(low_priority|quick)?\s*from\s',
			'alter\s+(ignore\s+)?table\s.*\s(add|drop|change|alter)\s',
		],
	};

	for my $type ( keys %$check_list ) {
	
		for ( @{ $check_list->{ $type } } ) {
	
			if ( $param =~ /$_/i ) {
				
				$self->query( 'query', __LINE__, "
					INSERT INTO SoftBan (IP, BanDate, Reason) VALUES (?, now(), ?)", {},
					$ENV{ HTTP_X_REAL_IP }, $type . ': ' . $param
				);
				
				$self->{ vars }->get_system->redirect( "/vcs/block.htm" );
			}
		}
	}
	
	return $param;
}

sub query
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $type = shift;
	my $line = shift;
	
	my $return;
	
	# my $time_start = $self->time_interval_calculate();

	$return = $self->{ vars }->db->selall( @_ ) if $type eq 'selall';
	
	$return = $self->{ vars }->db->selallkeys( @_ ) if $type eq 'selallkeys';
	
	$return = $self->{ vars }->db->query( @_ ) if $type eq 'query';
	
	my @result = $self->{ vars }->db->sel1( @_ ) if $type eq 'sel1';
	
	# my $milliseconds = $self->time_interval_calculate( $time_start );
	# warn Dumper( \@_ );
	# warn "sql (line $line) - $milliseconds ms" if $milliseconds > 1; 
	
	return ( wantarray ? @result : $result[ 0 ] ) if $type eq 'sel1';
	
	return $return;
}

1;
