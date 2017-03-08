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
				'model' => 'primitive',
				'type' => 'input',
				'name' => 'center',
				'label' => 'Визовый центр',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'CenterID',
					},
			},
		],
		'2' => [
			{
				'model' => 'primitive',
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
				'model' => 'primitive',
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
			#{
			#	'model' => 'primitive',
			#	'type' => 'checkbox',
			#	'name' => 'child',
			#	'label' => '',
			#	'label_for' => 'ребёнок',
			#	'comment' => '',
			#	'check' => 'zN',
			#	'db' => {
			#		'table' => 'AppData',
			#		'name' => 'isChild',
			#		},
			#	'relation' => {},
			#},
		],
		'3' => [
			{
				'model' => 'primitive',
				'type' => 'input',
				'name' => 'rulname',
				'label' => 'Фамилия на русском',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'RLName',
					},
			},
			{
				'model' => 'primitive',
				'type' => 'input',
				'name' => 'rufname',
				'label' => 'Имя на русском',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'RFName',
					},
			},
			{
				'model' => 'primitive',
				'type' => 'input',
				'name' => 'rumname',
				'label' => 'Отчество на русском',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'auto_tbl' => '',
					
					'table' => 'AppData',
					'name' => 'RMName',
					},
			},
			#{	type => 'radio',
			#	params => {
			#			items => [ 'Russia', 'USA' ]
			#			????
			#			70 => 'Russia',
			#			1 => 'Afghanistan' .... наверное лучше вынести куда-нибудь и подгружать
			#		}
			#	label;= > ./...
			#	subelem => {
			#		'1' =>	{
			#				'model' => 'primitive',
			#
		],
	};
	
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
	
	my $token = $self->get_token_and_create_new_form_if_need();
	
	if ($token =~ /^\d\d$/) {
		$page_content = $self->get_error($token);
	} else {
		($step, $page_content, $last_error) = $self->get_autoform_content($token);
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
	};
	$template->process('autoform.tt2',$tvars);
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
			SELECT ID, Finished FROM AutoformToken WHERE Token = ?", $token);
	
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
	
	my $appobj = VCS::Docs::appointments->new('VCS::Docs::appointments',$vars);
	my $maxnum = $appobj->getLastAppNum($vars, $centerid);
	
	$vars->db->query("
		INSERT INTO Appointments (AppNum, RDate, Login, Draft) VALUES (?, now(), ?, 1)", {}, 
		$maxnum, $vars->get_session->{'login'});
		
	my $app_id = $vars->db->sel1('SELECT last_insert_id()') || 0;
	
	$vars->db->query("
		INSERT INTO AppData (AnkDate, AppID) VALUES (now(), ?)", {}, 
		$app_id);
		
	my $appdata_id = $vars->db->sel1('SELECT last_insert_id()') || 0;
	
	$vars->db->query("
		UPDATE AutoformToken SET AppID = ?, AppDataID = ? WHERE Token = ?", {}, 
		$app_id, $appdata_id, $token);
}
	
sub save_new_token_in_db
# //////////////////////////////////////////////////
{	
	my $self = shift;
	my $token = shift;
	my $vars = $self->{'VCS::Vars'};

	$vars->db->query("
		INSERT INTO AutoformToken (Token, AppID, AppDataID, Step, LastError, Finished, Draft) VALUES (?, 0, 0, 1, '', 0, 0)", {}, 
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
			SELECT ID FROM AutoformToken WHERE Token = ?", $token) || 0;
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
		SELECT Step FROM AutoformToken WHERE Token = ?", $token);
	
	my $back_forward = $vars->getparam('a');
	$back_forward = lc($back_forward);
	$back_forward =~ s/[^a-z]//g;
	
	if ( ($back_forward eq 'back') and ($step > 1) ) {
		$self->save_data_from_form($step, $self->get_current_table_id($step, $token));
		$step--;
		$vars->db->query("
			UPDATE AutoformToken SET Step = ?, LastError = '' WHERE Token = ?", {}, 
			$step, $token);
	}

	if ( ($back_forward eq 'forward') and ($step < $self->get_content_rules('length')) ) {
		my $app_existing = $self->get_current_table_id($step, $token);
		$self->create_clear_form($token, $self->get_center_id()) if !$app_existing->{Appointments};
		$self->save_data_from_form($step, $self->get_current_table_id($step, $token));
		$last_error = $self->check_data_from_form($step);
		$step++ if !$last_error;
		$vars->db->query("
			UPDATE AutoformToken SET Step = ?, LastError = ? WHERE Token = ?", {}, 
			$step, $last_error, $token);
	}	
	
	my $content = $self->get_html_page($step, $token, $self->get_content_rules($step));
	
	return ($step, $content, $last_error);
}

sub get_html_page
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $token = shift;
	my $page_content = shift;
	
	my $content = '';
	
	my $current_values = $self->get_all_values($step, $self->get_current_table_id($step, $token));
	
	for my $element (@$page_content) {
		$content .= $self->get_html_line($element, $current_values);
	}
	
	return $content;
}

sub get_html_line
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	my $values = shift;
	
	my $content = $self->get_html_for_element('start_line');
	
	my $label_for_need = ( $element->{label_for} ? $self->get_html_for_element( 'label_for', $element->{name}, $element->{label_for} ) : '' );
	
	$content .= $self->get_cell(
			$self->get_html_for_element(
				'label', 'text', $element->{label}
			)
		) .
		$self->get_cell(
			$self->get_html_for_element(
				$element->{type}, $element->{name}, $values->{ $element->{name} }
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
	my $type_of_element = shift;
	my $name_of_element = shift;
	my $value_of_element = shift;
	
	my $elements = {
		'start_line'	=> '<tr>',
		'end_line'	=> '</tr>',
		'start_cell'	=> '<td>',
		'end_cell'	=> '</td>',
		
		'input' 	=> '<input type="text" value="[value]" name="[name]" id="[name]">',
		'checkbox' 	=> '<input type="checkbox" value="[name]" name="[name]" id="[name]" [checked]>',
		
		'label'		=> '<label id="[name]">[value]</label>',
		'label_for'	=> '<label for="[name]">[value]</label>',
	};
	
	my $content = $elements->{$type_of_element};
	
	$content =~ s/\[name\]/$name_of_element/gi;
	$content =~ s/\[value\]/$value_of_element/gi;
	if ($type_of_element eq 'checkbox') {
		$content =~ s/\[checked\]/checked/gi if $value_of_element;
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
			push (@values, $self->encode_data_for_db($step, $request_tables->{$table}->{$value}, $value));
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
	
	return $value;
}

sub encode_data_for_db
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $element_name = shift;
	my $value = shift;
	
	my $page_content = $self->get_content_rules($step);
	
	$value =~ s/^\s+|\s+$//g;
	
	# ici l'information change pour registre dans db
	
	return $value;
}

sub get_names_db_for_save_or_get
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page_content = shift;
	my $request_tables = {};
	
	for my $element (@$page_content) {
		$request_tables->{ $element->{db}->{table} }->{ $element->{db}->{name} } = $element->{name};
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
	
	my $tables_controled_by_autoformtoken = {
		'Appointments' => 'AppID',
		'AppData' => 'AppDataID',
	};
	
	for my $table_controlled (keys %$tables_controled_by_autoformtoken) {
		$request_tables .= $tables_controled_by_autoformtoken->{$table_controlled} . ', ';
		push @$tables_list, $table_controlled;
	}
	$request_tables =~ s/,\s$//;

	my @ids = $vars->db->sel1("
		SELECT $request_tables FROM AutoformToken WHERE Token = ?", $token);
	
	my $max_index = scalar( keys %$tables_controled_by_autoformtoken ) - 1;
	
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
		
		$first_error = $self->check_param( $element ) if ($element->{type} eq 'input');
	}
	
	return $first_error;
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
		'не заполнено',
		'неверная дата',
		'- недопустимые символы',
	];
	
	my $text_error = "$element->{name}|Поле '$name_of_element' $text->[$error_code]";
	$text_error .= ': ' . $incorrect_symbols if $error_code == 2;

	return $text_error;	
}
	
1;
