package VCS::Site::autoform;
use strict;

use VCS::Vars;

use Data::Dumper;
use Date::Calc qw/Add_Delta_Days/;


sub get_content_rules
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page = shift;
	
	my $content_rules = {
	
		# ord по вн параметру, название по типу страниц
	
		'1' => [
			{
				'type' => 'select',
				'name' => 'center',
				'label' => 'Визовый центр',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'CenterID',
				},
				'param' => '[centers_from_db]',
			},
			{
				'type' => 'checkbox',
				'name' => 'pers_info',
				'label' => 'Согласие',
				'label_for' => 'я согласен на обраточку персональных данных',
				'comment' => '',
				'check' => 'true',
				'db' => {
					'table' => 'Appointments',
					'name' => 'PersonalDataPermission',
					'transfer' => 'nope',
				},
				'relation' => {},
			},
			{
				'type' => 'input',
				'name' => 'bth_date',
				'label' => 'Дата рождения',
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'BirthDate',
				},
				#'special' => 'enabled',
				'special' => 'mask',
				'relation' => {},
			},
			{
				'type' => 'input',
				'name' => 'app_date',
				'label' => 'Дата записи',
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'Appointments',
					'name' => 'AppDate',
				},
				'special' => 'datepicker',
				#'special' => 'mask',
				'relation' => {},
			},
		],
		'2' => [
			{
				'type' => 'input',
				'name' => 'lname',
				'label' => 'Фамилия',
				'comment' => '',
				'check' => 'zW',
				'db' => {
					'table' => 'AppData',
					'name' => 'LName',
				},
			},
			{
				'type' => 'input',
				'name' => 'fname',
				'label' => 'Имя',
				'comment' => '',
				'check' => 'zW',
				'db' => {
					'table' => 'AppData',
					'name' => 'FName',
				},
			},
			{
				'type' => 'text',
				'name' => 'visa_text',
				'label' => 'Это просто текст, который расположен в анкете. Это просто текст, который расположен в анкете.',
				'comment' => '',
				'check' => '',
				'db' => {},
			},
			{
				'type' => 'radiolist',
				'name' => 'visa_type',
				'label' => 'Тип визы',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'VType',
				},
				'param' => '[visas_from_db]',
			},
		],
		'3' => [
			{
				'type' => 'input',
				'name' => 'rulname',
				'label' => 'Фамилия на русском',
				'comment' => '',
				'check' => 'zЁ',
				'db' => {
					'table' => 'AppData',
					'name' => 'RLName',
				},
			},
			{
				'type' => 'input',
				'name' => 'rufname',
				'label' => 'Имя на русском',
				'comment' => '',
				'check' => 'zЁ',
				'db' => {
					'table' => 'AppData',
					'name' => 'RFName',
				},
			},
			{
				'type' => 'input',
				'name' => 'rumname',
				'label' => 'Отчество на русском',
				'comment' => '',
				'check' => 'zЁ',
				'db' => {
					'table' => 'AppData',
					'name' => 'RMName',
				},
			},
			{
				'type' => 'checklist',
				'name' => 'mezzi',
				'label' => 'Варианты оплаты',
				'comment' => '',
				'check' => 'at_least_one',
				'db' => {
					'table' => 'AppData',
					'name' => 'complex'
				},
				'param' => {
					'mezzi1' => { 'db' => 'Mezzi1', 'label_for' => 'вариант 1' },
					'mezzi2' => { 'db' => 'Mezzi2', 'label_for' => 'вариант 2' },
					'mezzi3' => { 'db' => 'Mezzi3', 'label_for' => 'вариант 3' },
					'mezzi4' => { 'db' => 'Mezzi4', 'label_for' => 'вариант 4' },
					'mezzi5' => { 'db' => 'Mezzi5', 'label_for' => 'вариант 5' },
					'mezzi6' => { 'db' => 'Mezzi6', 'label_for' => 'вариант 6' },
					'mezzi7' => { 'db' => 'Mezzi7', 'label_for' => 'вариант 7' },
				},
			},

		],
		'4' => [
			{
				'type' => 'text',
				'name' => 'end_text',
				'label' => 'Дальше ничего нет.',
				'comment' => '',
				'check' => '',
				'db' => {},
			},
		],
	};
	
	$content_rules = $self->init_add_param($content_rules);
	
	if (!$page) {
		return $content_rules;
	} elsif ($page =~ /length/i) {
		return scalar(keys %$content_rules);
	} else {
		return $content_rules->{$page};
	};
}

sub new
# //////////////////////////////////////////////////
{
	my ($class,$pclass,$vars) = @_;
	my $self = bless {}, $pclass;
	$self->{'VCS::Vars'} = $vars;
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
	
	$self->{'autoform'}->{'addr'} = '/autoform/';
  
    	my $dispathcher = {
    		'index' => \&autoform,
		'check_data' => \&check_data,
    	};
    	
    	my $disp_link = $dispathcher->{$id};
    	$vars->get_system->redirect($vars->getform('fullhost').$self->{'autoform'}->{'addr'}.'index.htm')
    		if !$disp_link;
    	&{$disp_link}($self, $task, $id, $template);
    	
    	return 1;	
}

sub autoform
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $task = shift;
	my $id = shift;
	my $template = shift;

	my $vars = $self->{'VCS::Vars'};
	my $page_content;
	my $step = 0;
	my $last_error = '';
	my $datepickers;
	my $masks;
	
	my $token = $self->get_token_and_create_new_form_if_need();
	
	if ($token =~ /^\d\d$/) {
		$page_content = $self->get_error($token);
	} else {
		($step, $page_content, $last_error, $datepickers, $masks) = $self->get_autoform_content($token);
	}
	
	my ($last_error_name, $last_error_text) = split /\|/, $last_error;
	
	$vars->get_system->pheader($vars);
	my $tvars = {
		'langreq' => sub { return $vars->getLangSesVar(@_) },
		'vars' => {
				'lang' => $vars->{'lang'},
				'page_title'  => 'Autoform'
				},
		'form' => {
				'action' => $vars->getform('action')
				},
				
		'content_text' => $page_content,
		'token' => $token,
		'step' => $step,
		'max_step' => $self->get_content_rules('length'),
		'addr' => $vars->getform('fullhost').$self->{'autoform'}->{'addr'},
		'last_error_name' => $last_error_name,
		'last_error_text' => $last_error_text,
		'datepickers' => $datepickers,
		'masks' => $masks,
	};
	$template->process('autoform.tt2',$tvars);
}

sub init_add_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $content_rules = shift;
	my $vars = $self->{'VCS::Vars'};
	
	my $centers = $vars->db->selall("
		SELECT ID, BName FROM Branches WHERE Display = 1 AND isDeleted = 0");
	
	my $visas = $vars->db->selall("
		SELECT ID, VName FROM VisaTypes WHERE OnSite = 1");
	
	my $info_from_db = {
		'[centers_from_db]' => $centers,
		'[visas_from_db]' => $visas,
	};
	
	for my $page ( keys %$content_rules ) {
		for my $element ( @{ $content_rules->{$page} } ) {
			if ( ref($element->{param}) ne 'HASH' ) {
				my $param_array = $info_from_db->{ $element->{param} };
				my $param_result = {};
				
				for my $row (@$param_array) {
					$param_result->{ $row->[0] } = $row->[1];
				};
				$element->{param} = $param_result;
			}
		}
	}

	return $content_rules;
}	

sub get_token_and_create_new_form_if_need
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{'VCS::Vars'};
	
	my $token = $vars->getparam('t');
	$token = lc($token);
	$token =~ s/[^a-h0-9]//g;
	
	# новая запись
	if ($token eq '') {
		$token = $self->token_generation();
		$token = $self->save_new_token_in_db($token);
	}
	# возможные ошибки
	else {
		my ($token_exist, $finished) = $vars->db->sel1("
			SELECT ID, Finished FROM AutoToken WHERE Token = ?", $token);
	
		if (length($token) != 64) {
			$token = '01';
		}
		elsif (!$token_exist) {
			$token = '02';
		}
		elsif ($finished) {
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
	my $centerid = shift;
	my $vars = $self->{'VCS::Vars'};
	
	$vars->db->query("
		INSERT INTO AutoAppointments (RDate, Login, Draft) VALUES (now(), ?, 1)", {}, 
		$vars->get_session->{'login'});
		
	my $app_id = $vars->db->sel1('SELECT last_insert_id()') || 0;
	
	$vars->db->query("
		INSERT INTO AutoAppData (AnkDate, AppID) VALUES (now(), ?)", {}, 
		$app_id);
		
	my $appdata_id = $vars->db->sel1('SELECT last_insert_id()') || 0;
	
	$vars->db->query("
		UPDATE AutoToken SET AutoAppID = ?, AutoAppDataID = ? WHERE Token = ?", {}, 
		$app_id, $appdata_id, $token);
}
	
sub save_new_token_in_db
# //////////////////////////////////////////////////
{	
	my $self = shift;
	my $token = shift;
	my $vars = $self->{'VCS::Vars'};

	$vars->db->query("
		INSERT INTO AutoToken (Token, AutoAppID, AutoAppDataID, Step, LastError, Finished, Draft) VALUES (?, 0, 0, 1, '', 0, 0)", {}, 
		$token);
	
	return $token;
}

sub token_generation
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{'VCS::Vars'};

	my $token_existing = 1;
	my $token = '';
	
	do {
		my @alph = (0,1,2,3,4,5,6,7,8,9,'a','b','c','d','e','f');
		for (1..64) {
			$token .= @alph[int(rand(15))];
		}
		$token_existing = $vars->db->sel1("
			SELECT ID FROM AutoToken WHERE Token = ?", $token) || 0;
	} while ($token_existing);
	
	return $token;
}

sub get_error
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $error_num = shift;
	
	my $error_type = [
		'internal data error',
		'token corrupted',
		'token not existing',
		'app already finished',
	];
	
	my $content = 'your token has error: ' . $error_type->[$error_num];
	
	return $content;
}

sub get_autoform_content
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $last_error = '';
	
	my $vars = $self->{'VCS::Vars'};
	
	my $step = $vars->db->sel1("
		SELECT Step FROM AutoToken WHERE Token = ?", $token);
	
	my $back_forward = $vars->getparam('action');
	$back_forward = lc($back_forward);
	$back_forward =~ s/[^a-z]//g;
	
	if ( ($back_forward eq 'back') and ($step > 1) ) {
		$self->save_data_from_form($step, $self->get_current_table_id($step, $token));
		$step--;
		$vars->db->query("
			UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
			$step, $token);
	}

	if ( ($back_forward eq 'forward') and ($step < $self->get_content_rules('length')) ) {
		my $app_existing = $self->get_current_table_id($step, $token);
		$self->create_clear_form($token, $self->get_center_id()) if !$app_existing->{AutoAppointments};
		$self->save_data_from_form($step, $self->get_current_table_id($step, $token));
		$last_error = $self->check_data_from_form($step);
		$step++ if !$last_error;
		
		if ($last_error) {
			$vars->db->query("
				UPDATE AutoToken SET Step = ?, LastError = ? WHERE Token = ?", {}, 
				$step, $last_error, $token);
		} else {
			$vars->db->query("
				UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
				$step, $token);
		}
	}	
	
	my $content = $self->get_html_page($step, $token);
	
	my ($datepickers, $masks) = $self->get_specials_of_element($step);
	
	return ($step, $content, $last_error, $datepickers, $masks);
}

sub get_html_page
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $token = shift;
	
	my $content = '';
	
	my $page_content = $self->get_content_rules($step);
	my $current_values = $self->get_all_values($step, $self->get_current_table_id($step, $token));
	
	for my $element (@$page_content) {
		$content .= $self->get_html_line($element, $current_values);
	}
	
	return $content;
}

sub get_specials_of_element
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page_content = $self->get_content_rules(shift);
	
	my $datepickers = '';
	my $masks = '';
	
	for my $element (@$page_content) {
		$datepickers .= $element->{name} . ',' if $element->{special} eq 'datepicker';
		$masks .= $element->{name} . ',' if $element->{special} eq 'mask';
	}
	$datepickers =~ s/,$//;
	$masks =~ s/,$//;
	
	return ($datepickers, $masks);
}

sub get_html_line
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	my $values = shift;
	
	my $content = $self->get_html_for_element('start_line');
	
	if ( $element->{type} eq 'text' ) {
		$content .= $self->get_html_for_element('text', $element->{name}, $element->{label});
		$content .= $self->get_html_for_element('end_line');
	
		return $content;
	}	
	
	my $label_for_need = ( $element->{label_for} ? $self->get_html_for_element( 'label_for', $element->{name}, $element->{label_for} ) : '' );
	
	my $current_value = $values->{ $element->{name} };

	if ( $element->{db}->{name} eq 'complex' ) {
		for my $sub_value ( keys %{ $element->{param} } ) {
			$current_value->{$sub_value} = $values->{ $sub_value };
		}
	}
	
	$content .= $self->get_cell(
			$self->get_html_for_element(
				'label', 'text', $element->{label}
			) 
		) .
		$self->get_cell(
			$self->get_html_for_element(
				'helper', 'helper',  $element->{label}
			)
		) .
		$self->get_cell(
			$self->get_html_for_element(
				$element->{type}, $element->{name}, $current_value, $element->{param},
			) . $label_for_need
		);
	
	$content .= $self->get_html_for_element('end_line');

	return $content;
}

sub get_cell
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	
	return $self->get_html_for_element('start_cell') . $element . $self->get_html_for_element('end_cell');
}

sub get_html_for_element
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $type = shift;
	my $name = shift;
	my $value = shift;
	my $param = shift;
	
	my $elements = {
		'start_line'	=> '<tr>',
		'end_line'	=> '</tr>',
		'start_cell'	=> '<td>',
		'end_cell'	=> '</td>',
		
		'input' 	=> '<input type="text" value="[value]" name="[name]" id="[name]">',
		'checkbox' 	=> '<input type="checkbox" value="[name]" name="[name]" id="[name]" [checked]>',
		'select'	=> '<select size = "1" name="[name]">[options]</select>',
		'radiolist'	=> '[options]',
		'text'		=> '<td colspan="3">[value]</td>',
		'checklist'	=> '[options]',
		
		'helper'	=> '[?] ', # value вписать в текст хелпа
		'label'		=> '<label id="[name]">[value]</label>',
		'label_for'	=> '<label for="[name]">[value]</label>',
	};
	
	my $content = $elements->{$type};
	
	$content =~ s/\[name\]/$name/gi;
	$content =~ s/\[value\]/$value/gi;
	
	if ($type eq 'checkbox') {
		$content =~ s/\[checked\]/checked/gi if $value;
	}
	
	if ($type eq 'select') {
		my $list = '';
		for my $opt (sort keys %$param) {
			my $selected = ( $value == $opt ? 'selected' : '' );
			$list .= '<option ' . $selected . ' value=' . $opt . '>' . $param->{$opt} . '</option>'; 
		}
		$content =~ s/\[options\]/$list/gi;
	}
	
	if ($type eq 'radiolist') {
		my $list = '';
		for my $opt (sort keys %$param) {
			my $checked = ( $value == $opt ? 'checked' : '' );
			$list .= '<input type="radio" name="' . $name . '" value="' . $opt . '" ' . $checked . '>' . $param->{$opt} . '<br>';
		}
		$content =~ s/\[options\]/$list/gi;
		
	}
	
	if ($type eq 'checklist') {
		my $list = '';

		for my $opt (sort {$a cmp $b} keys %$param) {
			
			my $checked = ( $value->{$opt} ? 'checked' : '' );
			$list .= '<input type="checkbox" value="' . $opt . '" name="' . $opt . '" id="' . $opt . '" ' . $checked . '>'.
			'<label for="' . $opt . '">' . $param->{$opt}->{label_for} . '</label><br>';
		}
		$content =~ s/\[options\]/$list/gi;
		
	}
	
	return $content;
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

	my $request_tables = $self->get_names_db_for_save_or_get($self->get_content_rules($step));

	for my $table (keys %$request_tables) {
		
		next if !$table_id->{$table};
	
		my $request = '';
		my @values = ();
	
		for my $row (keys %{$request_tables->{$table}}) { 

			$request .=  "$row = ?, ";
			my $value = $vars->getparam($request_tables->{$table}->{$row});
			push (@values, $self->encode_data_for_db($step, $request_tables->{$table}->{$row}, $value));
		}
		$request =~ s/,\s$//;			

		$vars->db->query("
			UPDATE $table SET $request WHERE ID = ?", {}, 
			@values, $table_id->{$table});
		
	}
}

sub get_all_values
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $table_id = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	my $all_values = {};
	my $request_tables = $self->get_names_db_for_save_or_get($self->get_content_rules($step));

	for my $table (keys %$request_tables) {
		
		next if !$table_id->{$table};
	
		my $request = join ',', keys %{$request_tables->{$table}};
		
		my $result = $vars->db->selallkeys("
			SELECT $request FROM $table WHERE ID = ?", $table_id->{$table} );
		$result = $result->[0];
		
		for my $value (keys %$result) {
			$all_values->{$request_tables->{$table}->{$value} } = 
				$self->decode_data_from_db($step, $request_tables->{$table}->{$value}, $result->{$value});
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
	
	my $page_content = $self->get_content_rules($step);
	
	# ici l'information change pour montre sur l'ecrane
	
	$value =~ s/^(\d\d\d\d)\-(\d\d)\-(\d\d)$/$3.$2.$1/;
	
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

	if ($element->{type} =~ /checkbox|checklist/) {
		if ($value eq $element_name) {
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
	
	my $page_content = $self->get_content_rules($step);
	my $element;
	for my $element_search  (@$page_content) {
		if ($element_search->{name} eq $element_name) {
			$element = $element_search;
		};
		
		if ( $element_search->{db}->{name} eq 'complex' ) {
			for my $sub_element (keys %{ $element_search->{param} }) {
				if ($sub_element eq $element_name) {
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
	my $request_tables = {};

	for my $element (@$page_content) {
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
	my $step = shift;
	my $token = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $tables_id = {};
	my $request_tables = '';
	my $tables_list = [];
	
	my $tables_controled_by_AutoToken = {
		'AutoAppointments' => 'AutoAppID',
		'AutoAppData' => 'AutoAppDataID',
	};
	
	for my $table_controlled (keys %$tables_controled_by_AutoToken) {
		$request_tables .= $tables_controled_by_AutoToken->{$table_controlled} . ', ';
		push @$tables_list, $table_controlled;
	}
	$request_tables =~ s/,\s$//;

	my @ids = $vars->db->sel1("
		SELECT $request_tables FROM AutoToken WHERE Token = ?", $token);
	
	my $max_index = scalar( keys %$tables_controled_by_AutoToken ) - 1;
	
	for my $id (0..$max_index) {
		$tables_id->{ $tables_list->[$id] } = $ids[$id];
	};

	return $tables_id;
}

sub check_data_from_form
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $page_content = $self->get_content_rules($step);
	
	my $first_error = '';
	
	for my $element (@$page_content) {
		last if $first_error;
		next if !$element->{check};
		
		if ( $element->{type} =~ /checkbox/ ) {
			$first_error = $self->check_chkbox( $element );
		}
		else {
			$first_error = $self->check_param( $element );
		}
	}
	
	return $first_error;
}

sub check_chkbox
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $value = $vars->getparam($element->{name});
	my $rules = $element->{check};
	
	return $self->text_error(3, $element) if ( ($element->{check} =~ /true/) and ($value eq '') );
}

sub check_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $value = $vars->getparam($element->{name});
	my $error = '';
	my $rules = $element->{check};
	
	$value =~ s/^\s+|\s+$//g;

	return $self->text_error(0, $element) if ($rules =~ /z/) and ($value eq '');
	return if $rules eq 'z'; 

	if ($rules =~ /D/) {
		$rules =~ s/(z|D)//g;
		return $self->text_error(1, $element) if (!($value =~ /$rules/) and ($value ne ''));
	}
	else {
		my $regexp = '';
		$regexp .= 'A-Za-z' if $rules =~ /W/; 
		$regexp .= 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя' if $rules =~ /Ё/;
		$regexp .= '0-9' if $rules =~ /N/;
		$rules =~ s/(z|W|Ё|N)//g;
		my $revers_regexp = '[' . $regexp . $rules . ']';
		$regexp = '[^' . $regexp . $rules . ']';

		if (($value =~ /$regexp/) and ($value ne '')) {
			$value =~ s/$revers_regexp//gi;
			return $self->text_error(2, $element, $value);
		}
	}
}
	
sub text_error
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $error_code = shift;
	my $element = shift;
	my $incorrect_symbols = shift;

	my $name_of_element = (	$element->{label} ? $element->{label} : ( 
				$element->{label_for} ? $element->{label_for } : $element->{name} ) );
	
	my $text = [
		'Поле "[name]" не заполнено',
		'В поле "[name]" указана неверная дата',
		'В поле "[name]" введены недопустимые символы',
		'Вы должны дать указать поле "[name]"',
	];
	
	my $current_error = $text->[$error_code];
	$current_error =~ s/\[name\]/$name_of_element/;
	
	my $text_error = "$element->{name}|$current_error";
	$text_error .= ': ' . $incorrect_symbols if $error_code == 2;

	return $text_error;	
}
	
1;
