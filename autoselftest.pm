package VCS::Site::autoselftest;
use strict;

use VCS::Vars;
use Data::Dumper;


sub get_test_list {

	my $tests = [
		{ 	func => \&{ VCS::Site::autoform::get_token_and_create_new_form_if_need },
			comment => 'get_token_and_create_new_form_if_need',
			test => {	
				1 => { 	expected => '^t[a-z0-9]{63}$'
				},
				2 => {	param => { t => '[token]' },
					expected => '[token]',
				},
				3 => {	param => { t => '7[token]' },
					expected => '01',
				},
				4 => {	prepare => \&pre_corrupt_token,
					expected => '02',
				},
				5 => {	prepare => \&pre_finished,
					param => { t => '[token]' },
					expected => '02',
				},
				6 => {	param => { t => 'no_app' },
					expected => '02',
				},
				7 => {	param => { t => 'no_field' },
					expected => '03',
				},
			}
		},
		{ 	func => \&{ VCS::Site::autoform::token_generation },
			comment => 'token_generation',
			test => { 	
				1 => { 	expected => '^t[a-z0-9]{63}$'
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::save_new_token_in_db },
			comment => 'save_new_token_in_db',
			test => { 	
				1 => { 	tester => \&test_write_db,
					args => [ 'tbcdefghijklmnopqrstuvwxyz0123456789abcdefghigklmopqrstuvwxyz171' ],
					expected => 'tbcdefghijklmnopqrstuvwxyz0123456789abcdefghigklmopqrstuvwxyz171'.
						':AutoToken:Token:tbcdefghijklmnopqrstuvwxyz0123456789abcdefghigklmopqrstuvwxyz171',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_page_error },
			comment => 'get_page_error',
			test => { 	
				1 => { 	args => [ '0' ],
					expected => [ '<center>ошибка: для работы анкеты необходимо,<br>чтобы в браузере' .
							' был включён javascript</center>', undef, 'autoform.tt2' ],
				},
				2 => { 	args => [ '1' ],
					expected => [ '<center>ошибка: неправильный токен</center>', undef, 'autoform.tt2' ],
				},
				3 => { 	args => [ '2' ],
					expected => [ '<center>ошибка: запись не найдена</center>', undef, 'autoform.tt2' ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_autoform_content },
			comment => 'get_autoform_content',
			test => { 	
				1 => { 	prepare => \&pre_content_1,
					expected => [
						'1', 
						'Начало записи', 
						'[first_page]', 
						'',
						'autoform.tt2',
						{
							nearest_date => [ 'free_date' ],
							timeslots => [],
							mask => [],
							datepicker => [],
							with_map => [],
							post_index => [],
							captcha => [],
							include_in => [],
							include_out => [],
							no_copypast => [],
							min_date => [],
						},
						'[progress_bar]',
						undef,
						[
							{
								check => 'zN',
								name => 'center',
								label => 'Визовый центр',
								type => 'select'
							},
							{
								check => 'zN',
								name => 'vtype',
								label => 'Тип визы',
								type => 'select'
							},
							{
								check => 'zWN\\\\@\\\\s\\\\-\\\\.\\\\,\\\\;',
								name => 'email',
								label => 'Email',
								type => 'input'
							},
							{
								check => 'true',
								name => 'pers_info',
								label => 'я согласен на обработку персональных данных',
								type => 'checkbox'
							},
							{
								check => 'true',
								name => 'mobil_info',
								label => 'я согласен на условия работы с мобильными телефона на территории визового центра',
								type => 'checkbox'
							}
						],
					],
				},
				2 => { 	prepare => \&pre_content_1,
					param => {
						action => 'forward',
						center => '1',
						vtype => '13',
						email => 'mail@mail.ru',
						pers_info => 'pers_info',
						mobil_info => 'mobil_info',
					},
					expected => [
						'2', 
						'Данные поездки', 
						'[second_page]', 
						'',
						'autoform.tt2',
						{
							nearest_date => [],
							timeslots => [],
							mask => [
								's_date',
								'f_date',
							],
							datepicker => [
								's_date',
								'f_date',
							],
							with_map => [],
							post_index => [],
							captcha => [],
							include_in => [],
							include_out => [],
							no_copypast => [],
							min_date => [],
						},
						'[progress_bar_2]',
						undef,
						[
							{
							  check => 'zD^(([012]\\\\d|3[01])\\\\.((0\\\\d)|(1[012]))\\\\.(19\\\\d\\\\d|20[0-2]\\\\d))$',
							  name => 's_date',
							  label => 'Дата начала поездки',
							  type => 'input'
							},
							{
							  check => 'zD^(([012]\\\\d|3[01])\\\\.((0\\\\d)|(1[012]))\\\\.(19\\\\d\\\\d|20[0-2]\\\\d))$',
							  name => 'f_date',
							  label => 'Дата окончания поездки',
							  type => 'input'
							}	
						],
					],
				},
				3 => { 	prepare => \&pre_content_2,
					param => { action => 'back' },
					expected => [
						'1', 
						'Начало записи', 
						'[first_page_selected]', 
						'',
						'autoform.tt2',
						{
							nearest_date => [ 'free_date' ],
							timeslots => [],
							mask => [],
							datepicker => [],
							with_map => [],
							post_index => [],
							captcha => [],
							include_in => [],
							include_out => [],
							no_copypast => [],
							min_date => [],
						},
						'[progress_bar]',
						undef,
						[
							{
								check => 'zN',
								name => 'center',
								label => 'Визовый центр',
								type => 'select'
							},
							{
								check => 'zN',
								name => 'vtype',
								label => 'Тип визы',
								type => 'select'
							},
							{
								check => 'zWN\\\\@\\\\s\\\\-\\\\.\\\\,\\\\;',
								name => 'email',
								label => 'Email',
								type => 'input'
							},
							{
								check => 'true',
								name => 'pers_info',
								label => 'я согласен на обработку персональных данных',
								type => 'checkbox'
							},
							{
								check => 'true',
								name => 'mobil_info',
								label => 'я согласен на условия работы с мобильными телефона на территории визового центра',
								type => 'checkbox'
							}
						],
					],
				},
			},
		},
		
		{ 	func => \&{ VCS::Site::autoform::insert_hash_table },
			comment => 'insert_hash_table',
			test => { 	
				1 => { 	tester => \&test_write_db,
					args => [ 'AutoToken', { Token => 'Token', AutoAppID => 999 } ],
					expected => 'Token:AutoToken:AutoAppID:999',
				},
				2 => { 	tester => \&test_write_db,
					args => [ 'AutoToken', { Token => 'Token2', AutoAppID => 123 } ],
					expected => 'Token2:AutoToken:AutoAppID:123',
				},
				3 => { 	args => [ 'AutoToken', { Token => 'Token2', AutoAppID => 123 } ],
					expected => '^\d+$',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::mezzi_assembler },
			comment => 'mezzi_assembler',
			test => { 	
				1 => { 	tester => \&test_line_in_hash,
					args => [ { 
						Mezzi1 => '1',
						Mezzi2 => '0',
						Mezzi3 => '1',
						Mezzi4 => '0',
						Mezzi5 => '1',
						Mezzi6 => '0',
						Mezzi7 => '1',
					} ],
					expected => 'Mezzi:1|0|1|0|1|0|1',
				},
				2 => { 	tester => \&test_line_in_hash,
					args => [ { 
						Mezzi1 => '0',
						Mezzi2 => '1',
						Mezzi3 => '0',
						Mezzi4 => '1',
						Mezzi5 => '0',
						Mezzi6 => '1',
						Mezzi7 => '0',
					} ],
					expected => 'Mezzi:0|1|0|1|0|1|0',
				},
				3 => { 	tester => \&test_line_in_hash,
					args => [ { 
						Mezzi1 => '0',
						Mezzi2 => '0',
						Mezzi3 => '0',
						Mezzi4 => '0',
						Mezzi5 => '0',
						Mezzi6 => '0',
						Mezzi7 => '0',
					} ],
					expected => 'Mezzi:0|0|0|0|0|0|0',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::visapurpose_assembler },
			comment => 'visapurpose_assembler',
			test => { 	
				1 => { 	tester => \&test_line_in_hash,
					args => [ { VisaPurpose => '13' } ],
					expected => 'VisaPurpose:0|0|0|0|0|0|0|0|0|0|0|0|1|0|0|0|0',
				},
				2 => { 	tester => \&test_line_in_hash,
					args => [ { VisaPurpose => '2' } ],
					expected => 'VisaPurpose:0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0',
				},
				
			},
		},
		{ 	func => \&{ VCS::Site::autoform::mod_hash },
			comment => 'mod_hash',
			test => { 	
				1 => { 	tester => \&test_line_in_hash,
					args => [ { VisaPurpose => '13' } ],
					expected => 'VisaPurpose:0|0|0|0|0|0|0|0|0|0|0|0|1|0|0|0|0',
				},
				2 => { 	tester => \&test_line_in_hash,
					args => [ { ID => '1' } ],
					expected => 'ID:',
				},
				3 => { 	tester => \&test_line_in_hash,
					args => [ { Status => '3' } ],
					expected => 'Status:1',
				},
				4 => { 	tester => \&test_line_in_hash,
					args => [ { Status => '3' }, 'TableName', {}, '999' ],
					expected => 'AppID:999',
				},
				5 => { 	tester => \&test_line_in_hash,
					args => [ { ID => '100' } ],
					expected => 'ID:',
				},
				6 => { 	tester => \&test_line_in_hash,
					args => [ { OfficeToReceive => '2' }, 'Appointments' ],
					expected => 'OfficeToReceive:39',
				},
			},
		},
		
		{ 	func => \&{ VCS::Site::autoform::text_error },
			comment => 'text_error',
			test => { 	
				1 => { 	args => [ 0, { name => 'test' },  ],
					expected => 'test|Поле "test" не заполнено',
				},
				2 => { 	args => [ 1, { name => 'test', label => 'label' },  ],
					expected => 'test|В поле "label" указана неверная дата',
				},
				3 => { 	args => [ 2, { name => 'test', label_for => 'label_for' }, 'AB' ],
					expected => 'test|В поле "label_for" введены недопустимые символы: A, B',
				},
				4 => { 	args => [ 4 ],
					expected => '|Вы должны полностью заполнить анкеты или удалить ненужные черновики',
				},
				5 => { 	args => [ 7, { name => 'test', label_for => 'label_for' }, 
						undef, 'label2', 400 ],
					expected => 'test|"label_for" не может быть раньше, чем "label2" более, чем на 1 год',
				},
				6 => { 	args => [ 7, { name => 'test', label_for => 'label_for' }, 
						undef, undef, 5, 'Полный текст ошибки' ],
					expected => 'test|Полный текст ошибки',
				},
				7 => { 	args => [ 2, { name => 'test', label_for => 'label_for' }, '*/(' ],
					expected => 'test|В поле "label_for" введены недопустимые символы: звёздочка, косая черта, скобка',
				},
				8 => { 	args => [ 2, { name => 'test', label_for => 'label_for' }, '*/()//' ],
					expected => 'test|В поле "label_for" введены недопустимые символы: звёздочка, косая черта, скобка',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::resort_with_first_elements },
			comment => 'resort_with_first_elements',
			test => { 	
				1 => { 	args => [ { 10 => 10, 20 => 20, 30 => 30, 50 => 50, 40 => 40 }, '20, 40' ],
					expected => [ 20, 40, 10, 30, 50 ],
				},
				2 => { 	args => [ { 10 => 10, 20 => 20, 30 => 30, 50 => 50, 40 => 40 }, '40' ],
					expected => [ 40, 10, 20, 30, 50 ],
				},
				3 => { 	args => [ { 10 => 10, 20 => 20, 30 => 30, 50 => 50, 40 => 40 } ],
					expected => [ 10, 20, 30, 40, 50 ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_html_for_element },
			comment => 'get_html_for_element',
			test => { 	
				1 => { 	args => [ 'start_line' ],
					expected => '<tr>',
				},
				2 => { 	args => [ 'end_line' ],
					expected => '</tr>',
				},
				3 => { 	args => [ 'start_cell' ],
					expected => '<td class="left">',
				},
				4 => { 	args => [ 'end_cell' ],
					expected => '</td>',
				},
				5 => { 	args => [ 'input', 'element', 'val', {}, 'uniq', undef, 'comm' ],
					expected => '<input class="input_width input_gen optional_field" type="text" value="val" name="element" id="element" title="comm<br><br><b>Необязательное поле</b><br>В поле допустимо вводить " uniq>',
				},
				6 => { 	args => [ 'checkbox', 'element', 'val', {} ],
					expected => '<input type="checkbox" value="element" name="element" id="element" checked>',
				},
				7 => { 	args => [ 'checkbox', 'element' ],
					expected => '<input type="checkbox" value="element" name="element" id="element">',
				},
				8 => { 	args => [ 'select', 'element', '3', { 1 => 'first', 2 => 'second', 3 => 'third', 4 => 'fourth' }, undef, '2' ],
					expected => 
						'<select class="input_width select_gen" size = "1" name="element" title="" id="element"><option  value="2">second</option><option  value="1">first</option><option  value="4">fourth</option><option selected value="3">third</option></select>',
				},
				9 => { 	args => [ 'radiolist', 'element', '2', { 1 => 'first', 2 => 'second', 3 => 'third' } ],
					expected => 
						'<div id="element"><input type="radio" name="element" value="1"  title="" id="element1"><label for="element1">first</label><br><input type="radio" name="element" value="2" checked title="" id="element2"><label for="element2">second</label><br><input type="radio" name="element" value="3"  title="" id="element3"><label for="element3">third</label><br></div>',
				},
				10 => {	args => [ 'text', undef, 'text' ],
					expected => '<td class="left" colspan="3">text</td>',
				},
				11 => {	args => [ 'example', undef, 'text' ],
					expected => '<tr><td class="exam_td_gen left"><span class="exam_span_gen">пример: text</span></td></tr>',
				},
				12 => {	args => [ 'info', 'element', 'text' ],
					expected => '<label class="info" title="" id="element">text</label>',
				},
				13 => {	args => [ 'label', 'element', 'text' ],
					expected => '<label data-id="element">text</label>',
				},
				14 => {	args => [ 'label_for', 'element', 'text' ],
					expected => '&nbsp;<label for="element">text</label>',
				},
				15 => {	args => [ 'checklist', 'element', { test1 => 1 }, { 
						test1 => { db => 'test1', label_for => 'Тест 1' },
						test2 => { db => 'test2', label_for => 'Тест 2' },
					} ],
					expected =>
						'<div id="element"><input type="checkbox" value="test1" name="test1" title="" id="test1" checked><label for="test1">&nbsp;Тест 1</label><br><input type="checkbox" value="test2" name="test2" title="" id="test2" ><label for="test2">&nbsp;Тест 2</label><br></div>',
				},
				16 => {	args => [ 'progress', 'test', undef, 'past', 0 ],
					expected =>
						'<td class="pr_size_gen pr_red_red_gen center"><div class="ltl_progr pr_past centered" title=""><div class="pr_in_gen"></div></div></td>',
				},
				17 => {	args => [ 'progress', 'test', undef, 'current', 1 ],
					expected =>
						'<td class="pr_size_gen pr_white_gray_gen center"><div class="ltl_progr pr_current centered" title=""><div class="pr_in_gen"></div></div></td>',
				},
				18 => {	args => [ 'progress', 'test', undef, 'future', 2 ],
					expected =>
						'<td class="pr_size_gen pr_gray_white_gen center"><div class="ltl_progr pr_future centered" title=""><div class="pr_in_gen"></div></div></td>',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_cell },
			comment => 'get_cell',
			test => { 	
				1 => { 	args => [ 'test' ],
					expected => '<td class="left">test</td>',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_html_line },
			comment => 'get_html_line',
			test => { 	
				1 => { 	args => [
						{
							type => 'input',
							name => 'email',
							label => 'Email',
							comment => '',
							example => 'mail@mail.ru',
							check => 'z',
						},
						{
							email => 'testvalue@mail.ru',
						}
					],
					expected => 
						'<tr><td class="left" rowspan=2><label data-id="text">Email</label></td><td class="left bottom" ><input class="input_width input_gen" type="text" value="testvalue@mail.ru" name="email" id="email" title="<br><br><b>Обязательное поле</b><br>В поле допустимо вводить "></td></tr><tr><td class="exam_td_gen left"><span class="exam_span_gen">пример: mail@mail.ru</span></td></tr>',
				},
				2 => { 	args => [
						{
							type => 'checklist',
							name => 'test',
							label => 'Средства',
							comment => '',
							check => 'at_least_one',
							db => {
								name => 'complex'
							},
							param => {
								test1 => { db => 'Test1', label_for => 'Тест 1' },
								test2 => { db => 'Test2', label_for => 'Тест 2' },
							},
						},
						{
							test1 => '1',
							test2 => '0',
						}
					],
					expected => 
						'<tr><td class="left"><label data-id="text">Средства</label></td><td class="left"><div id="test"><input type="checkbox" value="test1" name="test1" title="" id="test1" checked><label for="test1">&nbsp;Тест 1</label><br><input type="checkbox" value="test2" name="test2" title="" id="test2" ><label for="test2">&nbsp;Тест 2</label><br></div></td></tr>',
				}
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_html_page },
			comment => 'get_html_page',
			test => { 	
				1 => { 	args => [ 1, '999' ],
					expected => [ '[first_page_selected]', 'autoform.tt2' ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_progressbar },
			comment => 'get_progressbar',
			test => { 	
				1 => { 	args => [ '[progress1]', '[progressbar_hash]' ],
					expected => '[progress_bar]',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_finish },
			comment => 'get_finish',
			test => { 	
				1 => { 	expected => [ undef, 'autoform_finish.tt2' ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_specials_of_element },
			comment => 'get_specials_of_element',
			test => { 	
				1 => { 	args => [ 1 ],
					expected => {
						nearest_date => [
							'free_date',
						],
						timeslots => [],
						mask => [],
						datepicker => [],
						post_index => [],
						with_map => [],
						captcha => [],
						include_in => [],
						include_out => [],
						no_copypast => [],
						min_date => [],
					},

				},
				2 => { 	args => [ 2 ],
					expected => {
						nearest_date => [],
						timeslots => [],
						mask => [
							's_date',
							'f_date',
						],
						datepicker => [
							's_date',
							'f_date',
						],
						post_index => [],
						with_map => [],
						captcha => [],
						include_in => [],
						include_out => [],
						no_copypast => [],
						min_date => [],
					},

				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::decode_data_from_db },
			comment => 'decode_data_from_db',
			test => { 	
				1 => { 	args => [ 1, 'test', '2010-01-03' ],
					expected => '03.01.2010',
				},
				2 => { 	args => [ 1, 'test', '03.01.2010' ],
					expected => '03.01.2010',
				},
				3 => { 	args => [ 1, 'test', '0000-00-00' ],
					expected => '',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::encode_data_for_db },
			comment => 'encode_data_for_db',
			test => { 	
				1 => { 	args => [ 1, 'pers_info', 'pers_info' ],
					expected => 1,
				},
				2 => { 	args => [ 1, 'pers_info', '' ],
					expected => 0,
				},
				3 => { 	args => [ 1, 'email', '   email   ' ],
					expected => 'email',
				},
				4 => { 	args => [ 1, 'email', '03.01.2010' ],
					expected => '2010-01-03',
				},
				5 => { 	args => [ 1, 'email', '2010-01-03' ],
					expected => '2010-01-03',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_element_by_name },
			comment => 'get_element_by_name',
			test => { 	
				1 => { 	args => [ 1, 'email' ],
					expected => {
						db => {
								name => 'EMail',
								table => 'Appointments'
						},
						example => 'mail@mail.ru',
						name => 'email',
						comment => 'Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре',
						check => 'zWN\@\s\-\.\,\;',
						type => 'input',
						label => 'Email',
					},
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_names_db_for_save_or_get },
			comment => 'get_names_db_for_save_or_get',
			test => { 	
				1 => { 	args => [ '[page1]' ],
					expected => {
						AutoAppointments => {
							PersonalDataPermission => 'pers_info',
							CenterID => 'center',
							EMail => 'email',
							MobilPermission => 'mobil_info',
							VType => 'vtype'
						},
						alternative_data_source => {},
					}
				},
				2 => { 	args => [ '[page2]' ],
					expected => {
						AutoAppointments => {
							SDate => 's_date',
							FDate => 'f_date'
						},
						alternative_data_source => {
							f_date => {
								table => 'AutoAppointments',
								field => 'SDate'
							}
						},
					}
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_checklist },
			comment => 'check_checklist',
			test => { 	
				1 => { 	args => [
						{
							name => 'test',
							label => 'Средства',
							check => 'at_least_one',
							param => {
								test1 => 0,
								test2 => 0,
								test3 => 0,
							},
						},
					],
					param => { test2 => '1' },
					expected => '',
				},
				2 => { 	args => [
						{
							name => 'test',
							label => 'Test',
							check => 'at_least_one',
							param => {
								test1 => 0,
								test2 => 0,
								test3 => 0,
							},
						},
					],
					param => {
						test1 => '',
						test2 => '',
						test3 => '',
					},
					expected => 'test|В поле "Test" нужно выбрать хотя бы одно значение',
				},
				3 => { 	args => [
						{
							name => 'test',
							label => 'Test',
							param => {
								test1 => 0,
								test2 => 0,
								test3 => 0,
							},
						},
					],
					param => {
						test1 => '',
						test2 => '',
						test3 => '',
					},
					expected => '',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_chkbox },
			comment => 'check_chkbox',
			test => { 	
				1 => { 	args => [ { name => 'test', check => 'true' } ],
					param => { test => '1' },
					expected => '',
				},
				2 => { 	args => [ { name => 'test', check => 'true'} ],
					param => { test => '' },
					expected => 'test|Вы должны указать поле "test"',
				},
				3 => { 	args => [ { name => 'test', check => '' } ],
					param => { test => '' },
					expected => '',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_param },
			comment => 'check_param',
			test => { 	
				1 => { 	args => [ { name => 'test', check => 'z'} ],
					param => { test => 'text' },
					expected => '',
				},
				2 => { 	args => [ { name => 'test', check => 'z' } ],
					param => { test => '' },
					expected => 'test|Поле "test" не заполнено',
				},
				3 => { 	args => [ { name => 'test', check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$' } ],
					param => { test => '2010-03-01' },
					expected => 'test|В поле "test" указана неверная дата',
				},
				4 => { 	args => [ { name => 'test', check => 'W' } ],
					param => { test => 'abcАБВ' },
					expected => 'test|В поле "test" введены недопустимые символы: А, Б, В',
				},
				5 => { 	args => [ { name => 'test', check => 'Ё' } ],
					param => { test => 'ABCабв' },
					expected => 'test|В поле "test" введены недопустимые символы: A, B, C',
				},
				6 => { 	args => [ { name => 'test', check => 'N' } ],
					param => { test => '123XYZ456' },
					expected => 'test|В поле "test" введены недопустимые символы: X, Y, Z',
				},
				7 => { 	args => [ { name => 'test', check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$' } ],
					param => { test => '31.12.1999' },
					expected => '',
				},
				8 => { 	args => [ { name => 'test', check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$' } ],
					param => { test => '32.12.1999' },
					expected => 'test|В поле "test" указана неверная дата',
				},
				9 => { 	args => [ { name => 'test', check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$' } ],
					param => { test => '31.02.1999' },
					expected => 'test|В поле "test" указана неверная дата',
				},
				10 => { args => [ { name => 'test', check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$' } ],
					param => { test => '' },
					expected => 'test|Поле "test" не заполнено',
				},
				11 => { args => [ { name => 'test', check => 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$' } ],
					param => { test => '' },
					expected => '',
				},
				12 => { args => [ { name => 'test', check => 'W\@\.' } ],
					param => { test => 'test@test.com' },
					expected => '',
				},
				13 => { args => [ { name => 'test', check => 'W' } ],
					param => { test => 'test@test.com' },
					expected => 'test|В поле "test" введены недопустимые символы: @, точка',
				},
				14 => { args => [ { name => 'test', check => 'N+' } ],
					param => { test => '360+360/360' },
					expected => 'test|В поле "test" введены недопустимые символы: косая черта',
				},
				15 => { args => [ { name => 'test', check => 'N+' } ],
					param => { test => '360+360|||360' },
					expected => 'test|В поле "test" введены недопустимые символы: вертикальная черта',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_existing_id_in_token },
			comment => 'check_existing_id_in_token',
			test => { 	
				1 => { 	args => [ '[appdata_id]' ],
					expected => '1',
				},
				2 => { 	args => [ '1' ],
					expected => '0',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_logic },
			comment => 'check_logic',
			test => { 	
				1 => { 	prepare => \&pre_logic_1,
					args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'unique_in_pending',
								table => 'AutoAppData',
								name => 'FinishedCenter',
							} ]
						},
						0,
					],
					param => { field_name => '21' },
					expected => 'field_name|Поле "field_name" уже встречается в актуальных записях',
				},
				2 => { 	prepare => \&pre_logic_1,
					args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'unique_in_pending',
								table => 'AutoAppData',
								name => 'FinishedCenter',
							} ]
						},
						0,
					],
					param => { field_name => '20' },
					expected => '',
				},
				3 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'unique_in_pending',
								table => 'AutoAppData',
								name => 'FinishedCenter',
							} ]
						},
						0,
					],
					param => { field_name => '21' },
					expected => '',
				},
				4 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'email_not_blocked' } ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'blocked1mail@mail.com' },
					expected => 'field_name|Вы ввели недопустимый адрес электронной почты',
				},
				5 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'email_not_blocked', } ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'blocked2mail@mail.com' },
					expected => 'field_name|Этот электронный адрес был заблокирован.<br>Вы превысили допустимое количество записей',
				},
				6 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'email_not_blocked', }, ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'blocked3mail@mail.com' },
					expected => '',
				},
				7 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'email_not_blocked', }, ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'blocked4mail@mail.com' },
					expected => '',
				},
				8 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'free_only_if',
								table => 'Appointments',
								name => 'Draft',
								error => 'Драфт',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '' },
					expected => '',
				},
				9 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'free_only_if',
								table => 'Appointments',
								name => 'PrintSrv',
								error => 'PrintSrv',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'PrintSrv' },
					expected => '',
				},
				10 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'free_only_if',
								table => 'Appointments',
								name => 'PrintSrv',
								error => 'PrintSrv',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '' },
					expected => 'field_name|Необходимо заполнить поле "field_name" или указать "PrintSrv"',
				},
				11 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { 	
								condition => 'free_only_if_not',
								table => 'Appointments',
								name => 'PrintSrv',
								error => 'PrintSrv',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '' },
					expected => '',
				},
				12 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'free_only_if_not',
								table => 'Appointments',
								name => 'PrintSrv',
								error => 'PrintSrv',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'PrintSrv' },
					expected => '',
				},
				13 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { 	condition => 'free_only_if_not',
								table => 'Appointments',
								name => 'Draft',
								error => 'Draft',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '' },
					expected => 'field_name|Необходимо заполнить поле "field_name", если заполнено "Draft"',
				},				

				14 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'now_or_later' } ]
						},
					],
					param => { field_name => '2100-01-01' },
					expected => '',
				},
				15 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'now_or_later' } ]
						},
					],
					param => { field_name => '1999-01-01' },
					expected => 'field_name|Недопустимая дата в поле "field_name"',
				},
				16 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'now_or_earlier' } ]
						},
					],
					param => { field_name => '1999-01-01' },
					expected => '',
				},
				17 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'now_or_earlier' } ]
						},
					],
					param => { field_name => '2100-01-01' },
					expected => 'field_name|Недопустимая дата в поле "field_name"',
				},
				18 => { prepare => \&pre_logic_2,
					args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'equal_or_later',
								table => 'Appointments',
								name => 'SDate',
								error => 'Draft',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '2011-01-01' },
					expected => '',
				},
				19 => { prepare => \&pre_logic_2,
					args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'equal_or_later',
								table => 'Appointments',
								name => 'SDate',
								error => 'Draft',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '2008-01-01' },
					expected => 'field_name|"field_name" не может быть раньше, чем "Draft"',
				},
				20 => { prepare => \&pre_logic_2,
					args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'equal_or_earlier',
								table => 'Appointments',
								name => 'SDate',
								error => 'Draft',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '2008-01-01' },
					expected => '',
				},
				21 => { prepare => \&pre_logic_2,
					args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'equal_or_earlier',
								table => 'Appointments',
								name => 'SDate',
								error => 'Draft',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '2011-01-01' },
					expected => 'field_name|"field_name" не может быть позднее, чем "Draft"',
				},
				22 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'now_or_earlier' } ]
						},
					],
					param => { field_name => '01.01.2009' },
					expected => '',
				},
				23 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'now_or_earlier' } ]
						},
					],
					param => { field_name => '01.01.2113' },
					expected => 'field_name|Недопустимая дата в поле "field_name"',
				},
				24 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'younger_than', offset => 10 } ]
						},
						{
							AutoAppData => '[appdata_id]',
						},
					],
					prepare => \&pre_age, # <--- fixed num 24
					expected => 'field_name|Указать данное поле можно только для заявителей младше 10 лет',
				},
				25 => { args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'younger_than', offset => 10 } ],
						},
						{
							AutoAppData => '[appdata_id]',
						},
					],
					prepare => \&pre_age, # <--- fixed num 25
					expected => '',
				},
				26 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'not_closer_than',
								table => 'AppData',
								name => 'FingersDate',
								error => 'Draft',
								offset => 10,
							} ]
						},
						{
							AutoAppData => '[appdata_id]',
						},
					],
					param => { field_name => '01.05.2000' },
					prepare => \&pre_not_closer,
					expected => 'field_name|"field_name" не может быть ближе к "Draft" менее, чем на 10 дней',
				},
				27 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'not_closer_than',
								table => 'AppData',
								name => 'FingersDate',
								error => 'Draft',
								offset => 10,
							} ]
						},
						{
							AutoAppData => '[appdata_id]',
						},
					],
					param => { field_name => '11.05.2000' },
					prepare => \&pre_not_closer,
					expected => '',
				},
				28 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'not_closer_than',
								table => 'AppData',
								name => 'FingersDate',
								error => 'Draft',
								offset => -10,
							} ]
						},
						{
							AutoAppData => '[appdata_id]',
						},
					],
					param => { field_name => '24.04.2000' },
					prepare => \&pre_not_closer,
					expected => 'field_name|"field_name" не может быть ближе к "Draft" менее, чем на 10 дней',
				},
				29 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'not_closer_than',
								table => 'AppData',
								name => 'FingersDate',
								error => 'Draft',
								offset => -10,
							} ]
						},
						{
							AutoAppData => '[appdata_id]',
						},
					],
					param => { field_name => '20.04.2000' },
					prepare => \&pre_not_closer,
					expected => '',
				},
				30 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'not_closer_than_in_spb',
								table => 'AppData',
								name => 'FingersDate',
								error => 'Draft',
								offset => 90,
							} ]
						},
						{
							AutoAppData => '[appdata_id]',
						},
					],
					param => { field_name => '31.01.2000' },
					prepare => \&pre_not_closer,
					expected => 'field_name|"field_name" не может быть ближе к "Draft" менее, чем на 3 месяца',
				},
				31 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'not_closer_than_in_spb',
								table => 'AppData',
								name => 'FingersDate',
								error => 'Draft',
								offset => 90,
							} ]
						},
						{
							AutoAppData => '[appdata_id]',
						},
					],
					param => { field_name => '29.01.2000' },
					prepare => \&pre_not_closer,
					expected => '',
				},
				32 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'not_closer_than_in_spb',
								table => 'AppData',
								name => 'FingersDate',
								full_error => 'test error message',
								offset => 90,
							} ]
						},
						{
							AutoAppData => '[appdata_id]',
						},
					],
					param => { field_name => '31.01.2000' },
					prepare => \&pre_not_closer,
					expected => 'field_name|test error message',
				},
				33 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'equal',
								table => 'Appointments',
								name => 'VType',
								full_error => 'test error message',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '13' },
					expected => '',
				},
				34 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'equal',
								table => 'Appointments',
								name => 'VType',
								full_error => 'test error message',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '14' },
					expected => 'field_name|test error message',
				},
				35 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'length_strict',
								length => 11,
								full_error => 'Неправильный формат телефонного номера',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '123123123123' },
					expected => 'field_name|Неправильный формат телефонного номера',
				},
				36 => { args => [ 
						{	name => 'field_name',
							check_logic => [ {
								condition => 'length_strict',
								length => 11,
								full_error => 'Неправильный формат телефонного номера',
							} ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => '12312312312' },
					expected => '',
				},
				
				37 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'this_is_email' } ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'test@mail.com' },
					expected => '',
				},
				38 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'this_is_email' } ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'test.test-test@mail-test.info' },
					expected => '',
				},
				39 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'this_is_email' } ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'test test-test@mail-test.info' },
					expected => 'field_name|Вы ввели недопустимый адрес электронной почты',
				},
				40 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'this_is_email' } ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'test-testmail-test.info' },
					expected => 'field_name|Вы ввели недопустимый адрес электронной почты',
				},
				41 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'this_is_email' } ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'test-test@mail-test' },
					expected => 'field_name|Вы ввели недопустимый адрес электронной почты',
				},
				42 => { 	args => [ 
						{	name => 'field_name',
							check_logic => [ { condition => 'this_is_email' } ]
						},
						{
							AutoAppointments => '[app_id]',
						},
					],
					param => { field_name => 'test-test@mail-test..info' },
					expected => 'field_name|Вы ввели недопустимый адрес электронной почты',
				},
			},
		},
		
		{ 	func => \&{ VCS::Site::autoform::get_current_table_id },
			comment => 'get_current_table_id',
			test => { 	
				1 => { 	expected =>  {
						AutoAppData => '[appdata_id]',
						AutoSchengenAppData => '[schdata_id]',
						AutoToken => '[token_id]',
						AutoAppointments => '[app_id]',
						AutoSpbAlterAppData => '[spb_id]',
					},
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::skip_by_condition },
			comment => 'skip_by_condition',
			test => { 	
				1 => { 	args => [ 12, '12', 'only_if' ],
					expected => '0',
				},
				2 => { 	args => [ 9, '8,9,10', 'only_if' ],
					expected => '0',
				},
				3 => { 	args => [ 9, '7,8,10', 'only_if' ],
					expected => '1',
				},
				4 => { 	args => [ 9, '6,8,10', 'only_if_not' ],
					expected => '0',
				},
				5 => { 	args => [ 9, '10,9,8', 'only_if_not' ],
					expected => '1',
				},
				6 => { 	args => [ 9, '8,9,10', 'only_if_5' ],
					expected => '0',
				},
				7 => { 	args => [ 9, '7,8,10', 'only_if_256' ],
					expected => '1',
				},
				8 => { 	args => [ 9, '6,8,10', 'only_if_not_1' ],
					expected => '0',
				},
				9 => { 	args => [ 9, '10,9,8', 'only_if_not_4' ],
					expected => '1',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::skip_page_by_relation },
			comment => 'skip_page_by_relation',
			test => { 	
				1 => { 	args => [ 'only_if', { value => '13', name => 'VType', table => 'Appointments' } ],
					expected => '0',
				},
				2 => { 	args => [ 'only_if', { value => '12', name => 'VType', table => 'Appointments' } ],
					expected => '1',
				},
				3 => { 	args => [ 'only_if_not', { value => '12', name => 'VType', table => 'Appointments' } ],
					expected => '0',
				},
				4 => { 	args => [ 'only_if_not', { value => '13', name => 'VType', table => 'Appointments' } ],
					expected => '1',
				},
				5 => { 	args => [ 'only_if_1', { value => '13', name => 'VType', table => 'Appointments' } ],
					expected => '0',
				},
				6 => { 	args => [ 'only_if_512', { value => '12', name => 'VType', table => 'Appointments' } ],
					expected => '1',
				},
				7 => { 	args => [ 'only_if_not_85', { value => '12', name => 'VType', table => 'Appointments' } ],
					expected => '0',
				},
				8 => { 	args => [ 'only_if_not_05', { value => '13', name => 'VType', table => 'Appointments' } ],
					expected => '1',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_same_info_for_timeslots },
			comment => 'get_same_info_for_timeslots',
			test => { 	
				1 => { 	prepare => \&pre_getinfo,
					expected =>  {
						persons => '1',
						center => '5',
						fdate => '01.05.2011',
						fdate_iso => '2011-05-01',
						timeslot => '0',
						appdate => '0000-00-00',
					},
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::init_add_param },
			comment => 'init_add_param',
			test => { 	
				1 => {	prepare => \&pre_init_param,
					args => [ 
						{ 
							1 => [
								{
									type => 'select',
									name => 'center',
									label => 'Визовый центр',
									comment => '',
									check => 'zN',
									db => {
										table => 'Appointments',
										name => 'CenterID',
									},
									param => '[centers_from_db]',
								},
							] 
						}, 
						{ param => 1 },
					],
					expected => { 
						1 => [
							{
								type => 'select',
								name => 'center',
								label => 'Визовый центр',
								comment => '',
								check => 'zN',
								db => {
									table => 'Appointments',
									name => 'CenterID',
								},
								param => {
									1 => 'Moscow',
								}
							},
						]
					},
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_content_rules },
			comment => 'get_content_rules',
			test => { 	
				1 => { 	args => [ '2', 'full', 'init' ],
					expected =>  
					[
						[
							{
								page_name => 'Данные поездки',
								page_ord => 2,
								progress => 2,
								collect_date => 1,
								param => {}
							},
							{
								type => 'input',
								name => 's_date',
								label => 'Дата начала поездки',
								comment => 'Введите предполагаемую дату начала поездки',
								example => '01.01.2025',
								check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
								check_logic => [
									{
										condition => 'now_or_later',
										offset => 0,
									},
								],
								db => {
									table => 'Appointments',
									name => 'SDate',
								},
								special => 'datepicker, mask',
								param => {}
							},
							{
								type => 'input',
								name => 'f_date',
								label => 'Дата окончания поездки',
								comment => 'Введите предполагаемую дату окончания поездки',
								example => '31.12.2025',
								check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
								check_logic => [
									{
										condition => 'equal_or_later',
										table => 'Appointments',
										name => 'SDate',
										error => 'Дата начала поездки',
									},
								],
								db => {
									table => 'Appointments',
									name => 'FDate',
								},
								load_if_free_field => {
									table => 'Appointments',
									name => 'SDate',
								},
								special => 'datepicker, mask',
								param => {}
							},
						],
					],
				},
				2 => { 	args => [ '2', undef, 'init' ],
					expected =>  
					[
						[
							{
								type => 'input',
								name => 's_date',
								label => 'Дата начала поездки',
								comment => 'Введите предполагаемую дату начала поездки',
								example => '01.01.2025',
								check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
								check_logic => [
									{
										condition => 'now_or_later',
										offset => 0,
									},
								],
								db => {
									table => 'Appointments',
									name => 'SDate',
								},
								special => 'datepicker, mask',
								param => {}
							},
							{
								type => 'input',
								name => 'f_date',
								label => 'Дата окончания поездки',
								comment => 'Введите предполагаемую дату окончания поездки',
								example => '31.12.2025',
								check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
								check_logic => [
									{
										condition => 'equal_or_later',
										table => 'Appointments',
										name => 'SDate',
										error => 'Дата начала поездки',
									},
								],
								db => {
									table => 'Appointments',
									name => 'FDate',
								},
								load_if_free_field => {
									table => 'Appointments',
									name => 'SDate',
								},
								special => 'datepicker, mask',
								param => {}
							},
						],
					],
				},
				3 => { 	args => [ 'length' ],
					expected => '^\d+$',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::set_current_app_finished },
			comment => 'set_current_app_finished',
			test => { 	
				1 => { 	tester => \&test_write_db,
					prepare => \&pre_app_finish,
					args => [ '[table_id]' ],
					expected => '[appdata_id]:AutoAppData:FinishedCenter:5',
				},
				2 => { 	prepare => \&pre_app_finish,
					args => [ '[table_id]' ],
					expected => 1,
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::query },
			comment => 'query',
			test => { 	
				1 => { 	tester => \&test_write_db,
					args => [ 'query', 'test', 'UPDATE AutoAppData SET FinishedCenter = 5 WHERE ID = ?', {}, '[appdata_id]' ],
					expected => '[appdata_id]:AutoAppData:FinishedCenter:5',
				},
				2 => { 	prepare => \&pre_logic_1,
					args => [ 'sel1', 'test', 'SELECT FinishedCenter FROM AutoAppData WHERE ID = ?', '[appdata_id]' ],
					expected => '21',
				},
				3 => { 	prepare => \&pre_logic_1,
					args => [ 'selall', 'test', 'SELECT FinishedCenter FROM AutoAppData WHERE ID = ?', '[appdata_id]' ],
					expected => [ [ [ '21' ] ] ],
				},
				4 => { 	prepare => \&pre_logic_1,
					args => [ 'selallkeys', 'test', 'SELECT FinishedCenter FROM AutoAppData WHERE ID = ?', '[appdata_id]' ],
					expected => [ [ { FinishedCenter => '21' } ] ],
				},
			},
		},
		{	func => \&{ VCS::Site::autoform::get_hash_table },
			comment => 'get_hash_table',
			test => { 	
				1 => { 	prepare => \&pre_init_param,
					args => [ 'Branches', 'ID', '1' ],
					expected => {
						ID => '1',	
						BName => 'Moscow',
						Ord => '1',
						Timezone => '3',
						isDeleted => '0',
						isDefault => '1',
						Display => '1',
						BAddr => 'г.Москва',
						JAddr => 'г.Москва',
						AddrEqualled => '0',
						SenderID => '1',
						CTemplate => 'rtf',
						isConcil => '0',
						isSMS => '1',
						isUrgent => '1',
						posShipping => '1',
						isDover => '1',
						Insurance => '1',
						calcInsurance => '0',
						cdSimpl => '3',
						cdUrgent => '2',
						cdCatD => '14',
						CollectDate => '1',
						siteLink => 'http',
						calcConcil => '0',
						ConsNDS => '0',
						genbank => '0',
						isTranslate => '0',
						shengen => '1',
						isAnketa => '1',
						isPrinting => '0',
						isPhoto => '0',
						isVIP => '1',
						Weekend => '67',
						isShippingFree => '0',
						isPrepayedAppointment => '1',
						DefaultPaymentMethod => '1',
						DisableAppSameDay => '0',
					},
				},
			},
		},
		{	func => \&{ VCS::Site::autoform::create_table },
			comment => 'create_table',
			test => { 	
				1 => { 	args => [ 
						'AutoAppointments', 'Appointments', { AutoAppointments => '[app_id]' }, 
						{
							Appointments => { 
								PersonalDataPermission => 'nope',
								MobilPermission => 'nope',
								PersonForAgreements => 'nope',
							}
						},
						undef, undef, undef, undef, 'test_ver',
					],
					expected => '^[1-9]\d*$',
				},
			},
		},
		{	func => \&{ VCS::Site::autoform::age },
			comment => 'age',
			test => { 	
				1 => { 	args => [ '1999-06-23', '2017-06-15' ],
					expected => '17',
				},
				2 => { 	args => [ '1999-06-22', '2017-06-15' ],
					expected => '18',
				},
				3 => { 	args => [ '2016-08-01', '2017-06-15' ],
					expected => '0',
				},
				4 => { 	args => [ '2016-06-14', '2017-06-15' ],
					expected => '1',
				},
				5 => { 	args => [ '2018-01-01', '2017-06-15' ],
					expected => '0',
				},
				6 => { 	args => [ undef, '2017-06-15' ],
					expected => '99',
				},
				7 => { 	args => [ '2016-06-14', undef ],
					expected => '99',
				},
				8 => { 	args => [ undef, undef ],
					expected => '99',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::lang },
			comment => 'lang',
			test => { 	
				1 => { 	prepare => \&pre_lang,
					args => [ 'Дата вылета' ],
					expected => 'Departure date',
				},
				2 => { 	prepare => \&pre_lang,
					args => [ 'Фраза не имеющая никакого перевода' ],
					expected => 'Фраза не имеющая никакого перевода',
				},
				3 => { 	prepare => \&pre_lang,
					args => [ 'Дата вылета', 'ru' ],
					expected => 'Дата вылета',
				},
				4 => { 	args => [ 'Фраза не имеющая никакого перевода', 'en' ],
					expected => 'Фраза не имеющая никакого перевода',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::add_css_class },
			comment => 'add_css_class',
			test => { 	
				1 => { 	args => [ '<label class="info">text</label>', 'class2' ],
					expected => '<label class="info class2">text</label>',
				},
				2 => { 	args => [ '<label class="info class1">text</label>', 'class2' ],
					expected => '<label class="info class1 class2">text</label>',
				},
				3 => { 	args => [ '<label class="">text</label>', 'class2' ],
					expected => '<label class=" class2">text</label>',
				},
				4 => { 	args => [ '<label id="name">text</label>', 'class2' ],
					expected => '<label class="class2" id="name">text</label>',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::offset_calc },
			comment => 'offset_calc',
			test => { 	
				1 => { 	args => [ '1' ],
					expected => '1 день',
				},
				2 => { 	args => [ '2' ],
					expected => '2 дня',
				},
				3 => { 	args => [ '59' ],
					expected => '59 дней',
				},
				4 => { 	args => [ '60' ],
					expected => '2 месяца',
				},
				5 => { 	args => [ '187' ],
					expected => '6 месяцев',
				},
				6 => { 	args => [ '365' ],
					expected => '1 год',
				},
				7 => { 	args => [ '1100' ],
					expected => '3 года',
				},
				8 => { 	args => [ '3650' ],
					expected => '10 лет',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::cached },
			comment => 'cached',
			test => { 	
				1 => { 	prepare => \&pre_cach,
					args => [ 'cach_selftest' ],
					expected => 'cash_ok',
				},
				2 => { 	prepare => \&pre_cach,
					args => [ 'cach_selftest_fail' ],
					expected => '',
				},
				3 => { 	args => [ 'cach_selftest' ],
					expected => '',
				},
				4 => { 	tester => \&test_cached,
					args => [ 'cach_selftest_write', 12345 ],
					expected => 'cach_selftest_write:12345',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_file_content },
			comment => 'get_file_content',
			test => { 	
				1 => { 	prepare => \&pre_file,
					args => [ '/tmp/autoform_selftest_file' ],
					expected => 'file_ok',
				},
				2 => { 	tester => \&test_line,
					args => [ '/tmp/autoform_not_existing_file' ],
					expected => '',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_postcode_id },
			comment => 'get_postcode_id',
			test => { 	
				1 => { 	args => [ '655000,       Абакан' ],
					expected => 1,
				},
				2 => { 	args => [ '      655000, Абакан' ],
					expected => 1,
				},
				3 => { 	args => [ '123456, Спрингфилд' ],
					expected => [ undef, 'Спрингфилд' ],
				},
				4 => { 	args => [ '123456' ],
					expected => [ undef, undef ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_geo_info },
			comment => 'get_geo_info',
			test => { 	
				1 => { 	prepare => \&pre_geo_or_collect,
					expected => [ [ 55, 49, 'Казань' ] ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_collect_date },
			comment => 'get_collect_date',
			test => { 	
				1 => { 	prepare => \&pre_geo_or_collect,
					expected => '7',
				},
				2 => { 	prepare => \&pre_geo_or_collect, # <--- fixed num 2
					expected => '14',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_relation },
			comment => 'check_relation',
			test => { 	
				1 => { 	args => [ 1, get_content_rules_hash( 'with_raltion' )->{ 'Начало записи' }, 0 ],
					expected => [ 1, get_content_rules_hash( 'with_raltion' )->{ 'Начало записи' } ],
				},
				2 => { 	args => [ 1, get_content_rules_hash( 'with_raltion', 'skip', 'add' )->{ 'Начало записи' }, 0 ],
					expected => [ 2, get_content_rules_hash( 'with_raltion', undef, 'add' )->{ 'Данные поездки' } ],
				},
				3 => { 	args => [ 2, get_content_rules_hash( 'with_raltion', 'skip', 'add' )->{ 'Данные поездки' }, 'moonwalk' ],
					expected => [ 1, get_content_rules_hash( 'with_raltion', undef, 'add' )->{ 'Начало записи' } ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_step_by_content },
			comment => 'get_step_by_content',
			test => { 	
				1 => { 	args => [ '[list_of_applicants]', 0 ],
					expected => '3',
				},
				2 => { 	args => [ '[list_of_applicants]', 'next' ],
					expected => '4',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::set_step_by_content },
			comment => 'set_step_by_content',
			test => { 	
				1 => { 	tester => \&test_write_db,
					args => [ '[list_of_applicants]', 0 ],
					expected => '[token]:AutoToken:Step:3',
				},
				2 => { 	tester => \&test_write_db,
					args => [ '[list_of_applicants]', 'next' ],
					expected => '[token]:AutoToken:Step:4',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_forward },
			comment => 'get_forward',
			test => { 
				1 => { 	args => [ 1, 'Token' ],
					param => { 
						center => '1',
						vtype => '13',
						free_date => '',
						email => 'mail@mail.ru',
						pers_info => '1',
						mobil_info => '1',
					},
					expected => [ 2, '', undef, undef],
				},			
				2 => { 	args => [ 1, 'Token' ],
					param => { 
						center => '1',
						vtype => '',
						free_date => '',
						email => 'mail@mail.ru',
						pers_info => '1',
						mobil_info => '1',
					},
					expected => [ 1, 'vtype|Поле "Тип визы" не заполнено', undef, undef],
				},
				3 => { 	args => [ 1, 'Token' ],
					param => { 
						center => '1',
						vtype => '13',
						free_date => '',
						email => 'mail@mail.ru',
						pers_info => '',
						mobil_info => '1',
					},
					expected => [ 1, 'pers_info|Вы должны указать поле "я согласен на обработку персональных данных"', 
						undef, undef],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_back },
			comment => 'get_back',
			test => { 
				1 => { 	args => [ 2, 'Token' ],
					expected => 1,
				},
				2 => { 	args => [ 5, 'Token' ],
					expected => 3,
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::set_appointment_finished },
			comment => 'set_appointment_finished',
			test => { 	
				1 => { 	args => [ '[token]' ],
					expected => '^[1-9]\d*$',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_edit },
			comment => 'get_edit',
			test => { 	
				1 => { 	tester => \&test_write_db,
					args => [ 1, '[appdata_id]' ],
					expected => '[token]:AutoToken:AutoAppDataID:[appdata_id]',
				},
				2 => { 	tester => \&test_write_db,
					args => [ 1, '111' ],
					expected => '[token]:AutoToken:AutoAppDataID:[appdata_id]',
				},
				3 => { 	tester => \&test_write_db,
					args =>[ 1, '[appdata_id]' ],
					expected => '[token]:AutoToken:Step:4',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_all_app_finished_and_not_empty },
			comment => 'check_all_app_finished_and_not_empty',
			test => { 	
				1 => { 	expected => 4,
				},
				2 => { 	prepare => \&pre_logic_1, # <--- fixed num 2
					expected => 19,
				},
				3 => { 	prepare => \&pre_logic_1,
					expected => 22,
				},
				4 => { 	prepare => \&pre_nobody,
					expected => 5,
				},
				5 => { 	prepare => \&pre_logic_1,  # <--- fixed num 5
					expected => 0,
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_passnum_already_in_pending },
			comment => 'check_passnum_already_in_pending',
			test => { 	
				1 => { 	prepare => \&pre_passnum,
					expected => 0,
				},
				2 => { 	expected => 1,
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_list_of_app },
			comment => 'get_list_of_app',
			test => { 	
				1 => { 	prepare => \&pre_token,
					args => [ 'Token' ],
					expected => [ [ { ID => 'X' } ], 'autoform_list.tt2' ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_comments_alter_version },
			comment => 'check_comments_alter_version',
			test => { 	
				1 => { 	args => [ { 1 => 'test1', 10 => 'test2' } ],
					expected => 'test1',
				},
				2 => { 	args => [ { '2,4,5' => 'test1', '2,1,3' => 'test2' } ],
					expected => 'test2',
				},
				3 => { 	args => [ { '2,3,4' => 'test1' } ],
					expected => '',
				},
				4 => { 	args => [ 'test0' ],
					expected => 'test0',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::change_current_appdata },
			comment => 'change_current_appdata',
			test => { 	
				1 => { 	args => [ 785, '[table_id]' ],
					expected => 1,
				},
				2 => { 	tester => \&test_write_db,
					args => [ 1234, '[table_id]' ],
					expected => '[token_id]:AutoToken:AutoAppDataID:1234',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_all_values },
			comment => 'get_all_values',
			test => { 	
				1 => { 	args => [ 5, '[table_id]' ],
					expected => { visa_text => undef },
				},
				2 => { 	args => [ 1, '[table_id]' ],
					expected => {
						email => 'mail@mail.ru',
						vtype => '13',
						pers_info => '0', 
						mobil_info => '0',
						center => '1',
					},
				},
				3 => { 	prepare => \&pre_getinfo,
					args => [ 2, '[table_id]' ],
					expected => {
						f_date => '01.05.2011',
						s_date => '01.05.2011'
					},
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_data_from_form },
			comment => 'check_data_from_form',
			test => { 	
				1 => { 	args => [ 1 ],
					param => { 
						center => '1',
						vtype => '13',
						free_date => '',
						email => 'mail@mail.ru',
						pers_info => '1',
						mobil_info => '1',
					},
					expected => '',
				},
				2 => { 	args => [ 3 ],
					expected => '',
				},
				3 => { 	args => [ 1 ],
					param => {
						center => '',
						vtype => '13',
						free_date => '',
						email => 'mail@mail.ru',
						pers_info => '1',
						mobil_info => '1',
					},
					expected => 'center|Поле "Визовый центр" не заполнено',
				},
				4 => { 	args => [ 1 ],
					param => { 
						center => '1',
						vtype => '13',
						free_date => '',
						email => '',
						pers_info => '1',
						mobil_info => '1',
					},
					expected => 'email|Поле "Email" не заполнено',
				},
				5 => { 	args => [ 1 ],
					param => {
						center => '1',
						vtype => '13',
						free_date => '',
						email => 'mail@mail.ru',
						pers_info => '',
						mobil_info => '1',
					},
					expected => 'pers_info|Вы должны указать поле "я согласен на обработку персональных данных"',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::save_data_from_form },
			comment => 'save_data_from_form',
			test => { 	
				1 => { 	tester => \&test_write_db,
					args => [ 1, '[table_id]' ],
					param => {
						center => '1',
						vtype => '99',
						free_date => '',
						email => 'mail@mail.ru',
						pers_info => '1',
						mobil_info => '1',
					},
					expected => '[app_id]:AutoAppointments:VType:99',
				},
				2 => { 	tester => \&test_write_db,
					args => [ 2, '[table_id]' ],
					param => { 
						f_date => '01.05.1998',
						s_date => '01.05.1999',
					},
					expected => '[app_id]:AutoAppointments:SDate:1999-05-01',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::correct_values },
			comment => 'correct_values',
			test => { 	
				1 => { 	args => [ \{ new_app_num => 10 }, 20 ],
					expected => { new_app_num => 20 },
				},
				2 => { 	prepare => \&pre_geo_or_collect, # <--- fixed num 2
					args => [ \{ new_app_branch => 5 } ],
					expected => { new_app_branch => 'Kazan' },
				},
				3 => { 	prepare => \&pre_init_param,
					args => [ \{ new_app_timeslot => 10 } ],
					expected => { new_app_timeslot => '9:00 - 9:25' },
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_mobile_api },
			comment => 'get_mobile_api',
			test => { 	
				1 => { 	args => [ '[token]' ],
					param => { mobile_api => 'get_token_wrong' },
					expected => {
						error => { error_text => 'ошибка API-запроса', error => 2 },
						token => '[token]',
					},
				},
				2 => { 	prepare => \&pre_token, # <--- fixed num 2
					param => { mobile_api => 'get_appdata' },
					expected => {
						error => { error_text => 'ошибка токена', error => 1 },
						token => '01',
					},
				},
				3 => { 	param => { mobile_api => 'get_token' },
					expected => {
						error => { error_text => undef, error => 0 },
						token => '[token]',
					},
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_prepare_line },
			comment => 'get_prepare_line',
			test => { 	
				1 => { 	args => [ '    start_line   end_line     ' ],
					expected => 'start_line   end_line',
				},
				2 => { 	args => [ 'line with nbsp' ],
					expected => 'line with nbsp',
				},
				3 => { 	args => [ '           ' ],
					expected => '',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::add_rules_format },
			comment => 'add_rules_format',
			test => {
				1 => { 	args => [ 'zN' ],
					expected => '<br><br><b>Обязательное поле</b><br>В поле допустимо вводить цифры',
				},
				2 => { 	args => [ 'WN\s\@' ],
					expected => '<br><br><b>Необязательное поле</b><br>В поле допустимо вводить английские буквы, цифры, а также символы пробела, @',
				},
				3 => { 	args => [ 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$' ],
					expected => '<br><br><b>Обязательное поле</b><br>В поле вводится дата в формате ДД.ММ.ГГГГ',
				},
				4 => { 	args => [ 'zЁ\s\-' ],
					expected => '<br><br><b>Обязательное поле</b><br>В поле допустимо вводить русские буквы, а также символы пробела, дефиса',
				},
				5 => { 	args => [ 'zWЁ\(\)' ],
					expected => '<br><br><b>Обязательное поле</b><br>В поле допустимо вводить русские и английские буквы, а также символы скобок',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::mod_last_change_date },
			comment => 'mod_last_change_date',
			test => { 	
				1 => { 	expected => 1,
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::send_link },
			comment => 'send_link',
			test => { 	
				1 => { 	args => [ 'test@test.com' ],
					expected => 1,
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_pcode },
			comment => 'get_pcode',
			test => { 	
				1 => { 	prepare => \&pre_init_param,
					param => { name_startsWith => 'ABA' },
					expected => [ [
						{
							ID => '1',
							isDefault => '0',
							CName => 'Абакан',
							PCode => '655000',
							DPrice => '2022.28',
							RName => 'Абакан',
							Center => 1
						}
					] ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::redirect },
			comment => 'redirect',
			test => {
				1 => { 	args => [ '' ],
					expected => '?lang=ru',
				},
				2 => { 	args => [ 'current' ],
					expected => '?t=[token]&lang=ru',
				},
				3 => { 	args => [ 'something' ],
					expected => '?t=something&lang=ru',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_content_rules_hash_opt },
			comment => 'get_content_rules_hash_opt',
			test => { 	
				1 => { 	expected => get_content_rules_hash()
				},
				2 => { 	prepare => \&pre_show_no_testing,
					expected => VCS::Site::autodata_type_c::get_content_rules_hash(),
				},
				3 => { 	prepare => [ \&pre_visa_type_d, \&pre_show_no_testing ],
					expected => VCS::Site::autodata_type_d::get_content_rules_hash(),
				},
				4 => { 	prepare => [ \&pre_spb_centers, \&pre_show_no_testing ],
					expected => VCS::Site::autodata_type_c_spb::get_content_rules_hash(),
				}
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_progressbar_hash_opt },
			comment => 'get_progressbar_hash_opt',
			test => { 	
				1 => { 	expected => [ get_progressline() ],
				},
				2 => { 	prepare => \&pre_show_no_testing,
					expected => [ VCS::Site::autodata_type_c::get_progressline() ],
				},
				3 => { 	prepare => [ \&pre_visa_type_d, \&pre_show_no_testing ],
					expected => [ VCS::Site::autodata_type_d::get_progressline() ],
				},
				4 => { 	prepare => [ \&pre_spb_centers, \&pre_show_no_testing ],
					expected => [ VCS::Site::autodata_type_c_spb::get_progressline() ],
				},
			},
		},
		{	func => \&{ VCS::Site::autoform::mutex_fail },
			comment => 'mutex_fail',
			test => {
				1 => { 	prepare => [ \&pre_show_no_testing ],
					args => [ [ { PassNum => '' } ] ],
					expected => 4,
				},
				2 => { 	prepare => [ \&pre_show_no_testing, \&pre_passnum, \&pre_logic_1 ],
					args => [ [ { PassNum => 'TEST_PASS_UNIQ' } ] ],
					expected => 25,
				},
				3 => { 	prepare => [ \&pre_show_no_testing, \&pre_mutex_fail_cach, \&pre_logic_1 ],
					args => [ [ { PassNum => '332211' } ] ],
					expected => 25,
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::check_mutex_for_creation },
			comment => 'check_mutex_for_creation',
			test => {
				1 => { 	args => [ 2 ],
					expected => [ '', 2 ],
				},
				2 => { 	prepare => [ \&pre_show_no_testing, \&pre_mutex_fail_creation ],
					args => [ 7 ],
					expected => [ 'applist|Вы должны полностью заполнить анкеты или удалить ненужные черновики', 5 ],
				},
				3 => { 	prepare => [ \&pre_mutex_fail_creation ],
					args => [ 7 ],
					expected => [ '', 7 ],
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_app_visa_and_center },
			comment => 'get_app_visa_and_center',
			test => {
				1 => { 	expected => [ 1, 'C' ],
				},
				2 => { 	prepare => \&pre_token,
					expected => '',
				},
				3 => {	prepare => \&pre_vtype_clear,
					expected => [ 1 ],
				}
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_app_version },
			comment => 'get_app_version',
			test => {
				1 => { 	expected => 'новая форма записи',
				},
				2 => { 	param => { mobile_ver => 1 },
					expected => 'новая форма записи (мобильная версия)',
				},
				3 => { 	param => { mobile_app => 1 },
					expected => 'новая форма записи (мобильное приложение)',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_captcha_id },
			comment => 'get_captcha_id',
			test => {
				1 => { 	expected => '^recaptcha_[0-9A-Za-z]{10}$',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::date_format },
			comment => 'date_format',
			test => {
				1 => { 	args => [ '2011-12-31' ],
					expected => '31.12.2011',
				},
				2 => { 	args => [ '31.12.2011' ],
					expected => '31.12.2011',
				},
				3 => { 	args => [ '31.12.2011', 'to_iso' ],
					expected => '2011-12-31',
				},
				4 => { 	args => [ '2011-12-31', 'to_iso' ],
					expected => '2011-12-31',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::split_and_clarify },
			comment => 'split_and_clarify',
			test => {
				1 => { 	args => [ 'ABCDEF' ],
					expected => 'A, B, C, D, E, F',
				},
				2 => { 	args => [ '/.A' ],
					expected => 'A, косая черта, точка',
				},
				3 => { 	args => [ 'A/A' ],
					expected => 'A, косая черта',
				},
				4 => { 	args => [ '.....' ],
					expected => 'точка',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::mobile_end },
			comment => 'mobile_end',
			test => {
				1 => { 	expected => '?lang=ru',
				},
			},
		},
		{ 	func => \&{ VCS::Site::autoform::get_delete }, # <--- fixed last
			comment => 'get_delete',
			test => {
				1 => { 	args => [ '[appdata_id]' ],
					expected => 2,
				},
				2 => { 	tester => \&test_write_db,
					args => [ '[appdata_id]' ],
					expected => '[appdata_id]:AutoAppData:ID:',
				},
			},
		},
	];
	
	my $test_obj = bless $tests, 'test';
	return $test_obj;
}

my $progress_bar = 
	'<td class="pr_size_gen pr_white_gray_gen center"><div class="big_progr pr_current centered" title=""><div class="pr_in_gen">1</div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Данные"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="big_progr pr_future centered" title=""><div class="pr_in_gen">2</div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Паспорта"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Допданные"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Поездка"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Проживание"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Расходы"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Ещё?"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="На кого?"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Данные"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="big_progr pr_future centered" title=""><div class="pr_in_gen">3</div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Офис"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Подтверждение"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_white_gen center"><div class="big_progr pr_future centered" title=""><div class="pr_in_gen">4</div></div></td></tr><tr><td class="stage_gen">Начало</td><td class="stage_gen"></td><td class="stage_gen">Заявители</td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen">Оформление</td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen">Готово!</td>';

my $progress_bar_2 = 
	'<td class="pr_size_gen pr_white_red_gen center"><div class="big_progr pr_past centered" title=""><div class="pr_in_gen">1</div></div></td><td class="pr_size_gen pr_red_gray_gen center"><div class="ltl_progr pr_current centered" title="Данные"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="big_progr pr_future centered" title=""><div class="pr_in_gen">2</div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Паспорта"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Допданные"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Поездка"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Проживание"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Расходы"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Ещё?"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="На кого?"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Данные"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="big_progr pr_future centered" title=""><div class="pr_in_gen">3</div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Офис"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_gray_gen center"><div class="ltl_progr pr_future centered" title="Подтверждение"><div class="pr_in_gen"></div></div></td><td class="pr_size_gen pr_gray_white_gen center"><div class="big_progr pr_future centered" title=""><div class="pr_in_gen">4</div></div></td></tr><tr><td class="stage_gen">Начало</td><td class="stage_gen"></td><td class="stage_gen">Заявители</td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen">Оформление</td><td class="stage_gen"></td><td class="stage_gen"></td><td class="stage_gen">Готово!</td>';

my $first_page = 
	'<tr><td class="left"><label data-id="text">Визовый центр</label></td><td class="left"><select class="input_width select_gen" size = "1" name="center" title="" id="center" onchange="update_nearest_date_free_date();"></select></td></tr><tr><td class="left"><label data-id="text">Тип визы</label></td><td class="left"><select class="input_width select_gen" size = "1" name="vtype" title="" id="vtype"><option  value="13">Turismo</option></select></td></tr><tr><td class="left"><label data-id="text">Ближайшее доступное время</label></td><td class="left"><label class="info" title="" id="free_date">—</label></td></tr><tr><td class="left" rowspan=2><label data-id="text">Email</label></td><td class="left bottom" ><input class="input_width input_gen" type="text" value="" name="email" id="email" title="Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре<br><br><b>Обязательное поле</b><br>В поле допустимо вводить английские буквы, цифры, а также символы @, пробела, дефиса, точки, запятой, точки с запятой"></td></tr><tr><td class="exam_td_gen left"><span class="exam_span_gen">пример: mail@mail.ru</span></td></tr><tr><td class="left"><label data-id="text"></label></td><td class="left"><input type="checkbox" value="pers_info" name="pers_info" id="pers_info">&nbsp;<label for="pers_info">я согласен на обработку персональных данных</label></td></tr><tr><td class="left"><label data-id="text"></label></td><td class="left"><input type="checkbox" value="mobil_info" name="mobil_info" id="mobil_info">&nbsp;<label for="mobil_info">я согласен на условия работы с мобильными телефона на территории визового центра</label></td></tr>';

my $first_page_selected = 
	'<tr><td class="left"><label data-id="text">Визовый центр</label></td><td class="left"><select class="input_width select_gen" size = "1" name="center" title="" id="center" onchange="update_nearest_date_free_date();"></select></td></tr><tr><td class="left"><label data-id="text">Тип визы</label></td><td class="left"><select class="input_width select_gen" size = "1" name="vtype" title="" id="vtype"><option selected value="13">Turismo</option></select></td></tr><tr><td class="left"><label data-id="text">Ближайшее доступное время</label></td><td class="left"><label class="info" title="" id="free_date">—</label></td></tr><tr><td class="left" rowspan=2><label data-id="text">Email</label></td><td class="left bottom" ><input class="input_width input_gen" type="text" value="" name="email" id="email" title="Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре<br><br><b>Обязательное поле</b><br>В поле допустимо вводить английские буквы, цифры, а также символы @, пробела, дефиса, точки, запятой, точки с запятой"></td></tr><tr><td class="exam_td_gen left"><span class="exam_span_gen">пример: mail@mail.ru</span></td></tr><tr><td class="left"><label data-id="text"></label></td><td class="left"><input type="checkbox" value="pers_info" name="pers_info" id="pers_info">&nbsp;<label for="pers_info">я согласен на обработку персональных данных</label></td></tr><tr><td class="left"><label data-id="text"></label></td><td class="left"><input type="checkbox" value="mobil_info" name="mobil_info" id="mobil_info">&nbsp;<label for="mobil_info">я согласен на условия работы с мобильными телефона на территории визового центра</label></td></tr>';
	
my $second_page = 
	'<tr><td class="left" rowspan=2><label data-id="text">Дата начала поездки</label></td><td class="left bottom" ><input class="input_width input_gen" type="text" value="" name="s_date" id="s_date" title="Введите предполагаемую дату начала поездки<br><br><b>Обязательное поле</b><br>В поле вводится дата в формате ДД.ММ.ГГГГ"></td></tr><tr><td class="exam_td_gen left"><span class="exam_span_gen">пример: 01.01.2025</span></td></tr><tr><td class="left" rowspan=2><label data-id="text">Дата окончания поездки</label></td><td class="left bottom" ><input class="input_width input_gen" type="text" value="" name="f_date" id="f_date" title="Введите предполагаемую дату окончания поездки<br><br><b>Обязательное поле</b><br>В поле вводится дата в формате ДД.ММ.ГГГГ"></td></tr><tr><td class="exam_td_gen left"><span class="exam_span_gen">пример: 31.12.2025</span></td></tr>';

sub get_content_rules_hash
# //////////////////////////////////////////////////
{
	my ( $with_raltion, $skip_this, $add_page_name ) = @_;

	my $content_rules = {
	
		'Начало записи' => [
			{
				page_ord => 1,
				progress => 1,
				param => 1,
			},
			{
				type => 'select',
				name => 'center',
				label => 'Визовый центр',
				comment => '',
				check => 'zN',
				db => {
					table => 'Appointments',
					name => 'CenterID',
				},
				param => '[centers_from_db]',
				uniq_code => 'onchange="update_nearest_date_free_date();"',
				special => 'cach_this_value',
			},
			{
				type => 'select',
				name => 'vtype',
				label => 'Тип визы',
				comment => '',
				check => 'zN',
				db => {
					table => 'Appointments',
					name => 'VType',
				},
				param => '[visas_from_db]',
				special => 'cach_this_value',
			},
			{
				type => 'info',
				name => 'free_date',
				label => 'Ближайшее доступное время',
				comment => '',
				check => '',
				special => 'nearest_date',
			},
			{
				type => 'input',
				name => 'email',
				label => 'Email',
				comment => 'Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре',
				example => 'mail@mail.ru',
				check => 'zWN\@\s\-\.\,\;',
				db => {
					table => 'Appointments',
					name => 'EMail',
				},
			},
			{
				type => 'checkbox',
				name => 'pers_info',
				label => '',
				label_for => 'я согласен на обработку персональных данных',
				comment => '',
				check => 'true',
				db => {
					table => 'Appointments',
					name => 'PersonalDataPermission',
					transfer => 'nope',
				},
			},
			{
				type => 'checkbox',
				name => 'mobil_info',
				label => '',
				label_for => 'я согласен на условия работы с мобильными телефона на территории визового центра',
				comment => '',
				check => 'true',
				db => {
					table => 'Appointments',
					name => 'MobilPermission',
					transfer => 'nope',
				},
				relation => {},
			},
		],
		
		'Данные поездки' => [
			{
				page_ord => 2,
				progress => 2,
				collect_date => 1,
			},
			{
				type => 'input',
				name => 's_date',
				label => 'Дата начала поездки',
				comment => 'Введите предполагаемую дату начала поездки',
				example => '01.01.2025',
				check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				check_logic => [
					{
						condition => 'now_or_later',
						offset => '[collect_date_offset]',
					},
				],
				db => {
					table => 'Appointments',
					name => 'SDate',
				},
				special => 'datepicker, mask',
			},
			{
				type => 'input',
				name => 'f_date',
				label => 'Дата окончания поездки',
				comment => 'Введите предполагаемую дату окончания поездки',
				example => '31.12.2025',
				check => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				check_logic => [
					{
						condition => 'equal_or_later',
						table => 'Appointments',
						name => 'SDate',
						error => 'Дата начала поездки',
					},
				],
				db => {
					table => 'Appointments',
					name => 'FDate',
				},
				load_if_free_field => {
					table => 'Appointments',
					name => 'SDate',
				},
				special => 'datepicker, mask',
			},

		],
		
		'Страница окончания записи' => [
			{
				page_ord => 6,
				progress => 6,
				replacer => '[app_finish]',
			},
		],
		
		'Выберите лицо на которое будет оформлен договор' => [
			{
				page_ord => 23,
				progress => 10,
				persons_in_page => 1,
			},
			{
				type => 'select',
				name => 'visa_text',
				label => 'Выберите на кого оформляется',
				comment => '',
				check => 'zN',
				db => {
					table => 'Appointments',
					name => 'PersonForAgreements',
					transfer => 'nope',
				},
				param => '[persons_in_app]',
				special => 'save_info_about_hastdatatype',
			},
		],
		'Список заявителей' => [
			{
				page_ord => 5,
				progress => 3,
				goto_link => 'back_to_appdata',
				replacer => '[list_of_applicants]',
			},
		],
		'Страница с непередающимися в БД полями' => [
			{
				page_ord => 100,
				progress => 10,
			},
			{
				type => 'checkbox',
				name => 'no_rumname',
				label_for => 'нет отчества',
				db => {
					table => 'AppData',
					name => 'NoRMName',
					transfer => 'nope',
				},
			},
			{
				type => 'input',
				name => 'info_address',
				label => 'Адрес',
				comment => 'Полный адрес, включая индекс',
				example => '105203, г.Москва, ул.Ленина, д.1, кв.1',
				check => 'zЁN\s\-\_\.\,\;\'\"',
				db => {
					table => 'AppData',
					name => 'RAddress',
					transfer => 'nope',
				},
			},
		],
	};
	
	for ( 'Начало записи', 'Данные поездки', 'Выберите лицо на которое будет оформлен договор' ) {
		$content_rules->{ $_ }->[ 0 ]->{ relation } = {} if $with_raltion;
		
		$content_rules->{ $_ }->[ 0 ]->{ relation } = { only_if => 
			{ table => 'Appointments', name => 'CenterID', value => '99' } } if $skip_this;
		$content_rules->{ $_ }->[ 0 ]->{ page_name } = $_ if $add_page_name;
	}

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


sub get_blocked_emails
# //////////////////////////////////////////////////
{
	return [
		{
			for_centers => [ 1 ],
			show_truth => 0,
			emails => [
				'blocked1mail@mail.com',
			],
		},
		{
			for_centers => [ 1 ],
			show_truth => 1,
			emails => [
				'blocked2mail@mail.com',
			],
		},
		{
			for_centers => [ 5 ],
			show_truth => 0,
			emails => [
				'blocked3mail@mail.com',
			],
		},
	];
};

sub get_geo_branches
# //////////////////////////////////////////////////
{
	return {
		5 => [ '55', '49', ],
	};
};

sub selftest 
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{ 'VCS::Vars' };
	my $config = $vars->getConfig('db');
	
	$self->{ this_is_self_testing } = 1;
	
	$self->{ vars } = $vars;
	
	$vars->get_memd->delete( $_ ) for (
		'cach_selftest', 'cach_selftest_write', 'autoform_addparam', 'autoform_collectdates', 'autoform_allpcode',
	);
	
	$vars->db->query("USE fake_vcs");

	my $result = [ { 'text' => "self_self_test", 'status' => self_self_test() } ];
	
	my @param = get_test_appointments( $self, $vars );

	$vars->get_memd->set( 'autoform_' . $param[0] . '_vtype', 1, 60 );
	$vars->get_memd->set( 'autoform_' . $param[0]. '_center', 5, 60 );
	
	push @$result, { 'text' => 'create_clear_form', 'status' => ( ( $param[0] =~ /^t[a-z0-9]{63}$/ ) and ( $param[1] =~ /^\d+$/ ) ? 0 : 1 ) };
	push @$result, { 'text' => 'get_add', 'status' => ( ( $param[1] =~ /^\d+$/ ) ? 0 : 1 ) };
	push @$result, get_tests( $self, $vars, @param );
	
	$vars->db->query( "USE $config->{'dbname'}" );
	
	$vars->get_memd->delete( $_ ) for ( 'autoform_addparam', 'autoform_collectdates', 'autoform_allpcode' );

	return show_result($result);
}

sub get_test_appointments
{
	my $self = shift;
	my $vars = shift;
	
	my $test_token = $self->get_token_and_create_new_form_if_need();
	
	$self->{ token } = $test_token;
	
	$self->create_clear_form();
	
	my $appid = $vars->db->sel1("
		SELECT AutoAppID FROM AutoToken WHERE Token = ?", $test_token);
	
	$self->get_add( $appid, $test_token );

	my @param = $vars->db->sel1("
		SELECT AutoAppDataID, AutoSchengenAppDataID, ID, AutoSpbDataID
		FROM AutoToken WHERE Token = ?", $test_token);
		
	return ( $test_token, $appid, @param );
}

sub get_tests
# //////////////////////////////////////////////////
{
	my ( $self, $vars, $test_token, $test_appid, $test_appdataid ) = @_;

	my @result = ();

	my $tests = get_test_list();
	
	for my $test (@$tests) {
	
		my ( $err_line, $test_num, $tester ) = ( '', 0, undef );
		
		for( sort { $a <=> $b } keys %{ $test->{test} } ) {
	
			$test_num++;

			my $t = $test->{test}->{$_};

			&{ $t->{prepare} }( $self, 'PREPARE', \$test, $_, \$test_token, $test_appid, $test_appdataid, $vars ) 
				if ref( $t->{prepare} ) eq 'CODE';
			
			if ( ref( $t->{prepare} ) eq 'ARRAY' ) {
				for my $func_prepare ( @{ $t->{prepare} } ) {
					&{ $func_prepare }( $self, 'PREPARE', \$test, $_, \$test_token, $test_appid, $test_appdataid, $vars );
				}
			}	
			
			$_ = replace_var( $_, @_ ) for ( @{ $t->{args} }, 
				( ref( $t->{expected} ) eq 'ARRAY' ? @{ $t->{expected} } : 
				( ref( $t->{expected} ) eq 'HASH' ? values %{ $t->{expected} } : $t->{expected} ) )
			);

			for ( keys %{ $t->{param} } ) {

				$t->{param}->{ $_ } = replace_var( $t->{param}->{ $_ }, @_ );
				$vars->setparam( $_, $t->{param}->{ $_ } );
			}
			
			my $tester = tester_func( $t );
			
			my $test_result = &{ $tester }( 
				$t->{debug}, $t->{expected}, "$test->{comment}-$test_num", $self, 
				&{ $test->{func} }( $self, @{ $t->{args} } )
			);
	
			if ( $test_result ) {
				$err_line .= ( $err_line ? ', ' : '' ) . $test_num;
			}
			
			&{ $t->{prepare} }( $self, 'CLEAR', \$test, $_, \$test_token, $test_appid, $test_appdataid, $vars ) 
				if ref( $t->{prepare} ) eq 'CODE';
				
			if ( ref( $t->{prepare} ) eq 'ARRAY' ) {
				for my $func_prepare ( @{ $t->{prepare} } ) {
					&{ $func_prepare }( $self, 'CLEAR', \$test, $_, \$test_token, $test_appid, $test_appdataid, $vars );
				}
			}	
		}
		
		push @result, { 'text' => "$test->{comment}", 'status' => $err_line };
	}
	
	return @result;
}

sub tester_func
# //////////////////////////////////////////////////
{
	my $t = shift;
	
	return $t->{tester} if $t->{tester};
	
	return \&test_hash if ref $t->{expected} eq 'HASH';
	
	return \&test_array if ref $t->{expected} eq 'ARRAY';
	
	return \&test_regexp if $t->{expected} =~ /^\^/ ;
	
	return \&test_line;
}

sub replace_var
# //////////////////////////////////////////////////
{
	local $_ = shift;
	
	my ( $self, $vars, $test_token, $test_appid, $test_appdataid, $test_appdata_schid, $token_id, $test_spb_id ) = @_;

	my $table_id = {
		'AutoToken' => $token_id,
		'AutoAppointments' => $test_appid,
		'AutoAppData' => $test_appdataid,
		'AutoSchengenAppData' => $test_appdata_schid,
		'AutoSpbAlterAppData' => $test_spb_id
	};
	
	$_ = $table_id if /\[table_id\]/;
	
	$_ = $self->get_progressbar_hash_opt() if /\[progressbar_hash\]/;
	
	s/\[token\]/$test_token/g;
	s/\[token_id\]/$token_id/g;
	s/\[app_id\]/$test_appid/g;
	s/\[appdata_id\]/$test_appdataid/g;
	s/\[schdata_id\]/$test_appdata_schid/g;
	s/\[spb_id\]/$test_spb_id/g;
	s/\[progress_bar\]/$progress_bar/g;
	s/\[progress_bar_2\]/$progress_bar_2/g;
	s/\[first_page\]/$first_page/g;
	s/\[first_page_selected\]/$first_page_selected/g;
	s/\[second_page\]/$second_page/g;
	
	if ( ref($_) eq 'HASH' ) {
		for my $field ( keys %$_ ) {
			$_->{ $field } = replace_var( $_->{ $field }, @_ );
		}
	}
	
	if ( /\[page(\d+)\]/ ) {
		$_ = $self->get_content_rules( $1, 'full' );
	}
	
	if ( /\[progress(\d+)\]/ ) {
		$_ = $self->get_content_rules( $1, 'full' )->[0]->{ progress };
	}
	
	return $_;
}

sub show_result
# //////////////////////////////////////////////////
{
	my $result = shift;
	
	my $result_line = self_test_htm( 'body_start' );
	
	my $test_num = 18; # <--- 16 self_self + create_clear_form + get_add
	
	my $test_func = 2; # <--- create_clear_form + get_add
	
	my $fails = 0;

	my $tests = get_test_list();
	
	for my $test (@$tests) {
		$test_num++ for( keys %{ $test->{test} } );
		$test_func++;
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
	$result_line .= 
		self_test_htm( 'br' ) . 
		self_test_htm( 'span', ( $fails ? 'red' : 'green' ), "Всего функций протестировано: $test_func" ) .
		self_test_htm( 'span', ( $fails ? 'red' : 'green' ), "Всего тестов: $test_num" );
	
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

	$fail_in_myself += ! test_hash( $self_debug, {}, 'self6', undef, { 'key1' => 'value1' } );
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

sub debug_head
# //////////////////////////////////////////////////
{
	return '>'x12 . ' ' . shift . ' ' . '<'x12;
}

sub test_line
# //////////////////////////////////////////////////
{
	my ( $debug, $expected, $comm, undef, $result ) = @_;

	warn debug_head( $comm ) . "\n\nEXPECTED\n\n$expected\n\nRESULT\n\n$result" if $debug;
	
	return $comm if lc( $expected ) ne lc( $result );
}

sub test_line_in_hash
# //////////////////////////////////////////////////
{
	my ( $debug, $expected, $comm, undef, $result ) = @_;
	my ( $key, $value ) = split( /:/, $expected );
	
	warn debug_head( $comm ) . "\n\n" . Dumper( $expected, $result ) if $debug;

	return $comm if lc( $result->{ $key } ) ne lc( $value );
}

sub test_hash
# //////////////////////////////////////////////////
{
	my ( $debug, $expected, $comm, undef, $result ) = @_;
	my $not_eq = 0;

	warn debug_head( $comm ) . "\n\n" . Dumper( $expected, $result ) if $debug;
	
	$not_eq += ( keys %$expected != keys %$result );
	
	for ( keys %$expected, keys %$result ) {
		$not_eq += ( recursive_check( $debug, $expected->{ $_ }, $comm, undef, $result->{ $_ } ) ? 1 : 0 );
	}

	return 1 if $not_eq;
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
	
	warn debug_head( $comm ) . "\n\n" . Dumper( $expected, \@result ) if $debug;
	
	return 0 if ( $#result < 0 ) and ( $#$expected < 0 );
	return 1 if ( $#result < 0 ) or ( $#$expected < 0 );
	return 1 if ( $#result != $#$expected );

	for ( 0..$#result ) {
		$not_eq += ( recursive_check( $debug, $expected->[$_], $comm, undef, $result[$_] ) ? 1 : 0 );
	}

	return 1 if $not_eq;
}

sub test_array_ref
# //////////////////////////////////////////////////
{
	my ( $debug, $expected, $comm, $self, $result ) = @_;

	warn debug_head( $comm ) . "\n\n" . Dumper( $expected, $result ) if $debug;
	
	my $not_eq = 0;
	
	return 0 if ( $#$result < 0 ) and ( $#$expected < 0 );
	return 1 if ( $#$result < 0 ) or ( $#$expected < 0 );
	return 1 if ( $#$result != $#$expected );


	for ( 0..$#$result ) {
		$not_eq += ( recursive_check( $debug, $expected->[$_], $comm, undef, $result->[$_] ) ? 1 : 0 );
	}
	
	return 1 if $not_eq;
}

sub test_regexp
# //////////////////////////////////////////////////
{
	my ( $debug, $regexp, $comm, undef, $result ) = @_;
	
	warn debug_head( $comm ) . "\n\nREGEXP:\n\n$regexp\n\nRESULT\n\n$result" if $debug;
	
	return $comm if $result !~ /$regexp/;
}

sub test_cached
# //////////////////////////////////////////////////
{
	my ( $debug, $cached, $comm, $self ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my ( $cached_name, $cached_value ) = split( /:/, shift );
	
	my $result = $vars->get_memd->get( $cached_name );
	
	warn debug_head( $comm ) . "\n\nCACHED\n\n$cached_value\n\nRESULT\n\n$result" if $debug;
	
	return $comm if $result ne $cached_value;
}

sub test_write_db
# //////////////////////////////////////////////////
{
	my $debug = shift;
	my ( $token_or_appid, $db_table, $db_name, $db_value ) = split( /:/, shift );
	my ( $comm, $self, $result ) = @_;

	my $vars = $self->{ 'VCS::Vars' };
	
	my $field = ( $token_or_appid =~ /^(t[a-z0-9]{63}|Token\d?)$/ ? "Token" : "ID" );
	
	my $value = $vars->db->sel1("
		SELECT $db_name FROM $db_table WHERE $field = '$token_or_appid'"
	);

	warn debug_head( $comm ) . "\n\nDB VALUE\n\n$db_value\n\nVALUE\n\n$value" if $debug;

	return $comm if lc( $db_value ) ne lc( $value );
}

sub pre_corrupt_token
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token ) = @_;
	
	return unless $type eq 'PREPARE'; 
	
	my $vars = $self->{ 'VCS::Vars' };

	my $t = $$token;
	
	$t =~ s/\w$/-/;
	
	$vars->setparam( 't', $t );
}

sub pre_finished
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	my $code = ( $type eq 'PREPARE' ? 13 : 0 );
	
	$vars->db->query("
		UPDATE AutoToken SET Finished = $code WHERE Token = '$$token'"
	);
}

sub pre_content_1
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	return unless $type eq 'PREPARE'; 
	
	$vars->db->query("
		UPDATE AutoToken SET Step = 1 WHERE Token = '$$token'"
	);
}

sub pre_content_2
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	return unless $type eq 'PREPARE'; 
	
	$vars->db->query("
		UPDATE AutoAppointments SET PersonalDataPermission = 0, MobilPermission = 0, EMail = '' 
		WHERE ID = '$appid'"
	);
		
	$vars->db->query("
		UPDATE AutoToken SET Step = 2 WHERE Token = '$$token'"
	);
}

sub pre_getinfo
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	return unless $type eq 'PREPARE'; 
	
	$vars->db->query("
		UPDATE AutoAppointments SET SDate = '2011-05-01', FDate = '2011-05-01', CenterID = '5'
		WHERE ID = '$appid'"
	);
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
			0, 1, 1, 1, 1, 0, 3, 2, 14, 1, 'http', 0, 0, 0, 0, 1, 1, 0, 0, 1, 67, 0, '1', 1, 0)"
		);
			
		$vars->db->query("
			INSERT INTO TimeData (SlotID, TimeID, TStart, TEnd, Visas, EVisas, isDeleted, DayNum)
			VALUES (10, 1, 32400, 33900, 200, 0, 0, 1)"
		);
	} 
	else {
		$vars->db->query( "DELETE FROM " . $_ ) for ( "Branches", "TimeData" );
	}
}

sub pre_app_finish
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	return unless $type eq 'PREPARE'; 
	
	$vars->db->query("
		UPDATE AutoAppData SET FinishedCenter = 0 WHERE ID = ?", {}, $appdataid 
	);
}

sub pre_lang
# //////////////////////////////////////////////////
{
	my ( $self, $type ) = @_;
	
	$self->{ lang } = ( $type eq 'PREPARE' ? 'en' : 'ru' );
}

sub pre_cach
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	if ( $type eq 'PREPARE' ) { 
	
		$vars->get_memd->set( 'cach_selftest', 'cash_ok', 60 );
	}
	else {
		$vars->get_memd->delete( 'cach_selftest' );
	}
	
	pre_show_no_testing( @_ );
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
		unlink '/tmp/autoform_selftest_file';
	}
}

sub pre_logic_1
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	my ( $vtype, $finished ) = ( 13, 21 );
	
	if ( $$test->{ comment } eq "check_all_app_finished_and_not_empty" ) {
	
		( $vtype, $finished ) = ( 20, 21 ) if $num == 2;
		
		( $vtype, $finished ) = ( 13, 1 ) if $num == 5;
	}
	
	$finished = 1 if $$test->{ comment } eq "mutex_fail";

	my @params = ( $type eq 'PREPARE' ? ( $finished, $vtype , 1 ) : ( 0, 0, 0 ) );
	
	$vars->db->query("
		UPDATE AutoAppData SET FinishedCenter = ?, FinishedVType = ?, Status = ? WHERE ID = ?", {}, 
		@params, $appdataid
	);
}

sub pre_logic_2
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	my $new_date = ( $type eq 'PREPARE' ? '2010-01-01' : '0000-00-00' );

	$vars->db->query("
		UPDATE AutoAppointments SET SDate = ? WHERE ID = ?", {}, 
		$new_date, $appid
	);
}

sub pre_geo_or_collect
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;
	
	if ( $type eq 'PREPARE' ) {
	
		$vars->db->query("
			INSERT INTO Branches (ID, BName, Ord, Timezone, isDeleted, isDefault, Display, 
			Insurance, BAddr, JAddr, AddrEqualled, SenderID, CTemplate, isConcil, 
			isSMS, isUrgent, posShipping, isDover, calcInsurance, cdSimpl, cdUrgent, cdCatD, 
			CollectDate, siteLink, calcConcil, ConsNDS, genbank, isTranslate, shengen, isAnketa, 
			isPrinting, isPhoto, isVIP, Weekend, isShippingFree, isPrepayedAppointment, 
			DefaultPaymentMethod, DisableAppSameDay) 
			VALUES (5, 'Kazan', 90, 3, 0, 0, 1, 0, 'Казань', NULL, 1, 1, 'rtf', 0, 1, 0, 
			1, 1, 0, 7, 0, 14, 1, 'http', 0, 0, 0, 0, 1, 1, 1, 0, 0, 67, 0, '0', 1, 0)"
		);
	}
	else {
		$vars->db->query("
			DELETE FROM Branches"
		);
	}
	
	pre_visa_type_d( @_ ) if ( $$test->{ comment } =~ /^(get_collect_date|correct_values)$/ ) and ( $num == 2 );
}

sub pre_nobody
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;

	my $new_appid = ( $type eq 'PREPARE' ? 0 : $appid_param );

	$vars->db->query("
		UPDATE AutoAppData SET AppID = ? WHERE ID = ?", {},
		$new_appid, $appdataid
	);
}

sub pre_token
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid, $appdataid, $vars ) = @_;

	if ( $type eq 'PREPARE' ) { 
	
		$self->{ save_token } = $self->{ token };
		
		if ( ( $$test->{ comment } eq "get_mobile_api" ) and ( $num == 2 ) ) {
			
			$self->{ token } = '01';
		}
		else {
			$self->{ token } = '';
		}
	}
	else {
		$self->{ token } = $self->{ save_token };
	}
}

sub pre_age
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;
	
	return unless $type eq 'PREPARE'; 

	$vars->db->query("
		UPDATE AutoAppData
		SET birthdate = DATE_SUB(CURRENT_DATE(), INTERVAL ? YEAR)
		WHERE ID = ?", {}, ( $num == 24 ? 18 : 9 ), $appdataid
	);
}

sub pre_not_closer
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;
	
	return unless $type eq 'PREPARE'; 
	
	$vars->db->query("
		UPDATE AutoAppData SET FingersDate = '2000-05-01' WHERE ID = ?", {}, $appdataid
	);
}

sub pre_passnum
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;
	
	my $new_passnum = "75556565611";
	
	if ( $type eq 'PREPARE' ) {
	
		$self->{ passnum_save } = $vars->db->sel1("
			SELECT PassNum FROM AutoAppData WHERE ID = ?", $appdataid
		);
	}
	else {
		$new_passnum = $self->{ passnum_save };
	}
	
	$vars->db->query("
		UPDATE AutoAppData SET PassNum = ? WHERE ID = ?", {},
		$new_passnum, $appdataid
	);
}

sub pre_show_no_testing
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;

	$self->{ this_is_self_testing } = ( $type eq 'PREPARE' ? undef : 1 );

	$vars->get_memd->delete( 'autoform_' . $token . $_  ) for ( '_vtype', '_center' );
}

sub pre_visa_type_d
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;
	
	$vars->db->query("
		UPDATE VisaTypes SET category = ? WHERE ID = 13", {},
		( $type eq 'PREPARE' ? 'D' : 'C' )
	);
	
	$vars->get_memd->delete( 'autoform_vcategory_13' );
	
	return unless $type eq 'PREPARE'; 
	
	$vars->db->query("
		UPDATE AutoAppointments SET VType = 13 WHERE ID = ?", {}, $appid_param
	);
}

sub pre_vtype_clear
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;
	
	my $vtype = ( $type eq 'PREPARE' ? 0 : 13 );

	$vars->db->query("
		UPDATE AutoAppointments SET VType = ? WHERE ID = ?", {}, $vtype, $appid_param
	);
}

sub pre_spb_centers
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;
	
	my $centerid = ( $type eq 'PREPARE' ? 11 : 1 ); 
	
	$vars->db->query("
		UPDATE AutoAppointments SET CenterID = ? WHERE ID = ?", {}, $centerid, $appid_param
	);

	$vars->get_memd->delete( 'autoform_' . $$token . '_center' );
}

sub pre_mutex_fail_creation
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;
	
	my $new_passnum = ( $type eq 'PREPARE' ? '112233' : '' ); 

	$vars->db->query("
		UPDATE AutoAppData SET PassNum = ? WHERE ID = ?", {}, $new_passnum, $appdataid
	);

	$vars->db->query("
		UPDATE AppData SET PassNum = ? ORDER BY ID LIMIT 1", {}, $new_passnum
	);
}

sub pre_mutex_fail_cach
# //////////////////////////////////////////////////
{
	my ( $self, $type, $test, $num, $token, $appid_param, $appdataid, $vars ) = @_;
	
	$vars->get_memd->add( "autoform_pass332211", 332211, 10 );
}

1;
