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
				'expected' => '^a[a-z0-9]{63}$',
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
					{ 'name' => 't', 'value' => '7[token]' },
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
				'expected' => '^a[a-z0-9]{63}$',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::save_new_token_in_db },
		'comment' => 'save_new_token_in_db',
		'test' => { 	
			1 => { 	'tester' => \&test_write_db,
				'args' => [ 'abcdefghijklmnopqrstuvwxyz0123456789abcdefghigklmopqrstuvwxyz171' ],
				'expected' => 'abcdefghijklmnopqrstuvwxyz0123456789abcdefghigklmopqrstuvwxyz171'.
					':AutoToken:Token:abcdefghijklmnopqrstuvwxyz0123456789abcdefghigklmopqrstuvwxyz171',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_token_error },
		'comment' => 'get_token_error',
		'test' => { 	
			1 => { 	'tester' => \&test_array,
				'args' => [ '0' ],
				'expected' => [ '<center>ошибка: внутренняя ошибка</center>', '', 'autoform.tt2' ],
			},
			2 => { 	'tester' => \&test_array,
				'args' => [ '1' ],
				'expected' => [ '<center>ошибка: неправильный токен</center>', '', 'autoform.tt2' ],
			},
			3 => { 	'tester' => \&test_array,
				'args' => [ '2' ],
				'expected' => [ '<center>ошибка: такого токена не существует</center>', '', 'autoform.tt2' ],
			},
			4 => { 	'tester' => \&test_array,
				'args' => [ '3' ],
				'expected' => [ '<center>ошибка: запись уже завершена</center>', '', 'autoform.tt2' ],
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
					{
						'nearest_date' => [ 'free_date' ],
						'comment' => [ 'email' ],
						'timeslots' => [],
						'mask' => [],
						'datepicker' => []
					},
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
					{
						'nearest_date' => [],
						'comment' => [
							's_date',
							'f_date',
						],
						'timeslots' => [],
						'mask' => [
							's_date',
							'f_date',
						],
						'datepicker' => [
							's_date',
							'f_date',
						],
					},
					'[progress_bar_2]',
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
					{
						'nearest_date' => [ 'free_date' ],
						'comment' => [ 'email' ],
						'timeslots' => [],
						'mask' => [],
						'datepicker' => []
					},
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
				'expected' => '<input style="width:20em" type="text" value="val" name="element" id="element" title="comm" uniq>',
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
					'<div id="element"><input type="radio" name="element" value="1"  id="element1"><label for="element1">' .
					'first</label><br><input type="radio" name="element" value="2" checked id="element2">' .
					'<label for="element2">second</label><br><input type="radio" name="element" value="3"  '.
					'id="element3"><label for="element3">third</label><br></div>',
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
				'args' => [ 'info', 'element', 'text' ],
				'expected' => '<label id="element"><b>text</b></label>',
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
					'<div id="element"><input type="checkbox" value="test1" name="test1" ' .
					'id="test1" checked><label for="test1">Тест 1</label><br><input type=' .
					'"checkbox" value="test2" name="test2" id="test2" ><label for="test2">' .
					'Тест 2</label><br></div>',
			},
			16 => {	'tester' => \&test_line,
				'args' => [ 'checklist_insurer', 'element', 'test1=0,test2=1', { 
					'test1' => 'Тест 1',
					'test2' => 'Тест 2',
				} ],
				'expected' =>
					'<input type="checkbox" value="test1" name="element_test1" id="test1" >' .
					'<label for="test1">Тест 1</label><br><input type="checkbox" value="test2" ' .
					'name="element_test2" id="test2" ><label for="test2">Тест 2</label><br>',
			},
			17 => {	'tester' => \&test_regexp,
				'args' => [ 'captcha' ],
				'expected' =>
					'^\<img\ssrc="/vcs/static/files/[a-h0-9]+\.png"\>\<input\stype="hidden"\sname="code"\svalue="[a-h0-9]+">',
			},
			18 => {	'tester' => \&test_line,
				'args' => [ 'progress', 'test', undef, 'past', 0 ],
				'expected' =>
					'<td align="center" style="background-image: url(' . "'/images/pbar-red-red.png'" .
					');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius' .
					':12px;background:#FF6666;" title=""><div style="padding-top:7px;color:white;' .
					'font-size:30"></div></div></td>',
			},
			19 => {	'tester' => \&test_line,
				'args' => [ 'progress', 'test', undef, 'current', 1 ],
				'expected' =>
					'<td align="center" style="background-image: url(' . "'/images/pbar-white-gray.png'" .
					');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:' .
					'12px;background:#CC0033;" title=""><div style="padding-top:7px;color:white;' .
					'font-size:30"></div></div></td>',
			},
			20 => {	'tester' => \&test_line,
				'args' => [ 'progress', 'test', undef, 'future', 2 ],
				'expected' =>
					'<td align="center" style="background-image: url(' . "'/images/pbar-gray-white.png'" .
					');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:' .
					'12px;background:#999999;" title=""><div style="padding-top:7px;color:white;' .
					'font-size:30"></div></div></td>',
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
					'<tr><td><label id="text">Email</label></td><td><input style="width:20em"' .
					' type="text" value="testvalue@mail.ru" name="email" id="email" title="">' .
					'</td></tr><tr><td>&nbsp;</td><td style="vertical-align:top;"><span style=' .
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
					'<tr><td><label id="text">Средства</label></td><td><div id="test">' .
					'<input type="checkbox" value="test1" name="test1" id="test1" checked>' .
					'<label for="test1">Тест 1</label><br><input type="checkbox" value=' .
					'"test2" name="test2" id="test2" ><label for="test2">Тест 2</label>' .
					'<br></div></td></tr>',
			}
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_progressbar },
		'comment' => 'get_progressbar',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ '[page1]' ],
				'expected' => '[progress_bar]',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_finish },
		'comment' => 'get_finish',
		'test' => { 	
			1 => { 	'tester' => \&test_array,
				'expected' => [ undef, 'autoform_finish.tt2' ],
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_specials_of_element },
		'comment' => 'get_specials_of_element',
		'test' => { 	
			1 => { 	'tester' => \&test_hash,
				'args' => [ 1 ],
				'expected' => {
					'nearest_date' => [
						'free_date',
					],
					'comment' => [
						  'email'
						],
					'timeslots' => [],
					'mask' => [],
					'datepicker' => []
				},

			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::decode_data_from_db },
		'comment' => 'decode_data_from_db',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ 1, 'test', '2010-01-03' ],
				'expected' => '03.01.2010',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ 1, 'test', '03.01.2010' ],
				'expected' => '03.01.2010',
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ 1, 'test', '0000-00-00' ],
				'expected' => '',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::encode_data_for_db },
		'comment' => 'encode_data_for_db',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ 1, 'pers_info', 'pers_info' ],
				'expected' => 1,
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ 1, 'pers_info', '' ],
				'expected' => 0,
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ 1, 'email', '   email   ' ],
				'expected' => 'email',
			},
			4 => { 	'tester' => \&test_line,
				'args' => [ 1, 'email', '03.01.2010' ],
				'expected' => '2010-01-03',
			},
			5 => { 	'tester' => \&test_line,
				'args' => [ 1, 'email', '2010-01-03' ],
				'expected' => '2010-01-03',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_element_by_name },
		'comment' => 'get_element_by_name',
		'test' => { 	
			1 => { 	'tester' => \&test_hash,
				'args' => [ 1, 'email' ],
				'expected' => {
					'db' => {
							'name' => 'EMail',
							'table' => 'Appointments'
					},
					'example' => 'mail@mail.ru',
					'name' => 'email',
					'comment' => 'Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре',
					'check' => 'z',
					'type' => 'input',
					'label' => 'Email',
					'param' => {},
				},
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_names_db_for_save_or_get },
		'comment' => 'get_names_db_for_save_or_get',
		'test' => { 	
			1 => { 	'tester' => \&test_hash,
				'args' => [ '[page1]' ],
				'expected' => {
					'Auto' => {
						'' => 'free_date'
					},
					'AutoAppointments' => {
						'PersonalDataPermission' => 'pers_info',
						'CenterID' => 'center',
						'EMail' => 'email',
						'MobilPermission' => 'mobil_info',
						'VType' => 'vtype'
					}
				}
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::check_chkbox },
		'comment' => 'check_chkbox',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'true' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '1' },
				],
				'expected' => '',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'true'} ],
				'param' => [
					{ 'name' => 'test', 'value' => '' },
				],
				'expected' => 'test|Вы должны указать поле "test"',
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => '' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '' },
				],
				'expected' => '',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::check_param },
		'comment' => 'check_param',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'z'} ],
				'param' => [
					{ 'name' => 'test', 'value' => 'text' },
				],
				'expected' => '',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'z' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '' },
				],
				'expected' => 'test|Поле "test" не заполнено',
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '2010-03-01' },
				],
				'expected' => 'test|В поле "test" указана неверная дата',
			},
			4 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'W' } ],
				'param' => [
					{ 'name' => 'test', 'value' => 'abcАБВ' },
				],
				'expected' => 'test|В поле "test" введены недопустимые символы: АБВ',
			},
			5 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'Ё' } ],
				'param' => [
					{ 'name' => 'test', 'value' => 'ABCабв' },
				],
				'expected' => 'test|В поле "test" введены недопустимые символы: ABC',
			},
			6 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'N' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '123XYZ456' },
				],
				'expected' => 'test|В поле "test" введены недопустимые символы: XYZ',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::check_existing_id_in_token },
		'comment' => 'check_existing_id_in_token',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ '[appdata_id]', '[token]' ],
				'expected' => '1',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_current_table_id },
		'comment' => 'get_current_table_id',
		'test' => { 	
			1 => { 	'tester' => \&test_hash,
				'args' => [ '[token]' ],
				'expected' =>  {
					'AutoAppData' => '[appdata_id]',
					'AutoSchengenAppData' => '[schdata_id]',
					'AutoToken' => '[token_id]',
					'AutoAppointments' => '[app_id]'
				},
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::skip_by_condition },
		'comment' => 'skip_by_condition',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ 9, '8,9,10', 'only_if' ],
				'expected' => '0',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ 9, '7,8,10', 'only_if' ],
				'expected' => '1',
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ 9, '6,8,10', 'only_if_not' ],
				'expected' => '0',
			},
			4 => { 	'tester' => \&test_line,
				'args' => [ 9, '10,9,8', 'only_if_not' ],
				'expected' => '1',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::skip_page_by_relation },
		'comment' => 'skip_page_by_relation',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ 'only_if', { 'value' => '13', 'name' => 'VType', 'table' => 'Appointments' }, '[token]' ],
				'expected' => '0',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ 'only_if_not', { 'value' => '13', 'name' => 'VType', 'table' => 'Appointments' }, '[token]' ],
				'expected' => '1',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_same_info_for_timeslots },
		'comment' => 'get_same_info_for_timeslots',
		'test' => { 	
			1 => { 	'tester' => \&test_hash,
				'prepare' => \&pre_getinfo,
				'args' => [ '[token]' ],
				'expected' =>  {
					'persons' => '1',
					'center' => '5',
					'fdate' => '01.05.2011',
				},
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::init_add_param },
		'comment' => 'init_add_param',
		'test' => { 	
			1 => { 	'tester' => \&test_hash,
				'prepare' => \&pre_init_param,
				'args' => [ 
					{ 
						1 => [
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
						] 
					}, 
					'[token]' 
				],
				'expected' => { 
					1 => [
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
							'param' => {
								'1' => 'Moscow',
							}
						},
					]
				},
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_content_rules },
		'comment' => 'get_content_rules',
		'test' => { 	
			1 => { 	'tester' => \&test_array,
				'args' => [ '2', 'full', '[token]' ],
				'expected' =>  
				[
					[
						{
							'page_name' => 'Данные поездки',
							'page_ord' => 2,
							'progress' => 2,
							'param' => {},
						},
						{
							'type' => 'input',
							'name' => 's_date',
							'label' => 'Дата начала поездки',
							'comment' => 'Введите предполагаемую дату начала поездки',
							'example' => '01.01.2025',
							'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
							'check_logic' => [
								{
									'condition' => 'now_or_later',
								},
							],
							'db' => {
								'table' => 'Appointments',
								'name' => 'SDate',
							},
							'special' => 'datepicker, mask',
							'param' => {},
						},
						{
							'type' => 'input',
							'name' => 'f_date',
							'label' => 'Дата окончания поездки',
							'comment' => 'Введите предполагаемую дату окончания поездки',
							'example' => '31.12.2025',
							'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
							'check_logic' => [
								{
									'condition' => 'equal_or_later',
									'table' => 'Appointments',
									'name' => 'SDate',
									'error' => 'Дата начала поездки',
								},
								{
									'condition' => 'equal_or_earlier',
									'table' => 'Appointments',
									'name' => 'SDate',
									'error' => 'Дата начала поездки',
								},
							],
							'db' => {
								'table' => 'Appointments',
								'name' => 'FDate',
							},
							'special' => 'datepicker, mask',
							'param' => {},
						},
					],
				],
			},
			2 => { 	'tester' => \&test_array,
				'args' => [ '2', undef, '[token]' ],
				'expected' =>  
				[
					[
						{
							'type' => 'input',
							'name' => 's_date',
							'label' => 'Дата начала поездки',
							'comment' => 'Введите предполагаемую дату начала поездки',
							'example' => '01.01.2025',
							'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
							'check_logic' => [
								{
									'condition' => 'now_or_later',
								},
							],
							'db' => {
								'table' => 'Appointments',
								'name' => 'SDate',
							},
							'special' => 'datepicker, mask',
							'param' => {},
						},
						{
							'type' => 'input',
							'name' => 'f_date',
							'label' => 'Дата окончания поездки',
							'comment' => 'Введите предполагаемую дату окончания поездки',
							'example' => '31.12.2025',
							'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
							'check_logic' => [
								{
									'condition' => 'equal_or_later',
									'table' => 'Appointments',
									'name' => 'SDate',
									'error' => 'Дата начала поездки',
								},
								{
									'condition' => 'equal_or_earlier',
									'table' => 'Appointments',
									'name' => 'SDate',
									'error' => 'Дата начала поездки',
								},
							],
							'db' => {
								'table' => 'Appointments',
								'name' => 'FDate',
							},
							'special' => 'datepicker, mask',
							'param' => {},
						},
					],
				],
			},
			3 => { 	'tester' => \&test_regexp,
				'args' => [ 'length', undef, '[token]' ],
				'expected' => '^\d+$',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::set_current_app_finished },
		'comment' => 'set_current_app_finished',
		'test' => { 	
			1 => { 	'tester' => \&test_write_db,
				'prepare' => \&pre_app_finish,
				'args' => [ '[appdata_id]' ],
				'expected' => '[appdata_id]:AutoAppData:Finished:1',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::query },
		'comment' => 'query',
		'test' => { 	
			1 => { 	'tester' => \&test_write_db,
				'args' => [ 'query', 'UPDATE AutoAppData SET Finished = 5 WHERE ID = ?', {}, '[appdata_id]' ],
				'expected' => '[appdata_id]:AutoAppData:Finished:5',
			},
			2 => { 	'tester' => \&test_line,
				'prepare' => \&pre_query,
				'args' => [ 'sel1', 'SELECT Finished FROM AutoAppData WHERE ID = ?', '[appdata_id]' ],
				'expected' => '15',
			},
			3 => { 	'tester' => \&test_array,
				'prepare' => \&pre_query,
				'args' => [ 'selall', 'SELECT Finished FROM AutoAppData WHERE ID = ?', '[appdata_id]' ],
				'expected' => [ [ [ '15' ] ] ],
			},
			4 => { 	'tester' => \&test_array,
				'prepare' => \&pre_query,
				'args' => [ 'selallkeys', 'SELECT Finished FROM AutoAppData WHERE ID = ?', '[appdata_id]' ],
				'expected' => [ [ { 'Finished' => '15' } ] ],
			},
		},
	},
	{	'func' 	=> \&{ VCS::Site::autoform::get_hash_table },
		'comment' => 'get_hash_table',
		'test' => { 	
			1 => { 	'tester' => \&test_hash,
				'prepare' => \&pre_init_param,
				'args' => [ 'Branches', '1' ],
				'expected' => {
					'ID' => '1',	
					'BName' => 'Moscow',
					'Ord' => '1',
					'Timezone' => '3',
					'isDeleted' => '0',
					'isDefault' => '1',
					'Display' => '1',
					'Insurance' => '1',
					'BAddr' => 'г.Москва',
					'JAddr' => 'г.Москва',
					'AddrEqualled' => '0',
					'SenderID' => '1',
					'SenderCity' => '26',
					'CTemplate' => 'rtf',
					'isConcil' => '0',
					'isSMS' => '1',
					'isUrgent' => '1',
					'posShipping' => '1',
					'isDover' => '1',
					'calcInsurance' => '0',
					'cdSimpl' => '3',
					'cdUrgent' => '2',
					'cdCatD' => '14',
					'CollectDate' => '1',
					'siteLink' => 'http',
					'calcConcil' => '0',
					'ConsNDS' => '0',
					'genbank' => '0',
					'isTranslate' => '0',
					'shengen' => '1',
					'isAnketa' => '1',
					'isPrinting' => '0',
					'isPhoto' => '0',
					'isVIP' => '1',
					'Weekend' => '67',
					'isShippingFree' => '0',
					'isPrepayedAppointment' => '1',
					'DefaultPaymentMethod' => '1',
					'DisableAppSameDay' => '0',
				},
			},
		},
	},
	{	'func' 	=> \&{ VCS::Site::autoform::create_table },
		'comment' => 'create_table',
		'test' => { 	
			1 => { 	'tester' => \&test_regexp,
				'args' => [ 
					'AutoAppointments', 'Appointments', { 'AutoAppointments' => '[app_id]' }, 
					{
						'Appointments' => { 
							'PersonalDataPermission' => 'nope',
							'MobilPermission' => 'nope',
							'PersonForAgreements' => 'nope',
						}
					}
				],
				'expected' => '^[1-9]\d*$',
			},
			
			# .......
		},
	},
	{	'func' 	=> \&{ VCS::Site::autoform::age },
		'comment' => 'age',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ '1999-06-23', '2017-06-15' ],
				'expected' => '17',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ '1999-06-22', '2017-06-15' ],
				'expected' => '18',
			},
		},
	},
	
];

my $progress_bar = '<td align="center" style="background-image: url('."'".'/images/pbar-white-gray.png'."'".');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#CC0033;" title=""><div style="padding-top:7px;color:white;font-size:30">1</div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Данные"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#999999;" title=""><div style="padding-top:7px;color:white;font-size:30">2</div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Паспорта"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Допданные"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Поездка"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Проживание"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Расходы"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Ещё?"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="На кого?"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Данные"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#999999;" title=""><div style="padding-top:7px;color:white;font-size:30">3</div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Офис"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-gray.png'."'".');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Подтверждение"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url('."'".'/images/pbar-gray-white.png'."'".');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#999999;" title=""><div style="padding-top:7px;color:white;font-size:30">4</div></div></td></tr><tr><td style="padding:5px;text-align:center;">Начало</td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;">Заявители</td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;">Оформление</td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;">Готово!</td>';

my $progress_bar_2 = '<td align="center" style="background-image: url(\'/images/pbar-white-red.png\');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#FF6666;" title=""><div style="padding-top:7px;color:white;font-size:30">1</div></div></td><td align="center" style="background-image: url(\'/images/pbar-red-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#CC0033;" title="Данные"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#999999;" title=""><div style="padding-top:7px;color:white;font-size:30">2</div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Паспорта"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Допданные"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Поездка"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Проживание"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Расходы"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Ещё?"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="На кого?"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Данные"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#999999;" title=""><div style="padding-top:7px;color:white;font-size:30">3</div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Офис"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-gray.png\');background-size: 100% 100%;"><div style="width:24px;height:24px;border-radius:12px;background:#999999;" title="Подтверждение"><div style="padding-top:7px;color:white;font-size:30"></div></div></td><td align="center" style="background-image: url(\'/images/pbar-gray-white.png\');background-size: 100% 100%;"><div style="width:50px;height:50px;border-radius:25px;background:#999999;" title=""><div style="padding-top:7px;color:white;font-size:30">4</div></div></td></tr><tr><td style="padding:5px;text-align:center;">Начало</td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;">Заявители</td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;">Оформление</td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;"></td><td style="padding:5px;text-align:center;">Готово!</td>';

my $first_page = '<tr><td><label id="text">Визовый центр</label></td><td><select size = "1" name="center" id="center" onchange="update_nearest_date_free_date();"></select></td></tr><tr><td><label id="text">Тип визы</label></td><td><select size = "1" name="vtype" id="vtype"></select></td></tr><tr><td><label id="text">Ближайшее доступное время</label></td><td><label id="free_date"><b>[text]</b></label></td></tr><tr><td><label id="text">Email</label></td><td><input style="width:20em" type="text" value="" name="email" id="email" title="Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре"></td></tr><tr><td>&nbsp;</td><td style="vertical-align:top;"><span style="color:gray; font-size:0.7em;">mail@mail.ru</span></td></td><tr><td><label id="text"></label></td><td><input type="checkbox" value="pers_info" name="pers_info" id="pers_info"><label for="pers_info">я согласен на обработку персональных данных</label></td></tr><tr><td><label id="text"></label></td><td><input type="checkbox" value="mobil_info" name="mobil_info" id="mobil_info"><label for="mobil_info">я согласен на условия работы с мобильными телефона на территории визового центра</label></td></tr>';

my $second_page = '<tr><td><label id="text">Дата начала поездки</label></td><td><input style="width:20em" type="text" value="" name="s_date" id="s_date" title="Введите предполагаемую дату начала поездки"></td></tr><tr><td>&nbsp;</td><td style="vertical-align:top;"><span style="color:gray; font-size:0.7em;">01.01.2025</span></td></td><tr><td><label id="text">Дата окончания поездки</label></td><td><input style="width:20em" type="text" value="" name="f_date" id="f_date" title="Введите предполагаемую дату окончания поездки"></td></tr><tr><td>&nbsp;</td><td style="vertical-align:top;"><span style="color:gray; font-size:0.7em;">31.12.2025</span></td></td>';

sub selftest 
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{ 'VCS::Vars' };
	my $config = $vars->getConfig('db');
	
	$vars->db->query("USE fake_vcs");

	my $result = [ { 'text' => "self_self_test", 'status' => self_self_test() } ];
	
	my @param = get_test_appointments( $self, $vars );
	
	push @$result, { 'text' => 'create_clear_form', 'status' => ( ( $param[0] =~ /^A[a-z0-9]{63}$/ ) and ( $param[1] =~ /^\d+$/ ) ? 0 : 1 ) };
	push @$result, { 'text' => 'get_add', 'status' => ( ( $param[1] =~ /^\d+$/ ) ? 0 : 1 ) };
	push @$result, get_tests( $self, $vars, @param );
	
	$vars->db->query( "USE $config->{'dbname'}" );	

	return show_result($result);
}

sub get_test_appointments
{
	my $self = shift;
	my $vars = shift;
	
	my $test_token = $self->get_token_and_create_new_form_if_need();
	
	$self->create_clear_form( $test_token );
	
	my $appid = $vars->db->sel1("
		SELECT AutoAppID FROM AutoToken WHERE Token = ?", $test_token);
	
	$self->get_add( $appid, $test_token );

	my @param = $vars->db->sel1("
		SELECT AutoAppDataID, AutoSchengenAppDataID, ID FROM AutoToken WHERE Token = ?", $test_token);

	return ( $test_token, $appid, @param );
}

sub get_tests
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = shift;
	my $test_token = shift;
	my $test_appid = shift;
	my $test_appdataid = shift;
	my $test_appdata_schid = shift;
	my $token_id = shift;

	my @result = ();
	
	for my $test (@$tests) {
	
		my $err_line = '';
		my $test_num = 0;
		
		for( sort { $a <=> $b } keys %{ $test->{test} } ) {
	
			$test_num++;
			
			my $t = $test->{test}->{$_};
			
			&{ $t->{prepare} }( 'PREPARE', \$test, $_, \$test_token, $test_appid, $test_appdataid, $vars ) 
				if ref( $t->{prepare} ) eq 'CODE';
			
			for (	@{ $t->{args} }, 
				@{ $t->{param} },
				( ref( $t->{expected} ) eq 'ARRAY' ? @{ $t->{expected} } : 
				( ref( $t->{expected} ) eq 'HASH' ? values %{ $t->{expected} } : $t->{expected} ) 
				)
			) {
				s/\[token\]/$test_token/g;
				s/\[token_id\]/$token_id/g;
				s/\[app_id\]/$test_appid/g;
				s/\[appdata_id\]/$test_appdataid/g;
				s/\[schdata_id\]/$test_appdata_schid/g;
				s/\[progress_bar\]/$progress_bar/g;
				s/\[progress_bar_2\]/$progress_bar_2/g;
				s/\[first_page\]/$first_page/g;
				s/\[second_page\]/$second_page/g;
				
				$_ = $self->get_content_rules( 1, 'full' ) if /\[page1\]/;
				
				if ( ref($_) eq 'HASH' ) {
					for my $field ( keys %$_ ) {
						$_->{ $field } =~ s/\[token\]/$test_token/g;
						$_->{ $field } =~ s/\[app_id\]/$test_appid/g;
					}
				}
			}
			
			for ( @{ $t->{param} } ) {
				$vars->setparam( $_->{name} ,$_->{value} );
			}

			my $test_result =  &{ $t->{tester} }( 
				$t->{debug}, $t->{expected}, "$test->{comment}-$test_num", $self, 
				&{ $test->{func} }( $self, @{ $t->{args} } )
			);
			
			if ( $test_result ) {
				$err_line .= ( $err_line ? ', ' : '' ) . $test_num;
			}
			
			&{ $t->{prepare} }( 'CLEAR', \$test, $_, \$test_token, $test_appid, $test_appdataid, $vars ) 
				if ref( $t->{prepare} ) eq 'CODE';
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
	
	my $test_num = 18; 	# 15 self_self + create_clear_form + get_add
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
	$result_line .= self_test_htm( 'br' ) . self_test_htm( 'span', ( $fails ? 'red' : 'green' ), "Всего тестов: $test_num" );
	
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
	my $self_debug = 0;

	$fail_in_myself += test_line( $self_debug, '12345ABCD', 'self1', undef, '12345ABCD' );
	$fail_in_myself += test_line_in_hash( $self_debug, 'key2:value2', 'self2', undef, { 'key1' => 'value1', 'key2' => 'value2' } );
	$fail_in_myself += test_array( $self_debug, [ '1', 'A', '2', 'B' ], 'self3', $self, ( '1', 'A', '2', 'B' ) );
	$fail_in_myself += test_array_ref( $self_debug, [ '1', 'A', '2', 'B' ], 'self4', $self, [ '1', 'A', '2', 'B' ] );
	$fail_in_myself += test_regexp( $self_debug, '^[A-D]+[0-5]+$', 'self5', undef, 'ABCD12345' );

	$fail_in_myself += test_hash( $self_debug, { 'key1' => 'value1', 'key2' => 'value2' }, 'self6', undef, 
		{ 'key1' => 'value1', 'key2' => 'value2' } );
	$fail_in_myself += test_hash( $self_debug, { 'key1' => 'value1', 'key2' => [ { 'key3' => [ 1, 2, 3 ] } ] }, 'self7', undef, 
		{ 'key1' => 'value1', 'key2' => [ { 'key3' => [ 1, 2, 3 ] } ] } );	

	$fail_in_myself += ! test_line( $self_debug, '12345ABCD', 'self8', undef, '12345ABCD0' );
	$fail_in_myself += ! test_line_in_hash( $self_debug, 'key2:value2', 'self9', undef, { 'key1' => 'value2', 'key2' => 'value1' } );
	$fail_in_myself += ! test_array( $self_debug, [ '1', 'A', '2', 'B', '3' ], 'self10', $self, ( '1', 'A', '2', 'B' ) );
	$fail_in_myself += ! test_array_ref( $self_debug, [ '1', 'A', '2', 'B' ], 'self11', $self, [ '1', 'A', '2', 'B', '3' ] );
	$fail_in_myself += ! test_regexp( $self_debug, '^[A-D]+[0-5]+$', 'self12', undef, 'ABC1234 5' );

	$fail_in_myself += ! test_hash( $self_debug, { 'key1' => 'value1', 'key2' => [ 1, 2, 3 ] }, 'self3', undef, 
		{ 'key1' => 'value1', 'key2' => ( 1, 3, 2 ) } );
	$fail_in_myself += ! test_hash( $self_debug, { 'key1' => 'value1', 'key2' => 'value2' }, 'self14', undef, 
		{ 'key1' => 'value1', 'key2' => 'value2', 'key3' => 'value3' } );
	$fail_in_myself += ! test_hash( $self_debug, { 'key1' => 'value1', 'key2' => [ { 'key3' => [ 1, 2, 3 ] } ] }, 'self15', undef, 
		{ 'key1' => 'value1', 'key2' => [ { 'key3' => [ 2, 1, 3 ] } ] } );
		
	return $fail_in_myself;
}

sub recursive_check
# //////////////////////////////////////////////////
{
	my ( $debug, $expect, $comm, undef, $result ) = @_;
	my $not_eq = 0;
	
	if ( ( ref( $result ) eq 'ARRAY' ) and ( ref( $expect ) eq 'ARRAY' ) ) {
		return 0 if ( $#$result < 0 ) and ( $#$expect < 0 );
		$not_eq += ( test_array_ref( $debug, $expect, $comm, undef, $result ) ? 1 : 0 );
	}
	elsif ( ( ref( $result ) eq 'HASH' ) and ( ref( $expect ) eq 'HASH' ) ) {
		return 0 if ( !%$result ) and ( !%$expect );
		$not_eq += ( test_hash( $debug, $expect, $comm, undef, $result ) ? 1 : 0 );
	}
	else {
		$not_eq += 1 if $expect ne $result;
	}
	
	return $not_eq;
	
}

sub test_line
# //////////////////////////////////////////////////
{
	my ( $debug, $expected, $comm, undef, $result ) = @_;

	warn "$expected\n$result" if $debug;
	
	if ( lc( $expected ) ne lc( $result ) ) {
		return $comm;
	};
}

sub test_line_in_hash
# //////////////////////////////////////////////////
{
	my ( $debug, $expected, $comm, undef, $result ) = @_;
	my ( $key, $value ) = split /:/, $expected;
	
	warn Dumper( $expected, $result ) if $debug;

	if ( lc( $result->{ $key } ) ne lc( $value ) ) { 
		return $comm;
	};
}

sub test_hash
# //////////////////////////////////////////////////
{
	my ( $debug, $expected, $comm, undef, $result ) = @_;
	my $not_eq = 0;

	warn Dumper( $expected, $result ) if $debug;
	
	for ( keys %$expected, keys %$result ) {
		$not_eq += ( recursive_check( $debug, $expected->{ $_ }, $comm, undef, $result->{ $_ } ) ? 1 : 0 );
	}

	if ( $not_eq ) {
		return 1;
	};
}

sub test_array
# //////////////////////////////////////////////////
{
	my $debug = shift;
	my $expected = shift;
	my $comm = shift;
	my $self = shift;
	my @result = @_;
	
	my $not_eq = 0;
	
	warn Dumper( $expected, \@result ) if $debug;
	
	return 0 if ( $#result < 0 ) and ( $#$expected < 0 );
	return 1 if ( $#result < 0 ) or ( $#$expected < 0 );
	return 1 if ( $#result != $#$expected );

	for ( 0..$#result ) {
		$not_eq += ( recursive_check( $debug, $expected->[$_], $comm, undef, $result[$_] ) ? 1 : 0 );
	}

	if ( $not_eq ) { 
		return 1;
	};
}

sub test_array_ref
# //////////////////////////////////////////////////
{
	my ( $debug, $expected, $comm, $self, $result ) = @_;

	warn Dumper( $expected, $result ) if $debug;
	
	my $not_eq = 0;
	
	return 0 if ( $#$result < 0 ) and ( $#$expected < 0 );
	return 1 if ( $#$result < 0 ) or ( $#$expected < 0 );
	return 1 if ( $#$result != $#$expected );


	for ( 0..$#$result ) {
		$not_eq += ( recursive_check( $debug, $expected->[$_], $comm, undef, $result->[$_] ) ? 1 : 0 );
	}
	
	if ( $not_eq ) { 
		return 1;
	};
}

sub test_regexp
# //////////////////////////////////////////////////
{
	my ( $debug, $regexp, $comm, undef, $result ) = @_;
	
	warn "$regexp\n$result" if $debug;
	
	if ( $result !~ /$regexp/ ) {
		return $comm;
	}
}

sub test_write_db
# //////////////////////////////////////////////////
{
	my $debug = shift;
	my ( $token_or_appid, $db_table, $db_name, $db_value ) = split /:/, shift;
	my ( $comment, $self, $result ) = @_;

	my $vars = $self->{ 'VCS::Vars' };
	
	my $field = ( $token_or_appid =~ /^(a[a-z0-9]{63}|Token)$/ ? "Token" : "ID" );
	
	my $value = $vars->db->sel1("
			SELECT $db_name FROM $db_table WHERE $field = '$token_or_appid'" );

	if ( lc( $db_value ) ne lc( $value ) ) {
		return $comment;
	}
}

sub pre_corrupt_token
# //////////////////////////////////////////////////
{
	my ( $type, $test, $num, $token ) = @_;
	
	if ( $type eq 'PREPARE' ) { 
		$$token =~ s/^a/F/;
	}
	else {
		$$token =~ s/^F/a/;
	}	
}

sub pre_finished
# //////////////////////////////////////////////////
{
	my ( $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	if ( $type eq 'PREPARE' ) { 
		$vars->db->query("
			UPDATE AutoToken SET Finished = 1 WHERE Token = '$$token'" );
	} 
	else {
		$vars->db->query("
			UPDATE AutoToken SET Finished = 0 WHERE Token = '$$token'" );
	}
}

sub pre_content_1
# //////////////////////////////////////////////////
{
	my ( $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	$vars->db->query("
		UPDATE AutoToken SET Step = 1 WHERE Token = '$$token'" );
}

sub pre_content_2
# //////////////////////////////////////////////////
{
	my ( $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	$vars->db->query("
		UPDATE AutoAppointments SET PersonalDataPermission = 0, MobilPermission = 0, EMail = '' 
		WHERE ID = '$appid'" );
		
	$vars->db->query("
		UPDATE AutoToken SET Step = 2 WHERE Token = '$$token'" );
}

sub pre_getinfo
# //////////////////////////////////////////////////
{
	my ( $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	$vars->db->query("
		UPDATE AutoAppointments SET SDate = '2011-05-01', CenterID = '5'
		WHERE ID = '$appid'" );
}

sub pre_init_param
# //////////////////////////////////////////////////
{
	my ( $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	my $info_from_db = $vars->get_memd->delete('autoform_addparam');
	
	if ( $type eq 'PREPARE' ) { 
		$vars->db->query("
			INSERT INTO Branches (ID, BName, Ord, Timezone, isDeleted, isDefault, Display, 
			Insurance, BAddr, JAddr, AddrEqualled, SenderID, SenderCity, CTemplate, isConcil, 
			isSMS, isUrgent, posShipping, isDover, calcInsurance, cdSimpl, cdUrgent, cdCatD, 
			CollectDate, siteLink, calcConcil, ConsNDS, genbank, isTranslate, shengen, isAnketa, 
			isPrinting, isPhoto, isVIP, Weekend, isShippingFree, isPrepayedAppointment, 
			DefaultPaymentMethod, DisableAppSameDay) 
			VALUES (1, 'Moscow', 1, 3, 0, 1, 1, 1, 'г.Москва', 'г.Москва', 0, 1, 26, 'rtf', 
			0, 1, 1, 1, 1, 0, 3, 2, 14, 1, 'http', 0, 0, 0, 0, 1, 1, 0, 0, 1, 67, 0, '1', 1, 0)");
	} 
	else {
		$vars->db->query("
			DELETE FROM Branches");
	}
}

sub pre_app_finish
# //////////////////////////////////////////////////
{
	my ( $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	$vars->db->query("
		UPDATE AutoAppData SET Finished = 0 WHERE ID = ?", {}, 
		$appdataid );
}

sub pre_query
# //////////////////////////////////////////////////
{
	my ( $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	if ( $type eq 'PREPARE' ) { 
		$vars->db->query("
			UPDATE AutoAppData SET Finished = 15 WHERE ID = ?", {}, 
			$appdataid );
	}
	else {
		$vars->db->query("
			UPDATE AutoAppData SET Finished = 0 WHERE ID = ?", {}, 
			$appdataid );
	}
}

1;