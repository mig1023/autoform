package VCS::Site::autoform;
use strict;

use VCS::Vars;
use VCS::Site::autodata;
use VCS::Site::autoselftest;

use Data::Dumper;
use Date::Calc qw/Add_Delta_Days/;


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
	my $self = shift;
	my $task = shift;
	my $id = shift;
	my $template = shift;

	my $vars = $self->{'VCS::Vars'};
	
	$self->{'autoform'} = VCS::Site::autodata::get_settings();
	
    	my $dispathcher = {
    		'index' => \&autoform,
		'selftest' => \&autoselftest,
    	};
    	
    	my $disp_link = $dispathcher->{$id};

    	$vars->get_system->redirect( $vars->getform('fullhost').$self->{'autoform'}->{'addr'}.'index.htm' )
    		if !$disp_link;
	
    	&{$disp_link}( $self, $task, $id, $template );
    	
    	return 1;	
}

sub get_content_rules
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $current_page = shift;
	my $full = shift;
	my $token = shift;
	
	my $content = VCS::Site::autodata::get_content_rules_hash( $self );
	my $persons_in_current_page = 0;
	
	my $new_content = {};
	for my $page ( sort { $content->{$a}->[0]->{page_ord} <=> $content->{$b}->[0]->{page_ord} } keys %$content ) {
		
		my $page_ord = $content->{$page}->[0]->{page_ord};
		
		$new_content->{ $page_ord } = $content->{ $page };
		$persons_in_current_page = ( $new_content->{ $page_ord }->[0]->{ persons_in_page } ? 1 : 0 ) if $current_page == $page_ord;
		
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

	$token = undef unless $persons_in_current_page;
	$content = $self->init_add_param( $new_content, $token );
	
	if ( !$current_page ) {
		return $content;
	} elsif ( $current_page =~ /length/i ) {
		return scalar( keys %$content );
	} else {
		return $content->{ $current_page };
	};
}

sub autoform
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $task = shift;
	my $id = shift;
	my $template = shift;

	my $vars = $self->{ 'VCS::Vars' };
	my ( $page_content, $special, $template_file, $title, $progress );
	my $step = 0;
	my $last_error = '';
	
	my $token = $self->get_token_and_create_new_form_if_need();
	
	$self->{'lang'} = 'en' if $vars->getparam( 'lang' ) =~ /^en$/i ;

	if ( $token =~ /^\d\d$/ ) {
		( $title, $page_content, $template_file ) = $self->get_token_error( $token );
	} else {
		( $step, $title, $page_content, $last_error, $template_file, $special, $progress ) = 
			$self->get_autoform_content( $token );
	}

	my ( $last_error_name, $last_error_text ) = split /\|/, $last_error;
	
	my $appinfo_for_timeslots = $self->get_same_info_for_timeslots( $token );

	$vars->get_system->pheader( $vars );
	my $tvars = {
		'langreq' => sub { return $vars->getLangSesVar(@_) },
		'vars' => {
				'lang' => $vars->{'lang'},
				'page_title'  => 'Autoform'
				},
		'form' => {
				'action' => $vars->getform('action')
				},
		'title' => $title,
		'content_text' => $page_content,
		'token' => $token,
		'step' => $step,
		'max_step' => $self->get_content_rules('length'),
		'addr' => $vars->getform('fullhost').$self->{'autoform'}->{'addr'},
		'last_error_name' => $last_error_name,
		'last_error_text' => $last_error_text,
		'special' => $special,
		'vcs_tools' => $self->{'autoform'}->{'addr_vcs'},
		'appinfo' => $appinfo_for_timeslots,
		'progress' => $progress,
		'lang_in_link' => $self->{'lang'},
	};
	$template->process( $template_file, $tvars );
}

sub autoselftest
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $task = shift;
	my $id = shift;
	my $template = shift;

	my $vars = $self->{ 'VCS::Vars' };
	
	my $self_test_result = VCS::Site::autoselftest::selftest( $self );
	
	$vars->get_system->pheader( $vars );
	
	print $self_test_result;
}

sub get_same_info_for_timeslots
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	
	my $appinfo = {};

	( $appinfo->{ persons }, $appinfo->{ center }, $appinfo->{ fdate } ) = $self->query('sel1', "
		SELECT count(AutoAppData.ID), CenterID, SDate
		FROM AutoToken 
		JOIN AutoAppData ON AutoToken.AutoAppID = AutoAppData.AppID
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		WHERE Token = ?", $token );
		
	$appinfo->{ fdate } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;

	return $appinfo;
}

sub init_add_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $content_rules = shift;
	my $token = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $country_code = 'RUS';
	my $age_for_agreements = 18;

	my $info_from_db = $vars->get_memd->get('autoform_addparam');
	
	if ( !$info_from_db ) {
		my $info_from_sql = {
			'[centers_from_db]' => 'SELECT ID, BName FROM Branches WHERE Display = 1 AND isDeleted = 0',
			'[visas_from_db]' => 'SELECT ID, VName FROM VisaTypes WHERE OnSite = 1',
			'[brh_countries]' => 'SELECT ID, EnglishName FROM Countries ORDER BY EnglishName',
			'[citizenship_countries]' => 'SELECT ID, EnglishName FROM Countries WHERE Ex=0 ORDER BY EnglishName',
			'[prevcitizenship_countries]' => 'SELECT ID, EnglishName FROM Countries',
			'[first_countries]' => 'SELECT ID, Name FROM Countries WHERE MemberOfEU=1 order by EnglishName',
			'[schengen_provincies]' => 'SELECT ID, Name FROM SchengenProvinces',
		};
		
		for ( keys %$info_from_sql ) {
			$info_from_db->{ $_ } = $self->query('selall', $info_from_sql->{ $_ } );
		}
		
		$vars->get_memd->set('autoform_addparam', $info_from_db, 12*3600 );
	}

	if ( $token ) {

		my $app_person_in_app = $self->query('selallkeys', "
			SELECT AutoAppData.ID as ID, CONCAT(RFName, ' ', RLName, ', ', BirthDate) as person,
			birthdate, CURRENT_DATE() as currentdate
			FROM AutoToken 
			JOIN AutoAppData ON AutoToken.AutoAppID = AutoAppData.AppID
			WHERE AutoToken.Token = ?", $token);

		for my $person ( @$app_person_in_app ) {
			$person->{ person } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
			
			push ( @{ $info_from_db->{ '[persons_in_app_for_insurance]' } },
				[ $person->{ ID }, $person->{ person } ] );

			next if $self->age( $person->{ birthdate }, $person->{ currentdate } ) < $age_for_agreements;

			push ( @{ $info_from_db->{ '[persons_in_app]' } }, [ $person->{ ID }, $person->{ person } ] );
		}
			
		push @{ $info_from_db->{ '[persons_in_app]' } }, [ 0, $self->lang('на доверенное лицо') ];
	}
		
	for my $page ( keys %$content_rules ) {
		next if $content_rules->{$page} =~ /^\[/;
		for my $element ( @{ $content_rules->{$page} } ) {
			if ( ref($element->{param}) ne 'HASH' ) {
				my $param_array = $info_from_db->{ $element->{param} };
				my $param_result = {};

				for my $row ( @$param_array ) {
					$param_result->{ $row->[0] } = $row->[1];
				};
				$element->{ param } = $param_result;
			}
		}
	}

	return $content_rules;
}	

sub get_token_and_create_new_form_if_need
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{ 'VCS::Vars' };
	
	my $token = $vars->getparam('t');

	$token = lc( $token );
	$token =~ s/[^a-z0-9]//g;

	if ( $token eq '' ) {
		$token = $self->save_new_token_in_db( $self->token_generation() );
	}
	else {
		my ( $token_exist, $finished ) = $self->query('sel1', "
			SELECT ID, Finished FROM AutoToken WHERE Token = ?", $token );
	
		if ( length($token) != 64 ) {
			$token = '01';
		}
		elsif ( !$token_exist ) {
			$token = '02';
		}
		elsif ( $finished ) {
			$token = '03';
		}
	}
	
	return $token;
}

sub create_clear_form
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $vars = $self->{ 'VCS::Vars' };
	
	$self->query('query', "
		INSERT INTO AutoAppointments (RDate, Login, Draft) VALUES (now(), ?, 1)", {}, 
		$vars->get_session->{'login'} );
		
	my $app_id = $self->query('sel1', "SELECT last_insert_id()") || 0;
	
	$self->query('query', "
		UPDATE AutoToken SET AutoAppID = ?, StartDate = now() WHERE Token = ?", {}, 
		$app_id, $token );
}
	
sub save_new_token_in_db
# //////////////////////////////////////////////////
{	
	my $self = shift;
	my $token = shift;

	$self->query('query', "
		INSERT INTO AutoToken (Token, AutoAppID, AutoAppDataID, AutoSchengenAppDataID, Step, LastError, Finished, Draft) 
		VALUES (?, 0, 0, 0, 1, '', 0, 0)", {}, 
		$token );
	
	return $token;
}

sub token_generation
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $token_existing = 1;
	my $token = 'a';
	
	do {
		my @alph = split //, '0123456789abcdefghigklmnopqrstuvwxyz';
		for (1..63) {
			$token .= @alph[ int( rand( 35 ) ) ];
		}
		$token_existing = $self->query('sel1', "
			SELECT ID FROM AutoToken WHERE Token = ?", $token ) || 0;
	} while ( $token_existing );
	
	return $token;
}

sub get_token_error
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $error_num = shift;
	my $template = 'autoform.tt2';

	my $error_type = [
		'внутренняя ошибка',
		'неправильный токен',
		'такого токена не существует',
		'запись уже завершена',
	];
	
	my $title = $self->lang( 'ошибка: ' ) . $self->lang( $error_type->[ $error_num ] );
	$title = "<center>$title</center>";
	
	return ( $title, '', $template );
}

sub get_autoform_content
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $last_error = '';
	my $title;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my ( $step, $app_id ) = $self->query('sel1', "
		SELECT Step, AutoAppID FROM AutoToken WHERE Token = ?", $token );

	my $action = $vars->getparam('action');
	$action = lc($action);
	$action =~ s/[^a-z]//g;
	
	my $appdata_id = $vars->getparam('person');
	$appdata_id =~ s/[^0-9]//g;
	
	my $appnum = undef;
	
	if ( ( $action eq 'back' ) and ( $step > 1 ) ) {
		$step = $self->get_back( $step, $token );
	}

	if ( ( $action eq 'forward' ) and ( $step < $self->get_content_rules('length') ) ) {
		( $step, $last_error, $appnum ) = $self->get_forward( $step, $token );
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
	
	my $page = $self->get_content_rules( $step, 'full' );

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
	
	return ( $step, $title, $content, $last_error, $template, $special, $progress );
}

sub check_relation
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $page = shift;
	my $token = shift;
	my $moonwalk = shift;

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
		$self->query('query', "
			UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
			$step, $token );
	}

	return ( $step, $page );
}

sub skip_page_by_relation
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $condition = shift;
	my $relation = shift;
	my $token = shift;

	my $current_table_id = $self->get_current_table_id( $token ); 
	
	my $value = $self->query('sel1', "
		SELECT $relation->{name} FROM Auto$relation->{table} WHERE ID = ?", $current_table_id->{ 'Auto'. $relation->{table} });
	
	return $self->skip_by_condition( $value, $relation->{ value }, $condition ); 
}

sub skip_by_condition
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $value = shift;
	my $relation = shift;
	my $condition = shift;

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
	my $self = shift;
	my $step = shift;
	my $token = shift;
	
	my $current_table_id = $self->get_current_table_id( $token );
	
	if ( !$current_table_id->{AutoAppointments} ) {
		$self->create_clear_form( $token, $self->get_center_id() );
		$current_table_id = $self->get_current_table_id( $token );
	}
	
	$self->save_data_from_form( $step, $current_table_id );
	$self->mod_last_change_date( $token );
	
	my $last_error = $self->check_data_from_form( $token, $step );

	if ( $last_error ) {
		my @last_error = split /\|/, $last_error;

		$self->query('query', "
			UPDATE AutoToken SET Step = ?, LastError = ? WHERE Token = ?", {}, 
			$step, "$last_error[1] ($last_error[0], step $step)", $token );
	} else {
		$step++;
			
		$self->query('query', "
			UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
			$step, $token );
	}

	my $appnum = undef;
	
	if ( !$last_error and ( $step == $self->get_step_by_content($token, '[app_finish]') ) ) {
		$self->set_current_app_finished( $current_table_id->{ AutoAppData } );
	}

	if ( $step >= $self->get_content_rules( 'length' ) ) {
		( undef, $appnum ) = $self->set_appointment_finished( $token );
	}

	return ( $step, $last_error, $appnum );
}

sub set_current_app_finished
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $appdata_id = shift;
	
	$self->query('query', "
		UPDATE AutoAppData SET Finished = 1 WHERE ID = ?", {}, 
		$appdata_id );
}

sub set_appointment_finished
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	
	my $this_is_draft = $self->query('sel1', "
		SELECT Draft FROM AutoToken WHERE Token = ?", 
		$token );

	return ( 0, 'draft' ) if $this_is_draft; 
	
	my ( $new_appid, $ncount, $appnum ) = $self->create_new_appointment( $token );
	
	$appnum =~ s!(\d{3})(\d{4})(\d{2})(\d{2})(\d{4})!$1/$2/$3/$4/$5!;
	
	$self->query('query', "
		UPDATE AutoToken SET EndDate = now(), Finished = 1, CreatedApp = ? WHERE Token = ?", {}, 
		$new_appid, $token );
		
	$self->query('query', "
		UPDATE Appointments SET RDate = now(), Login = 'website_newform', Draft = 0, NCount = ? WHERE ID = ?", {}, 
		$ncount, $new_appid );
		
	return ( $new_appid, $appnum );
}

sub get_step_by_content
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $content = shift;
	my $next = shift;
	
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
	my $self = shift;
	my $token = shift;
	my $content = shift;
	my $next = shift;

	my $step = $self->get_step_by_content( $token, $content, $next );

	$self->query('query', "
		UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
		$step, $token );

	return $step;
}

sub get_edit
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $appdata_id = shift; 
	my $token = shift;
	
	if ( $self->check_existing_id_in_token( $appdata_id, $token ) ) {
		
		$step = $self->get_step_by_content($token, '[list_of_applicants]', 'next');;
		
		my $sch_id = $self->query('sel1', "
			SELECT SchengenAppDataID FROM AutoAppData WHERE ID = ?", $appdata_id );
		
		$self->query('query', "
			UPDATE AutoToken SET Step = ?, AutoAppDataID = ?, AutoSchengenAppDataID = ? WHERE Token = ?", {}, 
			$step, $appdata_id, $sch_id, $token );
		
		$self->query('query', "
			UPDATE AutoAppData SET Finished = 0 WHERE ID = ?", {}, 
			$appdata_id );
	}
	
	$self->mod_last_change_date( $token );
	return $step;
}

sub get_delete
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $appdata_id = shift; 
	my $token = shift;
	
	if ( $self->check_existing_id_in_token( $appdata_id, $token ) ) {
	
		my $sch_id = $self->query('sel1', "
			SELECT SchengenAppDataID FROM AutoAppData WHERE ID = ?", $appdata_id );
	
		$self->query('query', "
			DELETE FROM AutoAppData WHERE ID = ?", {}, 
			$appdata_id );
		
		$self->query('query', "
			DELETE FROM AutoSchengenAppData WHERE ID = ?", {}, 
			$sch_id );

		$self->mod_last_change_date( $token );
	}
}

sub check_existing_id_in_token
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $appdata_id = shift; 
	my $token = shift;
	
	my $exist = 0;
	
	my $list_of_app_in_token = $self->query('selallkeys', "
		SELECT AutoAppData.ID FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
		WHERE Token = ?", $token );
		
	for my $app ( @$list_of_app_in_token ) {
		$exist = 1 if ( $app->{ID} == $appdata_id );
	}
	
	return $exist;
}

sub check_all_app_finished_and_not_empty
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	
	my $all_finished = 0;
	
	my ( $app_count, $app_finished ) = $self->query('sel1', "
		SELECT COUNT(AutoAppData.ID), SUM(AutoAppData.Finished) FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
		WHERE Token = ?", $token );
		
	$all_finished = 1 if $app_finished < $app_count;
	
	$all_finished = 2 if $app_count < 1;
	
	return $all_finished;
}

sub get_add
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $app_id = shift;
	my $token = shift;
	
	$self->query('query', "
		INSERT INTO AutoSchengenAppData (HostDataCity) VALUES (NULL);");
		
	my $sch_id = $self->query('sel1', "SELECT last_insert_id()" ) || 0;
	
	$self->query('query', "
		INSERT INTO AutoAppData (AnkDate, AppID, SchengenAppDataID) VALUES (now(), ?, ?)", {}, 
		$app_id, $sch_id );
	
	my $appdata_id = $self->query('sel1', "SELECT last_insert_id()" ) || 0;
	
	my $step = $self->get_step_by_content( $token, '[list_of_applicants]', 'next' );
	
	$self->query('query', "
		UPDATE AutoToken SET Step = ?, AutoAppDataID = ?, AutoSchengenAppDataID = ? WHERE Token = ?", {}, 
		$step, $appdata_id, $sch_id, $token );
	
	$self->mod_last_change_date( $token );
	return $step;
}

sub get_back
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $token = shift;
	
	$self->save_data_from_form( $step, $self->get_current_table_id( $token ) );
	$self->mod_last_change_date( $token );
	$step--;
	
	if ( $step == $self->get_step_by_content( $token, '[app_finish]' ) ) {
		$step = $self->set_step_by_content( $token, '[list_of_applicants]' );
	}
	
	$self->query('query', "
		UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
		$step, $token);
		
	return $step;
}

sub get_html_page
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $token = shift;
	my $appnum = shift;
	
	my $content = '';
	my $template = 'autoform.tt2';
	
	my $page_content = $self->get_content_rules( $step, '', $token );

	if ( $page_content eq '[list_of_applicants]' ) {
		return $self->get_list_of_app( $token );
	}
	
	if ( $page_content eq '[app_finish]' ) {
		return $self->get_finish();
	}
	
	my $current_values = $self->get_all_values( $step, $self->get_current_table_id( $token ) );
	
	$self->correct_values( \$current_values, $appnum, $token );
	
	for my $element ( @$page_content ) {
		$content .= $self->get_html_line( $element, $current_values );
	}
	return ( $content, $template );
}

sub correct_values
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $current_values = shift;
	my $appnum = shift;
	my $token = shift;
	
	my $vars = $self->{ 'VCS::Vars' };

	$$current_values->{ 'new_app_num' } = $appnum if $appnum;

	if ( $$current_values->{ 'new_app_branch' } ) {
	
		my $current_barnch = $$current_values->{ 'new_app_branch' };
		$$current_values->{ 'new_app_branch' } = $self->query('sel1', "
			SELECT BName FROM Branches WHERE ID = ?", $$current_values->{ 'new_app_branch' } );
	
		my $branch_geo = VCS::Site::autodata::get_geo_branches();
		
		$$current_values->{ 'new_app_branch' } .= $self->get_html_for_element( 'geo_link', 
			"$branch_geo->{ $current_barnch }->[1]|$branch_geo->{ $current_barnch }->[0]" );
	};
	
	if ( $$current_values->{ 'new_app_timedate' } ) {

		$$current_values->{ 'new_app_timedate' } = $self->query('sel1', "
			SELECT AppDate FROM AutoAppointments 
			JOIN AutoToken ON AutoAppointments.ID = AutoToken.AutoAppID
			WHERE AutoToken.Token = ?", $token );

		$$current_values->{ 'new_app_timedate' } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
	}
	
	if ( $$current_values->{ 'new_app_timeslot' } ) {
	
		my ( $start, $end ) = $self->query('sel1', "
			SELECT TStart, TEnd FROM TimeData WHERE SlotID = ?", $$current_values->{ 'new_app_timeslot' } );
		
		$_ = $vars->get_system->time_to_str( $_ ) for ( $start, $end );
		
		$$current_values->{ 'new_app_timeslot' } = "$start - $end";	
	}
}

sub get_list_of_app
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	
	my $content = $self->query('selallkeys', "
			SELECT AutoAppData.ID, AutoAppData.FName, AutoAppData.LName, AutoAppData.BirthDate,  AutoAppData.Finished
			FROM AutoToken 
			JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
			JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
			WHERE Token = ?", $token );
		
	if ( scalar(@$content) < 1 ) {
		$content->[0]->{ID} = 'X';
	} else {
		for my $app ( @$content ) {
			$app->{BirthDate} =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
		}
	}
	
	my $template = 'autoform_list.tt2';
	
	return ( $content, $template );
}

sub get_finish
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $template = 'autoform_finish.tt2';
	
	return ( undef, $template );
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
		'comment' => [],
	};
	
	for my $element ( @$page_content ) {
		for my $spec_type ( keys %$special ) {
			push( $special->{ $spec_type }, $element->{name} ) if $element->{special} =~ /$spec_type/;
		}

		push( $special->{ 'comment' }, $element->{name} ) if $element->{comment} ne '';
	}
	
	return ($special);
}

sub get_html_line
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	my $values = shift;

	return $self->get_html_for_element( 'free_line' ) if $element->{type} eq 'free_line';
	
	my $content = $self->get_html_for_element( 'start_line' );
	
	if ( $element->{type} eq 'text' ) {
		$content .= $self->get_html_for_element('text', $element->{ name }, $element->{ label }, 
				undef, $element->{ font } );
		$content .= $self->get_html_for_element('end_line');
	
		return $content;
	}	
	
	my $label_for_need = ( $element->{label_for} ? $self->get_html_for_element( 'label_for', $element->{name}, $element->{label_for} ) : '' );
	
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
				$element->{ uniq_code }, $element->{ first_elements }, $element->{ comment }
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
	my $self = shift;
	my $element = shift;
	
	return $self->get_html_for_element( 'start_cell' ) . $element . $self->get_html_for_element( 'end_cell' );
}

sub get_progressbar
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page = shift;
	
	my $line;
	my $content;
	
	my $progress_line = VCS::Site::autodata::get_progressline();
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
	my $self = shift;
	
	my ( $type, $name, $value_original, $param, $uniq_code, $first_elements, $comment ) = @_;
	
	my $value = $self->lang( $value_original );
	my $param = $self->lang( $param );
	my $comment = $self->lang( $comment );
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $elements = {
		'start_line'		=> '<tr [u]>',
		'end_line'		=> '</tr>',
		'start_cell'		=> '<td [u]>',
		'end_cell'		=> '</td>',
		
		'input' 		=> '<input class="input_width input_gen"type="text" value="[value]" name="[name]"'.
					' id="[name]" title="[comment]" [u]>',
		'checkbox' 		=> '<input type="checkbox" value="[name]" name="[name]" id="[name]" [checked] [u]>',
		'select'		=> '<select class="input_width" size = "1" name="[name]" id="[name]" [u]>[options]</select>',
		'radiolist'		=> '<div id="[name]">[options]</div>',
		'text'			=> '<td colspan="3" [u]>[value]</td>',
		'example'		=> '<tr class="mobil_hide" [u]><td>&nbsp;</td><td class="exam_td_gen">'.
					'<span class="exam_span_gen">[value]</span></td>',

		'info'			=> '<label class="info" id="[name]" [u]><b>[text]</b></label>',
		'checklist'		=> '<div id="[name]">[options]</div>',
		'checklist_insurer'	=> '[options]',
		'captcha'		=> '<img src="[captcha_file]" width="100%"><input type="hidden" name="code" value="[captcha_code]" [u]>',
		
		'label'			=> '<label id="[name]" [u]>[value]</label>',
		'label_for'		=> '<label for="[name]" [u]>[value]</label>',
		
		'progress'		=> '<td align="center" class="pr_size_gen pr_[file]_gen"><div class="[format]" ' .
					'title="[title]"><div class="pr_in_gen">[name]</div></div></td>',
					
		'stages'		=> '<td class="stage_gen">[progress_stage]</td>',
		'free_line'		=> '<tr class="mobil_hide"><td colspan="3">&nbsp;</td></tr>',
		
		'geo_link'		=> ' <a target="_blank" style="color: #FF6666; font-size: 12px; font-weight: normal; border-bottom:1px ' .
					'dotted #DB121A; text-decoration:none;" href="http://maps.yandex.ru/?ll=[x],[y]">',
	};
	
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
	
	if ( $uniq_code ) {
		$uniq_code = 'style="font-weight:bold;"' if $uniq_code eq 'bold';
		$content =~ s/\[u\]/$uniq_code/gi;
	}
	else {
		$content =~ s/\s\[u\]\>/>/gi;
	}
	
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
		$content =~ s/\[options\]/$list/gi;
	}
	
	if ( $type eq 'radiolist' ) {
	
		my $list = '';
		my $uniq_id = 0;
		
		for my $opt ( sort keys %$param ) {
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
		my $config = $vars->getConfig( 'captcha' );
		my $addr_captcha = $self->{ 'autoform' }->{ 'addr_captcha' };
		
		my $captcha = $vars->getcaptcha();
		my $ccode = $captcha->generate_code( $config->{ 'code_nums' } );
	
		$content =~ s!\[captcha_file\]!$addr_captcha$ccode.png!;
		$content =~ s/\[captcha_code\]/$ccode/;
	}
	
	
	if ( $type eq 'progress' ) {
		
		my $form = ( $first_elements ? 'big_progr pr_' : 'ltl_progr pr_' ) . $param;
			
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
	
	if ( $type eq 'info' and $value ) {
		$content =~ s/\[text\]/$value/;
	}
	
	if ( $type eq 'geo_link' ) {
		my ( $x, $y ) = split /\|/, $name;
		$content =~ s/\[x\]/$x/;
		$content =~ s/\[y\]/$y/;
		
		$content .= '[ ' . $self->lang( "найти визовый центр на карте" ) . ' ]</a>';
	}
	
	return $content;
}

sub add_css_class
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $html = shift;
	my $new_class = shift;
	
	if ( $html =~ /\sclass="([^"]*)"/i ) {
		my $classes = "$1 $new_class";
		$html =~ s/\sclass="[^"]*"/ class="$classes"/i;
	}
	else {
		$html =~ s/^\s*(\<[^\s]+\s)/$1class="$new_class"/;
	}
	
	return $html;
}

sub resort_with_first_elements
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $country_hash = shift;
	my $first_elements = shift;

	if ( !$first_elements ) {
		return sort keys %$country_hash;
	}	
	
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

sub get_center_id
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{'VCS::Vars'};
	
	my $center_id = $vars->getparam('center');
	
	return $center_id;
}

sub save_data_from_form
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $table_id = shift;
	
	my $vars = $self->{'VCS::Vars'};

	my $request_tables = $self->get_names_db_for_save_or_get( $self->get_content_rules($step), 'save' );

	for my $table ( keys %$request_tables ) {
		
		next if !$table_id->{$table};
	
		my $request = '';
		my @values = ();
	
		for my $row ( keys %{$request_tables->{$table}} ) { 
			$request .=  "$row = ?, ";
			my $value = $vars->getparam( $request_tables->{$table}->{$row} );
			push ( @values, $self->encode_data_for_db( $step, $request_tables->{$table}->{$row}, $value) );
			
			$self->change_current_appdata( $value, $table_id ) if $row eq 'PersonForAgreements';
		}
		$request =~ s/,\s$//;			

		$self->query('query', "
			UPDATE $table SET $request WHERE ID = ?", {}, 
			@values, $table_id->{$table} );
		
	}
	
	$self->check_special_in_rules_for_save( $step, $table_id );
}

sub change_current_appdata
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $current_app_id = shift;
	my $table_id = shift;
	
	$self->query('query', "
		UPDATE AutoToken SET AutoAppDataID = ? WHERE ID = ?", {}, 
		$current_app_id, $table_id->{ AutoToken} );
}

sub check_special_in_rules_for_save
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $table_id = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $elements = $self->get_content_rules( $step );
	
	return if $elements =~ /\[/;
	
	for my $element ( @$elements ) {
		if ( $element->{special} eq 'save_info_about_hastdatatype' ) {
			
			my $visa_type = $self->query('sel1', "
				SELECT VisaPurpose FROM AutoAppData WHERE ID = ?", $table_id->{AutoAppData});

			if ( $visa_type != 1 ) {
				$self->query('query', "
					UPDATE AutoSchengenAppData SET HostDataType = 'S' WHERE ID = ?", {}, 
					$table_id->{AutoSchengenAppData});
			}
		}
		elsif ( $element->{special} eq 'insurer_many_id' ) {
			my $all_insurer = $self->query('selallkeys', "
				SELECT ID FROM AutoAppData WHERE AppID = ?", $table_id->{AutoAppointments} );

			my $new_list = '';
				
			for my $insurer ( @$all_insurer ) {
				next unless $vars->getparam( 'insurance_' . $insurer->{ ID } );
				$new_list .= ( $new_list ? ',' : '' ) . $insurer->{ ID };
			}

			$self->query('query', "
				UPDATE AutoToken SET Insurance = ? WHERE ID = ?", {}, 
				$new_list, $table_id->{AutoToken} ) if $new_list;
		}
	}
}

sub get_all_values
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $table_id = shift;

	my $all_values = {};
	my $request_tables = $self->get_names_db_for_save_or_get( $self->get_content_rules( $step ), 'full' );

	for my $table ( keys %$request_tables ) {

		next if !$table_id->{ $table };

		my $request = join ',', keys %{ $request_tables->{ $table } };
		
		my $result = $self->query('selallkeys', "
			SELECT $request FROM $table WHERE ID = ?", $table_id->{ $table } );
		$result = $result->[0];
		
		for my $value ( keys %$result ) {
			$all_values->{$request_tables->{ $table }->{ $value } } = 
				$self->decode_data_from_db( $step, $request_tables->{ $table }->{ $value }, $result->{ $value } );
		}
	}

	return $all_values;
}

sub decode_data_from_db
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $element_name = shift;
	my $value = shift;
	
	$value =~ s/^(\d\d\d\d)\-(\d\d)\-(\d\d)$/$3.$2.$1/;
	
	$value = '' if ( $value eq '00.00.0000' );

	return $value;
}

sub encode_data_for_db
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $element_name = shift;
	my $value = shift;
	
	my $element = $self->get_element_by_name( $step, $element_name );
	
	$value =~ s/^\s+|\s+$//g;

	if ( $element->{type} =~ /checkbox|checklist/ ) {
		if ( $value eq $element_name ) {
			$value = 1;
		} else {
			$value = 0;
		};
	};
	
	$value =~ s/^(\d\d)\.(\d\d)\.(\d\d\d\d)$/$3-$2-$1/;
	
	return $value;
}

sub get_element_by_name
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $element_name = shift;
	
	my $page_content = $self->get_content_rules( $step );
	my $element;
	for my $element_search ( @$page_content ) {
		if ( $element_search->{name} eq $element_name ) {
			$element = $element_search;
		};
		
		if ( $element_search->{db}->{name} eq 'complex' ) {
			for my $sub_element ( keys %{ $element_search->{param} } ) {
				if ( $sub_element eq $element_name ) {
					$element = $element_search;
				}
			}
		};
	};
	
	return $element;
}

sub get_names_db_for_save_or_get
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page_content = shift;
	my $save_or_get = shift;
	
	my $request_tables = {};

	return if $page_content =~ /^\[/;
	
	for my $element (@$page_content) {
		next if ($element->{special} eq 'insurer_many_id') and ($save_or_get eq 'save');
		next if ($element->{type} eq 'info') and ($save_or_get eq 'save');

		if ( $element->{db}->{name} eq 'complex' ) {
			for my $sub_element (keys %{ $element->{param} }) {
				$request_tables->{ 'Auto' . $element->{db}->{table} }->{ $element->{param}->{$sub_element}->{db} } = $sub_element;
			}
		}
		else { 
			$request_tables->{ 'Auto' . $element->{db}->{table} }->{ $element->{db}->{name} } = $element->{name};
		}
	}

	return $request_tables;
}

sub get_current_table_id
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	
	my $tables_id = {};
	my $request_tables = '';
	my $tables_list = [];

	my $tables_controled_by_AutoToken = VCS::Site::autodata::get_tables_controled_by_AutoToken();
	
	for my $table_controlled (keys %$tables_controled_by_AutoToken) {
		$request_tables .= $tables_controled_by_AutoToken->{$table_controlled} . ', ';
		push @$tables_list, $table_controlled;
	}
	$request_tables =~ s/,\s$//;

	my @ids = $self->query('sel1', "
		SELECT $request_tables FROM AutoToken WHERE Token = ?", $token);
	
	my $max_index = scalar( keys %$tables_controled_by_AutoToken ) - 1;
	
	for my $id (0..$max_index) {
		$tables_id->{ $tables_list->[$id] } = $ids[$id];
	};
	
	$tables_id->{ AutoToken } = $self->query('sel1', "
		SELECT ID FROM AutoToken WHERE Token = ?", $token );

	return $tables_id;
}

sub check_data_from_form
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $step = shift;
	
	my $page_content = $self->get_content_rules( $step );
	my $tables_id = $self->get_current_table_id( $token );

	return if $page_content =~ /^\[/;
	
	my $first_error = '';
	
	for my $element (@$page_content) {
		last if $first_error;
		
		if ( $element->{check} ) {
			if ( $element->{type} =~ /checkbox/ ) {
				$first_error = $self->check_chkbox( $element );
			}
			elsif ( ( $element->{type} =~ /input/ ) and ( $element->{check} =~ /captcha_input/ ) ) {
				$first_error = $self->check_captcha( $element );
			}
			elsif ( $element->{type} =~ /checklist/ ) {
				$first_error = $self->check_checklist( $element );
			}
			else {
				$first_error = $self->check_param( $element );
			}
		}
		
		if ( !$first_error and $element->{check_logic} ) {
			$first_error = $self->check_logic( $element, $tables_id );
		}
	}
	return $first_error;
}

sub check_checklist
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	
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
	my $self = shift;
	my $element = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $value = $vars->getparam( $element->{ name } );
	
	return $self->text_error( 3, $element ) if ( ( $element->{ check } =~ /true/ ) and ( $value eq '' ) );
}

sub check_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $value = $vars->getparam( $element->{ name } );
	my $rules = $element->{ check };

	$value =~ s/^\s+|\s+$//g;

	return $self->text_error( 0, $element ) if ( $rules =~ /z/ ) and ( $value eq '' );
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
	my $element = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $captcha = $vars->getcaptcha();
	
	my $capverify = $vars->getparam( $element->{ name } ) || '';
	my $rcode = $vars->getparam('code') || '';
	my $c_status = $captcha->check_code( $capverify, $rcode );
	
	my $captcha_error = $vars->getCaptchaErr( $c_status );
	$captcha_error = "$element->{name}|$captcha_error" if $captcha_error;
	
	return $captcha_error;
}

sub check_logic
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	my $tables_id = shift;

	my $vars = $self->{ 'VCS::Vars' };
	my $value = $vars->getparam( $element->{ name } );
	my $first_error = '';
	my $error = 0;

	for my $rule ( @{ $element->{ check_logic } } ) {
	
		if ( $rule->{ condition } =~ /^equal_or_(later|earlier)$/ ) {
			$value =~ s/^(\d\d)\.(\d\d)\.(\d\d\d\d)$/$3-$2-$1/;

			my $datediff = $self->query('sel1', "
				SELECT DATEDIFF( ?, $rule->{name} ) FROM Auto$rule->{table} WHERE ID = ?",
				$value, $tables_id->{ 'Auto'.$rule->{table} } );

			my $offset = ( $rule->{ offset } ? $rule->{ offset } : 0 );
				
			$error = 6 if ( ( $datediff < ( $offset * -1 ) ) and ( $rule->{ condition } =~ /later$/ ) );
			$error = 8 if ( ( $datediff > $offset ) and ( $rule->{ condition } =~ /earlier$/ ) );

			$first_error = $self->text_error( ( $offset ? $error+1 : $error ), $element, undef, 
				$rule->{ error }, $offset ) if $error;
		}
		
		if ( $rule->{ condition } =~ /^now_or_later$/ ) {
			$value =~ s/^(\d\d)\.(\d\d)\.(\d\d\d\d)$/$3-$2-$1/;

			my $datediff = $self->query('sel1', "
				SELECT DATEDIFF( ?, now() )", $value );

			my $offset = ( $rule->{ offset } ? $rule->{ offset } : 0 );

			$first_error = $self->text_error( 12, $element, undef, $rule->{ error } )
				if ( ( $datediff < $offset ) and ( $rule->{ condition } =~ /later$/ ) );
		}
		
		if ( $rule->{ condition } =~ /^unique_in_pending$/ ) {

			my $id_in_db = $self->query('sel1', "
				SELECT COUNT(ID) FROM $rule->{table} WHERE Status = 1 AND $rule->{name} = ?",
				$value );

			$error = 10 if $id_in_db;

			$first_error = $self->text_error( 10, $element ) if $id_in_db;
		}
		
		last if $first_error;
	}
	
	return $first_error;	
}

sub text_error
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $error_code = shift;
	my $element = shift;
	my $incorrect_symbols = shift;
	my $relation = shift;
	my $offset = shift;
	
	my $text = [
		'Поле "[name]" не заполнено',
		'В поле "[name]" указана неверная дата',
		'В поле "[name]" введены недопустимые символы',
		'Вы должны указать поле "[name]"',
		'Вы должны полностью закончить все анкеты',
		'Вы должны добавить по меньшей мере одного заявителя',
		'"[name]" не может быть раньше, чем "[relation]"',
		'"[name]" не может быть раньше, чем "[relation]", больше чем на [offset] дня',
		'"[name]" не может быть позднее, чем "[relation]"',
		'"[name]" не может быть позднее, чем "[relation]", больше чем на [offset] дня',
		'Поле "[name]" уже встречается в актуальных записях.',
		'В поле "[name]" нужно выбрать хотя бы одно значение',
		'Недопустимая дата в поле "[name]"',
	];
	
	if ( !defined($element) ) {
		return "|" . $self->lang( $text->[$error_code] );
	}
	
	my $name_of_element = (	$element->{label} ? $element->{label} : ( 
				$element->{label_for} ? $element->{label_for } : $element->{name} ) );
	
	my $current_error = $self->lang( $text->[ $error_code ] );
	$current_error =~ s/\[name\]/$name_of_element/;
	$current_error =~ s/\[relation\]/$relation/;
	$current_error =~ s/\[offset\]/$offset/;
	
	my $text_error = "$element->{name}|$current_error";
	$text_error .= ': ' . $incorrect_symbols if $error_code == 2;
	
	return $text_error;	
}

sub mod_last_change_date
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	
	my $lastip = $ENV{'HTTP_X_REAL_IP'};
	
	$self->query('query', "
		UPDATE AutoToken SET LastChange = now(), LastIP = ? WHERE Token = ?", {}, 
		$lastip, $token );
}

sub create_new_appointment
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	
	my $new_appid;
	
	my $tables_transfered_id = $self->get_current_table_id( $token );
	my $db_rules = $self->get_content_db_rules();

	my $new_appid = $self->create_table( 'AutoAppointments', 'Appointments', $tables_transfered_id, $db_rules );

# insurance!
	
	my $allapp = $self->query('selallkeys', "
		SELECT ID, SchengenAppDataID FROM AutoAppData WHERE AppID = ?", 
		$tables_transfered_id->{ 'AutoAppointments' } );
	
	for my $app ( @$allapp ) {
		
		my $sch_appid = $self->create_table( 'AutoSchengenAppData', 'SchengenAppData', $tables_transfered_id, $db_rules );
		
		my $appid = $self->create_table( 'AutoAppData', 'AppData', $tables_transfered_id, $db_rules, $new_appid, $sch_appid );
	}
	
	my $appnum = $self->query('sel1', "
		SELECT AppNum FROM Appointments WHERE ID = ?", $new_appid );

	return ( $new_appid, scalar @$allapp, $appnum );
}

sub create_table
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $autoname = shift;
	my $name = shift;
	my $tables_transfered_id = shift;
	my $db_rules = shift;

	my $new_appid = shift;
	my $sch_appid = shift;
	
	my $hash = $self->get_hash_table( $autoname, $tables_transfered_id->{ $autoname } );
	
	$hash = $self->mod_hash( $hash, $name, $db_rules, $new_appid, $sch_appid );
	
	my $new_appid = $self->insert_hash_table( $name, $hash );
	
	return $new_appid;
}

sub mod_hash
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{ 'VCS::Vars' };
	
	my $hash = shift;
	my $table_name = shift;
	my $db_rules = shift;
	my $appid = shift;
	my $schappid = shift;
	
	for my $column ( keys %$hash ) {
		if ( $db_rules->{ $table_name }->{ $column } eq 'nope') {
			delete $hash->{ $column };
		}
	}
	
	$hash = $self->visapurpose_assembler( $hash ) if exists $hash->{ VisaPurpose };
	$hash = $self->mezzi_assembler( $hash ) if exists $hash->{ Mezzi1 };
	
	delete $hash->{ ID } if ( exists $hash->{ ID } );
	delete $hash->{ Finished } if ( exists $hash->{ Finished } and $table_name eq 'AppData' );

	$hash->{AppID} = $appid if $appid;
	$hash->{SchengenAppDataID} = $schappid if $schappid;
	$hash->{Status} = 1 if exists $hash->{Status};
	
	if ( $table_name eq 'Appointments' ) {
		my $appobj = VCS::Docs::appointments->new('VCS::Docs::appointments', $vars);
		$hash->{ AppNum }  = $appobj->getLastAppNum( $vars, $hash->{ CenterID }, $hash->{ AppDate } );
	}
		
	return $hash;
}

sub visapurpose_assembler
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $hash = shift;

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
	my $self = shift;
	my $hash = shift;

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
	my $self = shift;
	my $table_name = shift;
	my $table_id = shift;
	
	my $hash_table = $self->query('selallkeys', "
		SELECT * FROM $table_name WHERE ID = ?", $table_id );
	$hash_table = $hash_table->[0];

	return $hash_table;
}

sub insert_hash_table
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $table_name = shift;
	my $hash = shift;
	
	my $request_columns = '';
	my $request_values = '';
	my @request_values = ();
	
	for (keys %$hash) {
		$request_columns .= ( $request_columns ? ',' : '' ) . $_;
		$request_values .= ( $request_values ? ',' : '' ) . '?';
		push @request_values, $hash->{ $_ };
	}
	
	$self->query('query', "
		INSERT INTO $table_name($request_columns) VALUES ($request_values)", {}, 
		@request_values);

	my $current_id = $self->query('sel1', "SELECT last_insert_id()") || 0;

	return $current_id;
}

sub age
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $gconfig = $vars->getConfig('general');
	my $age_free_days = $gconfig->{'age_free_days'} + 0;

	my ( $birth_year, $birth_month, $birth_day ) = split /\-/, shift; 
	my ( $year, $month, $day ) = Add_Delta_Days( split( /\-/, shift ), $age_free_days );
	
	my $age = $year - $birth_year;
	$age-- unless sprintf("%02d%02d", $month, $day)
		>= sprintf("%02d%02d", $birth_month, $birth_day);
	$age = 0 if $age < 0;

	return $age;
}

sub lang
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $text = shift;
	my $vocabulary = $self->{ 'VCS::Vars' }->{ 'VCS::Resources' }->{ 'list' };

	return if !$text;
	
	if ( ref( $text ) ne 'HASH' ) {
		return $vocabulary->{ $text }->{ $self->{ 'lang' } } || $text;
	}
	else {
		for ( keys %$text ) {
			$text->{ $_ } = $vocabulary->{ $text->{ $_ } }->{ $self->{ 'lang' } } || $text->{ $_ };
		}
		return $text;
	}
}

sub query
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{ 'VCS::Vars' };
	my $type = shift;

	if ( $type eq 'sel1' ) {
		my @result = $vars->db->sel1(@_);
		return ( wantarray ? @result : $result[0] );
	}
		
	return $vars->db->selall(@_) if $type eq 'selall';
	return $vars->db->selallkeys(@_) if $type eq 'selallkeys';
	return $vars->db->query(@_) if $type eq 'query';
}

1;
