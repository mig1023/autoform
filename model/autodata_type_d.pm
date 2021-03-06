﻿package VCS::Site::autodata_type_d;
use strict;

sub get_progressline
# //////////////////////////////////////////////////
{
	return [ '',
		{ big => 1, name => 'Начало', },
		{ big => 0, name => 'Даты поездки', },
		{ big => 1, name => 'Заявители', },
		{ big => 0, name => 'Данные паспорта', },
		{ big => 0, name => 'Данные загранпаспорта', },
		{ big => 1, name => 'Оформление', },
		{ big => 0, name => 'Данные для договора', },
		{ big => 0, name => 'Выбор даты записи', },
		{ big => 0, name => 'Офис выдачи', },
		{ big => 0, name => 'Подтверждение', },
		{ big => 1, name => 'Готово!', },
	];
}
		
sub get_content_rules_hash
# //////////////////////////////////////////////////
{

	my $standart_date_check = 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-3]\d))$';

	return {
		
		'Начало записи' => [
			{
				page_ord => 100,
				progress => 1,
				param => 1,
				goto_link => 'to_start',
				page_db_id => 300001,
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
		
		'Даты поездки' => [
			{
				page_ord => 200,
				progress => 2,
				collect_date => 1,
				page_db_id => 300002,
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
				page_ord => 300,
				progress => 3,
				goto_link => 'back_to_appdata',
				all_app_in_title => 1,
				replacer => '[list_of_applicants]',
				page_db_id => 300003,
			},
		],
		
		'Данные паспорта' => [
			{
				page_ord => 400,
				progress => 4,
				all_app_in_title => 1,
				param => 1,
				page_db_id => 300004,
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
				progress => 5,
				page_db_id => 300005,
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
		
		'Вы успешно добавили заявителя' => [	
			{
				page_ord => 600,
				progress => 6,
				all_app_in_title => 1,
				replacer => '[app_finish]',
				page_db_id => 300006,
			},
		],
		
		'Выберите лицо на которое будет оформлен договор' => [
			{
				page_ord => 700,
				progress => 6,
				persons_in_page => 1,
				page_db_id => 300007,
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
				page_ord => 800,
				progress => 7,
				relation => {
					only_if_not => {
						table => 'Appointments',
						name => 'PersonForAgreements',
						value => '-1',
					}
				},
				page_db_id => 300008,
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
				type => 'input',
				name => 'info_phone',
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
		
		'Укажите данные доверенного лица' => [
			{
				page_ord => 900,
				progress => 7,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'PersonForAgreements',
						value => '-1',
					}
				},
				page_db_id => 300009,
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
				type => 'input',
				name => 'dovpasswhere',
				label => 'Кем выдан',
				comment => 'Укажите полное название выдавшей организации, так, как она указана в паспорте',
				example => 'ОВД по району Беговой города Москвы',
				check => 'zWЁN\s\-\_\.\,\;\'\"',
				db => {
					table => 'Appointments',
					name => 'PassWhom',
				},
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
				page_ord => 1000,
				progress => 8,
				persons_in_page => 1,
				page_db_id => 300010,
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
				label => 'СМС-оповещение о готовности документов ( <a target = "_blank" class = "dotted_link_big" href="/dopolnitelnye-uslugi/">платная услуга</a> )',
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
				label => 'Доставка документов DHL ( <a target = "_blank" class = "dotted_link_big" href="/dopolnitelnye-uslugi/">платная услуга</a> )',
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
				label => 'Страхование ( <a target = "_blank" class = "dotted_link_big" href="/dopolnitelnye-uslugi/">платная услуга</a> )',
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
		
		'Предпочтительный офис получения готовых документов' => [
			{
				page_ord => 1100,
				progress => 9,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'CenterID',
						value => '1',
					}
				},
				page_db_id => 300011,
			},
			{
				type => 'radiolist',
				name => 'mezziwhom',
				label => 'Выберите офис, в котором будет осуществляться выдачи готовых документов',
				check => 'zN',
				db => {
					table => 'Appointments',
					name => 'OfficeToReceive',
				},
				param => { 
					1 => '<b>м.Третьяковская</b>, Малый Толмачёвский пер., д.6 стр.1',
					2 => '<b>м.Киевская</b>, ул. Киевская, вл. 2, 3 этаж',
				},
			},
		],
		
		'Подтвердить запись' => [
			{
				page_ord => 1200,
				progress => 10,
				page_db_id => 300012,
			},
			{
				type => 'captcha',
			},
		],
		
		'Запись успешно создана!' => [
			{
				page_ord => 1300,
				progress => 11,
				page_db_id => 300013,
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
}

1;
