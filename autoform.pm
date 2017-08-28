package VCS::Site::autoform;
use strict;

use VCS::Vars;
use VCS::Site::autodata;
use VCS::Site::autoselftest;

use Data::Dumper;
use Date::Calc qw/Add_Delta_Days/;
use Time::HiRes qw[gettimeofday tv_interval];
use POSIX;
use JSON;
use HTTP::Tiny;

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
	my ( $self, $task, $id, $template ) = @_;

	my $vars = $self->{'VCS::Vars'};
	
	$self->{ autoform } = VCS::Site::autodata::get_settings();

    	my $dispathcher = {
    		'index' => \&autoform,
		'selftest' => \&autoselftest,
		'findpcode' => \&find_pcode,
    	};
    	
    	my $disp_link = $dispathcher->{ $id };

    	$vars->get_system->redirect( $vars->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr } . 'index.htm' )
    		if !$disp_link;
	
    	&{$disp_link}( $self, $task, $id, $template );
    	
	return 1;
}

sub get_content_rules
# //////////////////////////////////////////////////
{
	my ( $self, $current_page, $full, $token, $need_to_init ) = @_;
	
	my $content = ( exists $self->{ this_is_self_testing } ?
		VCS::Site::autoselftest::get_content_rules_hash( $self ) :
		VCS::Site::autodata::get_content_rules_hash( $self )
	);
	
	my $keys_in_current_page = {};
	my $new_content = {};
	
	for my $page ( sort { $content->{$a}->[0]->{page_ord} <=> $content->{$b}->[0]->{page_ord} } keys %$content ) {
		
		my $page_ord = $content->{$page}->[0]->{page_ord};
		
		$new_content->{ $page_ord } = $content->{ $page };
		
		if ( $current_page == $page_ord ) {
			for ( 'persons_in_page', 'collect_date', 'param', 'ussr_or_rf_first' ) {
				$keys_in_current_page->{ $_ } = ( $new_content->{ $page_ord }->[0]->{ $_ } ? 1 : 0 );
			}
		}
		
		if ( !$full ) {
			if ( $content->{ $page }->[0]->{replacer} ) {
				$new_content->{ $page_ord } = $content->{ $page }->[0]->{replacer};
			} else {
				delete $new_content->{ $page_ord }->[0];
				@{ $new_content->{ $page_ord } } = grep defined, @{ $new_content->{ $page_ord } };
			}
		} else {
			$new_content->{ $page_ord }->[0]->{page_name} = $page;
		}
	}

	$content = ( $need_to_init ? $self->init_add_param( $new_content, $token, $keys_in_current_page ) : $new_content );
	
	return $content if !$current_page;
	
	return scalar( keys %$content ) if $current_page =~ /^length$/i;
	
	return $content->{ $current_page };
}

sub autoform
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my $vars = $self->{ 'VCS::Vars' };
	my ( $page_content, $template_file, $title, $progress, $appid, $last_error );
	my $step = 0;
	my $special = {};
	my $javascript_check = 1;
	
	my $token = $self->get_token_and_create_new_form_if_need();
	
	$self->{'lang'} = 'en' if $vars->getparam( 'lang' ) =~ /^en$/i ;

	if ( $token =~ /^\d\d$/ ) {
	
		( $title, $page_content, $template_file ) = $self->get_page_error( $token );
	}
	elsif ( $vars->getparam( 'script' ) ) {
	
		( $title, $page_content, $template_file ) = $self->get_page_error( 0 );
		
		$javascript_check = 0;
	}
	else {
		( $step, $title, $page_content, $last_error, $template_file, $special, $progress, $appid ) = 
			$self->get_autoform_content( $token );
	}

	my ( $last_error_name, $last_error_text ) = split /\|/, $last_error;
	
	my ( $appinfo_for_timeslots, $map_in_page );

	if ( ( ref( $special->{ timeslots } ) eq 'ARRAY' ) and ( @{ $special->{ timeslots } } > 0 ) ) {
		$appinfo_for_timeslots = $self->get_same_info_for_timeslots( $token );
	}

	if ( ( ref( $special->{ with_map } ) eq 'ARRAY' ) and ( @{ $special->{ with_map } } > 0 ) ) {
		$map_in_page = $self->get_geo_info( $token );
	}

	$vars->get_system->pheader( $vars );
	
	my $tvars = {
		'langreq' => sub { return $vars->getLangSesVar(@_) },
		'title' => $title,
		'content_text' => $page_content,
		'token' => $token,
		'appid' => $appid,
		'step' => $step,
		'min_step' => 1,
		'max_step' => $self->get_content_rules('length'),
		'max_applicants' => $self->{ autoform }->{ general }->{ max_applicants },
		'addr' => $vars->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr },
		'last_error_name' => $last_error_name,
		'last_error_text' => $last_error_text,
		'special' => $special,
		'vcs_tools' => $self->{ autoform }->{ paths }->{ addr_vcs },
		'appinfo' => $appinfo_for_timeslots,
		'progress' => $progress,
		'lang_in_link' => $self->{ lang },
		'javascript_check' => $javascript_check,
		'map_in_page' => $map_in_page,
	};
	$template->process( $template_file, $tvars );
}

sub autoselftest
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my $vars = $self->{ 'VCS::Vars' };
	
	my $self_test_result = VCS::Site::autoselftest::selftest( $self );
	
	$vars->get_system->pheader( $vars );
	
	print $self_test_result;
}

sub get_same_info_for_timeslots
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my $appinfo = {};

	( $appinfo->{ persons }, $appinfo->{ center }, $appinfo->{ fdate } ) = $self->query( 'sel1', __LINE__, "
		SELECT count(AutoAppData.ID), CenterID, SDate
		FROM AutoToken 
		JOIN AutoAppData ON AutoToken.AutoAppID = AutoAppData.AppID
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		WHERE Token = ?", $token
	);
	
	$appinfo->{ fdate } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;

	return $appinfo;
}

sub get_geo_info
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my ( $center, $addr ) = $self->query( 'sel1', __LINE__, "
		SELECT CenterID, BAddr FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN Branches ON AutoAppointments.CenterID = Branches.ID
		WHERE Token = ?", $token
	);

	my $branches = VCS::Site::autodata::get_geo_branches();
	
	$addr =~ s/\r?\n/<br>/g;
	
	$branches->{ $center }->[ 2 ] = $addr;

	return $branches->{ $center };
}

sub init_add_param
# //////////////////////////////////////////////////
{
	my ( $self, $content_rules, $token, $keys_in_current_page ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $info_from_db = undef;
	my $ussr_first = 0;
	
	if ( $keys_in_current_page->{ param } ) {
	
		$info_from_db = $self->cached( 'autoform_addparam' );
		
		if ( !$info_from_db ) {
			my $info_from_sql = {
				'[centers_from_db]' => 'SELECT ID, BName FROM Branches WHERE Display = 1 AND isDeleted = 0',
				'[visas_from_db]' => 'SELECT ID, VName FROM VisaTypes WHERE OnSite = 1',
				'[brh_countries]' => 'SELECT ID, EnglishName FROM Countries ORDER BY EnglishName',
				'[citizenship_countries]' => 'SELECT ID, EnglishName FROM Countries WHERE Ex=0 ORDER BY EnglishName',
				'[prevcitizenship_countries]' => 'SELECT ID, EnglishName FROM Countries',
				'[first_countries]' => 'SELECT ID, Name FROM Countries WHERE MemberOfEU=1 order by EnglishName',
				'[schengen_provincies]' => 'SELECT ID, Name FROM SchengenProvinces',
				'[eu_countries]' => 'SELECT ID, Name FROM Countries WHERE MemberOfEU=1 order by EnglishName',
			};
			
			for ( keys %$info_from_sql ) {
				$info_from_db->{ $_ } = $self->query( 'selall', __LINE__, $info_from_sql->{ $_ } );
			}
			
			my $add_eu_countries = [
				[ 37, "BULGARIA" ],
				[ 47, "CIPRO" ],
				[ 104, "IRLANDA" ],
				[ 201, "REGNO UNITO DI GRAN BRETAGNA E DI IRLANDA DEL NORD" ],
				[ 215, "ROMANIA" ],
			];

			push ( @{ $info_from_db->{ '[eu_countries]' } }, $_ ) for @$add_eu_countries;

			$vars->get_memd->set('autoform_addparam', $info_from_db, 
				$self->{ autoform }->{ memcached }->{ memcached_exptime } );
		}
	}

	if ( $token and $keys_in_current_page->{ persons_in_page } ) {

		my $app_person_in_app = $self->query( 'selallkeys', __LINE__, "
			SELECT AutoAppData.ID as ID, CONCAT(RFName, ' ', RLName, ', ', BirthDate) as person,
			birthdate, CURRENT_DATE() as currentdate
			FROM AutoToken 
			JOIN AutoAppData ON AutoToken.AutoAppID = AutoAppData.AppID
			WHERE AutoToken.Token = ?", $token
		);

		for my $person ( @$app_person_in_app ) {
		
			$person->{ person } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
			
			push ( @{ $info_from_db->{ '[persons_in_app_for_insurance]' } },
				[ $person->{ ID }, $person->{ person } ] );

			next if ( $self->age( $person->{ birthdate }, $person->{ currentdate } ) < 
					$self->{ autoform }->{ age }->{ age_for_agreements } );

			push ( @{ $info_from_db->{ '[persons_in_app]' } }, [ $person->{ ID }, $person->{ person } ] );
		};
			
		push @{ $info_from_db->{ '[persons_in_app]' } }, [ 0, $self->lang('на доверенное лицо') ];
	}
	
	if ( $token and $keys_in_current_page->{ ussr_or_rf_first } ) {
	
		my $birthdate = $self->query( 'sel1', __LINE__, "
			SELECT DATEDIFF(AutoAppData.BirthDate, '1991-12-26')
			FROM AutoAppData JOIN AutoToken ON AutoAppData.ID = AutoToken.AutoAppDataID 
			WHERE AutoToken.Token = ?", $token
		);
	
		$ussr_first = 1 if $birthdate < 0;
	}

	if ( $keys_in_current_page->{ param } or $keys_in_current_page->{ collect_date } or 
		$keys_in_current_page->{ persons_in_page } or $keys_in_current_page->{ ussr_or_rf_first } ) {

		for my $page ( keys %$content_rules ) {
		
			next if $content_rules->{$page} =~ /^\[/;
			
			for my $element ( @{ $content_rules->{$page} } ) {

				if ( ref( $element->{ param } ) ne 'HASH' ) {
				
					my $param_array = $info_from_db->{ $element->{ param } };
					$element->{ param } = {};
					$element->{ param }->{ $_->[0] } = $_->[1] for ( @$param_array );
				}
				
				if ( exists $element->{ check_logic } and $token and $keys_in_current_page->{ collect_date } ) {
					for ( @{ $element->{ check_logic } } ) {
						$_->{ offset } = $self->get_collect_date( $token )	
							if $_->{ offset } =~ /\[collect_date_offset\]/;
					}
				}
				
				if ( $element->{ name } =~ /^(brhcountry|prev_сitizenship)$/ ) {
					$element->{ first_elements } = '272, 70' if $ussr_first;
				}
			}
		}
	}

	return $content_rules;
}	

sub get_collect_date
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;

	my $vars = $self->{ 'VCS::Vars' };
	
	my $collect_dates = $self->cached( 'autoform_collectdates' );
		
	if ( !$collect_dates ) {
	
		my $collect_dates_array = $self->query( 'selallkeys', __LINE__, "
			SELECT ID, CollectDate, cdSimpl, cdUrgent, cdCatD from Branches where isDeleted = 0 and Display = 1"
		);
		$collect_dates = {};
		
		for my $date ( @$collect_dates_array ) {

			$collect_dates->{ $date->{ ID } }->{ $_ } = $date->{ $_ }
				for ( 'CollectDate', 'cdSimpl', 'cdUrgent', 'cdCatD' );
		}

		$vars->get_memd->set('autoform_collectdates', $collect_dates, 
			$self->{ autoform }->{ memcached }->{ memcached_exptime } );
	}
	
	my ( $center_id, $category ) = $self->query( 'sel1', __LINE__, "
		SELECT CenterID, Category FROM AutoAppointments
		JOIN AutoToken ON AutoAppointments.ID = AutoToken.AutoAppID
		JOIN VisaTypes ON AutoAppointments.VType = VisaTypes.ID
		WHERE Token = ?", $token
	);

	$collect_dates = $collect_dates->{ $center_id };

	return 0 unless $collect_dates->{ CollectDate };
	
	return $collect_dates->{ cdCatD } if $category eq 'D';
	
	return ( $collect_dates->{ cdUrgent } ? $collect_dates->{ cdUrgent } : $collect_dates->{ cdSimpl } );
}

sub get_token_and_create_new_form_if_need
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $token = lc( $vars->getparam('t') );
	
	$token =~ s/[^a-z0-9]//g;

	if ( $token eq '' ) {
		$token = $self->save_new_token_in_db( $self->token_generation() );
	}
	else {
		my ( $token_exist, $finished ) = $self->query( 'sel1', __LINE__, "
			SELECT ID, Finished FROM AutoToken WHERE Token = ?", $token
		);
	
		return '01' if ( length($token) != 64 ) or ( $token !~ /^t/i );
		
		return '02' if !$token_exist;
		
		return '03' if $finished;
	}
	
	return $token;
}

sub create_clear_form
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	$self->query( 'query', __LINE__, "
		INSERT INTO AutoAppointments (RDate, Login, Draft) VALUES (now(), ?, 1)", {}, 
		$vars->get_session->{'login'}
	);
		
	my $app_id = $self->query( 'sel1', __LINE__, "
		SELECT last_insert_id()"
	) || 0;
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET AutoAppID = ?, StartDate = now() WHERE Token = ?", {}, 
		$app_id, $token
	);
}
	
sub save_new_token_in_db
# //////////////////////////////////////////////////
{	
	my ( $self, $token ) = @_;

	$self->query( 'query', __LINE__, "
		INSERT INTO AutoToken (Token, AutoAppID, AutoAppDataID, 
		AutoSchengenAppDataID, Step, LastError, Finished, Draft) 
		VALUES (?, 0, 0, 0, 1, '', 0, 0)", {}, $token
	);
	
	return $token;
}

sub token_generation
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $token_existing = 1;
	my $token = 't';
	
	do {
		my @alph = split //, '0123456789abcdefghigklmnopqrstuvwxyz';
		
		for ( 1..63 ) {
			$token .= @alph[ int( rand( 35 ) ) ];
		}
		$token_existing = $self->query( 'sel1', __LINE__, "
			SELECT ID FROM AutoToken WHERE Token = ?", $token
		) || 0;
			
	} while ( $token_existing );
	
	return $token;
}

sub get_page_error
# //////////////////////////////////////////////////
{
	my ( $self, $error_num ) = @_;
	
	my $error_type = [
		'для правильной работы анкеты необходимо, чтобы в браузере был включён javascript',
		'неправильный токен',
		'такого токена не существует',
		'запись уже завершена',
	];
	
	my $title = $self->lang( 'ошибка: ' ) . $self->lang( $error_type->[ $error_num ] );
	
	return ( "<center>$title</center>", undef, 'autoform.tt2' );
}

sub get_autoform_content
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my $last_error = '';
	my $title;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my ( $step, $app_id ) = $self->query( 'sel1', __LINE__, "
		SELECT Step, AutoAppID FROM AutoToken WHERE Token = ?", $token
	);

	my $action = lc( $vars->getparam('action') );
	$action =~ s/[^a-z]//g;
	
	my $appdata_id = $vars->getparam('person');
	$appdata_id =~ s/[^0-9]//g;
	
	my $appnum = undef;
	my $appid = undef;

	if ( ( $action eq 'back' ) and ( $step > 1 ) ) {
		$step = $self->get_back( $step, $token );
	}

	if ( ( $action eq 'forward' ) and ( $step < $self->get_content_rules('length') ) ) {
		( $step, $last_error, $appnum, $appid ) = $self->get_forward( $step, $token );
	}

	if ( ( $action eq 'edit' ) and $appdata_id ) {
		$step = $self->get_edit( $step, $appdata_id, $token );
	}
	
	if ( ( $action eq 'delapp' ) and $appdata_id ) {
		$self->get_delete( $appdata_id, $token );
	}
	
	if ( $action eq 'addapp' ) {
		$step = $self->get_add( $app_id, $token );
	}
	
	if ( $action eq 'tofinish' ) {
		my $app_status = $self->check_all_app_finished_and_not_empty( $token );
		
		if ( $app_status == 0 ) {
			$step = $self->set_step_by_content( $token, '[app_finish]', 'next' );
		} else {
			$step = $self->set_step_by_content( $token, '[list_of_applicants]' );
			
			$last_error = $self->text_error( ( $app_status == 1 ? 4 : 5 ), { 'name' => 'applist' }, undef);
		}
	}
	
	if ( $action eq 'tolist' ) {
		$step = $self->set_step_by_content( $token, '[list_of_applicants]' );
	}
	
	my $page = $self->get_content_rules( $step, 'full', $token );

	my $back = ( $action eq 'back' ? 'back' : '' );
	
	if ( !$last_error and ( exists $page->[0]->{relation} ) ) {
		( $step, $page ) = $self->check_relation( $step, $page, $token, $back );
	}
	
	if ( $page !~ /\[/ ) { 
		$title = $self->lang( $page->[0]->{ page_name } );
	}

	my ( $content, $template ) = $self->get_html_page( $step, $token, $appnum );

	my $progress = $self->get_progressbar( $page );
	
	my ( $special ) = $self->get_specials_of_element( $step );
	
	return ( $step, $title, $content, $last_error, $template, $special, $progress, $appid );
}

sub check_relation
# //////////////////////////////////////////////////
{
	my ( $self, $step, $page, $token, $moonwalk ) = @_;

	my $skip_this_page;
	my $at_least_one_page_skipped = 0;
	
	my $current_table_id = $self->get_current_table_id( $token ); 
	
	do {
		$skip_this_page = 0;

		for my $relation ( keys %{ $page->[0]->{ relation } } ) {
			$skip_this_page += $self->skip_page_by_relation( $relation, $page->[0]->{ relation }->{ $relation }, $token );
		}
		
		if ( $skip_this_page ) {
		
			$at_least_one_page_skipped = 1;
			
			if ( $moonwalk ) {
				$step--;
			} else {
				$step++;
			}
			
			$page = $self->get_content_rules( $step, 'full' );
			
			my $current_table_id = $self->get_current_table_id( $token ); 
			
			if ( $step == $self->get_step_by_content($token, '[app_finish]') ) {
				$self->set_current_app_finished( $current_table_id->{ AutoAppData } );
			}
		}
	
	} while ( $skip_this_page );

	if ( $at_least_one_page_skipped ) {
	
		$self->query( 'query', __LINE__, "
			UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, $step, $token
		);
	}

	return ( $step, $page );
}

sub skip_page_by_relation
# //////////////////////////////////////////////////
{
	my ( $self, $condition, $relation, $token ) = @_;

	my $current_table_id = $self->get_current_table_id( $token ); 
	
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

	my $skip_it = 0;
	
	my %relation = map { $_ => 1 } split /,/, $relation; 

	if ( $condition eq 'only_if' ) {
		$skip_it = 1 unless exists $relation{ $value };
	}
	
	if ( $condition eq 'only_if_not' ) {
		$skip_it = 1 if exists $relation{ $value };
	}

	return $skip_it;
}

sub get_forward
# //////////////////////////////////////////////////
{
	my ( $self, $step, $token ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $current_table_id = $self->get_current_table_id( $token );
	
	if ( !$current_table_id->{AutoAppointments} ) {
		$self->create_clear_form( $token, $vars->getparam( 'center' ) );
		$current_table_id = $self->get_current_table_id( $token );
	}
	
	$self->save_data_from_form( $step, $current_table_id );
	$self->mod_last_change_date( $token );
	
	my $last_error = $self->check_data_from_form( $token, $step );

	if ( $last_error ) {
		my @last_error = split /\|/, $last_error;

		$self->query( 'query', __LINE__, "
			UPDATE AutoToken SET Step = ?, LastError = ? WHERE Token = ?", {}, 
			$step, "$last_error[1] ($last_error[0], step $step)", $token
		);
	} else {
		$step++;
			
		$self->query( 'query', __LINE__, "
			UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, $step, $token
		);
	}

	my $appnum = undef;
	my $appid = undef;
	
	if ( !$last_error and ( $step == $self->get_step_by_content($token, '[app_finish]') ) ) {
		$self->set_current_app_finished( $current_table_id->{ AutoAppData } );
	}

	if ( $step >= $self->get_content_rules( 'length' ) ) {
		( $appid, $appnum ) = $self->set_appointment_finished( $token );
	}

	return ( $step, $last_error, $appnum, $appid );
}

sub set_current_app_finished
# //////////////////////////////////////////////////
{
	my ( $self, $appdata_id ) = @_;
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoAppData SET Finished = 1 WHERE ID = ?", {}, $appdata_id
	);
}

sub set_appointment_finished
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my $this_is_draft = $self->query( 'sel1', __LINE__, "
		SELECT Draft FROM AutoToken WHERE Token = ?", $token
	);

	if ( $this_is_draft ) {
		$self->query( 'query', __LINE__, "
			UPDATE AutoToken SET EndDate = now(), Step = 1 WHERE Token = ?", {}, $token
		);
	
		return ( 0, 'draft_app_num' );
	}
	
	my ( $new_appid, $ncount, $appnum ) = $self->create_new_appointment( $token );
	
	$appnum =~ s!(\d{3})(\d{4})(\d{2})(\d{2})(\d{4})!$1/$2/$3/$4/$5!;

	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET EndDate = now(), Finished = 1, CreatedApp = ? WHERE Token = ?", {}, 
		$new_appid, $token
	);

	$self->query( 'query', __LINE__, "
		UPDATE Appointments SET RDate = now(), Login = 'website_newform', Draft = 0, NCount = ? 
		WHERE ID = ?", {}, $ncount, $new_appid
	);
		
	return ( $new_appid, $appnum );
}

sub get_step_by_content
# //////////////////////////////////////////////////
{
	my ( $self, $token, $content, $next ) = @_;
	
	my $page_content = $self->get_content_rules();
	my $step;

	for my $page ( keys %$page_content ) {
		$step = $page if ( $page_content->{ $page } eq $content );
	}

	$step++ if $next;

	return $step;
}

sub set_step_by_content
# //////////////////////////////////////////////////
{
	my ( $self, $token, $content, $next ) = @_;

	my $step = $self->get_step_by_content( $token, $content, $next );

	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, $step, $token
	);

	return $step;
}

sub get_edit
# //////////////////////////////////////////////////
{
	my ( $self, $step, $appdata_id, $token ) = @_;
	
	if ( $self->check_existing_id_in_token( $appdata_id, $token ) ) {
		
		$step = $self->get_step_by_content($token, '[list_of_applicants]', 'next');;
		
		my $sch_id = $self->query( 'sel1', __LINE__, "
			SELECT SchengenAppDataID FROM AutoAppData WHERE ID = ?", $appdata_id
		);
		
		$self->query( 'query', __LINE__, "
			UPDATE AutoToken SET Step = ?, AutoAppDataID = ?, AutoSchengenAppDataID = ? WHERE Token = ?", {}, 
			$step, $appdata_id, $sch_id, $token
		);
		
		$self->query( 'query', __LINE__, "
			UPDATE AutoAppData SET Finished = 0 WHERE ID = ?", {}, $appdata_id
		);
		
		$self->mod_last_change_date( $token );
	}
	
	return $step;
}

sub get_delete
# //////////////////////////////////////////////////
{
	my ( $self, $appdata_id, $token ) = @_;
	
	if ( $self->check_existing_id_in_token( $appdata_id, $token ) ) {
	
		my $sch_id = $self->query( 'sel1', __LINE__, "
			SELECT SchengenAppDataID FROM AutoAppData WHERE ID = ?", $appdata_id
		);
	
		$self->query( 'query', __LINE__, "
			DELETE FROM AutoAppData WHERE ID = ?", {}, $appdata_id
		);
		
		$self->query( 'query', __LINE__, "
			DELETE FROM AutoSchengenAppData WHERE ID = ?", {}, $sch_id
		);

		$self->mod_last_change_date( $token );
	}
}

sub check_existing_id_in_token
# //////////////////////////////////////////////////
{
	my ( $self, $appdata_id, $token ) = @_;
	
	my $exist = 0;
	
	my $list_of_app_in_token = $self->query( 'selallkeys', __LINE__, "
		SELECT AutoAppData.ID FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
		WHERE Token = ?", $token
	);
		
	for my $app ( @$list_of_app_in_token ) {
		$exist = 1 if ( $app->{ID} == $appdata_id );
	}
	
	return $exist;
}

sub check_all_app_finished_and_not_empty
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my ( $app_count, $app_finished ) = $self->query( 'sel1', __LINE__, "
		SELECT COUNT(AutoAppData.ID), SUM(AutoAppData.Finished) FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
		WHERE Token = ?", $token
	);

	return 2 if $app_count < 1;
	
	return 1 if $app_finished < $app_count;
	
	return 0;
}

sub get_add
# //////////////////////////////////////////////////
{
	my ( $self, $app_id, $token ) = @_;
	
	$self->query( 'query', __LINE__, "
		INSERT INTO AutoSchengenAppData (HostDataCity) VALUES (NULL);"
	);
		
	my $sch_id = $self->query( 'sel1', __LINE__, "SELECT last_insert_id()" ) || 0;
	
	$self->query( 'query', __LINE__, "
		INSERT INTO AutoAppData (AnkDate, AppID, SchengenAppDataID) VALUES (now(), ?, ?)", {}, 
		$app_id, $sch_id
	);
	
	my $appdata_id = $self->query( 'sel1', __LINE__, "SELECT last_insert_id()" ) || 0;
	
	my $step = $self->get_step_by_content( $token, '[list_of_applicants]', 'next' );
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET Step = ?, AutoAppDataID = ?, AutoSchengenAppDataID = ? WHERE Token = ?", {}, 
		$step, $appdata_id, $sch_id, $token
	);
	
	$self->mod_last_change_date( $token );
	
	return $step;
}

sub get_back
# //////////////////////////////////////////////////
{
	my ( $self, $step, $token ) = @_;
	
	$self->save_data_from_form( $step, $self->get_current_table_id( $token ) );
	$self->mod_last_change_date( $token );
	
	$step--;
	
	if ( $step == $self->get_step_by_content( $token, '[app_finish]' ) ) {
		$step = $self->set_step_by_content( $token, '[list_of_applicants]' );
	}
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, $step, $token
	);
		
	return $step;
}

sub get_html_page
# //////////////////////////////////////////////////
{
	my ( $self, $step, $token, $appnum ) = @_;
	
	my $content = '';
	my $template = 'autoform.tt2';
	
	my $page_content = $self->get_content_rules( $step, undef, $token, 'init' );

	if ( $page_content eq '[list_of_applicants]' ) {
		return $self->get_list_of_app( $token );
	}
	
	if ( $page_content eq '[app_finish]' ) {
		return $self->get_finish();
	}
	
	my $current_values = $self->get_all_values( $step, $self->get_current_table_id( $token ) );
	
	$self->correct_values( \$current_values, $appnum, $token );
	
	for my $element ( @$page_content ) {
		$content .= $self->get_html_line( $element, $current_values, $token );
	}
	
	return ( $content, $template );
}

sub correct_values
# //////////////////////////////////////////////////
{
	my ( $self, $current_values, $appnum, $token ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };

	$$current_values->{ 'new_app_num' } = $appnum if $appnum;

	if ( $$current_values->{ 'new_app_branch' } ) {
	
		$$current_values->{ 'new_app_branch' } = $self->query( 'sel1', __LINE__, "
			SELECT BName FROM Branches WHERE ID = ?", $$current_values->{ 'new_app_branch' }
		);
	};
	
	if ( $$current_values->{ 'new_app_timedate' } ) {

		$$current_values->{ 'new_app_timedate' } = $self->query( 'sel1', __LINE__, "
			SELECT AppDate FROM AutoAppointments 
			JOIN AutoToken ON AutoAppointments.ID = AutoToken.AutoAppID
			WHERE AutoToken.Token = ?", $token
		);

		$$current_values->{ 'new_app_timedate' } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
	}
	
	if ( $$current_values->{ 'new_app_timeslot' } ) {
	
		my ( $start, $end ) = $self->query( 'sel1', __LINE__, "
			SELECT TStart, TEnd FROM TimeData WHERE SlotID = ?", $$current_values->{ 'new_app_timeslot' }
		);
		
		$_ = $vars->get_system->time_to_str( $_ ) for ( $start, $end );
		
		$$current_values->{ 'new_app_timeslot' } = "$start - $end";	
	}
}

sub get_list_of_app
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my $content = $self->query( 'selallkeys', __LINE__, "
		SELECT AutoAppData.ID, AutoAppData.FName, AutoAppData.LName, AutoAppData.BirthDate,  AutoAppData.Finished
		FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
		WHERE Token = ?", $token
	);
		
	if ( scalar(@$content) < 1 ) {
		$content->[0]->{ID} = 'X';
	} else {
		for my $app ( @$content ) {
			$app->{BirthDate} =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
		}
	}
	
	return ( $content, 'autoform_list.tt2' );
}

sub get_finish
# //////////////////////////////////////////////////
{
	return ( undef, 'autoform_finish.tt2' );
}

sub get_specials_of_element
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page_content = $self->get_content_rules(shift);
	
	return if $page_content =~ /^\[/;
	
	my $special = {
		'datepicker' => [],
		'mask' => [],
		'nearest_date' => [],
		'timeslots' => [],
		'post_index' => [],
		'with_map' => [],
	};
	
	for my $element ( @$page_content ) {
	
		for my $spec_type ( keys %$special ) {
			push( $special->{ $spec_type }, $element->{ name } ) if $element->{ special } =~ /$spec_type/;
		}
	}

	return ( $special );
}

sub get_html_line
# //////////////////////////////////////////////////
{
	my ( $self, $element, $values, $token ) = @_;

	return $self->get_html_for_element( 'free_line' ) if $element->{ type } eq 'free_line';
	
	my $content = $self->get_html_for_element( 'start_line' );
	
	if ( $element->{ type } eq 'text' ) {
		$content .= $self->get_html_for_element( 'text', $element->{ name }, $element->{ label }, 
				undef, $element->{ font } );
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

	$content .= $self->get_cell(
			$self->get_html_for_element(
				'label', 'text', $element->{ label }
			) 
		) .
		$self->get_cell(
			$self->get_html_for_element(
				$element->{ type }, $element->{ name }, $current_value, $element->{ param }, 
				$element->{ uniq_code }, $element->{ first_elements },
				$self->check_comments_alter_version( $element->{ comment }, $token ),
				$element->{ check },
			) . $label_for_need
		);
	
	$content .= $self->get_html_for_element( 'end_line' );
	
	if ( $element->{ example } ne '' ) {
		$content .= $self->get_html_for_element( 'example', $element->{name}, $element->{example} );
	}

	return $content;
}

sub get_cell
# //////////////////////////////////////////////////
{
	my ( $self, $element ) = @_;
	
	return $self->get_html_for_element( 'start_cell' ) . $element . $self->get_html_for_element( 'end_cell' );
}

sub get_progressbar
# //////////////////////////////////////////////////
{
	my ( $self, $page ) = @_;
	
	my ( $line, $content );
	
	my $progress_line = ( exists $self->{ this_is_self_testing } ?
		VCS::Site::autoselftest::get_progressline() :
		VCS::Site::autodata::get_progressline()
	);
	
	my $current_progress = $page->[0]->{ progress };
	my $big_element = 0;
	
	for ( 1..$#$progress_line ) {
		
		my $past_current_future = 'current';
		$past_current_future = 'past' if $_ < $current_progress;
		$past_current_future = 'future' if $_ > $current_progress;
		
		my $add_el = ( $_ == 1 ? 1 : ( $_ == $#$progress_line ? 2 : 0 ) ); # 1 - first, 2 - last
		
		$big_element++ if $progress_line->[ $_ ]->{ big };
	
		$line .= $self->get_html_for_element( 'progress', $big_element, $progress_line->[ $_ ]->{ name }, 
				$past_current_future, $add_el, $progress_line->[ $_ ]->{ big } );
				
		$content .= $self->get_html_for_element( 'stages', undef, $progress_line->[ $_ ]->{ name }, 
				$past_current_future, undef, $progress_line->[ $_ ]->{ big } );
	}
	
	$content = $line . $self->get_html_for_element( 'end_line' ) . $self->get_html_for_element( 'start_line' ) . $content;
	
	return $content;
}

sub get_html_for_element
# //////////////////////////////////////////////////
{
	my ( $self, $type, $name, $value_original, $param, $uniq_code, $first_elements, $comment, $check ) = @_;
	
	my $value = $self->lang( $value_original );
	my $param = $self->lang( $param );
	my $comment = $self->lang( $comment );
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $elements = VCS::Site::autodata::get_html_elements();
	
	my $content = $elements->{ $type };
	
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
	
	if ( $type eq 'checkbox' ) {
		$content =~ s/\[checked\]/checked/gi if $value_original;
		$content =~ s/\s\[checked\]//gi;
	}
	
	if ( $type eq 'select' ) {
	
		my $list = '';

		for my $opt ( $self->resort_with_first_elements( $param, $first_elements ) ) {
			my $selected = ( $value_original == $opt ? 'selected' : '' );
			$list .= '<option ' . $selected . ' value="' . $opt . '">' . $param->{ $opt } . '</option>'; 
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
			$list .= '<input type="radio" name="' . $name . '" value="' . $opt . '" ' . $checked . ' id="'.$name.$uniq_id.'">'.
				'<label for="'.$name.$uniq_id.'">'.$param->{$opt}.'</label><br>';
		}
		$content =~ s/\[options\]/$list/gi;
		
	}
	
	if ($type eq 'checklist') {

		my $list = '';

		for my $opt ( sort {$a cmp $b} keys %$param ) {
		
			my $checked = ( $value->{$opt} ? 'checked' : '' );
			
			$list .= '<input type="checkbox" value="' . $opt . '" name="' . $opt . '" id="' . $opt . '" ' . $checked . '>'.
			'<label for="' . $opt . '">' . $param->{$opt}->{label_for} . '</label><br>';
		}
		$content =~ s/\[options\]/$list/gi;
	}

	if ( $type eq 'checklist_insurer' ) {
		
		my $list = '';
		my %value_list = map { $_ => 1 } split /,/, $value;

		for my $opt ( sort {$a cmp $b} keys %$param ) {
		
			my $checked = ( $value_list{$opt} ? 'checked' : '' );
			$list .= '<input type="checkbox" value="' . $opt . '" name="' . $name . '_' . $opt . '" id="' . $opt . '" ' . $checked . '>'.
			'<label for="' . $opt . '">' . $param->{$opt} . '</label><br>';
		}
		$content =~ s/\[options\]/$list/gi;
	}
	
	if ( $type eq 'captcha' ) {
	
		my $key = $self->{ autoform }->{ captcha }->{ public_key };
		my $widget_api = $self->{ autoform }->{ captcha }->{ widget_api };
		
		my $json_options = to_json(
			{ 
				sitekey => $key, 
				theme => 'light' 
			}, 
			$self->{ json_options } || {}
		);
		
		my $captch_id = 'recaptcha_' . substr( $key, 0, 10 );
		
		$content =~ s/\[captch_id\]/$captch_id/gi;
		$content =~ s/\[json_options\]/$json_options/gi;
		$content =~ s/\[widget_api\]/$widget_api/gi;
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
		$content =~ s/\[text\]/$value/;
	}
	
	if ( $uniq_code ) {
		$content = $self->add_css_class( $content, 'bold_text') if $uniq_code eq 'bold';
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

sub check_comments_alter_version
# //////////////////////////////////////////////////
{
	my ( $self, $comment, $token ) = @_;
	
	return $comment unless ref( $comment ) eq 'HASH';
	
	my $current_center = $self->query( 'sel1', __LINE__, "
		SELECT CenterID FROM AutoAppointments 
		JOIN AutoToken ON AutoToken.AutoAppID = AutoAppointments.ID 
		WHERE AutoToken.Token = ?", $token
	);
	
	for ( keys %$comment ) {
	
		my %centers = map { $_ => 1 } split /,/, $_;
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

	return sort keys %$country_hash if !$first_elements;	
	
	my @first_elements = split /,/, $first_elements;

	my @array_with_first_elements = ();
	
	for my $f ( @first_elements ) {
	
		$f =~ s/^\s+|\s+$//g;
		
		for my $e (keys %$country_hash) {
			push @array_with_first_elements, $f if $e == $f;
		}
	}
	
	my %first_elements = map { $_ => 1 } @first_elements; 
	
	for my $e ( sort { $country_hash->{ $a } cmp $country_hash->{ $b } } keys %$country_hash ) {
		push @array_with_first_elements, $e if !exists $first_elements{ $e };
	}

	return @array_with_first_elements;
}

sub save_data_from_form
# //////////////////////////////////////////////////
{
	my ( $self, $step, $table_id ) = @_;
	
	my $vars = $self->{'VCS::Vars'};

	my $request_tables = $self->get_names_db_for_save_or_get( $self->get_content_rules($step), 'save' );

	for my $table ( keys %$request_tables ) {
		
		next if !$table_id->{$table};
		next if $table eq 'alternative_data_source';
	
		my $request = '';
		my @values = ();
	
		for my $row ( keys %{$request_tables->{$table}} ) { 
		
			$request .=  "$row = ?, ";
			
			my $value = $vars->getparam( $request_tables->{$table}->{$row} );
			
			push ( @values, $self->encode_data_for_db( $step, $request_tables->{$table}->{$row}, $value) );
			
			$self->change_current_appdata( $value, $table_id ) if $row eq 'PersonForAgreements';
		}
		$request =~ s/,\s$//;			

		$self->query( 'query', __LINE__, "
			UPDATE $table SET $request WHERE ID = ?", {}, @values, $table_id->{ $table }
		);
	}
	
	$self->check_special_in_rules_for_save( $step, $table_id );
}

sub change_current_appdata
# //////////////////////////////////////////////////
{
	my ( $self, $new_app_id, $table_id ) = @_;
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET AutoAppDataID = ? WHERE ID = ?", {}, $new_app_id, $table_id->{ AutoToken }
	);
}

sub check_special_in_rules_for_save
# //////////////////////////////////////////////////
{
	my ( $self, $step, $table_id ) = @_;
	
	my $vars = $self->{'VCS::Vars'};
	my $elements = $self->get_content_rules( $step );
	
	return if $elements =~ /\[/;
	
	for my $element ( @$elements ) {
		if ( $element->{special} eq 'save_info_about_hastdatatype' ) {
			
			my $visa_type = $self->query( 'sel1', __LINE__, "
				SELECT VisaPurpose FROM AutoAppData WHERE ID = ?", $table_id->{AutoAppData}
			);

			if ( $visa_type != 1 ) {
				$self->query( 'query', __LINE__, "
					UPDATE AutoSchengenAppData SET HostDataType = 'S' WHERE ID = ?", {}, 
					$table_id->{AutoSchengenAppData}
				);
			}
		}
		elsif ( $element->{special} eq 'insurer_many_id' ) {
		
			my $all_insurer = $self->query( 'selallkeys', __LINE__, "
				SELECT ID FROM AutoAppData WHERE AppID = ?", $table_id->{AutoAppointments}
			);

			my $new_list = '';
				
			for my $insurer ( @$all_insurer ) {
				next unless $vars->getparam( 'insurance_' . $insurer->{ ID } );
				$new_list .= ( $new_list ? ',' : '' ) . $insurer->{ ID };
			}

			$self->query( 'query', __LINE__, "
				UPDATE AutoToken SET Insurance = ? WHERE ID = ?", {}, $new_list, $table_id->{AutoToken}
			) if $new_list;
		}
	}
}

sub get_all_values
# //////////////////////////////////////////////////
{
	my ( $self, $step, $table_id ) = @_;

	my $all_values = {};
	my $request_tables = $self->get_names_db_for_save_or_get( $self->get_content_rules( $step ), 'full' );

	for my $table ( keys %$request_tables ) {

		next if !$table_id->{ $table };
		
		next if $table eq 'alternative_data_source';

		my $request = join ',', keys %{ $request_tables->{ $table } };
		
		my $result = $self->query( 'selallkeys', __LINE__, "
			SELECT $request FROM $table WHERE ID = ?", $table_id->{ $table }
		);
		$result = $result->[0];
		
		for my $value ( keys %$result ) {
			$all_values->{ $request_tables->{ $table }->{ $value } } = 
				$self->decode_data_from_db( $step, $request_tables->{ $table }->{ $value }, $result->{ $value } );
		}
	}

	if ( $request_tables->{ alternative_data_source } ) {
	
		my $alt = $request_tables->{ alternative_data_source };

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

sub decode_data_from_db
# //////////////////////////////////////////////////
{
	my ( $self, $step, $element_name, $value ) = @_;
	
	$value =~ s/^(\d\d\d\d)\-(\d\d)\-(\d\d)$/$3.$2.$1/;
	
	$value = '' if ( $value eq '00.00.0000' );

	return $value;
}

sub encode_data_for_db
# //////////////////////////////////////////////////
{
	my ( $self, $step, $element_name, $value ) = @_;
	my $vars = $self->{'VCS::Vars'};
	my $element = $self->get_element_by_name( $step, $element_name );
	
	$value =~ s/^\s+|\s+$//g;
	
	$value = ( ( $value eq $element_name ) ? 1 : 0 ) if $element->{type} =~ /checkbox|checklist/;
	$value = $vars->get_system->to_upper_case( $value ) if $element->{ format } eq 'capslock';
	$value = $vars->get_system->to_upper_case_first( $value ) if $element->{ format } eq 'capitalized';
	
	$value =~ s/^(\d\d)\.(\d\d)\.(\d\d\d\d)$/$3-$2-$1/;
	
	return $value;
}

sub get_element_by_name
# //////////////////////////////////////////////////
{
	my ( $self, $step, $element_name ) = @_;
	
	my $page_content = $self->get_content_rules( $step );
	
	my $element;
	
	for my $element_search ( @$page_content ) {
		return $element_search if $element_search->{name} eq $element_name;
		
		if ( $element_search->{db}->{name} eq 'complex' ) {
			for my $sub_element ( keys %{ $element_search->{param} } ) {
				return $element_search if $sub_element eq $element_name;
			}
		};
	};
}

sub get_names_db_for_save_or_get
# //////////////////////////////////////////////////
{
	my ( $self, $page_content, $save_or_get ) = @_;
	
	my $request_tables = {};
	my $alternative_data_source = {};

	return if $page_content =~ /^\[/;
	
	for my $element (@$page_content) {
		next if ( $element->{ special } eq 'insurer_many_id' ) and ( $save_or_get eq 'save' );
		next if ( $element->{ type } eq 'info' ) and ( $save_or_get eq 'save' );

		if ( $element->{ db }->{ name } eq 'complex' ) {
			for my $sub_element ( keys %{ $element->{ param } } ) {
				$request_tables->{ 'Auto' . $element->{ db }->{ table } }->{ $element->{ param }->{ $sub_element }->{ db } } = 
					$sub_element;
			}
		}
		else { 
			$request_tables->{ 'Auto' . $element->{ db }->{ table } }->{ $element->{ db }->{ name } } = $element->{ name };
			
			if ( $element->{ load_if_free_field } ) {
				$alternative_data_source->{ $element->{ name } }->{ table } = 'Auto' . $element->{ load_if_free_field }->{ table };
				$alternative_data_source->{ $element->{ name } }->{ field } = $element->{ load_if_free_field }->{ name };
			}
		}
	}
	
	$request_tables->{ alternative_data_source } = $alternative_data_source;

	return $request_tables;
}

sub get_current_table_id
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my $tables_id = {};
	my $request_tables = '';
	my $tables_list = [];

	my $tables_controled_by_AutoToken = VCS::Site::autodata::get_tables_controled_by_AutoToken();
	
	for my $table_controlled (keys %$tables_controled_by_AutoToken) {
	
		$request_tables .= $tables_controled_by_AutoToken->{$table_controlled} . ', ';
		
		push @$tables_list, $table_controlled;
	}
	$request_tables =~ s/,\s$//;

	my @ids = $self->query( 'sel1', __LINE__, "
		SELECT $request_tables FROM AutoToken WHERE Token = ?", $token
	);
	
	my $max_index = scalar( keys %$tables_controled_by_AutoToken ) - 1;
	
	for my $id (0..$max_index) {
		$tables_id->{ $tables_list->[$id] } = $ids[$id];
	};
	
	$tables_id->{ AutoToken } = $self->query( 'sel1', __LINE__, "
		SELECT ID FROM AutoToken WHERE Token = ?", $token
	);

	return $tables_id;
}

sub check_data_from_form
# //////////////////////////////////////////////////
{
	my ( $self, $token, $step ) = @_;
	
	my $page_content = $self->get_content_rules( $step, undef, $token, 'init' );
	my $tables_id = $self->get_current_table_id( $token );

	return if $page_content =~ /^\[/;
	
	my $first_error = '';
	
	for my $element (@$page_content) {

		last if $first_error;
		
		if ( $element->{check} ) {
			if ( $element->{type} =~ /checkbox/ ) {
				$first_error = $self->check_chkbox( $element );
			}
			elsif ( $element->{type} =~ /checklist/ ) {
				$first_error = $self->check_checklist( $element );
			}
			else {
				$first_error = $self->check_param( $element );
			}
		}

		$first_error = $self->check_captcha() if $element->{type} =~ /captcha/;

		if ( !$first_error and $element->{check_logic} ) {
			$first_error = $self->check_logic( $element, $tables_id );
		}
	}
	
	return $first_error;
}

sub check_checklist
# //////////////////////////////////////////////////
{
	my ( $self, $element ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $at_least_one = 0;
	
	for my $field ( keys %{ $element->{ param } } ) {
		$at_least_one += ( $vars->getparam( $field ) ? 1 : 0 );
	}
	
	return $self->text_error( 11, $element ) if ( ( $element->{ check } =~ /at_least_one/ ) and ( $at_least_one == 0 ) );
}

sub check_chkbox
# //////////////////////////////////////////////////
{
	my ( $self, $element ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $value = $vars->getparam( $element->{ name } );
	
	return $self->text_error( 3, $element ) if ( ( $element->{ check } =~ /true/ ) and ( $value eq '' ) );
}

sub check_param
# //////////////////////////////////////////////////
{
	my ( $self, $element ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $value = $vars->getparam( $element->{ name } );
	my $rules = $element->{ check };

	$value =~ s/^\s+|\s+$//g;

	return $self->text_error( 0, $element ) if ( $rules =~ /z/ ) and ( ( $value eq '' ) or 
			( ( $value eq '0' ) and ( $element->{ name } eq 'timeslot') ) );
			
	return if $rules eq 'z';

	if ( $rules =~ /D/ ) {
		$rules =~ s/(z|D)//g;
		return $self->text_error( 1, $element ) if ( !( $value =~ /$rules/ ) and ( $value ne '' ) );
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
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $response = $vars->getparam( 'g-recaptcha-response' ) || '';
	
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
	my ( $self, $element, $tables_id ) = @_;

	my $vars = $self->{ 'VCS::Vars' };
	my $value = $vars->getparam( $element->{ name } );
	my $first_error = '';
	my $error = 0;
	
	$value =~ s/^\s+|\s+$//g;

	for my $rule ( @{ $element->{ check_logic } } ) {
	
		if ( $rule->{ condition } =~ /^(equal|now)_or_(later|earlier)$/ ) {
		
			$value =~ s/^(\d\d)\.(\d\d)\.(\d\d\d\d)$/$3-$2-$1/;
			
			my $datediff;
			
			if ( $rule->{ condition } =~ /^equal/ ) {
			
				$datediff = $self->query( 'sel1', __LINE__, "
					SELECT DATEDIFF( ?, $rule->{name} ) FROM Auto$rule->{table} WHERE ID = ?",
					$value, $tables_id->{ 'Auto'.$rule->{table} }
				);
			}
			else {
				$datediff = $self->query( 'sel1', __LINE__, "
					SELECT DATEDIFF( ?, now() )", $value
				);
			}

			my $offset = ( $rule->{ offset } ? $rule->{ offset } : 0 );
				
			$error = 6 if ( ( $datediff < ( $offset * -1 ) ) and ( $rule->{ condition } =~ /later$/ ) );
			$error = 8 if ( ( $datediff > $offset ) and ( $rule->{ condition } =~ /earlier$/ ) );
			$error = 12 if ( $error and $rule->{ condition } =~ /^now/ );
			
			$error++ if ( $offset and ( $error == 6 or $error == 8 ) );
			
			$first_error = $self->text_error( $error , $element, undef, $rule->{ error }, $offset ) 
				if $error;
		}
		
		if ( $rule->{ condition } =~ /^unique_in_pending$/ ) {

			my $id_in_db = $self->query( 'sel1', __LINE__, "
				SELECT COUNT(ID) FROM $rule->{table} WHERE Status = 1 AND $rule->{name} = ?", $value
			);

			$first_error = $self->text_error( 10, $element ) if $id_in_db;
		}
		
		if ( $rule->{ condition } =~ /^free_only_if(_not)?$/ ) {
			
			my $not = $1;
			
			my $field_in_db = $self->query( 'sel1', __LINE__, "
				SELECT $rule->{name} FROM Auto$rule->{table} WHERE ID = ?", 
				$tables_id->{ 'Auto'.$rule->{table} }
			);

			if ( $not ) {
				$first_error = $self->text_error( 14, $element, undef, $rule->{error} ) 
					if ( $field_in_db and !$value );
			}
			else {
				$first_error = $self->text_error( 13, $element, undef, $rule->{error} ) 
					unless ( $field_in_db or $value );
			}
		}
		
		if ( $rule->{ condition } =~ /^existing_postcode$/ and $value ) {
			
			my ( $postcode_id, undef ) = $self->get_postcode_id( $value );
			
			$first_error = $self->text_error( 15, $element ) unless ( $postcode_id );
		}
		
		if ( $rule->{ condition } =~ /^email_not_blocked$/ and $value ) {
		
			my $center = $self->query( 'sel1', __LINE__, "
				SELECT CenterID FROM AutoAppointments WHERE ID = ?", 
				$tables_id->{ 'AutoAppointments' }
			);
			
			my $blocket_emails = VCS::Site::autodata::get_blocked_emails();
			
			for my $m ( @$blocket_emails ) {
				
				next if $m->{ email } !~ /^$value$/i;
				
				if ( ref( $m->{ for_centers } ) eq 'ARRAY' ) {
				
					my %centers = map { $_ => 1 } @{ $m->{ for_centers } };
					next unless exists $centers{ $center };
				}
				
				$first_error = $self->text_error( 16 + ( $m->{ show_truth } ? 1 : 0 ) , $element ); 
			};
		}
		
		last if $first_error;
	}
	
	return $first_error;	
}

sub get_postcode_id
# //////////////////////////////////////////////////
{
	my ( $self, $value ) = @_;
	
	my ( $index, $city ) = split /,/, $value;
	
	s/^\s+|\s+$//g for ( $index, $city );
	
	my $postcode_in_db = $self->query( 'sel1', __LINE__, "
		SELECT ID FROM DHL_Cities WHERE PCode = ? AND RName = ?", 
		$index, $city
	);
	
	return ( $postcode_in_db, $city );
}

sub text_error
# //////////////////////////////////////////////////
{
	my ( $self, $error_code, $element, $incorrect_symbols, $relation, $offset ) = @_;
	
	my $text = [
		'Поле "[name]" не заполнено',
		'В поле "[name]" указана неверная дата',
		'В поле "[name]" введены недопустимые символы',
		'Вы должны указать поле "[name]"',
		'Вы должны полностью заполнить анкеты или удалить ненужные черновики',
		'Вы должны добавить по меньшей мере одного заявителя',
		'"[name]" не может быть раньше, чем "[relation]"',
		'"[name]" не может быть раньше, чем "[relation]" на [offset]',
		'"[name]" не может быть позднее, чем "[relation]"',
		'"[name]" не может быть позднее, чем "[relation]" на [offset]',
		'Поле "[name]" уже встречается в актуальных записях',
		'В поле "[name]" нужно выбрать хотя бы одно значение',
		'Недопустимая дата в поле "[name]"',
		'Необходимо заполнить поле "[name]" или указать "[relation]"',
		'Необходимо заполнить поле "[name]", если заполнено "[relation]"',
		'Введён недопустимый индекс или город в поле "[name]", попробуйте указать другой',
		'Вы ввели недопустимый адрес электронной почты',
		'Этот электронный адрес был заблокирован. Вы превысили допустимое количество записей',
		'Капча введена неверно.<br>Пожалуйста, попробуйте ещё раз',
	];
	
	if ( !defined($element) ) {
		return "|" . $self->lang( $text->[$error_code] );
	}
	
	my $name_of_element = (	$element->{label} ? $element->{label} : ( 
				$element->{label_for} ? $element->{label_for } : $element->{name} ) );
	
	my $current_error = $self->lang( $text->[ $error_code ] );
	
	$current_error =~ s/\[name\]/$name_of_element/;
	$current_error =~ s/\[relation\]/$relation/;
	
	$offset = $self->offset_calc( $offset ) if $offset;
	
	$current_error =~ s/\[offset\]/$offset/;
	
	my $text_error = "$element->{name}|$current_error";
	$text_error .= ': ' . $incorrect_symbols if $error_code == 2;
	
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
			$offset .= " лет";
		}
		else {
			if ( $2 == 1 ) {
				$offset .= " год";
			}
			elsif ( ( $2 >= 2 ) and ( $2 <= 4 ) ) {
				$offset .= " года";
			}
			else {
				$offset .= " лет";
			}
		}
	}
	elsif ( $offset >= 60 ) {
	
		$offset = floor( $offset / 30 );
		
		if ( ( $offset >= 2 ) and ( $offset <= 4) ) {
			$offset .= " месяца";
		}
		else {
			$offset .= " месяцев";
		}
	}
	else {
		$offset =~ /(\d)?(\d)/;
		
		if ( ( $1 == 1 ) or ( $2 == 0 ) or ( $2 >= 5 ) ) {
			$offset .= " дней";
		}
		elsif ( ( $2 >= 2 ) and ( $2 <= 4) ) {
			$offset .= " дня";
		}
		else {
			$offset .= " день";
		}
	}
	
	return $offset;
}

sub mod_last_change_date
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my $lastip = $ENV{'HTTP_X_REAL_IP'};
	
	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET LastChange = now(), LastIP = ? WHERE Token = ?", {}, $lastip, $token
	);
}

sub create_new_appointment
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;
	
	my $new_appid;
	my $info_for_contract = "from_db";
	
	my $tables_transfered_id = $self->get_current_table_id( $token );
	
	my $db_rules = $self->get_content_db_rules();

	my ( $insurance_line, $person_for_contract ) = $self->query( 'sel1', __LINE__, "
		SELECT Insurance, PersonForAgreements FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		WHERE Token = ?", $token
	);

	if ( $person_for_contract ) {
	
		$info_for_contract = $self->query( 'selallkeys', __LINE__, "
			SELECT RLName as LName, RFName as FName, RMName as MName, RPassNum as PassNum, 
			RPWhen as PassDate, RPWhere as PassWhom, AppPhone as Phone, RAddress as Address 
			FROM AutoAppData WHERE ID = ?", $person_for_contract
		);
		$info_for_contract = $info_for_contract->[0];
	}
	
	my $new_appid = $self->create_table( 'AutoAppointments', 'Appointments',
		$tables_transfered_id->{ AutoAppointments }, $db_rules, undef, undef, undef, 
		$info_for_contract );
 	
	my %insurance_list = map { $_ => 1 } split /,/, $insurance_line;
	
	my $allapp = $self->query( 'selallkeys', __LINE__, "
		SELECT ID, SchengenAppDataID FROM AutoAppData WHERE AppID = ?", 
		$tables_transfered_id->{ 'AutoAppointments' }
	);
	
	for my $app ( @$allapp ) {
		
		my $sch_appid = $self->create_table( 'AutoSchengenAppData', 'SchengenAppData', $app->{ SchengenAppDataID }, $db_rules );
		
		my $appid = $self->create_table( 'AutoAppData', 'AppData', $app->{ ID }, 
			$db_rules, $new_appid, $sch_appid, ( exists $insurance_list{ $app->{ ID } } ? 1 : 0 )
		);
	}
	
	my $appnum = $self->query( 'sel1', __LINE__, "
		SELECT AppNum FROM Appointments WHERE ID = ?", $new_appid
	);

	return ( $new_appid, scalar @$allapp, $appnum );
}

sub create_table
# //////////////////////////////////////////////////
{
	my ( $self, $autoname, $name, $transfered_id, $db_rules, $new_appid, $sch_appid, $insurance, $info_for_contract ) = @_;

	my $hash = $self->get_hash_table( $autoname, $transfered_id );

	$hash = $self->mod_hash( $hash, $name, $db_rules, $new_appid, $sch_appid, $insurance, $info_for_contract );

	my $new_appid = $self->insert_hash_table( $name, $hash );

	return $new_appid;
}

sub mod_hash
# //////////////////////////////////////////////////
{
	my ( $self, $hash, $table_name, $db_rules, $appid, $schappid, $insurance, $info_for_contract ) = @_;

	my $vars = $self->{ 'VCS::Vars' };

	for my $column ( keys %$hash ) {
		if ( $db_rules->{ $table_name }->{ $column } eq 'nope') {
			delete $hash->{ $column };
		}
	}
	
	$hash = $self->visapurpose_assembler( $hash ) if exists $hash->{ VisaPurpose };
	$hash = $self->mezzi_assembler( $hash ) if exists $hash->{ Mezzi1 };
	
	if ( $hash->{ ShIndex } ) {
		# my ( $postcode_id, $city ) = $self->get_postcode_id( $hash->{ ShIndex } );
		
		$hash->{ Shipping } = 1;
		$hash->{ ShAddress } = $hash->{ ShIndex } . ", " . $hash->{ ShAddress };
	}
	
	$hash->{ FullAddress } .= ' ' . $hash->{ AppEMail } if exists $hash->{ FullAddress };
	
	delete $hash->{ $_ } for ( 'ShIndex', 'ID', 'Finished', 'AppEMail' );
	
	$hash->{ SMS } = 1 if $hash->{ Mobile };
	$hash->{ AppID } = $appid if $appid;
	$hash->{ SchengenAppDataID } = $schappid if $schappid;
	$hash->{ Status } = 1 if exists $hash->{ Status };
	$hash->{ PolicyType } = 1 if $insurance;

	if ( $table_name eq 'Appointments' ) {
	
		my $appobj = VCS::Docs::appointments->new('VCS::Docs::appointments', $vars);
		
		$hash->{ AppNum } = $appobj->getLastAppNum( $vars, $hash->{ CenterID }, $hash->{ AppDate } );
		
		if ( ref( $info_for_contract ) eq 'HASH' ) {
			$hash->{ $_ } = $info_for_contract->{ $_ } for ( keys %$info_for_contract );
		}
	}
		
	return $hash;
}

sub visapurpose_assembler
# //////////////////////////////////////////////////
{
	my ( $self, $hash ) = @_;

	my $visa = '';

	for (1..17) {
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
	
	for (1..7) {
		$mezzi .= ( $_ > 1 ? '|' : '' ) . ( $hash->{ 'Mezzi' . $_ } == 1 ? '1' : '0' );
		
		delete $hash->{ 'Mezzi' . $_ };
	};

	$hash->{ Mezzi } = $mezzi;
	
	return $hash;
}

sub get_content_db_rules
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $content = $self->get_content_rules();
	
	my $db_rules = {};

	for my $page ( keys %$content ) {
		
		next if ( $content->{$page} =~ /\[/ );
		
		for my $element ( @{ $content->{$page} } ) {
		
			next if ( !defined $element->{db}->{table} or $element->{db}->{name} eq 'complex' );
			
			$db_rules->{ $element->{db}->{table} }->{ $element->{db}->{name} } = $element->{db}->{transfer};
		}
	}
	return $db_rules;
}

sub get_hash_table
# //////////////////////////////////////////////////
{
	my ( $self, $table_name, $table_id ) = @_;
	
	my $hash_table = $self->query( 'selallkeys', __LINE__, "
		SELECT * FROM $table_name WHERE ID = ?", $table_id
	);
	
	return $hash_table->[0];
}

sub insert_hash_table
# //////////////////////////////////////////////////
{
	my ( $self, $table_name, $hash ) = @_;
	
	my @request_values = ();
	
	my $request_columns = join ',', keys %$hash;

	my $request_values = join ',', split //, '?' x keys %$hash;
	
	push @request_values, $hash->{ $_ } for keys %$hash;
	
	$self->query( 'query', __LINE__, "
		INSERT INTO $table_name($request_columns) VALUES ($request_values)", {}, @request_values
	);

	my $current_id = $self->query( 'sel1', __LINE__, 
		"SELECT last_insert_id()"
	) || 0;

	return $current_id;
}

sub find_pcode
{
	my ( $self, $task, $id, $template ) = @_;

	my $vars = $self->{ 'VCS::Vars' };
	my $request = $vars->getparam( 'name_startsWith' ) || '';
	my $request_limit = $vars->getparam( 'maxRows' ) || 20;
	my $callback = $vars->getparam( 'callback' ) || "";
	
	$request_limit =~ s/[^0-9]//g;
	$request_limit = 20 if ( $request_limit eq '' ) or ( $request_limit == 0 ) or ( $request_limit > 100 );

	my $rws = [];
	
	if ( $request ne '' ) {
		if ( $request =~ /[^0-9]/ ) {
		
			$rws = $self->query( 'selallkeys', __LINE__, "
				SELECT ID, CName, RName, PCode, isDefault FROM DHL_Cities 
				WHERE (CName LIKE (" . $vars->db->{ 'dbh' }->quote( $request.'%' ) . ") OR 
				RName LIKE (" . $vars->db->{ 'dbh' }->quote( '%'.$request.'%' ) . ")) AND isDeleted=0 
				ORDER BY CName, isDefault DESC, PCode LIMIT $request_limit"
			);		
		}
		else {
			$rws = $self->query( 'selallkeys', __LINE__, "
				SELECT ID, CName, RName, PCode, isDefault FROM DHL_Cities 
				WHERE PCode LIKE (" . $vars->db->{ 'dbh' }->quote( $request.'%' ) . ") AND isDeleted=0 
				ORDER BY CName, isDefault DESC, PCode LIMIT $request_limit"
			);		
		}
		
		for my $rk ( @$rws ) {
			$rk->{ CName } = ( $rk->{ RName } ne '' ? 
				$vars->get_system->converttext( $rk->{ RName } ) : 
				$vars->get_system->converttext( $rk->{ CName } ) 
			);
			$rk->{ PCode } = $rk->{ PCode };
		}
	}
	
	$vars->get_system->pheaderJSON( $vars );
	
	my $tvars = {
		'alist' => $rws,
		'callback' => $callback
	};
	
	$template->process( 'autoform_pcode.tt2', $tvars );
}

sub age
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $age_free_days = $vars->getConfig( 'general' )->{ age_free_days } + 0;

	my ( $birth_year, $birth_month, $birth_day ) = split /\-/, shift; 
	my ( $year, $month, $day ) = Add_Delta_Days( split( /\-/, shift ), $age_free_days );
	
	my $age = $year - $birth_year;
	$age-- unless sprintf( "%02d%02d", $month, $day )
		>= sprintf( "%02d%02d", $birth_month, $birth_day );
	$age = 0 if $age < 0;

	return $age;
}

sub lang
# //////////////////////////////////////////////////
{
	my ( $self, $text ) = @_;
	
	my $vocabulary = $self->{ 'VCS::Vars' }->{ 'VCS::Resources' }->{ 'list' };

	return if !$text;
	
	if ( ref( $text ) ne 'HASH' ) {
		return $vocabulary->{ $text }->{ $self->{ 'lang' } } || $text;
	}
	
	for ( keys %$text ) {
		$text->{ $_ } = $vocabulary->{ $text->{ $_ } }->{ $self->{ 'lang' } } || $text->{ $_ };
	}
	
	return $text;
}

sub cached
# //////////////////////////////////////////////////
{
	my ( $self, $name ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	return if exists $self->{ this_is_self_testing };
		
	return $vars->get_memd->get( $name );
}

sub query
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $type = shift;
	my $line = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $return;
	
	# my $time_start = [ gettimeofday() ];

	$return = $vars->db->selall(@_) if $type eq 'selall';
	$return = $vars->db->selallkeys(@_) if $type eq 'selallkeys';
	$return = $vars->db->query(@_) if $type eq 'query';
	
	my @result = $vars->db->sel1(@_) if $type eq 'sel1';
	
	# my $milliseconds = tv_interval( $time_start ) * 1000;
	# warn Dumper( \@_ ) . '>' x 25 . " line $line - $milliseconds ms" if $milliseconds > 1; 
	
	return ( wantarray ? @result : $result[0] ) if $type eq 'sel1';
	
	return $return;
}

1;
