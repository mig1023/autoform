﻿package VCS::Site::autodata_type_c_spb;
use strict;

sub get_progressline
# //////////////////////////////////////////////////
{
	return [ '',
		{ big => 1, name => 'Начало', },
		{ big => 0, name => 'Даты поездки', },
		{ big => 1, name => 'Заявители', },
		{ big => 0, name => 'Данные паспорта', },
		{ big => 0, name => 'Дополнительные данные', },
		{ big => 0, name => 'Данные о поездке', },
		{ big => 0, name => 'Проживание', },
		{ big => 0, name => 'Расходы', },
		{ big => 1, name => 'Оформление', },
		{ big => 0, name => 'Данные для договора', },
		{ big => 0, name => 'Выбор даты записи', },
		{ big => 0, name => 'Подтверждение', },
		{ big => 1, name => 'Готово!', },
	];
}
		
sub get_content_rules_hash
# //////////////////////////////////////////////////
{

	my $standart_date_check = 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-3]\d))$';
	my $standart_date_check_opt = 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-3]\d))$';

	return {

		'Начало записи' => [
			{
				page_ord => 100,
				progress => 1,
				param => 1,
				goto_link => 'to_start',
				page_db_id => 200001,
			},
			{
				type => 'select',
				name => 'center',
				label => 'Визовый центр',
				comment => 'Выберите визовый центр для подачи документов',
				check => 'zN',
				db => {
					table => 'Appointments',
					name => 'CenterID',
				},
				param => '[centers_from_db]',
				uniq_code => 'onchange="update_nearest_date_free_date();"',
				first_elements => 'default_free, 1, 44, 41',
				special => 'cach_this_value',
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
				type => 'info',
				name => 'free_date',
				label => 'Ближайшая доступная дата',
				comment => 'Вы сможете выбрать удобную для Вас дату подачи документов во время оформления записи',
				special => 'nearest_date',
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'email',
				label => 'Email',
				comment => 'Введите существующий адрес почты. На него будет выслано подтверждение записи в визовый центр. Пожалуйста, проверьте правильность каждой буквы/символа, из которых состоит адрес Вашей электронной почты',
				example => 'info@example.ru',
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
				example => 'info@example.ru',
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
				type => 'checkbox',
				name => 'mobil_info',
				label_for => 'я уведомлён о том, что на территории Визового центра <a target = "_blank" class = "dotted_link_big" href = "/vazhnaya-informaciya/">запрещается</a> пользоваться электронными мобильными устройствами',
				check => 'true',
				full_line => 1,
				db => {
					table => 'Appointments',
					name => 'MobilPermission',
					transfer => 'nope',
				},
				relation => {},
			},
			{
				type => 'include',
				place => 'out',
				template => 'vip_form.tt2',
			},
		],
				
		'Услуга Primetime' => [
			{
				page_ord => 200,
				progress => 2,
				primetime_spb_price => 1,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'CenterID',
						value => '43',
					}
				},
				page_db_id => 200002,
			},
			{
				type => 'text',
				name => 'primetime_text',
				label => 'Стоимость услуги «Прайм-тайм» составляет: [primetime_price] рублей за каждого заявителя и не включает в себя стоимость сервисного и консульского сборов, а также <a target = "_blank" class = "dotted_link_big" href = "/spb-dopolnitelnye-uslugi/">дополнительных услуг</a>',
			},
			{
				type => 'free_line',
			},
			{
				type => 'checkbox',
				name => 'pers_info',
				label_for => 'я ознакомлен со стоимостью дополнительных услуг',
				check => 'true',
				full_line => 1,
				db => {
					table => 'Appointments',
					name => 'PrimetimeAlert',
				},
			},
		],
		
		'Даты поездки' => [
			{
				page_ord => 300,
				progress => 2,
				collect_date => 1,
				page_db_id => 200003,
			},
			{
				type => 'input',
				name => 's_date',
				label => 'Дата начала поездки',
				comment => 'Введите предполагаемую дату начала поездки',
				example => '31.12.1900',
				check => $standart_date_check,
				check_logic => [
					{
						condition => 'now_or_later',
						offset => '[collect_date_offset]',
					},
					{
						condition => 'now_or_earlier',
						offset => 180,
						equality_is_also_fail => 1,
						full_error => 'Действует ограничение на максимальную дату вылета: не более [offset] с текущей даты',
					},
				],
				db => {
					table => 'Appointments',
					name => 'SDate',
				},
				special => 'datepicker, mask',
				minimal_date => 'current',
			},
			{
				type => 'input',
				name => 'f_date',
				label => 'Дата окончания поездки',
				comment => 'Введите предполагаемую дату окончания поездки',
				example => '31.12.1900',
				check => $standart_date_check,
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
				special => 'datepicker, mask',
				minimal_date => 's_date',
			},
		],
		
		'Список заявителей' => [
			{
				page_ord => 400,
				progress => 3,
				goto_link => 'back_to_appdata',
				all_app_in_title => 1,
				replacer => '[list_of_applicants]',
				page_db_id => 200004,
			},
		],
		
		'Данные паспортов' => [
			{
				page_ord => 500,
				progress => 4,
				all_app_in_title => 1,
				param => 1,
				page_db_id => 200005,
			},
			{
				type => 'text',
				name => 'rupass_text',
				label => 'Данные внутреннего паспорта',
				font => 'bold',
			},
			{
				type => 'free_line',
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
			{
				type => 'free_line',
			},
			{
				type => 'radiolist',
				name => 'gender',
				label => 'Пол',
				check => 'zN',
				complete_check => 'not_empty',
				db => {
					table => 'AppData',
					name => 'Gender',
				},
				param => { 
					1 => 'мужской', 
					2 => 'женский', 
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'rupass_text',
				label => 'Данные загранпаспорта',
				font => 'bold',
			},
			{
				type => 'free_line',
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
				type => 'input',
				name => 'passdate',
				label => 'Дата выдачи',
				comment => 'Введите дату выдачи, указанную в паспорте',
				example => '31.12.1900',
				check => $standart_date_check,
				complete_check => 'not_empty',
				check_logic => [
					{
						condition => 'now_or_earlier',
					},
					{
						condition => 'now_or_later',
						offset => ( -10 * 365 ), # <--- 10 years
						full_error => 'Паспорт не должен быть выдан больше [offset] назад',
					},
				],
				db => {
					table => 'AppData',
					name => 'PassDate',
				},
				special => 'mask',
			},
			{
				type => 'input',
				name => 'passtill',
				label => 'Действителен до',
				comment => 'Введите дату окончания действия загранпаспорта, указанную в паспорте',
				example => '31.12.1900',
				check => $standart_date_check,
				complete_check => 'not_empty',
				check_logic => [
					{
						condition => 'now_or_later',
						full_error => 'Паспорт c истекшим сроком действия, не может быть принят',
					},
					{
						condition => 'not_closer_than',
						table => 'Appointments',
						name => 'FDate',
						offset => 90,
						full_error => 'Срок действия паспорта должен превышать срок запрашиваемой визы на [offset]',
					},
				],
				db => {
					table => 'AppData',
					name => 'PassTill',
				},
				special => 'mask',
			},
			{
				type => 'select',
				name => 'passwhere',
				label => 'Кем выдан',
				comment => 'Укажите название страны, выдавшей паспорт',
				example => 'The Russian Federation',
				check => 'zN',
				complete_check => 'not_empty',
				db => {
					table => 'AppData',
					name => 'PassWhom',
				},
				param => '[citizenship_countries]',
				first_elements => '70',
			},
			{
				type => 'free_line',
			},
			{
				type => 'checkbox',
				name => 'ischild',
				label => 'Если ребёнок вписан в загранпаспорт родителей',
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
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'rupass_text',
				label => 'Контактные данные',
				font => 'bold',
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'home_city',
				label => 'Город',
				comment => 'Укажите город, в котором проживаете',
				example => 'Moscow',
				check => 'zNW\s\-',
				db => {
					table => 'SpbAlterAppData',
					name => 'HomeCity',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'fulladdress',
				label => 'Домашний адрес',
				comment => 'Фактический адрес проживания заявителя, без города',
				example => 'M.Tolmachevskiy pereulok 6 b.1',
				check => 'zWN\s\-\_\.\,\;\'\"\/',
				complete_check => 'not_empty',
				db => {
					table => 'SpbAlterAppData',
					name => 'HomeAddr',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'appemail',
				label => 'Email',
				comment => 'Введите существующий адрес почты, по которому можно будет связаться с заявителем',
				example => 'info@example.ru',
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
					table => 'SpbAlterAppData',
					name => 'HomeEmail',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'appphone',
				label => 'Телефон',
				comment => 'Введите контактный телефон, сотовый или городской, с кодом оператора, без пробелов и разделителей',
				example => '79XXXXXXXXX',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'AppPhone',
				},
			},
		],
		
		'Дополнительные данные' => [
			{
				page_ord => 600,
				progress => 5,
				param => 1,
				all_app_in_title => 1,
				ussr_or_rf_first => 1,
				page_db_id => 200006,
			},
			{
				type => 'text',
				name => 'otherpass_text',
				label => 'Иные данные',
				font => 'bold',
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'rulname',
				label => 'Фамилия при рождении / предыдущие фамилии',
				comment => 'Введите все предыдущие фамилии. При перечисление нескольких фамилий используйте запятую. Если фамилия не менялась, то оставьте поле пустым',
				example => 'Ivanov, Petrov, Sidorov',
				check => 'W\s\,',
				db => {
					table => 'AppData',
					name => 'PrevLNames',
				},
				format => 'capitalized'
			},
			{
				type => 'select',
				name => 'brhcountry',
				label => 'Страна рождения',
				comment => 'Для тех, кто родился до 1992 необходимо указывать The Soviet Union, позднее - The Russian Federation',
				example => 'The Soviet Union',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'BrhCountry',
				},
				param => '[brh_countries]',
				first_elements => '70, 272', # <--- chng in init_add_param
			},
			{
				type => 'input',
				name => 'brhplace',
				label => 'Место рождения',
				comment => 'Укажите место рождения латинскими буквами в соответствии с информацией в загранпаспорте',
				example => 'Moscow',
				check => 'zWN\s\-\,\;',
				db => {
					table => 'AppData',
					name => 'BrhPlace',
				},
				format => 'capslock'
			},
			
			{
				type => 'select',
				name => 'prev_сitizenship',
				label => 'Гражданство при рождении',
				comment => 'Для тех, кто родился до 1992 необходимо указывать The Soviet Union, позднее - The Russian Federation',
				example => 'The Soviet Union',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'PrevCitizenship',
				},
				param => '[prevcitizenship_countries]',
				first_elements => '70, 272', # <--- chng in init_add_param
			},
			{
				type => 'free_line',
			},
			{
				type => 'radiolist',
				name => 'family',
				label => 'Семейное положение',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'Family',
				},
				param => {
					1 => 'холост/не замужем',
					2 => 'женат/замужем',
					3 => 'не проживает с супругом',
					4 => 'разведен/-а',
					5 => 'вдовец/вдова',
					6 => 'иное'
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'workdata',
				label => 'Профессиональная деятельность',
				comment => 'Профессию необходимо указывать на английском или итальянском языках. Если на данный момент Вы не работаете, то укажите unemployed / housewife, для учащихся указывается student / pupil, для пенсионеров – pensioner',
				example => 'Doctor',
				check => 'zWN\s\_\.\,\"\'\-\(\)\#\*',
				complete_check => 'not_empty',
				db => {
					table => 'AppData',
					name => 'ProfActivity',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'work_name',
				label => 'Название компании',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы. Для безработных/домохозяек поставьте дефис',
				example => 'VMS',
				check => 'zWN\s\_\.\,\"\'\-\(\)\#\*',
				db => {
					table => 'SpbAlterAppData',
					name => 'JobName',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'work_city',
				label => 'Город нахождения компании',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы. Для безработных/домохозяек поставьте дефис',
				example => 'Moscow',
				check => 'zWN\s\_\.\,\"\'\-\(\)\#\*',
				db => {
					table => 'SpbAlterAppData',
					name => 'JobCity',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'work_addr',
				label => 'Адрес нахождения компании',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы. Для безработных/домохозяек поставьте дефис',
				example => 'M.Tolmachevskiy pereulok 6 b.1',
				check => 'zWN\s\_\.\,\"\'\-\(\)\#\*\/',
				db => {
					table => 'SpbAlterAppData',
					name => 'JobAddr',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'work_phone',
				label => 'Контактный телефон компании',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы. Для безработных/домохозяек поставьте дефис',
				example => '12345',
				check => 'zN\-',
				db => {
					table => 'SpbAlterAppData',
					name => 'JobPhone',
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'radiolist',
				name => 'purpose',
				label => 'Основная цель поездки',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'VisaPurpose',
				},
				param => { 
					1 => 'туризм', 
					2 => 'деловая',
					3 => 'учёба',
					4 => 'официальная',
					5 => 'культура',
					6 => 'спорт',
					7 => 'транзит',
					8 => 'лечение',
					9 => 'посещение родственников или друзей',
					10 => 'иная',
				},
				special => 'save_info_about_hastdatatype',
			},
			{
				type => 'input',
				name => 'add_purpose',
				label => 'Дополнительные сведения о цели поездки',
				comment => 'Укажите латинскими буквами дополнительную информацию о цели вашей поездки. При наличии нескольких поездок в рамках 2 месяцев  вносятся даты, страны и цели всех поездок за 2 месяца',
				example => 'participating in conference', 
				check => 'WN\s\.\,\"\-\(\)',
				db => {
					table => 'AppData',
					name => 'AdditionalPurpose',
				},
				format => 'capslock'
			},
			
		],
		
		'Информация о родителе / законном представителе' => [
			{
				page_ord => 700,
				progress => 5,
				all_app_in_title => 1,
				copy_from_other_applicants => 'now',
				relation => {
					only_if_younger => {
						table => 'AppData',
						name => 'BirthDate',
						value => '18',
					}
				},
				page_db_id => 200007,
			},
			{
				type => 'input',
				name => 'kinderdata',
				label => 'Для несовершеннолетних: фамилия, имя, адрес (если отличается от адреса заявителя) и гражданство лица с полномочием родителей / законного представителя',
				comment => 'Фамилия, имя, адрес (если отличается от адреса заявителя) и гражданство лица с полномочием родителей или законного представителя',
				example => 'Ivanov Ivan, The Russian Federation',
				check => 'zWN\s\-\,\.\;\_\\\/\'\"',
				db => {
					table => 'AppData',
					name => 'KinderData',
				},
				format => 'capslock'
			},
		],
		
		'Уточнение по семейному положению' => [
			{
				page_ord => 800,
				progress => 5,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'Family',
						value => '6',
					}
				},
				page_db_id => 200008,
			},
			{
				type => 'input',
				name => 'familyother',
				label => 'Семейное положение',
				comment => 'Укажите своё текущее семейное положение',
				check => 'zW\s',
				db => {
					table => 'AppData',
					name => 'FamilyOther',
				},
				format => 'capslock'
			},
		],
		
		'Основания для пребывания в Российской Федерации' => [
			{
				page_ord => 900,
				progress => 5,
				all_app_in_title => 1,
				relation => {
					only_if_not => {
						table => 'AppData',
						name => 'Citizenship',
						value => '70',
					}
				},
				page_db_id => 200009,
			},
			{
				type => 'input',
				name => 'vidno',
				label => 'Номер вида на жительство или равноценного документа',
				comment => 'Укажите номер вида на жительство; при наличии временной регистрации оставьте поле пустым',
				example => '820000000',
				check => 'N\s\-',
				db => {
					table => 'AppData',
					name => 'VidNo',
				},
			},
			{
				type => 'input',
				name => 'brhplace',
				label => 'Действителен до',
				comment => 'Укажите срок действия документа',
				example => '31.12.1900',
				check => $standart_date_check,
				db => {
					table => 'AppData',
					name => 'VidTill',
				},
				special => 'mask',
			},
		],
		
		'Уточнение по цели посещения' => [
			{
				page_ord => 1000,
				progress => 5,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '10',
					}
				},
				page_db_id => 200010,
			},
			{
				type => 'input',
				name => 'visaother',
				label => 'Основная цель поездки',
				comment => 'Укажите цель предполагаемой поездки',
				check => 'zWN\s\-',
				db => {
					table => 'AppData',
					name => 'VisaOther',
				},
				format => 'capslock',
			},
		],
		
		'Данные о поездке' => [
			{
				page_ord => 1100,
				progress => 6,
				param => 1,
				all_app_in_title => 1,
				page_db_id => 200011,
			},
			{
				type => 'text',
				name => 'otherpass_text',
				label => 'Данные визы',
				font => 'bold',
			},
			{
				type => 'free_line',
			},
			{
				type => 'select',
				name => 'nulla',
				label => 'Страна первого въезда',
				comment => 'Укажите страну первого въезда в шенгенскую зону в рамках запланированной поездки',
				example => 'ITALY',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'FirstCountry',
				},
				param => '[schengen_countries]',
				first_elements => 'default_free, 133',
			},
			{
				type => 'select',
				name => 'visanum',
				label => 'Виза запрашивается для',
				comment => 'Виза с однократным въездом даёт возможность пересечь границу Шенгена только один раз. После того как Вы покинете зону Шенгена по данной визе, она будет закрыта и перестанет действовать. Виза с двукратным въездом позволяет въехать и покинуть зону Шенгена два раза в период действия визы. Виза с многократным въездом даёт возможность пересекать границу зоны Шенгенского соглашения в период действия визы',
				example => 'многократного въезда',
				check => 'N',
				db => {
					table => 'AppData',
					name => 'VisaNum',
				},
				param => {
					0 => 'однократного въезда',
					1 => 'двукратного въезда',
					2 => 'многократного въезда',
				},
				first_elements => '2, 1, 0',
			},
			{
				type => 'input',
				name => 'apps_date',
				label => 'Дата начала поездки',
				comment => 'Укажите дату начала действия запрашиваемой визы',
				example => '31.12.1900',
				check => $standart_date_check,
				check_logic => [
					{
						condition => 'now_or_later',
						offset => '[collect_date_offset]',
					},
					{
						condition => 'equal_or_earlier',
						table => 'AppData',
						name => 'PassDate',
						offset => ( 10 * 365 ), # <--- 10 years
						error => 'Дата выдачи паспорта',
					},
					{
						condition => 'now_or_earlier',
						offset => 180,
						equality_is_also_fail => 1,
						full_error => 'Действует ограничение на максимальную дату вылета: не более [offset] с текущей даты',
					},
				],
				db => {
					table => 'AppData',
					name => 'AppSDate',
				},
				load_if_free_field => {
					table => 'Appointments',
					name => 'SDate',
				},
				special => 'datepicker, mask',
				minimal_date => 'current',
			},
			{
				type => 'input',
				name => 'appf_date',
				label => 'Дата окончания поездки',
				comment => 'Укажите дату окончания действия запрашиваемой визы',
				example => '31.12.1900',
				check => $standart_date_check,
				check_logic => [
					{
						condition => 'equal_or_later',
						table => 'AppData',
						name => 'AppSDate',
						error => 'Дата начала поездки',
					},
					{
						condition => 'not_closer_than_in_spb',
						table => 'AppData',
						name => 'PassTill',
						offset => 90, # <--- only for error text
						full_error => 'Между окончанием срока действия паспорта и датой окончания поездки должно быть как минимум [offset]',
					},
				],
				db => {
					table => 'AppData',
					name => 'AppFDate',
				},
				load_if_free_field => {
					table => 'Appointments',
					name => 'FDate',
				},
				special => 'datepicker, mask',
				minimal_date => 'apps_date',
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'permi_text',
				label => 'Предыдущие шенгенские визы',
				font => 'bold',
			},
			{
				type => 'free_line',
			},
			{
				type => 'radiolist',
				name => 'fingers',
				label => 'Отпечатки предоставлены за последние 5 лет',
				check => 'N',
				db => {
					table => 'AppData',
					name => 'Fingers',
				},
				param => { 
					0 => 'нет', 
					1 => 'да',
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'permi_text',
				label => 'Родственник в ЕС',
				font => 'bold',
			},
			{
				type => 'radiolist',
				name => 'femrel',
				label => 'Степень родства',
				check => 'N',
				db => {
					table => 'AppData',
					name => 'FamRel',
				},
				param => { 
					0 => 'нет', 
					1 => 'супруг',
					2 => 'ребёнок',
					3 => 'иные близкие родственники',
					4 => 'иждивенец',
				},
			},
		],
		
		'Разрешение на въезд, если необходимо' => [
			{
				page_ord => 1200,
				progress => 6,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '7',
					}
				},
				page_db_id => 200012,
			},
			{
				type => 'input',
				name => 'premesso',
				label => 'Кем выдано',
				comment => 'Укажите, есть ли разрешение на въезд в страну конечного следования, если такое разрешение необходимо',
				example => 'EMBASSY OF THE REPUBLIC OF BULGARIA Consular Section Moscow 552',
				check => 'WN\s\-\_\.\,\;\'\"',
				db => {
					table => 'AppData',
					name => 'Permesso',
				},
				format => 'capslock',
			},
			{
				type => 'input',
				name => 'premessofd',
				label => 'Действительно с',
				comment => 'Начало действия разрешения',
				example => '31.12.1900',
				check => $standart_date_check,
				db => {
					table => 'AppData',
					name => 'PermessoFD',
				},
				special => 'mask',
			},
			{
				type => 'input',
				name => 'premessoed',
				label => 'Действительно по',
				comment => 'окончание действия разрешения',
				example => '31.12.1900',
				check => $standart_date_check,
				db => {
					table => 'AppData',
					name => 'PermessoED',
				},
				special => 'mask',
			},
		],
		
		'Сроки действия последней визы' => [
			{
				page_ord => 1300,
				progress => 6,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'PrevVisa',
						value => '2',
					}
				},
				page_db_id => 200013,
			},
			{
				type => 'input',
				name => 'prevvisafd',
				label => 'Дата начала',
				comment => 'Укажите дату начала действия визы',
				example => '31.12.1900',
				check => $standart_date_check,
				db => {
					table => 'AppData',
					name => 'PrevVisaFD',
				},
				special => 'mask',
			},
			{
				type => 'input',
				name => 'prevvised',
				label => 'Дата окончания',
				comment => 'Укажите дату окончания действия визы',
				example => '31.12.1900',
				check => $standart_date_check,
				check_logic => [
					{
						condition => 'now_or_later',
						offset => ( -3 * 365 ), # <--- 3 years
						full_error => 'Допустимо указывать только визы, выданные за последние [offset]'
					},
					{
						condition => 'equal_or_later',
						table => 'AppData',
						name => 'PrevVisaFD',
						error => 'Дата начала действия визы',
					},
				],
				db => {
					table => 'AppData',
					name => 'PrevVisaED',
				},
				special => 'mask',
			},
		],
		
		'Дата сдачи отпечатков' => [
			{
				page_ord => 1400,
				progress => 6,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'Fingers',
						value => '1',
					}
				},
				page_db_id => 200014,
			},
			{
				type => 'input',
				name => 'prevvisafd',
				label => 'Дата сдачи отпечатков, если известна',
				comment => 'Укажите, если помните, дату, когда сдавались отпечатки пальцев для предыдущей визы',
				example => '31.12.1900',
				check => $standart_date_check_opt,
				db => {
					table => 'AppData',
					name => 'FingersDate',
				},
				check_logic => [
					{
						condition => 'now_or_later',
						offset => ( -5 * 365 ), # <--- 5 years
						full_error => 'Дата сканирования отпечатков пальцев не должна быть более [offset] назад'
					},
					{
						condition => 'now_or_earlier',
					},
				],
				special => 'mask',
			},
			{
				type => 'input',
				name => 'prevvisanum',
				label => 'Номер визы, по которой сдавались отпечатки, если известе',
				comment => 'Укажите номер соответствующей виз, если он вам известен',
				example => '123456789',
				check => 'N',
				db => {
					table => 'AppData',
					name => 'VisaAdeviso',
				},
				format => 'capslock',
			},
		],
		
		'Проживание' => [
			{
				page_ord => 1500,
				progress => 7,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '1',
					}
				},
				page_db_id => 200015,
			},
			{
				type => 'radiolist',
				name => 'hostdatatype',
				label => 'Вариант проживания',
				check => 'zW',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataType',
				},
				param => { 
					H => 'гостиница/аренда/собственность', 
					P => 'приглашение',
				},
				special => 'copy_from_other_applicants',
			},
		],
		
		'Информация о проживании' => [
			{
				page_ord => 1600,
				progress => 7,
				all_app_in_title => 1,
				relation => {
					only_if_not => {
						table => 'SchengenAppData',
						name => 'HostDataType',
						value => 'P',
					},
					only_if_not_1 => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '7',
					}
				},
				page_db_id => 200016,
			},
			{
				type => 'input',
				name => 'hotel_name',
				label => 'Название гостиницы или ФИО приглашающего',
				comment => 'Укажите полное название гостиницы и данные приглашающего лица',
				example => 'VMS',
				check => 'zNW\s\-\.\&',
				db => {
					table => 'SpbAlterAppData',
					name => 'HotelName',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotel_postcode',
				label => 'Индекс гостиницы',
				comment => 'Укажите индекс гостиницы',
				example => '12345',
				check => 'zN',
				db => {
					table => 'SpbAlterAppData',
					name => 'HotelPostCode',
				},
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotel_city',
				label => 'Город расположения гостиницы',
				comment => 'Укажите город, в котором располагается гостиница',
				example => 'Rome',
				check => 'zW\s\-\.',
				db => {
					table => 'SpbAlterAppData',
					name => 'HotelCity',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotel_street',
				label => 'Улица расположения гостиницы',
				comment => 'Укажите улицу, на которой располагается гостиница',
				example => 'Via Esempio',
				check => 'zW\s\-\.',
				db => {
					table => 'SpbAlterAppData',
					name => 'HotelStreet',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotel_building',
				label => 'Номер дома гостиницы',
				comment => 'Номер дома на улице, на которой располагается гостиница',
				example => '1',
				check => 'zN',
				db => {
					table => 'SpbAlterAppData',
					name => 'HotelHouse',
				},
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotelphon',
				label => 'Телефон',
				comment => 'Укажите контактный телефон гостиницы',
				example => '39XXXXXXXX',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'HotelPhone',
				},
				special => 'copy_from_other_applicants',
			},
		],
		
		'Информация о месте проживания' => [
			{
				page_ord => 1700,
				progress => 7,
				all_app_in_title => 1,
				relation => {
					only_if_not => {
						table => 'SchengenAppData',
						name => 'HostDataType',
						value => 'P',
					},
					only_if => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '7',
					}
				},
				page_db_id => 200017,
			},
			{
				type => 'input',
				name => 'hotels',
				label => 'Название гостиницы или ФИО приглашающего',
				comment => 'Укажите полное название гостиницы и данные приглашающего лица',
				example => 'VMS',
				check => 'NW\s\-\.\&',
				db => {
					table => 'AppData',
					name => 'Hotels',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotelsaddr',
				label => 'Адрес места пребывания',
				comment => 'Укажите адрес гостиницы',
				example => 'Via Esempio 1, Rome',
				check => 'WN\s\-\_\.\,\;\'\"',
				db => {
					table => 'AppData',
					name => 'HotelAdresses',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotelpho',
				label => 'Телефон',
				comment => 'Укажите контактный телефон гостиницы',
				example => '39XXXXXXXX',
				check => 'N',
				db => {
					table => 'AppData',
					name => 'HotelPhone',
				},
				special => 'copy_from_other_applicants',
			},
		],
		
		'Приглашение' => [
			{
				page_ord => 1800,
				progress => 7,
				all_app_in_title => 1,
				param => 1,
				relation => {
					only_if_not => {
						table => 'SchengenAppData',
						name => 'HostDataType',
						value => 'H',
					},
					only_if => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '1',
					}
				},
				page_db_id => 200018,
			},
			{
				type => 'input',
				name => 'p_name',
				label => 'Имя',
				comment => 'Укажите имя приглашающего лица',
				example => 'Ivan',
				check => 'zW\s\-',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataName',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'p_last_name',
				label => 'Фамилия',
				comment => 'Укажите фамилию приглашающего лица',
				example => 'Ivanov',
				check => 'zW\s\-',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataDenomination',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'p_birthdate',
				label => 'Дата рождения',
				comment => 'Укажите дату рождения приглашающего лица',
				example => '31.12.1900',
				check => $standart_date_check,
				db => {
					table => 'SchengenAppData',
					name => 'HostDataDateOfBirth',
				},
				special => 'mask, copy_from_other_applicants',
			},
			{
				type => 'select',
				name => 'p_province',
				label => 'Провинция',
				check => 'N',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataProvince',
				},
				param => '[schengen_provincies]',
				first_elements => 'default_free',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'p_index',
				label => 'Индекс',
				comment => 'Укажите почтовый индекс',
				example => '12345',
				check => 'zN',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataPostalCode',
				},
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'p_city',
				label => 'Город',
				comment => 'Укажите название города',
				example => 'Rome',
				check => 'zWN\s\-\_\.\,\;\'\"',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataCity',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'p_adress',
				label => 'Адрес',
				comment => 'Укажите адрес без названия города',
				example => 'Via Esempio 1',
				check => 'zWN\s\-\_\.\,\;\'\"',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataAddress',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'p_phone',
				label => 'Телефон',
				comment => 'Укажите контактный номер телефона',
				example => '39XXXXXXXX',
				check => 'zN',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataPhoneNumber',
				},
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'p_email',
				label => 'Email',
				comment => 'Укажите адрес электронной почты',
				example => 'info@example.ru',
				check => 'zWN\@\s\-\_\.',
				check_logic => [
					{
						condition => 'this_is_email',
					},
				],
				db => {
					table => 'SchengenAppData',
					name => 'HostDataEmail',
				},
				special => 'copy_from_other_applicants',
			},
		],
	
		'Приглашение организации' => [
			{
				page_ord => 1900,
				progress => 7,
				param => 1,
				all_app_in_title => 1,
				relation => {
					only_if_not => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '1, 7, 9',
					},
				},
				page_db_id => 200019,
			},
			{
				type => 'select',
				name => 'a_province',
				label => 'Провинция',
				example => 'Milano',
				check => 'N',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataProvince',
				},
				param => '[schengen_provincies]',
				first_elements => 'default_free',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'a_postcode',
				label => 'Индекс компании',
				comment => 'Укажите индекс компании',
				example => '12345',
				check => 'zN',
				db => {
					table => 'SpbAlterAppData',
					name => 'CompanyIndex',
				},
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'a_city',
				label => 'Город',
				comment => 'Укажите название города',
				example => 'Milano',
				check => 'zWN\s\-\_\.\,\;\'\"',
				db => {
					table => 'SchengenAppData',
					name => 'HostDataCity',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'a_company',
				label => 'Название приглашающей компании',
				comment => 'Укажите полное название организации',
				example => 'Visa Management Service',
				check => 'zW\s\-\.',
				db => {
					table => 'AppData',
					name => 'ACompanyName',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'a_companyaddr',
				label => 'Адрес приглашающей компании',
				comment => 'Укажите адрес организации',
				example => 'Via Esempio 10, Milano',
				check => 'zWN\s\-\,\;',
				db => {
					table => 'AppData',
					name => 'ACompanyAddress',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'a_phone',
				label => 'Телефон компании',
				comment => 'Укажите контактный телефон организации',
				example => '39XXXXXXXX',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'ACompanyPhone',
				},
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'a_fax',
				label => 'Факс компании',
				comment => 'Укажите контактный факс организации',
				example => '39XXXXXXXX',
				check => 'N',
				db => {
					table => 'AppData',
					name => 'ACompanyFax',
				},
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'a_person',
				label => 'ФИО, адрес, телефон, email контактного лица',
				comment => 'Укажите данные кантактного лица приглашающей организации',
				example => 'Ivanov Ivan, Via Esempio 10, Milano, 39XXXXXXXX, info@example.ru',
				check => 'zWN\@\s\-\.\,\;',
				db => {
					table => 'AppData',
					name => 'ACopmanyPerson',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
		],
		
		'Расходы заявителя' => [
			{
				page_ord => 2000,
				progress => 8,
				all_app_in_title => 1,
				page_db_id => 200020,
			},
			{
				type => 'radiolist',
				name => 'mezziwhom',
				label => 'Расходы заявителя оплачивает',
				check => 'N',
				db => {
					table => 'AppData',
					name => 'MezziWhom',
				},
				param => { 
					0 => 'сам заявитель', 
					1 => 'приглашающая сторона',
					2 => 'иной спонсор',
				},
			},
		],
		
		'Уточните спонсора' => [
			{
				page_ord => 2100,
				progress => 8,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'MezziWhom',
						value => '2',
					}
				},
				page_db_id => 200021,
			},
			{
				type => 'input',
				name => 'mezziwhomother',
				label => 'Спонсор',
				comment => 'Укажите спонсора, оплачивающего расходы во время поездки',
				check => 'zWN\s\_\.\,\"\'\-\(\)\#\*',
				db => {
					table => 'AppData',
					name => 'MezziWhomOther',
				},
				format => 'capslock',
			},
		],
		
		'Средства заявителя' => [
			{
				page_ord => 2200,
				progress => 8,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'MezziWhom',
						value => '0',
					}
				},
				page_db_id => 200022,
			},
			{
				type => 'checklist',
				name => 'mezzi',
				label => 'Средства',
				check => 'at_least_one',
				db => {
					table => 'AppData',
					name => 'complex'
				},
				param => {
					mezzi1 => { db => 'Mezzi1', label_for => 'Наличные деньги' },
					mezzi2 => { db => 'Mezzi2', label_for => 'Дорожные чеки' },
					mezzi3 => { db => 'Mezzi3', label_for => 'Кредитная карточка' },
					mezzi4 => { db => 'Mezzi4', label_for => 'Предоплачено место проживания' },
					mezzi5 => { db => 'Mezzi5', label_for => 'Предоплаченный транспорт' },
					mezzi6 => { db => 'Mezzi7', label_for => 'Иные' },
				},
			},
		],
		
		'Средства спонсора' => [
			{
				page_ord => 2300,
				progress => 8,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'MezziWhom',
						value => '1,2',
					}
				},
				page_db_id => 200023,
			},
			{
				type => 'checklist',
				name => 'sponsor_mezzi',
				label => 'Средства',
				check => 'at_least_one',
				db => {
					table => 'AppData',
					name => 'complex'
				},
				param => {
					sponsor_mezzi1 => { db => 'Mezzi1', label_for => 'Наличные деньги' },
					sponsor_mezzi2 => { db => 'Mezzi6', label_for => 'Оплачиваются все расходы' },
					sponsor_mezzi3 => { db => 'Mezzi5', label_for => 'Оплачивается транспорт' },
					sponsor_mezzi4 => { db => 'Mezzi4', label_for => 'Оплачивается место проживания' },
					sponsor_mezzi5 => { db => 'Mezzi7', label_for => 'Иные' },
				},
			},
		],
		
		'Уточните иные средства' => [
			{
				page_ord => 2400,
				progress => 8,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'Mezzi7',
						value => '1',
					}
				},
				page_db_id => 200024,
			},
			{
				type => 'input',
				name => 'whomothersrc',
				label => 'Иные средства',
				comment => 'Укажите иные финансовые гарантии',
				check => 'zWwN\s_\.\,\"\'\-\(\)\#\*',
				db => {
					table => 'AppData',
					name => 'MezziOtherSrc',
				},
				format => 'capslock',
			},
		],
				
		'Данные родственника в ЕС' => [
			{
				page_ord => 2500,
				progress => 8,
				all_app_in_title => 1,
				param => 1,
				relation => {
					only_if_not => {
						table => 'AppData',
						name => 'FamRel',
						value => '0',
					}
				},
				page_db_id => 200025,
			},
			{
				type => 'input',
				name => 'eu_lname',
				label => 'Фамилия',
				comment => 'Введите фамилию на английском языке так, как она указана в паспорте',
				example => 'Ivanov',
				check => 'zW\s\-',
				db => {
					table => 'AppData',
					name => 'EuLName',
				},
				format => 'capslock',
			},
			{
				type => 'input',
				name => 'eu_fname',
				label => 'Имя',
				comment => 'Введите имя на английском языке так, как оно указано в паспорте',
				example => 'Ivan',
				check => 'zW\s\-',
				db => {
					table => 'AppData',
					name => 'EuFName',
				},
				format => 'capslock',
			},
			{
				type => 'input',
				name => 'eu_bdate',
				label => 'Дата рождения',
				comment => 'Введите дату рождения',
				example => '31.12.1900',
				check => $standart_date_check,
				db => {
					table => 'AppData',
					name => 'EuBDate',
				},
				special => 'mask',
			},
			{
				type => 'select',
				name => 'eu_citizenship',
				label => 'Гражданство',
				comment => 'Укажите гражданство родственника',
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'EuCitizen',
				},
				param => '[eu_countries]',
				first_elements => '133',
			},
			{
				type => 'input',
				name => 'eu_idnum',
				label => 'Номер паспорта',
				comment => 'Введите серию и номер паспорта',
				example => '750000001',
				check => 'zWN',
				db => {
					table => 'AppData',
					name => 'EuPassNum',
				},
				format => 'capslock',
			},
		],
		
		'Вы успешно добавили заявителя' => [	
			{
				page_ord => 2600,
				progress => 9,
				all_app_in_title => 1,
				replacer => '[app_finish]',
				page_db_id => 200026,
			},
		],
		
		'Выберите лицо на которое будет оформлен договор' => [
			{
				page_ord => 2700,
				progress => 9,
				persons_in_page => 1,
				page_db_id => 200027,
			},
			{
				type => 'select',
				name => 'visa_text',
				label => 'Выберите на кого оформляется',
				check => 'zN-',
				db => {
					table => 'Appointments',
					name => 'PersonForAgreements',
					transfer => 'nope',
				},
				param => '[persons_in_app]',
				first_elements => 'default_free',
			},
		],
		
		'Укажите данные документа, удостоверяющего личность' => [
			{
				page_ord => 2800,
				progress => 10,
				relation => {
					only_if_not => {
						table => 'Appointments',
						name => 'PersonForAgreements',
						value => '-1',
					}
				},
				page_db_id => 200028,
			},
			{
				type => 'text',
				name => 'rupass_text',
				label => 'Для граждан РФ необходимо указать данные внутреннего паспорта',
			},
			{
				type => 'free_line',
			},
			{
				type => 'info',
				name => 'info_rulname',
				label => 'Фамилия',
				db => {
					table => 'AppData',
					name => 'RLName',
				},
			},
			{
				type => 'info',
				name => 'info_rufname',
				label => 'Имя',
				db => {
					table => 'AppData',
					name => 'RFName',
				},
			},
			{
				type => 'info',
				name => 'info_rumname',
				label => 'Отчество',
				db => {
					table => 'AppData',
					name => 'RMName',
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'info_passnum',
				label => '№ паспорта',
				comment => 'Введите серию и номер паспорта как единый набор цифр без пробелов',
				example => '4510ХХХХХХ',
				check => 'zNW',
				db => {
					table => 'AppData',
					name => 'RPassNum',
				},
			},
			{
				type => 'input',
				name => 'info_passdate',
				label => 'Дата выдачи',
				comment => 'Введите дату выдачи, указанную в паспорте',
				example => '31.12.1900',
				check => $standart_date_check,
				check_logic => [
					{
						condition => 'now_or_earlier',
					},
				],
				db => {
					table => 'AppData',
					name => 'RPWhen',
				},
				special => 'mask',
			},
			{
				type => 'input',
				name => 'info_rupasswhere',
				label => 'Кем выдан',
				comment => 'Укажите полное название выдавшей организации, так, как она указана в паспорте',
				example => 'ОВД по району Беговой города Москвы',
				check => 'zWЁN\s\-\_\.\,\;\'\"',
				db => {
					table => 'AppData',
					name => 'RPWhere',
				},
			},
			{
				type => 'input',
				name => 'info_address',
				label => 'Адрес регистрации',
				comment => 'Укажите адрес регистрации',
				example => 'г.Москва, М.Толмачевский пер., д. 6, стр.1',
				check => 'zWЁN\s\-\_\.\,\;\'\"',
				db => {
					table => 'AppData',
					name => 'RAddress',
					transfer => 'nope',
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'info',
				name => 'info_phone',
				label => 'Телефон',
				db => {
					table => 'AppData',
					name => 'AppPhone',
				},
			},
		],
		
		'Укажите данные доверенного лица' => [
			{
				page_ord => 2900,
				progress => 10,
				param => 1,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'PersonForAgreements',
						value => '-1',
					}
				},
				page_db_id => 200029,
			},
			{
				type => 'input',
				name => 'dovlname',
				label => 'Фамилия',
				comment => 'Введите фамилию на русском языке так, как она указана во внутреннем паспорте',
				example => 'Иванов',
				check => 'zWЁ\s\-',
				db => {
					table => 'Appointments',
					name => 'LName',
				},
			},
			{
				type => 'input',
				name => 'dovfname',
				label => 'Имя',
				comment => 'Введите имя на русском языке так, как оно указана во внутреннем паспорте',
				example => 'Иван',
				check => 'zWЁ\s\-',
				db => {
					table => 'Appointments',
					name => 'FName',
				},
			},
			{
				type => 'input',
				name => 'dovmname',
				label => 'Отчество',
				comment => 'Введите отчество на русском языке так, как оно указана во внутреннем паспорте',
				example => 'Иванович',
				check => 'zWЁ\s\-',
				db => {
					table => 'Appointments',
					name => 'MName',
				},
			},
			{
				type => 'input',
				name => 'dovpassnum',
				label => '№ паспорта',
				comment => 'Введите серию и номер паспорта как единый набор цифр без пробелов',
				example => '4510ХХХХХХ',
				check => 'zNW',
				db => {
					table => 'Appointments',
					name => 'PassNum',
				},
			},
			{
				type => 'input',
				name => 'dovpassdate',
				label => 'Дата выдачи',
				comment => 'Введите дату выдачи, указанную в паспорте',
				example => '31.12.1900',
				check => $standart_date_check,
				check_logic => [
					{
						condition => 'now_or_earlier',
					},
				],
				db => {
					table => 'Appointments',
					name => 'PassDate',
				},
				special => 'mask',
			},
			{
				type => 'select',
				name => 'passwhere',
				label => 'Кем выдан',
				comment => 'Укажите название страны, выдавшей паспорт',
				example => 'The Russian Federation',
				check => 'zN',
				complete_check => 'not_empty',
				db => {
					table => 'AppData',
					name => 'PassWhom',
				},
				param => '[citizenship_countries]',
				first_elements => '70',
			},
			{
				type => 'input',
				name => 'dovaddress',
				label => 'Адрес',
				comment => 'Полный адрес, включая индекс',
				example => '119017, г.Москва, М.Толмачевский пер., д. 6, стр.1',
				check => 'zWЁN\s\-\_\.\,\;\'\"',
				db => {
					table => 'Appointments',
					name => 'Address',
				},
			},
			{
				type => 'input',
				name => 'dovphone',
				label => 'Телефон',
				comment => 'Введите контактный телефон, сотовый или городской, с кодом оператора, без пробелов и разделителей',
				example => '79161234567',
				check => 'zN',
				db => {
					table => 'Appointments',
					name => 'Phone',
				},
			},
		],
		
		'Оформление записи' => [
			{
				page_ord => 3000,
				progress => 11,
				persons_in_page => 1,
				goto_link => 'back_to_appdate',
				page_db_id => 200030,
			},
			{
				type => 'text',
				name => 'appdate_text',
				label => 'Дата записи',
				font => 'bold',
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'app_date',
				label => 'Дата записи в Визовый центр',
				comment => 'Введите дату, когда собираетесь посетить Визовый центр для подачи документов',
				check => $standart_date_check,
				check_logic => [
					{
						condition => 'now_or_later',
					},
					{
						condition => 'now_or_earlier',
						offset => 90,
						equality_is_also_fail => 1,
						full_error => 'Запись в Визовый центр более чем за [offset] не осуществляется',
					},
				],
				db => {
					table => 'Appointments',
					name => 'AppDate',
				},
				special => 'datepicker, mask',
				uniq_code => 'onchange="update_timeslots(1);"',
			},
			{
				type => 'select',
				name => 'timeslot',
				label => 'Время',
				check => 'zN',
				db => {
					table => 'Appointments',
					name => 'TimeslotID',
				},
				param => '[free]',
				special => 'timeslots',
			},
			{
				type => 'free_line',
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'services_text',
				label => 'СМС-оповещение о готовности документов ( <a target = "_blank" class = "dotted_link_big" href="/spb-dopolnitelnye-uslugi/">платная услуга</a> )',
				font => 'bold',
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'sms',
				label => 'Номер телефона для<br>SMS-уведомления',
				comment => 'Введите номер сотового телефона для получения СМС о готовности документов; услуга платная, оставьте поле пустым, если в ней нет необходимости',
				example => '79XXXXXXXXX',
				check => 'N',
				check_logic => [
					{
						condition => 'length_strict',
						length => 11,
						full_error => 'Неправильный формат телефонного номера',
					}
				],
				db => {
					table => 'Appointments',
					name => 'Mobile',
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'services_text',
				label => 'Доставка документов DHL ( <a target = "_blank" class = "dotted_link_big" href="/spb-dopolnitelnye-uslugi/">платная услуга</a> )',
				font => 'bold',
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'ship_index',
				label => 'Индекс доставки',
				comment => 'Введите первые цифры индекса или первые буквы города для доставки документов; выберите из списка подходящий индекс и город; услуга платная, оставьте поле пустым, если в ней нет необходимости',
				example => '119017, Москва',
				check => 'ЁN\s\,\.\-\(\)',
				check_logic => [
					{
						condition => 'free_only_if_not',
						table => 'Appointments',
						name => 'ShAddress',
						error => 'Адрес доставки',
					}
				],
				db => {
					table => 'Appointments',
					name => 'ShIndex',
				},
				special => 'post_index',
			},
			{
				type => 'input',
				name => 'shipping',
				label => 'Адрес доставки',
				comment => 'Введите адрес для доставки документов документов, без указания индекса и города; услуга платная, оставьте поле пустым, если в ней нет необходимости',
				example => 'Малый Толмачёвский пер., д.6 стр.1',
				check => 'ЁN\s\-\_\.\,\;\'\"',
				check_logic => [
					{
						condition => 'free_only_if_not',
						table => 'Appointments',
						name => 'ShIndex',
						error => 'Индекс доставки',
					},
				],
				db => {
					table => 'Appointments',
					name => 'ShAddress',
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'services_text',
				label => 'Страхование ( <a target = "_blank" class = "dotted_link_big" href="/spb-dopolnitelnye-uslugi/">платная услуга</a> )',
				font => 'bold',
			},
			{
				type => 'free_line',
			},
			{
				type => 'include',
				place => 'in',
				template => 'insurance_form.tt2',
			}
		],
		
		'Подтвердить запись' => [
			{
				page_ord => 3100,
				progress => 12,
				page_db_id => 200031,
			},
			{
				type => 'captcha',
			},
		],
		
		'Запись успешно создана!' => [
			{
				page_ord => 3200,
				progress => 13,
				page_db_id => 200032,
			},
			{
				type => 'text',
				name => 'conf_mail_text',
				label => 'На вашу почту отправлено письмо с подтверждением записи.',
			},
			{
				type => 'free_line',
			},
			{
				type => 'info',
				name => 'new_app_num',
				label => 'Номер записи',
			},
			{
				type => 'info',
				name => 'new_app_branch',
				label => 'Визовый центр',
				db => {
					table => 'Appointments',
					name => 'CenterID',
				},
			},
			{
				type => 'info',
				name => 'new_app_timedate',
				label => 'Дата',
				db => {
					table => 'Appointments',
					name => 'AppDate',
				},
			},
			{
				type => 'info',
				name => 'new_app_timeslot',
				label => 'Время записи',
				db => {
					table => 'Appointments',
					name => 'TimeslotID',
				},
			},
		],
	};
	
sub get_content_edit_rules_hash
# //////////////////////////////////////////////////
{

	my $standart_date_check = 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-3]\d))$';
	my $standart_date_check_opt = 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-3]\d))$';

	return [
		{
			type => 'info',
			name => 'edt_lname',
			label => 'Фамилия',
			db => {
				table => 'AppData',
				name => 'LName',
			},
		},
		{
			type => 'info',
			name => 'edt_fname',
			label => 'Имя',
			db => {
				table => 'AppData',
				name => 'FName',
			},
		},
		{
			type => 'info',
			name => 'edt_passnum',
			label => 'Паспорт',
			db => {
				table => 'AppData',
				name => 'PassNum',
			},
		},
		{
			type => 'free_line',
		},
		{
			type => 'text',
			name => 'edt_addr_text',
			label => 'Адреса',
			font => 'bold',
		},
		{
			type => 'free_line',
		},
		{
			type => 'input',
			name => 'edt_addr',
			label => 'Домашний адрес и адрес электронной почты',
			comment => 'Укажите адрес места жительства',
			example => 'Moscow, M.Tolmachevskiy pereulok 6 b.1',
			check => 'zWN\s\-\_\.\,\;\'\"\@',
			db => {
				table => 'AppData',
				name => 'FullAddress',
			},
			format => 'capslock',
		},
		{
			type => 'free_line',
		},
		{
			type => 'input',
			name => 'edt_hotels',
			label => 'Название гостиницы или ФИО приглашающего',
			comment => 'Укажите полное название гостиницы или данные приглашающего лица. Укажите только одно место проживания, в котором планируете провести большее количество дней, при равном количестве дней- укажите первое.',
			example => 'Via Esempio 1',
			check => 'zNW\s\-\.\&',
			db => {
				table => 'AppData',
				name => 'Hotels',
			},
			format => 'capslock',
		},
		{
			type => 'free_line',
		},
		{
			type => 'input',
			name => 'edt_hoteladdr',
			label => 'Адрес места пребывания и телефон',
			comment => 'Укажите адрес гостиницы или приглашающего, или временного места пребывания, а также контактный телефон',
			example => 'Rome, Via Esempio 1, 39XXXXXXXX',
			check => 'zWN\s\-\_\.\,\;\'\"\@',
			db => {
				table => 'AppData',
				name => 'HotelAdresses',
			},
			format => 'capslock',
		},
		{
			type => 'free_line',
		},
		{
			type => 'text',
			name => 'edt_visa_text',
			label => 'Виза',
			font => 'bold',
		},
		{
			type => 'free_line',
		},
		{
			type => 'select',
			name => 'edt_visanum',
			label => 'Виза запрашивается для',
			comment => 'Виза с однократным въездом даёт возможность пересечь границу Шенгена только один раз. После того как Вы покинете зону Шенгена по данной визе, она будет закрыта и перестанет действовать. Виза с двукратным въездом позволяет въехать и покинуть зону Шенгена два раза в период действия визы. Виза с многократным въездом даёт возможность пересекать границу зоны Шенгенского соглашения в период действия визы',
			example => 'многократного въезда',
			check => 'N',
			db => {
				table => 'AppData',
				name => 'VisaNum',
			},
			param => {
				0 => 'однократного въезда',
				1 => 'двукратного въезда',
				2 => 'многократного въезда',
			},
			first_elements => '2, 1, 0',
		},
		{
			type => 'input',
			name => 'edt_apps_date',
			label => 'Дата начала поездки',
			comment => 'Укажите дату начала действия запрашиваемой визы',
			example => '31.12.1900',
			check => $standart_date_check,
			check_logic => [
				{
					condition => 'now_or_later',
					offset => '[collect_date_offset]',
				},
				{
					condition => 'equal_or_earlier',
					table => 'AppData',
					name => 'PassDate',
					offset => ( 10 * 365 ), # <--- 10 years
					error => 'Дата выдачи паспорта',
				},
				{
					condition => 'now_or_earlier',
					offset => 180,
					equality_is_also_fail => 1,
					full_error => 'Действует ограничение на максимальную дату вылета: не более [offset] с текущей даты',
				},
			],
			db => {
				table => 'AppData',
				name => 'AppSDate',
			},
			special => 'datepicker, mask',
			minimal_date => 'current',
		},
		{
			type => 'input',
			name => 'edt_appf_date',
			label => 'Дата окончания поездки',
			comment => 'Укажите дату окончания действия запрашиваемой визы',
			example => '31.12.1900',
			check => $standart_date_check,
			check_logic => [
				{
					condition => 'equal_or_later',
					table => 'AppData',
					name => 'AppSDate',
					error => 'Дата начала поездки',
				},
				{
					condition => 'not_closer_than',
					table => 'AppData',
					name => 'PassTill',
					offset => -90,
					full_error => 'Между окончанием срока действия паспорта и датой окончания поездки должно быть как минимум [offset]',
				},
			],
			db => {
				table => 'AppData',
				name => 'AppFDate',
			},
			special => 'datepicker, mask',
			minimal_date => 'apps_date',
		},
		{
			type => 'free_line',
		},
		{
			type => 'text',
			name => 'edt_prevvise_text',
			label => 'Предыдущие визы',
			font => 'bold',
		},
		{
			type => 'radiolist',
			name => 'edt_prevvisa',
			label => 'Были ли визы за последние три года',
			check => 'zN',
			db => {
				table => 'AppData',
				name => 'PrevVisa',
			},
			param => { 
				1 => 'нет', 
				2 => 'да',
			},
		},
		{
			type => 'free_line',
		},
		{
			type => 'input',
			name => 'edt_prevvisafd',
			label => 'Дата начала',
			comment => 'Укажите дату начала действия визы',
			example => '31.12.1900',
			check => $standart_date_check_opt,
			db => {
				table => 'AppData',
				name => 'PrevVisaFD',
			},
			special => 'mask',
		},
		{
			type => 'input',
			name => 'edt_prevvised',
			label => 'Дата окончания',
			comment => 'Укажите дату окончания действия визы',
			example => '31.12.1900',
			check => $standart_date_check_opt,
			check_logic => [
				{
					condition => 'now_or_later',
					offset => ( -3 * 365 ), # <--- 3 years
					full_error => 'Допустимо указывать только визы, выданные за последние [offset]'
				},
				{
					condition => 'equal_or_later',
					table => 'AppData',
					name => 'PrevVisaFD',
					error => 'Дата начала действия визы',
				},
			],
			db => {
				table => 'AppData',
				name => 'PrevVisaED',
			},
			special => 'mask',
		},
		{
			type => 'free_line',
		},
		{
			type => 'text',
			name => 'edt_purpose_text',
			label => 'Цель поездки',
			font => 'bold',
		},
		{
			type => 'radiolist',
			name => 'edt_purpose',
			label => 'Основная цель поездки',
			check => 'zN',
			db => {
				table => 'AppData',
				name => 'VisaPurpose',
			},
			param => { 
				1 => 'туризм', 
				2 => 'деловая',
				3 => 'учёба',
				4 => 'официальная',
				5 => 'культура',
				6 => 'спорт',
				7 => 'транзит',
				8 => 'лечение',
				9 => 'посещение родственников или друзей',
				10 => 'иная',
			},
			special => 'save_info_about_hastdatatype',
		},
		{
			type => 'free_line',
		},
		{
			type => 'text',
			name => 'edt_prof_text',
			label => 'Профессиональная деятельность',
			font => 'bold',
		},
		{
			type => 'free_line',
		},
		{
			type => 'input',
			name => 'etc_workdata',
			label => 'Профессиональная деятельность',
			comment => 'Профессию необходимо указывать на английском или итальянском языках',
			example => 'Manager',
			check => 'zWN\s\_\.\,\"\'\-\(\)\#\*',
			db => {
				table => 'AppData',
				name => 'ProfActivity',
			},
			format => 'capslock'
		},
		{
			type => 'input',
			name => 'edt_workorg',
			label => 'Адрес места работы и телефон',
			comment => 'Укажите адрес места своей работы и телефон',
			example => '191186, St. Petersburg, 1/25 Kazanskaya st., 5, 79XXXXXXXX',
			check => 'zWN\s\-\_\.\,\;\'\"\@',
			db => {
				table => 'AppData',
				name => 'WorkOrg',
			},
			format => 'capslock',
		},
		{
			type => 'free_line',
		},
		{
			type => 'text',
			name => 'edt_ec_text',
			label => 'Данные родственника в ЕС',
			font => 'bold',
		},
		{
			type => 'free_line',
		},
		{
			type => 'radiolist',
			name => 'femrel',
			label => 'Степень родства',
			check => 'N',
			db => {
				table => 'AppData',
				name => 'FamRel',
			},
			param => { 
				0 => 'нет', 
				1 => 'супруг',
				2 => 'ребёнок',
				3 => 'иные близкие родственники',
				4 => 'иждивенец',
			},
		},
		{
			type => 'free_line',
		},
		{
			type => 'input',
			name => 'eu_lname',
			label => 'Фамилия',
			comment => 'Введите фамилию на английском языке так, как она указана в паспорте',
			example => 'Ivanov',
			check => 'W\s\-',
			db => {
				table => 'AppData',
				name => 'EuLName',
			},
			format => 'capslock',
		},
		{
			type => 'input',
			name => 'eu_fname',
			label => 'Имя',
			comment => 'Введите имя на английском языке так, как оно указано в паспорте',
			example => 'Ivan',
			check => 'W\s\-',
			db => {
				table => 'AppData',
				name => 'EuFName',
			},
			format => 'capslock',
		},
		{
			type => 'input',
			name => 'eu_bdate',
			label => 'Дата рождения',
			comment => 'Введите дату рождения',
			example => '31.12.1900',
			check => $standart_date_check_opt,
			db => {
				table => 'AppData',
				name => 'EuBDate',
			},
			special => 'mask',
		},

		{
			type => 'input',
			name => 'eu_idnum',
			label => 'Номер паспорта',
			comment => 'Введите серию и номер паспорта',
			example => '750000001',
			check => 'WN',
			db => {
				table => 'AppData',
				name => 'EuPassNum',
			},
			format => 'capslock',
		},
		{
			type => 'select',
			name => 'eu_citizenship',
			label => 'Гражданство',
			comment => 'Укажите гражданство родственника',
			check => 'N',
			db => {
				table => 'AppData',
				name => 'EuCitizen',
			},
			param => '[eu_countries]',
			first_elements => '133',
		},
		{
			type => 'free_line',
		},
		{
			type => 'text',
			name => 'edt_ec_text',
			label => 'Оплата расходов',
			font => 'bold',
		},
		{
			type => 'radiolist',
			name => 'edt_mezziwhom',
			label => 'Расходы заявителя оплачивает',
			check => 'N',
			db => {
				table => 'AppData',
				name => 'MezziWhom',
			},
			param => { 
				0 => 'сам заявитель', 
				1 => 'приглашающая сторона',
				2 => 'иной спонсор',
			},
		},
		{
			type => 'input',
			name => 'edt_mezziwhomother',
			label => 'Иной спонсор',
			comment => 'Укажите спонсора, оплачивающего расходы во время поездки',
			check => 'WN\s\_\.\,\"\'\-\(\)\#\*',
			db => {
				table => 'AppData',
				name => 'MezziWhomOther',
			},
			format => 'capslock',
		},
		{
			type => 'free_line',
		},
		{
			type => 'checklist',
			name => 'edt_mezzi',
			label => 'Средства',
			check => 'at_least_one',
			db => {
				table => 'AppData',
				name => 'Mezzi'
			},
			param => {
				mezzi1 => { db => 'Mezzi1', label_for => 'Наличные деньги' },
				mezzi2 => { db => 'Mezzi2', label_for => 'Дорожные чеки' },
				mezzi3 => { db => 'Mezzi3', label_for => 'Кредитная карточка' },
				mezzi4 => { db => 'Mezzi4', label_for => 'Предоплачено место проживания' },
				mezzi5 => { db => 'Mezzi5', label_for => 'Предоплаченный транспорт' },
				mezzi6 => { db => 'Mezzi6', label_for => 'Оплачиваются все расходы' },
				mezzi7 => { db => 'Mezzi7', label_for => 'Иные' },
			},
		},
		{
			type => 'input',
			name => 'edt_whomothersrc',
			label => 'Иные средства',
			comment => 'Укажите иные финансовые гарантии',
			check => 'WwN\s_\.\,\"\'\-\(\)\#\*',
			db => {
				table => 'AppData',
				name => 'MezziOtherSrc',
			},
			format => 'capslock',
		},
	];
}

1;
}

1;
