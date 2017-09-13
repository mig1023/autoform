package VCS::Site::autoselftest;
use strict;

use VCS::Vars;
use Data::Dumper;


sub get_test_list {

	my $tests = [
		{ 	'func' 	=> \&{ VCS::Site::autoform::get_token_and_create_new_form_if_need },
			'comment' => 'get_token_and_create_new_form_if_need',
			'test' => {	
				1 => { 	'tester' => \&test_regexp,
					'args' => [],
					'expected' => '^t[a-z0-9]{63}$',
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
					'expected' => '^t[a-z0-9]{63}$',
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
		{ 	'func' 	=> \&{ VCS::Site::autoform::get_page_error },
			'comment' => 'get_page_error',
			'test' => { 	
				1 => { 	'tester' => \&test_array,
					'args' => [ '0' ],
					'expected' => [ '<center>ошибка: для правильной работы анкеты необходимо, чтобы в браузере' .
							' был включён javascript</center>', '', 'autoform.tt2' ],
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
							'timeslots' => [],
							'mask' => [],
							'datepicker' => [],
							'with_map' => [],
							'post_index' => [],
						},
						'[progress_bar]',
						undef,
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
							'timeslots' => [],
							'mask' => [
								's_date',
								'f_date',
							],
							'datepicker' => [
								's_date',
								'f_date',
							],
							'with_map' => [],
							'post_index' => [],
						},
						'[progress_bar_2]',
						undef,
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
						'[first_page_selected]', 
						'',
						'autoform.tt2',
						{
							'nearest_date' => [ 'free_date' ],
							'timeslots' => [],
							'mask' => [],
							'datepicker' => [],
							'with_map' => [],
							'post_index' => [],
						},
						'[progress_bar]',
						undef,
					],
				},
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
				2 => { 	'tester' => \&test_line_in_hash,
					'args' => [ { VisaPurpose => '2' } ],
					'expected' => 'VisaPurpose:0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0',
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
				5 => { 	'tester' => \&test_line_in_hash,
					'args' => [ { ID => '100' } ],
					'expected' => 'ID:',
				},
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
					'expected' => '|Вы должны полностью заполнить анкеты или удалить ненужные черновики',
				},
				5 => { 	'tester' => \&test_line,
					'args' => [ 7, { 'name' => 'test', 'label_for' => 'label_for' }, 
						undef, 'label2', 400 ],
					'expected' => 'test|"label_for" не может быть раньше, чем "label2" на 1 год',
				},
			},
		},
		{ 	'func' 	=> \&{ VCS::Site::autoform::resort_with_first_elements },
			'comment' => 'resort_with_first_elements',
			'test' => { 	
				1 => { 	'tester' => \&test_array,
					'args' => [ { 10 => 10, 20 => 20, 30 => 30, 50 => 50, 40 => 40 }, '20, 40' ],
					'expected' => [ 20, 40, 10, 30, 50 ],
				},
				2 => { 	'tester' => \&test_array,
					'args' => [ { 10 => 10, 20 => 20, 30 => 30, 50 => 50, 40 => 40 } ],
					'expected' => [ 10, 20, 30, 40, 50 ],
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
					'expected' => '<input class="input_width input_gen optional_field" type="text" value="val" ' .
						'name="element" id="element" title="comm" uniq>',
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
						'<select class="input_width select_gen" size = "1" name="element" title="" id="element">' .
						'<option  value="2">second</option><option  value="1">first</option>' .
						'<option  value="4">fourth</option><option selected value="3">third</option></select>',
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
					'expected' => '<tr class="mobil_hide"><td class="exam_td_gen"><span class="exam_span_gen">пример: text</span></td>',
				},
				12 => {	'tester' => \&test_line,
					'args' => [ 'info', 'element', 'text' ],
					'expected' => '<label class="info" id="element">text</label>',
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
				17 => {	'tester' => \&test_line,
					'args' => [ 'progress', 'test', undef, 'past', 0 ],
					'expected' =>
						'<td align="center" class="pr_size_gen pr_red_red_gen">' .
						'<div class="ltl_progr pr_past" title=""><div class="pr_in_gen"></div></div></td>',
				},
				18 => {	'tester' => \&test_line,
					'args' => [ 'progress', 'test', undef, 'current', 1 ],
					'expected' =>
						'<td align="center" class="pr_size_gen pr_white_gray_gen">' .
						'<div class="ltl_progr pr_current" title=""><div class="pr_in_gen"></div></div></td>',
				},
				19 => {	'tester' => \&test_line,
					'args' => [ 'progress', 'test', undef, 'future', 2 ],
					'expected' =>
						'<td align="center" class="pr_size_gen pr_gray_white_gen">' .
						'<div class="ltl_progr pr_future" title=""><div class="pr_in_gen"></div></div></td>',
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
						'<tr><td rowspan=2><label id="text">Email</label></td><td><input class="input_width input_gen" type="text" value="testvalue@mail.ru" name="email" id="email" title=""></td></tr><tr class="mobil_hide"><td class="exam_td_gen"><span class="exam_span_gen">пример: mail@mail.ru</span></td>',
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
						'timeslots' => [],
						'mask' => [],
						'datepicker' => [],
						'post_index' => [],
						'with_map' => [],
					},

				},
				2 => { 	'tester' => \&test_hash,
					'args' => [ 2 ],
					'expected' => {
						'nearest_date' => [],
						'timeslots' => [],
						'mask' => [
							's_date',
							'f_date',
						],
						'datepicker' => [
							's_date',
							'f_date',
						],
						'post_index' => [],
						'with_map' => [],
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
						'check' => 'zWN\@\s\-\.\,\;',
						'type' => 'input',
						'label' => 'Email',
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
						},
						'alternative_data_source' => {},
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
					'args' => [ 12, '12', 'only_if' ],
					'expected' => '0',
				},
				2 => { 	'tester' => \&test_line,
					'args' => [ 9, '8,9,10', 'only_if' ],
					'expected' => '0',
				},
				3 => { 	'tester' => \&test_line,
					'args' => [ 9, '7,8,10', 'only_if' ],
					'expected' => '1',
				},
				4 => { 	'tester' => \&test_line,
					'args' => [ 9, '6,8,10', 'only_if_not' ],
					'expected' => '0',
				},
				5 => { 	'tester' => \&test_line,
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
					'args' => [ 'only_if', { 'value' => '12', 'name' => 'VType', 'table' => 'Appointments' }, '[token]' ],
					'expected' => '1',
				},
				3 => { 	'tester' => \&test_line,
					'args' => [ 'only_if_not', { 'value' => '12', 'name' => 'VType', 'table' => 'Appointments' }, '[token]' ],
					'expected' => '0',
				},
				4 => { 	'tester' => \&test_line,
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
						'[token]',
						{ 'param' => 1 },
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
					'args' => [ '2', 'full', '[token]', 'init' ],
					'expected' =>  
					[
						[
							{
								'page_name' => 'Данные поездки',
								'page_ord' => 2,
								'progress' => 2,
								'collect_date' => 1,
								'param' => {}
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
										'offset' => 0,
									},
								],
								'db' => {
									'table' => 'Appointments',
									'name' => 'SDate',
								},
								'special' => 'datepicker, mask',
								'param' => {}
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
								],
								'db' => {
									'table' => 'Appointments',
									'name' => 'FDate',
								},
								'special' => 'datepicker, mask',
								'param' => {}
							},
						],
					],
				},
				2 => { 	'tester' => \&test_array,
					'args' => [ '2', undef, '[token]', 'init' ],
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
										'offset' => 0,
									},
								],
								'db' => {
									'table' => 'Appointments',
									'name' => 'SDate',
								},
								'special' => 'datepicker, mask',
								'param' => {}
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
								],
								'db' => {
									'table' => 'Appointments',
									'name' => 'FDate',
								},
								'special' => 'datepicker, mask',
								'param' => {}
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
					'args' => [ 'query', 'test', 'UPDATE AutoAppData SET Finished = 5 WHERE ID = ?', {}, '[appdata_id]' ],
					'expected' => '[appdata_id]:AutoAppData:Finished:5',
				},
				2 => { 	'tester' => \&test_line,
					'prepare' => \&pre_query,
					'args' => [ 'sel1', 'test', 'SELECT Finished FROM AutoAppData WHERE ID = ?', '[appdata_id]' ],
					'expected' => '15',
				},
				3 => { 	'tester' => \&test_array,
					'prepare' => \&pre_query,
					'args' => [ 'selall', 'test', 'SELECT Finished FROM AutoAppData WHERE ID = ?', '[appdata_id]' ],
					'expected' => [ [ [ '15' ] ] ],
				},
				4 => { 	'tester' => \&test_array,
					'prepare' => \&pre_query,
					'args' => [ 'selallkeys', 'test', 'SELECT Finished FROM AutoAppData WHERE ID = ?', '[appdata_id]' ],
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
		{ 	'func' 	=> \&{ VCS::Site::autoform::lang },
			'comment' => 'lang',
			'test' => { 	
				1 => { 	'tester' => \&test_line,
					'prepare' => \&pre_lang,
					'args' => [ 'Дата вылета' ],
					'expected' => 'Departure date',
				},
				2 => { 	'tester' => \&test_line,
					'prepare' => \&pre_lang,
					'args' => [ 'Фраза не имеющая никакого перевода' ],
					'expected' => 'Фраза не имеющая никакого перевода',
				},
			},
		},
		{ 	'func' 	=> \&{ VCS::Site::autoform::add_css_class },
			'comment' => 'add_css_class',
			'test' => { 	
				1 => { 	'tester' => \&test_line,
					'args' => [ '<label class="info">text</label>', 'class2' ],
					'expected' => '<label class="info class2">text</label>',
				},
				2 => { 	'tester' => \&test_line,
					'args' => [ '<label id="name">text</label>', 'class2' ],
					'expected' => '<label class="class2" id="name">text</label>',
				},
			},
		},
		{ 	'func' 	=> \&{ VCS::Site::autoform::offset_calc },
			'comment' => 'offset_calc',
			'test' => { 	
				1 => { 	'tester' => \&test_line,
					'args' => [ '1' ],
					'expected' => '1 день',
				},
				2 => { 	'tester' => \&test_line,
					'args' => [ '2' ],
					'expected' => '2 дня',
				},
				3 => { 	'tester' => \&test_line,
					'args' => [ '59' ],
					'expected' => '59 дней',
				},
				4 => { 	'tester' => \&test_line,
					'args' => [ '60' ],
					'expected' => '2 месяца',
				},
				5 => { 	'tester' => \&test_line,
					'args' => [ '187' ],
					'expected' => '6 месяцев',
				},
				6 => { 	'tester' => \&test_line,
					'args' => [ '365' ],
					'expected' => '1 год',
				},
				7 => { 	'tester' => \&test_line,
					'args' => [ '1100' ],
					'expected' => '3 года',
				},
				8 => { 	'tester' => \&test_line,
					'args' => [ '3650' ],
					'expected' => '10 лет',
				},
			},
		},
		{ 	'func' 	=> \&{ VCS::Site::autoform::cached },
			'comment' => 'cached',
			'test' => { 	
				1 => { 	'tester' => \&test_line,
					'prepare' => \&pre_cach,
					'args' => [ 'cach_selftest' ],
					'expected' => 'cash_ok',
				},
				2 => { 	'tester' => \&test_line,
					'prepare' => \&pre_cach,
					'args' => [ 'cach_selftest_fail' ],
					'expected' => '',
				},
				3 => { 	'tester' => \&test_line,
					'args' => [ 'cach_selftest' ],
					'expected' => '',
				},
				
			},
		},
		{ 	'func' 	=> \&{ VCS::Site::autoform::get_file_content },
			'comment' => 'get_file_content',
			'test' => { 	
				1 => { 	'tester' => \&test_line,
					'prepare' => \&pre_file,
					'args' => [ '/tmp/autoform_selftest_file' ],
					'expected' => 'file_ok',
				},
				2 => { 	'tester' => \&test_line,
					'args' => [ '/tmp/autoform_not_existing_file' ],
					'expected' => '',
				},
			},
		},
	];
	
	my $test_obj = bless $tests, 'test';
	return $test_obj;
}

my $progress_bar = 
	'<td align="center" class="pr_size_gen pr_white_gray_gen"><div class="big_progr pr_current" title=""><div class="pr_in_gen">1</div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Данные"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="big_progr pr_future" title=""><div class="pr_in_gen">2</div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Паспорта"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Допданные"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Поездка"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Проживание"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Расходы"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Ещё?"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="На кого?"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Данные"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="big_progr pr_future" title=""><div class="pr_in_gen">3</div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Офис"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Подтверждение"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_white_gen"><div class="big_progr pr_future" title=""><div class="pr_in_gen">4</div></div></td></tr><tr><td class="stage_gen">Начало</td><td class="stage_gen"></td><td class="stage_gen">Заявители</td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen">Оформление</td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen">Готово!</td>';

my $progress_bar_2 = 
	'<td align="center" class="pr_size_gen pr_white_red_gen"><div class="big_progr pr_past" title=""><div class="pr_in_gen">1</div></div></td><td align="center" class="pr_size_gen pr_red_gray_gen"><div class="ltl_progr pr_current" title="Данные"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="big_progr pr_future" title=""><div class="pr_in_gen">2</div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Паспорта"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Допданные"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Поездка"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Проживание"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Расходы"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Ещё?"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="На кого?"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Данные"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="big_progr pr_future" title=""><div class="pr_in_gen">3</div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Офис"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_gray_gen"><div class="ltl_progr pr_future" title="Подтверждение"><div class="pr_in_gen"></div></div></td><td align="center" class="pr_size_gen pr_gray_white_gen"><div class="big_progr pr_future" title=""><div class="pr_in_gen">4</div></div></td></tr><tr><td class="stage_gen">Начало</td><td class="stage_gen"></td><td class="stage_gen">Заявители</td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen">Оформление</td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen">Готово!</td>';

my $first_page = 
	'<tr><td><label id="text">Визовый центр</label></td><td><select class="input_width select_gen" size = "1" name="center" title="" id="center" onchange="update_nearest_date_free_date();"></select></td></tr><tr><td><label id="text">Тип визы</label></td><td><select class="input_width select_gen" size = "1" name="vtype" title="" id="vtype"><option  value="13">Turismo</option></select></td></tr><tr><td><label id="text">Ближайшее доступное время</label></td><td><label class="info" id="free_date"></label></td></tr><tr><td rowspan=2><label id="text">Email</label></td><td><input class="input_width input_gen" type="text" value="" name="email" id="email" title="Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре"></td></tr><tr class="mobil_hide"><td class="exam_td_gen"><span class="exam_span_gen">пример: mail@mail.ru</span></td><tr><td><label id="text"></label></td><td><input type="checkbox" value="pers_info" name="pers_info" id="pers_info"><label for="pers_info">я согласен на обработку персональных данных</label></td></tr><tr><td><label id="text"></label></td><td><input type="checkbox" value="mobil_info" name="mobil_info" id="mobil_info"><label for="mobil_info">я согласен на условия работы с мобильными телефона на территории визового центра</label></td></tr>';

my $first_page_selected = 
	'<tr><td><label id="text">Визовый центр</label></td><td><select class="input_width select_gen" size = "1" name="center" title="" id="center" onchange="update_nearest_date_free_date();"></select></td></tr><tr><td><label id="text">Тип визы</label></td><td><select class="input_width select_gen" size = "1" name="vtype" title="" id="vtype"><option selected value="13">Turismo</option></select></td></tr><tr><td><label id="text">Ближайшее доступное время</label></td><td><label class="info" id="free_date"></label></td></tr><tr><td rowspan=2><label id="text">Email</label></td><td><input class="input_width input_gen" type="text" value="" name="email" id="email" title="Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре"></td></tr><tr class="mobil_hide"><td class="exam_td_gen"><span class="exam_span_gen">пример: mail@mail.ru</span></td><tr><td><label id="text"></label></td><td><input type="checkbox" value="pers_info" name="pers_info" id="pers_info"><label for="pers_info">я согласен на обработку персональных данных</label></td></tr><tr><td><label id="text"></label></td><td><input type="checkbox" value="mobil_info" name="mobil_info" id="mobil_info"><label for="mobil_info">я согласен на условия работы с мобильными телефона на территории визового центра</label></td></tr>';
	
my $second_page = 
	'<tr><td rowspan=2><label id="text">Дата начала поездки</label></td><td><input class="input_width input_gen" type="text" value="" name="s_date" id="s_date" title="Введите предполагаемую дату начала поездки"></td></tr><tr class="mobil_hide"><td class="exam_td_gen"><span class="exam_span_gen">пример: 01.01.2025</span></td><tr><td rowspan=2><label id="text">Дата окончания поездки</label></td><td><input class="input_width input_gen" type="text" value="" name="f_date" id="f_date" title="Введите предполагаемую дату окончания поездки"></td></tr><tr class="mobil_hide"><td class="exam_td_gen"><span class="exam_span_gen">пример: 31.12.2025</span></td>';

sub get_content_rules_hash
# //////////////////////////////////////////////////
{
	my $content_rules = {
	
		'Начало записи' => [
			{
				'page_ord' => 1,
				'progress' => 1,
				'param' => 1,
			},
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
				'uniq_code' => 'onchange="update_nearest_date_free_date();"',
			},
			{
				'type' => 'select',
				'name' => 'vtype',
				'label' => 'Тип визы',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'VType',
				},
				'param' => '[visas_from_db]',
			},
			{
				'type' => 'info',
				'name' => 'free_date',
				'label' => 'Ближайшее доступное время',
				'comment' => '',
				'check' => '',
				'special' => 'nearest_date',
			},
			{
				'type' => 'input',
				'name' => 'email',
				'label' => 'Email',
				'comment' => 'Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре',
				'example' => 'mail@mail.ru',
				'check' => 'zWN\@\s\-\.\,\;',
				'db' => {
					'table' => 'Appointments',
					'name' => 'EMail',
				},
			},
			{
				'type' => 'checkbox',
				'name' => 'pers_info',
				'label' => '',
				'label_for' => 'я согласен на обработку персональных данных',
				'comment' => '',
				'check' => 'true',
				'db' => {
					'table' => 'Appointments',
					'name' => 'PersonalDataPermission',
					'transfer' => 'nope',
				},
			},
			{
				'type' => 'checkbox',
				'name' => 'mobil_info',
				'label' => '',
				'label_for' => 'я согласен на условия работы с мобильными телефона на территории визового центра',
				'comment' => '',
				'check' => 'true',
				'db' => {
					'table' => 'Appointments',
					'name' => 'MobilPermission',
					'transfer' => 'nope',
				},
				'relation' => {},
			},
		],
		
		'Данные поездки' => [
			{
				'page_ord' => 2,
				'progress' => 2,
				'collect_date' => 1,
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
						'offset' => '[collect_date_offset]',
					},
				],
				'db' => {
					'table' => 'Appointments',
					'name' => 'SDate',
				},
				'special' => 'datepicker, mask',
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
				],
				'db' => {
					'table' => 'Appointments',
					'name' => 'FDate',
				},
				'special' => 'datepicker, mask',
			},
		],
		
		'Выберите лицо на которое будет оформлен договор' => [
			{
				'page_ord' => 23,
				'progress' => 10,
				'persons_in_page' => 1,
			},
			{
				'type' => 'select',
				'name' => 'visa_text',
				'label' => 'Выберите на кого оформляется',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'PersonForAgreements',
					'transfer' => 'nope',
				},
				'param' => '[persons_in_app]',
			},
		],
	};
	
	return $content_rules;
}

sub get_progressline
# //////////////////////////////////////////////////
{
	my $progress_line = [ '',
		{ big => 1, name => 'Начало', },
		{ big => 0, name => 'Данные', },
		{ big => 1, name => 'Заявители', },
		{ big => 0, name => 'Паспорта', },
		{ big => 0, name => 'Допданные', },
		{ big => 0, name => 'Поездка', },
		{ big => 0, name => 'Проживание', },
		{ big => 0, name => 'Расходы', },
		{ big => 0, name => 'Ещё?', },
		{ big => 0, name => 'На кого?', },
		{ big => 0, name => 'Данные', },
		{ big => 1, name => 'Оформление', },
		{ big => 0, name => 'Офис', },
		{ big => 0, name => 'Подтверждение', },
		{ big => 1, name => 'Готово!', },
	];
	
	return $progress_line;
}

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
	$self->{ this_is_self_testing } = 1;

	my $tests = get_test_list();
	
	for my $test (@$tests) {
	
		my $err_line = '';
		my $test_num = 0;
		
		for( sort { $a <=> $b } keys %{ $test->{test} } ) {
	
			$test_num++;

			my $t = $test->{test}->{$_};
			
			&{ $t->{prepare} }( $self, 'PREPARE', \$test, $_, \$test_token, $test_appid, $test_appdataid, $vars ) 
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
				s/\[first_page_selected\]/$first_page_selected/g;
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
				$vars->setparam( $_->{name}, $_->{value} );
			}

			my $test_result = &{ $t->{tester} }( 
				$t->{debug}, $t->{expected}, "$test->{comment}-$test_num", $self, 
				&{ $test->{func} }( $self, @{ $t->{args} } )
			);
	
			if ( $test_result ) {
				$err_line .= ( $err_line ? ', ' : '' ) . $test_num;
			}
			
			&{ $t->{prepare} }( $self, 'CLEAR', \$test, $_, \$test_token, $test_appid, $test_appdataid, $vars ) 
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

	my $tests = get_test_list();
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
	my ( $self, $type, $test, $num, $token ) = @_;
	
	if ( $type eq 'PREPARE' ) { 
		$self->{ test_token_save } = $$token;
		$$token =~ s/\w$/F/;
	}
	else {
		$$token = $self->{ test_token_save };
	}	
}

sub pre_finished
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
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
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	$vars->db->query("
		UPDATE AutoToken SET Step = 1 WHERE Token = '$$token'" );
}

sub pre_content_2
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	$vars->db->query("
		UPDATE AutoAppointments SET PersonalDataPermission = 0, MobilPermission = 0, EMail = '' 
		WHERE ID = '$appid'" );
		
	$vars->db->query("
		UPDATE AutoToken SET Step = 2 WHERE Token = '$$token'" );
}

sub pre_getinfo
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	$vars->db->query("
		UPDATE AutoAppointments SET SDate = '2011-05-01', CenterID = '5'
		WHERE ID = '$appid'" );
}

sub pre_init_param
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	my $info_from_db = $vars->get_memd->delete('autoform_addparam');
	
	if ( $type eq 'PREPARE' ) { 
		$vars->db->query("
			INSERT INTO Branches (ID, BName, Ord, Timezone, isDeleted, isDefault, Display, 
			Insurance, BAddr, JAddr, AddrEqualled, SenderID, CTemplate, isConcil, 
			isSMS, isUrgent, posShipping, isDover, calcInsurance, cdSimpl, cdUrgent, cdCatD, 
			CollectDate, siteLink, calcConcil, ConsNDS, genbank, isTranslate, shengen, isAnketa, 
			isPrinting, isPhoto, isVIP, Weekend, isShippingFree, isPrepayedAppointment, 
			DefaultPaymentMethod, DisableAppSameDay) 
			VALUES (1, 'Moscow', 1, 3, 0, 1, 1, 1, 'г.Москва', 'г.Москва', 0, 1, 'rtf', 
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
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	$vars->db->query("
		UPDATE AutoAppData SET Finished = 0 WHERE ID = ?", {}, 
		$appdataid );
}

sub pre_query
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
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

sub pre_lang
# //////////////////////////////////////////////////
{
	my ( $self, $type ) = @_;
	
	if ( $type eq 'PREPARE' ) { 
		$self->{ lang } = 'en';
	}
	else {
		$self->{ lang } = 'ru';
	}
}

sub pre_cach
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	if ( $type eq 'PREPARE' ) { 
		$vars->get_memd->set( 'cach_selftest', 'cash_ok', 60 );
		$self->{ this_is_self_testing } = undef;
	}
	else {
		$vars->get_memd->delete( 'cach_selftest' );
		$self->{ this_is_self_testing } = 1;
	}
}
sub pre_file
# //////////////////////////////////////////////////
{
	my ( $self, $type ) = @_;
	
	if ( $type eq 'PREPARE' ) { 
		open my $test_file, '>', '/tmp/autoform_selftest_file';
		print $test_file 'file_ok';
		close $test_file;
	}
	else {
		unlink '\tmp\autoform_selftest_file';
	}
}

1;
