package VCS::Site::autoselftest;
use strict;

use VCS::Vars;
use Data::Dumper;

my $tests = [
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_token_and_create_new_form_if_need },
		'comment' => 'get_token_and_create_new_form_if_need',
		'test' => {	
			1 => { 	'tester' => \&test_regexp,
				'args' => [],
				'expected' => '^A[a-z0-9]{63}$',
			},
			2 => {	'tester' => \&test_line,
				'args' => [],
				'param' => [ 
					{ 'name' => 't', 'value' => '[token]' },
				],
				'expected' => '[token]',
			},
			3 => {	'tester' => \&test_line,
				'args' => [],
				'param' => [
					{ 'name' => 't', 'value' => 'F[token]' },
				],
				'expected' => '01',
			},
			4 => {	'tester' => \&test_line,
				'prepare' => \&pre_corrupt_token,
				'args' => [],
				'param' => [
					{ 'name' => 't', 'value' => '[token]' },
				],
				'expected' => '02',
			},
			5 => {	'tester' => \&test_line,
				'prepare' => \&pre_finished,
				'args' => [],
				'param' => [
					{ 'name' => 't', 'value' => '[token]' },
				],
				'expected' => '03',
			},
		}
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::token_generation },
		'comment' => 'token_generation',
		'test' => { 	
			1 => { 	'tester' => \&test_regexp,
				'args' => [],
				'expected' => '^A[a-z0-9]{63}$',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::save_new_token_in_db },
		'comment' => 'save_new_token_in_db',
		'test' => { 	
			1 => { 	'tester' => \&test_write_db,
				'args' => [ '[token]' ],
				'expected' => '[token]:AutoToken:Token:[token]',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_token_error },
		'comment' => 'get_token_error',
		'test' => { 	
			1 => { 	'tester' => \&test_array,
				'args' => [ '0' ],
				'expected' => [ 'token error', 'your token has error: internal data error', 'autoform.tt2' ],
			},
			2 => { 	'tester' => \&test_array,
				'args' => [ '1' ],
				'expected' => [ 'token error', 'your token has error: token corrupted', 'autoform.tt2' ],
			},
			3 => { 	'tester' => \&test_array,
				'args' => [ '2' ],
				'expected' => [ 'token error', 'your token has error: token not existing', 'autoform.tt2' ],
			},
			4 => { 	'tester' => \&test_array,
				'args' => [ '3' ],
				'expected' => [ 'token error', 'your token has error: app already finished', 'autoform.tt2' ],
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::simple_array_clone },
		'comment' => 'simple_array_clone',
		'test' => { 	
			1 => { 	'tester' => \&test_array_ref,
				'args' => [ [ '1', 'A', '2', 'B' ] ],
				'expected' => [ '1', 'A', '2', 'B' ],
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_autoform_content },
		'comment' => 'get_autoform_content',
		'test' => { 	
			1 => { 	'tester' => \&test_array,
				'prepare' => \&pre_content_1,
				'args' => [ '[token]' ],
				'expected' => [
					'1', 
					'Начало записи', 
					'[first_page]', 
					'',
					'autoform.tt2',
					{},
					'[progress_bar]',
				],
			},
			2 => { 	'tester' => \&test_array,
				'prepare' => \&pre_content_1,
				'args' => [ '[token]' ],
				'param' => [
					{ 'name' => 'action', 'value' => 'forward' },
					
					{ 'name' => 'center', 'value' => '1' },
					{ 'name' => 'vtype', 'value' => '13' },
					{ 'name' => 'email', 'value' => 'mail@mail.ru' },
				
					{ 'name' => 'pers_info', 'value' => 'pers_info' },
					{ 'name' => 'mobil_info', 'value' => 'mobil_info' },
				],
				'expected' => [
					'2', 
					'Данные поездки', 
					'[second_page]', 
					'',
					'autoform.tt2',
					{},
					'[progress_bar]',
				],
			},
			3 => { 	'tester' => \&test_array,
				'prepare' => \&pre_content_2,
				'args' => [ '[token]' ],
				'param' => [
					{ 'name' => 'action', 'value' => 'back' },
				],
				'expected' => [
					'1', 
					'Начало записи', 
					'[first_page]', 
					'',
					'autoform.tt2',
					{},
					'[progress_bar]',
				],
			},
			
			# .......
			
		},
	},
	
	{ 	'func' 	=> \&{ VCS::Site::autoform::insert_hash_table },
		'comment' => 'insert_hash_table',
		'test' => { 	
			1 => { 	'tester' => \&test_write_db,
				'args' => [ 'AutoToken', { Token => 'Token', AutoAppID => 999 } ],
				'expected' => 'Token:AutoToken:AutoAppID:999',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::mezzi_assembler },
		'comment' => 'mezzi_assembler',
		'test' => { 	
			1 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { 
					Mezzi1 => '1',
					Mezzi2 => '0',
					Mezzi3 => '1',
					Mezzi4 => '0',
					Mezzi5 => '1',
					Mezzi6 => '0',
					Mezzi7 => '1',
				} ],
				'expected' => 'Mezzi:1|0|1|0|1|0|1',
			},
			2 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { 
					Mezzi1 => '0',
					Mezzi2 => '1',
					Mezzi3 => '0',
					Mezzi4 => '1',
					Mezzi5 => '0',
					Mezzi6 => '1',
					Mezzi7 => '0',
				} ],
				'expected' => 'Mezzi:0|1|0|1|0|1|0',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::visapurpose_assembler },
		'comment' => 'visapurpose_assembler',
		'test' => { 	
			1 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { VisaPurpose => '13' } ],
				'expected' => 'VisaPurpose:0|0|0|0|0|0|0|0|0|0|0|0|1|0|0|0|0',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::mod_hash },
		'comment' => 'mod_hash',
		'test' => { 	
			1 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { VisaPurpose => '13' } ],
				'expected' => 'VisaPurpose:0|0|0|0|0|0|0|0|0|0|0|0|1|0|0|0|0',
			},
			2 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { ID => '1' } ],
				'expected' => 'ID:',
			},
			3 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { Status => '3' } ],
				'expected' => 'Status:1',
			},
			4 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { Status => '3' }, 'TableName', {}, '999' ],
				'expected' => 'AppID:999',
			},
			
			# .......
		},
	},
	
	{ 	'func' 	=> \&{ VCS::Site::autoform::text_error },
		'comment' => 'text_error',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ 0, { 'name' => 'test' },  ],
				'expected' => 'test|Поле "test" не заполнено',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ 1, { 'name' => 'test', 'label' => 'label' },  ],
				'expected' => 'test|В поле "label" указана неверная дата',
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ 2, { 'name' => 'test', 'label_for' => 'label_for' }, 'ABC' ],
				'expected' => 'test|В поле "label_for" введены недопустимые символы: ABC',
			},
			4 => { 	'tester' => \&test_line,
				'args' => [ 4 ],
				'expected' => '|Вы должны полностью закончить все анкеты',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::check_param },
		'comment' => 'check_param',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'z' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '' },
				],
				'expected' => 'test|Поле "test" не заполнено',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'zW' } ],
				'param' => [
					{ 'name' => 'test', 'value' => 'ABC5АБВ9' },
				],
				'expected' => 'test|В поле "test" введены недопустимые символы: 5АБВ9',
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'zЁ' } ],
				'param' => [
					{ 'name' => 'test', 'value' => 'ABC5АБВ9' },
				],
				'expected' => 'test|В поле "test" введены недопустимые символы: ABC59',
			},
			4 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'zN' } ],
				'param' => [
					{ 'name' => 'test', 'value' => 'ABC5АБВ9' },
				],
				'expected' => 'test|В поле "test" введены недопустимые символы: ABCАБВ',
			},
			
			# .......
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::check_chkbox },
		'comment' => 'check_chkbox',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'true' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '' },
				],
				'expected' => 'test|Вы должны указать поле "test"',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => '' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '' },
				],
				'expected' => '',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::resort_with_first_elements },
		'comment' => 'resort_with_first_elements',
		'test' => { 	
			1 => { 	'tester' => \&test_array,
				'args' => [ { 10 => 'first', 20 => 'second', 30 => 'third', 40 => 'fourth' }, '20, 40' ],
				'expected' => [ 20, 40, 10, 30 ],
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_center_id },
		'comment' => 'get_center_id',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [],
				'param' => [
					{ 'name' => 'center', 'value' => '999' },
				],
				'expected' => '999',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_html_for_element },
		'comment' => 'get_html_for_element',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ 'start_line' ],
				'expected' => '<tr>',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ 'end_line' ],
				'expected' => '</tr>',
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ 'start_cell' ],
				'expected' => '<td>',
			},
			4 => { 	'tester' => \&test_line,
				'args' => [ 'end_cell' ],
				'expected' => '</td>',
			},
			5 => { 	'tester' => \&test_line,
				'args' => [ 'input', 'element', 'val', {}, 'uniq', undef, 'comm' ],
				'expected' => '<input type="text" value="val" name="element" id="element" title="comm" uniq>',
			},
			6 => { 	'tester' => \&test_line,
				'args' => [ 'checkbox', 'element', 'val', {} ],
				'expected' => '<input type="checkbox" value="element" name="element" id="element" checked>',
			},
			7 => { 	'tester' => \&test_line,
				'args' => [ 'checkbox', 'element' ],
				'expected' => '<input type="checkbox" value="element" name="element" id="element">',
			},
			8 => { 	'tester' => \&test_line,
				'args' => [ 'select', 'element', '3', { 1 => 'first', 2 => 'second', 3 => 'third', 4 => 'fourth' }, undef, '2' ],
				'expected' => 
					'<select size = "1" name="element" id="element"><option  value="2">second</option>' .
					'<option  value="1">first</option><option  value="4">fourth</option><option selected ' .
					'value="3">third</option></select>',
			},
			9 => { 	'tester' => \&test_line,
				'args' => [ 'radiolist', 'element', '2', { 1 => 'first', 2 => 'second', 3 => 'third' } ],
				'expected' => 
					'<input type="radio" name="element" value="1"  id="element1"><label for="element1">' .
					'first</label><br><input type="radio" name="element" value="2" checked id="element2">' .
					'<label for="element2">second</label><br><input type="radio" name="element" value="3"  '.
					'id="element3"><label for="element3">third</label><br>',
			},
			10 => {	'tester' => \&test_line,
				'args' => [ 'text', undef, 'text' ],
				'expected' => '<td colspan="3">text</td>',
			},
			11 => {	'tester' => \&test_line,
				'args' => [ 'example', undef, 'text' ],
				'expected' => '<tr><td>&nbsp;</td><td style="vertical-align:top;">'.
					'<span style="color:gray; font-size:0.7em;">text</span></td></td>',
			},
			12 => {	'tester' => \&test_line,
				'args' => [ 'info', 'element' ],
				'expected' => '<label id="element"></label>',
			},
			13 => {	'tester' => \&test_line,
				'args' => [ 'label', 'element', 'text' ],
				'expected' => '<label id="element">text</label>',
			},
			14 => {	'tester' => \&test_line,
				'args' => [ 'label_for', 'element', 'text' ],
				'expected' => '<label for="element">text</label>',
			},
			15 => {	'tester' => \&test_line,
				'args' => [ 'checklist', 'element', { 'test1' => 1 }, { 
					'test1' => { 'db' => 'test1', 'label_for' => 'Тест 1' },
					'test2' => { 'db' => 'test2', 'label_for' => 'Тест 2' },
				} ],
				'expected' =>
					'<input type="checkbox" value="test1" name="test1" id="test1" checked>'.
					'<label for="test1">Тест 1</label><br><input type="checkbox" '.
					'value="test2" name="test2" id="test2" ><label for="test2">Тест 2</label><br>',
			},
			16 => {	'tester' => \&test_line,
				'args' => [ 'checklist_insurer', 'element', 'test1=0,test2=1', { 
					'test1' => 'Тест 1',
					'test2' => 'Тест 2',
				} ],
				'expected' =>
					'<input type="checkbox" value="test1" name="element_test1" id="test1" >'.
					'<label for="test1">Тест 1</label><br><input type="checkbox" value="test2" '.
					'name="element_test2" id="test2" checked><label for="test2">Тест 2</label><br>',
			},
			17 => {	'tester' => \&test_regexp,
				'args' => [ 'captcha' ],
				'expected' =>
					'^\<img\ssrc="/vcs/static/files/[a-h0-9]+\.png"\>\<input\stype="hidden"\sname="code"\svalue="[a-h0-9]+">',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_cell },
		'comment' => 'get_cell',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ 'test' ],
				'expected' => '<td>test</td>',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_html_line },
		'comment' => 'get_html_line',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [
					{
						'type' => 'input',
						'name' => 'email',
						'label' => 'Email',
						'comment' => '',
						'example' => 'mail@mail.ru',
						'check' => 'z',
					},
					{
						'email' => 'testvalue@mail.ru',
					}
				],
				'expected' => 
					'<tr><td><label id="text">Email</label></td><td><input type="text" ' .
					'value="testvalue@mail.ru" name="email" id="email" title=""></td>' .
					'</tr><tr><td>&nbsp;</td><td style="vertical-align:top;"><span style='.
					'"color:gray; font-size:0.7em;">mail@mail.ru</span></td></td>',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [
					{
						'type' => 'checklist',
						'name' => 'test',
						'label' => 'Средства',
						'comment' => '',
						'check' => 'at_least_one',
						'db' => {
							'name' => 'complex'
						},
						'param' => {
							'test1' => { 'db' => 'Test1', 'label_for' => 'Тест 1' },
							'test2' => { 'db' => 'Test2', 'label_for' => 'Тест 2' },
						},
					},
					{
						'test1' => '1',
						'test2' => '0',
					}
				],
				'expected' => 
					'<tr><td><label id="text">Средства</label></td><td><input type="checkbox" ' .
					'value="test1" name="test1" id="test1" checked><label for="test1">Тест 1' .
					'</label><br><input type="checkbox" value="test2" name="test2" id="test2" ' .
					'><label for="test2">Тест 2</label><br></td></tr>',
			}
		},
	},
];

my $progress_bar = '<td align="center" style="background-image: url(\'/images/pbar-white-gray.png\');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#CC0033;"><div style="padding-top:7px;color:white;font-size:30">1</div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#999999;"><div style="padding-top:7px;color:white;font-size:30">2</div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#999999;"><div style="padding-top:7px;color:white;font-size:30">3</div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-white.png\');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#999999;"><div style="padding-top:7px;color:white;font-size:30">4</div></div></td></tr><tr><td style="padding:5px;">Начало</td><td style="padding:5px;">Заявители</td><td style="padding:5px;">Оформление</td><td style="padding:5px;">Готово!</td>';

my $first_page = '<tr><td><label id="text">Визовый центр</label></td><td><select size = "1" name="center" id="center" onchange="update_nearest_date_free_date();"></select></td></tr><tr><td><label id="text">Тип визы</label></td><td><select size = "1" name="vtype" id="vtype"></select></td></tr><tr><td><label id="text">Ближайшее доступное время</label></td><td><label id="free_date"></label></td></tr><tr><td><label id="text">Email</label></td><td><input type="text" value="" name="email" id="email" title="Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре"></td></tr><tr><td>&nbsp;</td><td style="vertical-align:top;"><span style="color:gray; font-size:0.7em;">mail@mail.ru</span></td></td><tr><td><label id="text"></label></td><td><input type="checkbox" value="pers_info" name="pers_info" id="pers_info"><label for="pers_info">я согласен на обработку персональных данных</label></td></tr><tr><td><label id="text"></label></td><td><input type="checkbox" value="mobil_info" name="mobil_info" id="mobil_info"><label for="mobil_info">я согласен на условия работы с мобильными</label></td></tr>';

my $second_page = '<tr><td><label id="text">Дата начала поездки</label></td><td><input type="text" value="" name="s_date" id="s_date" title=""></td></tr><tr><td><label id="text">Дата окончания поездки</label></td><td><input type="text" value="" name="f_date" id="f_date" title=""></td></tr>';

sub selftest 
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{ 'VCS::Vars' };
	my $config = $vars->getConfig('db');
	
	$vars->db->query("USE fake_vcs");
	
	my $result = [ { 'text' => "self_self_test", 'status' => self_self_test() } ];

	my $test_token = $self->get_token_and_create_new_form_if_need();
	
	push @$result, get_tests( $self, $vars, $test_token );
	
	$vars->db->query( "USE " . $config->{"dbname"} );	

	return show_result($result);
}

sub get_tests
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = shift;
	my $test_token = shift;
	
	my @result = ();
	
	for my $test (@$tests) {
	
		my $err_line = '';
		my $test_num = 0;
		
		for( sort { $a <=> $b } keys %{ $test->{test} } ) {
	
			$test_num++;
			
			my $t = $test->{test}->{$_};
			
			&{ $t->{prepare} }( 'PREPARE', \$test, $_, \$test_token, $vars ) if ref( $t->{prepare} ) eq 'CODE';
			
			for (	@{ $t->{args} }, @{ $t->{param} },
				( ref( $t->{expected} ) eq 'ARRAY' ? @{ $t->{expected} } : $t->{expected} )
			) {
				s/\[token\]/$test_token/g;
				s/\[progress_bar\]/$progress_bar/g;
				s/\[first_page\]/$first_page/g;
				s/\[second_page\]/$second_page/g;
				
				if ( ref($_) eq 'HASH' ) {
					$_->{value} =~ s/\[token\]/$test_token/g if exists $_->{value};
				}
			}
			
			for ( @{ $t->{param} } ) {
				$vars->setparam( $_->{name} ,$_->{value} );
			}

			my $test_result =  &{ $t->{tester} }( 
				$t->{expected}, $test->{comment}, $self, 
				&{ $test->{func} }( $self, @{ $t->{args} } )
			);
			
			if ( $test_result ) {
				$err_line .= ( $err_line ? ', ' : '' ) . $test_num;
			}
			
			&{ $t->{prepare} }( 'CLEAR', \$test, $_, \$test_token, $vars ) if ref( $t->{prepare} ) eq 'CODE';
		} 
		
		push @result, { 'text' => "$test->{comment}", 'status' => $err_line };
	}
	
	return @result;
}

sub show_result
# //////////////////////////////////////////////////
{
	my $result = shift;
	
	my $result_line = self_test_htm( 'body_start' );
	
	my $test_num = 0;
	my $fails = 0;

	for my $test (@$tests) {
		for( keys %{ $test->{test} } ) {
			$test_num++;
		}
	}
	
	for ( @$result ) {
		$fails++ if $_->{status};
	}
	
	$result_line .= self_test_htm( 'span', ( $fails ? ( 'red', "Присутствуют ошибки" ) : ( 'green', "Всё нормально" ) ) );
	
	for ( @$result ) {
		$result_line .= $_->{text} . ' ' . 
			( !$_->{status} ? 
				self_test_htm( 'font', 'green', "-- ok" ) : 
				self_test_htm( 'font', 'red', "-- fail: $_->{status}" )
			) . self_test_htm( 'br' );
	}
	$result_line .= self_test_htm( 'br' ) . self_test_htm( 'span', ( $fails ? 'red' : 'green' ), "$test_num тест(ов)" );
	
	return $result_line . self_test_htm( 'body_end' );
}

sub self_test_htm
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $param = shift;
	my $line = shift;
	
	my $html = {
		'body_start' => '<body style = "padding: 40px">',
		'body_end' => '</body>',
		'span' => '<span style="width:auto; color:white; background-color:[param]">&nbsp;[line]&nbsp;</span><br><br>',
		'font' => '<font color="[param]">[line]</font>',
		'br' => '<br>',
	};
	
	my $html_line = $html->{$type};
	
	$html_line =~ s/\[param\]/$param/g;
	$html_line =~ s/\[line\]/$line/g;
	
	return $html_line;
}

sub self_self_test
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $fail_in_myself = 0;
	
	$fail_in_myself += test_line( '12345ABCD', '1', undef, '12345ABCD' );
	$fail_in_myself += test_line_in_hash( 'key2:value2', '1', undef, { 'key1' => 'value1', 'key2' => 'value2' } );
	$fail_in_myself += test_hash( { 'key1' => 'value1', 'key2' => 'value2' }, { 'key1' => 'value1', 'key2' => 'value2' }, '1' );
	$fail_in_myself += test_array( [ '1', 'A', '2', 'B' ], '1', $self, ( '1', 'A', '2', 'B' ) );
	$fail_in_myself += test_array_ref( [ '1', 'A', '2', 'B' ], '1', $self, [ '1', 'A', '2', 'B' ] );
	$fail_in_myself += test_regexp( '^[A-D]+[0-5]+$', '1', undef, 'ABCD12345' );
	
	$fail_in_myself += ! test_line( '12345ABCD', '1', undef, '12345ABCD0' );
	$fail_in_myself += ! test_line_in_hash( 'key2:value2', '1', undef, { 'key1' => 'value2', 'key2' => 'value1' } );
	$fail_in_myself += ! test_hash( 
		{ 'key1' => 'value1', 'key2' => 'value2' }, { 'key1' => 'value1', 'key2' => 'value2', 'key3' => 'value3' }, '1' );
	$fail_in_myself += ! test_array( [ '1', 'A', '2', 'B', '3' ], '1', $self, ( '1', 'A', '2', 'B' ) );
	$fail_in_myself += ! test_array_ref( [ '1', 'A', '2', 'B' ], '1', $self, [ '1', 'A', '2', 'B', '3' ] );
	$fail_in_myself += ! test_regexp( '^[A-D]+[0-5]+$', '1', undef, 'ABC1234 5' );
	
	return $fail_in_myself;
}

sub test_line
# //////////////////////////////////////////////////
{
	my ( $expected, $comm, undef, $result ) = @_;

	if ( lc( $expected ) ne lc( $result ) ) { 
		return $comm;
	};
}

sub test_line_in_hash
# //////////////////////////////////////////////////
{
	my ( $expected, $comm, undef, $result ) = @_;
	my ( $key, $value ) = split /:/, $expected;

	if ( lc( $result->{ $key } ) ne lc( $value ) ) { 
		return $comm;
	};
}

sub test_hash
# //////////////////////////////////////////////////
{
	my $first_hash = shift;
	my $second_hash = shift;
	
	my $eq = 1;
	
	for ( keys %$first_hash, keys %$second_hash ) {
		$eq = 0 if $first_hash->{ $_ } ne $second_hash->{ $_ };
	}
	
	if ( !$eq ) { 
		return shift;
	};
}
sub test_array
# //////////////////////////////////////////////////
{
	my $array_2 = shift;
	my $comm = shift;
	my $self = shift;
	my @array_1 = @_;

	my $eq = 1;
	
	for ( 1..$#array_1 ) {
		next if ref( $array_1[$_] ) and ref( $array_2->[$_] );
		$eq = 0 if $array_1[$_] ne $array_2->[$_];
	}
	
	$eq = 0 unless $#array_1 == $#$array_2;
	
	if ( !$eq ) { 
		return $comm;
	};
}

sub test_array_ref
# //////////////////////////////////////////////////
{
	my $array_2 = shift;
	my $comm = shift;
	my $self = shift;
	my $array_1 = shift;

	my $eq = 1;
	
	for ( 1..$#{$array_1} ) {
		$eq = 0 if $array_1->[$_] ne $array_2->[$_];
	}
	
	if ( !$eq ) { 
		return $comm;
	};
}

sub test_regexp
# //////////////////////////////////////////////////
{
	my ( $regexp, $comm, undef, $result ) = @_;
	
	if ( $result !~ /$regexp/ ) {
		return $comm;
	}
}

sub test_write_db
# //////////////////////////////////////////////////
{
	my ( $test_token, $db_table, $db_name, $db_value ) = split /:/, shift;
	my $comment = shift;
	my $self = shift;
	my $result = shift;

	my $vars = $self->{ 'VCS::Vars' };
	
	my $value = $vars->db->sel1( "SELECT $db_name FROM $db_table WHERE Token = '$test_token'" );

	if ( lc( $db_value ) ne lc( $value ) ) {
		return $comment;
	}
}

sub pre_corrupt_token
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $test = shift;
	my $num = shift;
	my $token = shift;
	
	if ( $type eq 'PREPARE' ) { 
		$$token =~ s/^A/F/;
	}
	else {
		$$token =~ s/^F/A/;
	}	
}

sub pre_finished
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $test = shift;
	my $num = shift;
	my $token = shift;
	my $vars = shift;
	
	if ( $type eq 'PREPARE' ) { 
		$vars->db->query( "UPDATE AutoToken SET Finished = 1 WHERE Token = '$$token'" );
	} 
	else {
		$vars->db->query( "UPDATE AutoToken SET Finished = 0 WHERE Token = '$$token'" );
	}
}

sub pre_content_1
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $test = shift;
	my $num = shift;
	my $token = shift;
	my $vars = shift;
	
	$vars->db->query( "UPDATE AutoToken SET Step = 1 WHERE Token = '$$token'" );
}

sub pre_content_2
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $test = shift;
	my $num = shift;
	my $token = shift;
	my $vars = shift;
	
	my $appid = $vars->db->sel1( "SELECT AutoAppID FROM AutoToken WHERE Token = '$$token'" );
		
	$vars->db->query( 
		"UPDATE AutoAppointments SET PersonalDataPermission = 0,
		MobilPermission = 0, EMail = '' WHERE ID = '$appid'" );
		
	$vars->db->query( "UPDATE AutoToken SET Step = 2 WHERE Token = '$$token'" );
}

1;
