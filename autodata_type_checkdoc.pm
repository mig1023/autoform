package VCS::Site::autodata_type_checkdoc;
use strict;

sub get_progressline
# //////////////////////////////////////////////////
{
	return [ '',
		{ big => 1, name => 'Начало', },
		{ big => 1, name => 'Заявители', },
		{ big => 0, name => 'Данные паспорта', },
		{ big => 0, name => 'Данные загранпаспорта', },
		{ big => 0, name => 'Загрузка документов', },
		{ big => 1, name => 'Оплата', },
		{ big => 1, name => 'Готово!', },
	];
}
		
sub get_content_rules_hash
# //////////////////////////////////////////////////
{

	my $standart_date_check = 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-3]\d))$';

	return {
		
		'Тип услуги' => [
			{
				page_ord => 90,
				progress => 1,
				param => 1,
				replacer => '[service_type_change]',
				page_db_id => 400000,
			},
		],
	
		'Начало записи' => [
			{
				page_ord => 100,
				progress => 1,
				param => 1,
				goto_link => 'to_start',
				page_db_id => 400001,
			},
			{
				type => 'select',
				name => 'vtype',
				label => 'Тип визы',
				comment => 'Выберите тип запрашиваемой визы',
				check => 'zN',
				db => {
					table => 'Appointments',
					name => 'VType',
				},
				param => '[visas_from_db]',
				first_elements => '13',
				special => 'cach_this_value',
			},
			{
				type => 'input',
				name => 'num_of_person',
				label => 'Количество заявителей',
				comment => 'Укажите количество человек, запрашивающих визу',
				example => '1',
				check => 'zN',
				uniq_code => 'onkeyup="update_nearest_date_free_date(1);"',
				check_logic => [
					{
						condition => 'less_than',
						offset => '40',
					},
				],
				db => {
					table => 'Appointments',
					name => 'NCount',
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'email',
				label => 'Email',
				comment => 'Введите существующий адрес почты. На него будет выслано подтверждение записи в визовый центр. Пожалуйста, проверьте правильность каждой буквы/символа, из которых состоит адрес Вашей электронной почты',
				example => 'info@italyvms.ru',
				check => 'zWN\@\-\_\.',
				check_logic => [
					{
						condition => 'this_is_email',
					},
					{
						condition => 'email_not_blocked',
					},
				],
				db => {
					table => 'Appointments',
					name => 'EMail',
				},
			},
			{
				type => 'input',
				name => 'emailcheck',
				label => 'Подтвердите email',
				comment => 'Обратите внимание, что адрес электронной почты необходимо вводить вручную, не копируя его из предыдущего поля. Это поможет Вам избежать ошибки и возможной отправки подтверждения Вашей записи не тому адресату. ',
				example => 'info@italyvms.ru',
				check => 'zWN\@\-\_\.',
				check_logic => [
					{
						condition => 'equal',
						table => 'Appointments',
						name => 'EMail',
						full_error => 'EMail не совпадает с подтверждением',
					},
				],
				db => {
					table => 'AutoToken',
					name => 'EMail',
				},
				special => 'no_copypast',
			},
			{
				type => 'free_line',
			},
			{
				type => 'disclaimer',
				name => 'pers_info',
				label_for => 'я согласен с <a class = "dotted_link_big" href = "javascript:openDisclaimer()">условиями</a> обработки персональных данных визовым центром',
				comment => 'disclaimer_text',
				check => 'true',
				full_line => 1,
				db => {
					table => 'Appointments',
					name => 'PersonalDataPermission',
					transfer => 'nope',
				},
			},
			{
				type => 'include',
				place => 'out',
				template => 'vip_form.tt2',
			},
		],
			
		'Список заявителей' => [
			{
				page_ord => 300,
				progress => 2,
				goto_link => 'back_to_appdata',
				all_app_in_title => 1,
				replacer => '[list_of_applicants]',
				page_db_id => 400003,
			},
		],
		
		'Данные паспорта' => [
			{
				page_ord => 400,
				progress => 3,
				all_app_in_title => 1,
				param => 1,
				page_db_id => 400004,
			},
			{
				type => 'select',
				name => 'сitizenship',
				label => 'Гражданство в настоящее время',
				comment => 'Если у вас два гражданства, то укажите гражданство по паспорту той страны, который подаёте на визу',
				example => 'The Russian Federation',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'Citizenship',
				},
				param => '[citizenship_countries]',
				first_elements => '70',
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'rulname',
				label => 'Фамилия',
				comment => 'Введите фамилию на русском языке так, как она указана во внутреннем паспорте',
				example => 'Петров',
				check => 'zWЁ\s\-',
				check_logic => [
					{
						condition => 'english_only_for_not_rf_citizen',
						full_error => 'Для граждан РФ фамилию необходимо вводить на русском языке',
					},
				],
				db => {
					table => 'AppData',
					name => 'RLName',
				},
				format => 'capitalized'
			},
			{
				type => 'input',
				name => 'rufname',
				label => 'Имя',
				comment => 'Введите имя на русском языке так, как оно указано во внутреннем паспорте',
				example => 'Петр',
				check => 'zWЁ\s\-',
				check_logic => [
					{
						condition => 'english_only_for_not_rf_citizen',
						full_error => 'Для граждан РФ имя необходимо вводить на русском языке',
					},
				],
				db => {
					table => 'AppData',
					name => 'RFName',
				},
				format => 'capitalized'
			},
			{
				type => 'input',
				name => 'rumname',
				label => 'Отчество',
				comment => 'Введите отчество на русском языке так, как оно указано во внутреннем паспорте',
				example => 'Петрович',
				check => 'WЁ\s\-',
				check_logic => [
					{
						condition => 'english_only_for_not_rf_citizen',
						full_error => 'Для граждан РФ отч необходимо вводить на русском языке',
					},
					{
						condition => 'free_only_if',
						table => 'AppData',
						name => 'NoRMName',
						error => 'Нет отчества',
					},
				],
				db => {
					table => 'AppData',
					name => 'RMName',
				},
				format => 'capitalized'
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
				relation => {},
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'birthdate',
				label => 'Дата рождения',
				comment => 'Введите дату рождения',
				example => '31.12.1900',
				check => $standart_date_check,
				complete_check => 'not_empty',
				check_logic => [
					{
						condition => 'now_or_earlier',
					},
				],
				db => {
					table => 'AppData',
					name => 'BirthDate',
				},
				special => 'mask',
			},
		],
		
		'Данные загранпаспорта' => [
			{
				page_ord => 500,
				all_app_in_title => 1,
				progress => 4,
				page_db_id => 400005,
			},
			{
				type => 'input',
				name => 'rupassnum',
				label => '№ загранпаспорта',
				comment => 'Введите серию и номер паспорта как единый набор цифр без пробелов',
				example => '650000001',
				check => 'zWN',
				complete_check => 'not_empty',
				check_logic => [
					{
						condition => 'unique_in_pending',
						table => 'AppData',
						name => 'PassNum',
					},
					{
						condition => 'rf_pass_format',
						full_error => 'Неверный формат загранпаспорта. Гражданам РФ необходимо ввести серию и номер паспорта как единый набор цифр без пробелов и знака N',
					}
				],
				db => {
					table => 'AppData',
					name => 'PassNum',
				},
			},
			{
				type => 'input',
				name => 'lname',
				label => 'Фамилия',
				comment => 'Введите фамилию на английском языке так, как она указана в загранпаспорте',
				example => 'Ivanov',
				check => 'zW\s\-',
				complete_check => 'not_empty',
				db => {
					table => 'AppData',
					name => 'LName',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'fname',
				label => 'Имя',
				comment => 'Введите имя на английском языке так, как оно указано в загранпаспорте',
				example => 'Ivan',
				check => 'zW\s\-',
				complete_check => 'not_empty',
				db => {
					table => 'AppData',
					name => 'FName',
				},
				format => 'capslock'
			},
			{
				type => 'free_line',
			},
			{
				type => 'checkbox',
				name => 'ischild',
				label => 'Если ребёнок вписан в паспорт родителей',
				label_for => 'вписан в паспорт',
				check_logic => [
					{
						condition => 'younger_than',
						offset => 18,
					},
				],
				db => {
					table => 'AppData',
					name => 'isChild',
				},
				relation => {},
			},
		],
		
		'Загрузка документов' => [
			{
				page_ord => 550,
				progress => 5,
				all_app_in_title => 1,
				replacer => '[doc_uploading]',
				page_db_id => 400006,
			},
		],
		
		'Вы успешно добавили заявителя' => [	
			{
				page_ord => 600,
				progress => 6,
				all_app_in_title => 1,
				replacer => '[app_finish]',
				page_db_id => 400007,
			},
		],
			
		'Оплата' => [
			{
				page_ord => 700,
				progress => 6,
				page_db_id => 400008,
			},
			{
				type => 'payment',
				full_line => 1,
			},
		],
				
		'Заявка на проверку успешно создана!' => [
			{
				page_ord => 800,
				progress => 7,
				page_db_id => 400009,
			},
			{
				type => 'text',
				name => 'conf_mail_text',
				label => 'Скоро на вашу почту придёт письмо с ответом по документом.',
			},
			{
				type => 'text',
				name => 'conf_mail_text2',
				label => 'Ждите.',
			},
		],
	};
}

1;