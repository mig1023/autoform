﻿package VCS::Site::autodata_type_rinnuovo;
use strict;

sub get_progressline
# //////////////////////////////////////////////////
{
	return [ '',
		{ big => 1, name => 'Начало', },
		{ big => 1, name => 'Заявители', },
		{ big => 0, name => 'Данные паспорта', },
		{ big => 0, name => 'Дополнительные данные', },
		{ big => 0, name => 'Данные о поездке', },
		{ big => 0, name => 'Расходы', },
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
	my $standart_date_check_opt = 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-3]\d))$';

	return {
		
		'Начало записи' => [
			{
				page_ord => 100,
				progress => 1,
				param => 1,
				goto_link => 'to_start',
				page_db_id => 500001,
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
				param => '[centers_from_db_rinnuovo]',
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
				param => '[visas_from_db_rinnuovo]', # <--- from js
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
				example => 'test@mail.com',
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
				comment => 'Обратите внимание, что адрес электронной почты необходимо вводить вручную, не копируя его из предыдущего поля. Это поможет Вам избежать ошибки и возможной отправки подтверждения Вашей записи не тому адресату.',
				example => 'test@mail.com',
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
			},
			#{
			#	type => 'include',
			#	place => 'out',
			#	template => 'vip_form.tt2',
			#},
		],
				
		'Услуга Primetime' => [
			{
				page_ord => 150,
				progress => 1,
				primetime_price => 1,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'CenterID',
						value => '41',
					}
				},
				page_db_id => 500003,
			},
			{
				type => 'text',
				name => 'primetime_text',
				label => 'Стоимость услуги «Прайм-тайм» составляет: [primetime_price] рублей за каждого заявителя и не включает в себя стоимость сервисного и консульского сборов, а также <a target = "_blank" class = "dotted_link_big" href = "/dopolnitelnye-uslugi/">дополнительных услуг</a>',
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
				
		'Список заявителей' => [
			{
				page_ord => 300,
				progress => 3,
				all_app_in_title => 1,
				goto_link => 'back_to_appdata',
				replacer => '[list_of_applicants]',
				page_db_id => 500005,
			},
		],
		
		'Данные паспортов' => [
			{
				page_ord => 400,
				progress => 4,
				all_app_in_title => 1,
				param => 1,
				page_db_id => 500006,
			},
			{
				type => 'free_line',
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
				type => 'm_select',
				name => 'other_сitizenship',
				label => 'Иное гражданство',
				comment => 'Если у вас имеется второе гражданство, укажите его в данном поле',
				example => 'The Russian Federation',
				check => 'N,',
				db => {
					table => 'AppData',
					name => 'OtherCitizenship',
				},
				param => '[citizenship_countries]',
				special => 'multiple_select',
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
						full_error => 'Для граждан РФ отчество необходимо вводить на русском языке',
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
				name => 'pass_data',
				label => 'Данные загранпаспорта',
				font => 'bold',
			},
			{
				type => 'biometric_data',
				comment => 'сканировать данные<br>биометрического паспорта',
			},
			{
				type => 'select',
				name => 'doctype',
				label => 'Тип паспорта',
				example => 'Обычный паспорт',
				check => 'N',
				db => {
					table => 'AppData',
					name => 'DocType',
				},
				param => {
					0 => 'Обычный паспорт',
					1 => 'Служебный паспорт',
					2 => 'Особый паспорт',
					3 => 'Дипломатический паспорт',
					4 => 'Официальный паспорт',
					5 => 'Иной проездной документ',
				},
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
			},
			{
				type => 'free_line',
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
				type => 'select',
				name => 'homeсitizenship',
				label => 'Страна проживания',
				comment => 'Страна фактического проживания в настоящее время',
				example => 'The Russian Federation',
				check => 'zN',
				complete_check => 'not_empty',
				db => {
					table => 'SchengenExtData',
					name => 'HomeCountry',
				},
				param => '[citizenship_countries]',
				first_elements => '70',
			},
			{
				type => 'input',
				name => 'homecity',
				label => 'Город проживания',
				comment => 'Укажите название города фактического проживания в настоящее время',
				example => 'Moscow',
				check => 'zWN\s\-\_\.\,\;\'\"',
				complete_check => 'not_empty',
				db => {
					table => 'SchengenExtData',
					name => 'HomeCity',
				},
				format => 'capslock',
			},
			{
				type => 'input',
				name => 'homeaddress',
				label => 'Домашний адрес',
				comment => 'Фактический адрес проживания заявителя',
				example => 'M.Tolmachevskiy pereulok 6 b.1',
				check => 'zWN\s\-\_\.\,\;\'\"\/',
				complete_check => 'not_empty',
				db => {
					table => 'SchengenExtData',
					name => 'HomeAddress',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'homepostal',
				label => 'Индекс',
				comment => 'Введите почтовый индекс фактического адреса проживания заявителя',
				example => '119017',
				check => 'zN\s\-',
				complete_check => 'not_empty',
				db => {
					table => 'SchengenExtData',
					name => 'HomePostal',
				},
			},
			{
				type => 'input',
				name => 'appemail',
				label => 'Email',
				comment => 'Введите существующий адрес почты, по которому можно будет связаться с заявителем',
				example => 'test@mail.com',
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
					table => 'AppData',
					name => 'AppEMail',
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
				page_ord => 500,
				progress => 5,
				param => 1,
				all_app_in_title => 1,
				ussr_or_rf_first => 1,
				page_db_id => 500007,
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
				comment => 'Укажите место рождения латинскими буквами в соответствии с информацией в загранпаспорте, населенный пункт должен быть указан обязательно',
				example => [
					'Pushkino, Moscowskaya',
					'Moscow',
					'Belgorod, Belgorodskaya',
				],
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
					6 => 'иное',
					7 => 'в зарегистр-ном партнерстве'
				},
			},
			{
				type => 'free_line',
			},
			{
				type => 'select',
				name => 'workdata',
				label => 'Профессиональная деятельность',
				comment => 'Профессию необходимо выбрать в соответствии со справкой с места работы/учёбы. Если на данный момент Вы не работаете, а также для детей дошкольного возраста, выберите - без профессии',
				example => 'Менеджер',
				check => 'z',
				complete_check => 'not_empty',
				db => {
					table => 'SchengenExtData',
					name => 'Occupation',
				},
				param => {
					'Specialista informatico' => 'IT-специалист',
					'Personale amministrativo e di servizio' => 'Административный и обслуживающий персонал (администратор, секретарь)',
					'Personale nel settore della ristorazione e turistico' => 'Персонал в сфере общественного питания и туризма (администратор, офисный работник, экскурсовод, официант)',
					'Architetto' => 'Архитектор',
					'Banchiere' => 'Банкир',
					'Businessman' => 'Бизнесмен',
					'Assistente di volo' => 'Бортпроводник',
					'Contabile' => 'Бухгалтер, экономист',
					'Autista' => 'Водитель',
					'Impiegato del governo' => 'Государственный служащий',
					'Artista' => 'Деятель искусств',
					'Casalinga' => 'Домохозяйка',
					'Diplomatico' => 'Дипломатический агент',
					'Giornalista' => 'Журналист',
					'Personale sanitario' => 'Медицинские профессии/средний медицинский персонал (врач, ветеринар, хирург, медсестра)',
					'Manager' => 'Менеджер',
					'Capo sezione' => 'Начальник отдела',
					'Dipendente nel settore di moda o estetica' => 'Работник в сфере моды, косметики',
					'Imprenditore individuale' => 'Индивидуальный предприниматель',
					'Marinaio' => 'Моряк',
					'Ricercatore scientifico' => 'Научный работник',
					'Pensionata' => 'Пенсионер',
					'Pilota' => 'Пилот',
					'Personalita politica' => 'Политический деятель',
					'Insegnante' => 'Преподаватель, воспитатель',
					'Venditore' => 'Продавец-кассир, консультант',
					'Atleta' => 'Профессиональный спортсмен, тренер',
					'Lavoratore' => 'Рабочий',
					'Artigiano' => 'Ремесленник',
					'Dirigente d azienda' => 'Руководящий сотрудник компании',
					'Prete o Religioso' => 'Священник, представитель духовенства',
					'Agente di polizia' => 'Сотрудник полиции',
					'Militare' => 'Военнослужащий',
					'Studente' => 'Студент',
					'Apprendista' => 'Стажер',
					'Scolaro' => 'Школьник',
					'Giudice' => 'Судья',
					'Procuratore' => 'Прокурор',
					'Agricoltore' => 'Фермер',
					'Freelancer' => 'Фрилансер',
					'Chimico' => 'Химик',
					'Domestico' => 'Частный домашний работник',
					'Elettricista' => 'Электрик',
					'Professione legale' => 'Юрист (адвокат, юридический консультант)',
					'Disoccupato' => 'Без профессии',
					'Altre professioni' => 'Другие профессии',
				},
				format => 'capslock',
				first_elements => 'default_free',
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'company_text',
				label => 'Данные работодателя',
				font => 'bold',
			},
			{
				type => 'free_line',
			},
			{
				type => 'input',
				name => 'workname',
				label => 'Название',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы',
				example => 'VMS',
				check => 'WN\s\_\.\,\"\'\-\(\)\#\*',
				check_logic => [
					{
						condition => 'free_only_if_eq',
						table => 'SchengenExtData',
						name => 'Occupation',
						values => 'Freelancer; Pensionata; Disoccupato; Casalinga; Imprenditore individuale',
						error => 'Без профессии / Фрилансер / Домохозяйка / ИП',
					},
				],
				db => {
					table => 'SchengenExtData',
					name => 'JobName',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'workpostal',
				label => 'Индекс',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы',
				example => '119017',
				check => 'WN\s\-',
				check_logic => [
					{
						condition => 'free_only_if_eq',
						table => 'SchengenExtData',
						name => 'Occupation',
						values => 'Freelancer; Pensionata; Disoccupato; Casalinga; Imprenditore individuale',
						error => 'Без профессии / Фрилансер / Домохозяйка / ИП',
					},
				],
				db => {
					table => 'SchengenExtData',
					name => 'JobPostal',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'workphone',
				label => 'Телефон',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы',
				example => '79XXXXXXXXX',
				check => 'N\-',
				check_logic => [
					{
						condition => 'free_only_if_eq',
						table => 'SchengenExtData',
						name => 'Occupation',
						values => 'Freelancer; Pensionata; Disoccupato; Casalinga; Imprenditore individuale',
						error => 'Без профессии / Фрилансер / Домохозяйка / ИП',
					},
				],				
				db => {
					table => 'SchengenExtData',
					name => 'JobPhone',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'workemail',
				label => 'Email',
				comment => 'Введите адрес почты, по которому можно будет связаться с компанией',
				example => 'test@mail.com',
				check => 'WN\@\-\_\.',
				check_logic => [
					{
						condition => 'this_is_email',
					},
				],
				db => {
					table => 'SchengenExtData',
					name => 'JobEmail',
				},
				format => 'capslock'
			},
			{
				type => 'select',
				name => 'workcountry',
				label => 'Страна',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы.',
				example => 'The Russian Federation',
				check => 'N',
				check_logic => [
					{
						condition => 'free_only_if_eq',
						table => 'SchengenExtData',
						name => 'Occupation',
						values => 'Freelancer; Pensionata; Disoccupato; Casalinga; Imprenditore individuale',
						error => 'Без профессии / Фрилансер / Домохозяйка / ИП',
					},
				],
				db => {
					table => 'SchengenExtData',
					name => 'JobCountry',
				},
				param => '[citizenship_countries]',
				first_elements => '70',
			},
			{
				type => 'input',
				name => 'workcity',
				label => 'Город расположения',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы',
				example => 'Moscow',
				check => 'WN\s\_\.\,\"\'\-\(\)\#\*',
				check_logic => [
					{
						condition => 'free_only_if_eq',
						table => 'SchengenExtData',
						name => 'Occupation',
						values => 'Freelancer; Pensionata; Disoccupato; Casalinga; Imprenditore individuale',
						error => 'Без профессии / Фрилансер / Домохозяйка / ИП',
					},
				],
				db => {
					table => 'SchengenExtData',
					name => 'JobCity',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'workaddr',
				label => 'Адрес компании',
				comment => 'Данные заполняются в соответствии со справкой с места работы/учёбы',
				example => 'M.Tolmachevskiy pereulok 6 b.1',
				check => 'WN\s\_\.\,\"\'\-\(\)\#\*\/',
				check_logic => [
					{
						condition => 'free_only_if_eq',
						table => 'SchengenExtData',
						name => 'Occupation',
						values => 'Freelancer; Pensionata; Disoccupato; Casalinga; Imprenditore individuale',
						error => 'Без профессии / Фрилансер / Домохозяйка / ИП',
					},
				],
				db => {
					table => 'SchengenExtData',
					name => 'JobAddress',
				},
				format => 'capslock'
			},
		],
		
		'Уточнение по профессии' => [
			{
				page_ord => 550,
				progress => 5,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'SchengenExtData',
						name => 'Occupation',
						value => 'ALTRE PROFESSIONI',
					}
				},
				page_db_id => 500008,
			},
			{
				type => 'input',
				name => 'workdata_add',
				label => 'Профессиональная деятельность',
				comment => 'Профессию необходимо указывать на английском или итальянском языках',
				check => 'zWN\s\_\.\,\"\'\-\(\)\#\*',
				db => {
					table => 'AppData',
					name => 'ProfActivity',
				},
				format => 'capslock'
			},
		],
		
		'Информация о родителе / законном представителе' => [
			{
				page_ord => 600,
				progress => 5,
				param => 1,
				all_app_in_title => 1,
				relation => {
					only_if_younger => {
						table => 'AppData',
						name => 'BirthDate',
						value => '18',
					}
				},
				page_db_id => 500009,
			},
			{
				type => 'input',
				name => 'kindermothername',
				label => 'Имя матери',
				comment => 'Для несовершеннолетних: имя лица с полномочием родителей или законного представителя. В случае отсутствия родителя (прочерк в свидетельстве о рождении, лишение родительских прав, смерть), поставьте прочерк',
				example => 'Maria',
				check => 'zW\s\-',
				db => {
					table => 'SchengenExtData',
					name => 'MotherName',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'kindermothersurname',
				label => 'Фамилия матери',
				comment => 'Для несовершеннолетних: фамилия лица с полномочием родителей или законного представителя. В случае отсутствия родителя (прочерк в свидетельстве о рождении, лишение родительских прав, смерть), поставьте прочерк',
				example => 'Ivanova',
				check => 'zW\s\-',
				db => {
					table => 'SchengenExtData',
					name => 'MotherSurname',
				},
				format => 'capslock'
			},
			{
				type => 'select',
				name => 'motherсitizenship',
				label => 'Гражданство матери',
				comment => 'Для несовершеннолетних: гражданство родителей или законного представителя',
				example => 'The Russian Federation',
				check => 'zN',
				db => {
					table => 'SchengenExtData',
					name => 'MotherCitizenship',
				},
				param => '[citizenship_countries]',
				first_elements => '70',
			},
			{
				type => 'input',
				name => 'kinderfathername',
				label => 'Имя отца',
				comment => 'Для несовершеннолетних: имя лица с полномочием родителей или законного представителя. В случае отсутствия родителя (прочерк в свидетельстве о рождении, лишение родительских прав, смерть), поставьте прочерк',
				example => 'Ivan',
				check => 'zW\s\-',
				db => {
					table => 'SchengenExtData',
					name => 'FatherName',
				},
				format => 'capslock'
			},
			{
				type => 'input',
				name => 'kinderfathersurname',
				label => 'Фамилия отца',
				comment => 'Для несовершеннолетних: фамилия лица с полномочием родителей или законного представителя. В случае отсутствия родителя (прочерк в свидетельстве о рождении, лишение родительских прав, смерть), поставьте прочерк',
				example => 'Ivanov',
				check => 'zW\s\-',
				db => {
					table => 'SchengenExtData',
					name => 'FatherSurname',
				},
				format => 'capslock'
			},
			{
				type => 'select',
				name => 'fatherсitizenship',
				label => 'Гражданство отца',
				comment => 'Для несовершеннолетних: гражданство родителей или законного представителя',
				example => 'The Russian Federation',
				check => 'zN',
				db => {
					table => 'SchengenExtData',
					name => 'FatherCitizenship',
				},
				param => '[citizenship_countries]',
				first_elements => '70',
			},
		],
		
		'Уточнение по семейному положению' => [
			{
				page_ord => 700,
				progress => 5,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'Family',
						value => '6',
					}
				},
				page_db_id => 500010,
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
				page_ord => 800,
				progress => 5,
				all_app_in_title => 1,
				relation => {
					only_if_not => {
						table => 'AppData',
						name => 'Citizenship',
						value => '70',
					}
				},
				page_db_id => 500011,
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
		
		'Данные о поездке' => [
			{
				page_ord => 1000,
				progress => 6,
				all_app_in_title => 1,
				param => 1,
				copy_from_other_applicants => 'now',
				page_db_id => 500013,
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
		],
		
		'Дата сдачи отпечатков' => [
			{
				page_ord => 1300,
				progress => 6,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'Fingers',
						value => '1',
					}
				},
				page_db_id => 500016,
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
				label => 'Номер соответствующей визы, если известен',
				comment => 'Укажите номер соответствующей виз, если он вам известен',
				example => '123456789',
				check => 'WN',
				db => {
					table => 'AppData',
					name => 'VisaAdeviso',
				},
				format => 'capslock',
			},
		],
				
		'Расходы заявителя' => [
			{
				page_ord => 1900,
				progress => 8,
				all_app_in_title => 1,
				page_db_id => 500022,
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
				page_ord => 2000,
				progress => 8,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'MezziWhom',
						value => '2',
					}
				},
				page_db_id => 500023,
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
				page_ord => 2100,
				progress => 8,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'MezziWhom',
						value => '0',
					}
				},
				page_db_id => 500024,
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
				page_ord => 2200,
				progress => 8,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'MezziWhom',
						value => '1,2',
					}
				},
				page_db_id => 500025,
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
				page_ord => 2300,
				progress => 8,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'Mezzi7',
						value => '1',
					}
				},
				page_db_id => 500026,
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
				page_ord => 2400,
				progress => 8,
				param => 1,
				all_app_in_title => 1,
				relation => {
					only_if_not => {
						table => 'AppData',
						name => 'FamRel',
						value => '0',
					}
				},
				page_db_id => 500027,
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
				page_ord => 2500,
				progress => 9,
				all_app_in_title => 1,
				replacer => '[app_finish]',
				page_db_id => 500028,
			},
		],
		
		'Выберите лицо на которое будет оформлен договор' => [
			{
				page_ord => 2600,
				progress => 9,
				persons_in_page => 1,
				page_db_id => 500029,
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
				page_ord => 2700,
				progress => 10,
				relation => {
					only_if_not => {
						table => 'Appointments',
						name => 'PersonForAgreements',
						value => '-1',
					}
				},
				page_db_id => 500030,
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
				example => 'г.Москва',
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
				page_ord => 2800,
				progress => 10,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'PersonForAgreements',
						value => '-1',
					}
				},
				page_db_id => 500031,
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
				example => 'г.Москва',
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
				page_ord => 2900,
				progress => 11,
				persons_in_page => 1,
				goto_link => 'back_to_appdate',
				page_db_id => 500032,
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
					{
						condition => 'not_beyond_than',
						table => 'AppData',
						name => 'AppSDate',
						offset => 180,
						full_error => 'Запись в Визовый центр более чем за [offset] до дня вылета не осуществляется',
					},
					{
						condition => 'not_beyond_than',
						table => 'Appointments',
						name => 'SDate',
						offset => 180,
						full_error => 'Запись в Визовый центр более чем за [offset] до дня вылета не осуществляется',
					},
				],
				db => {
					table => 'Appointments',
					name => 'AppDate',
				},
				special => 'datepicker, mask, save_urgent_info',
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
				example => 'Москва',
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
				page_ord => 3000,
				progress => 12,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'CenterID',
						value => '1',
					}
				},
				page_db_id => 500033,
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
					1 => '<b>м.Третьяковская</b>',
					2 => '<b>м.Киевская</b>',
				},
			},
		],
		
		'Оплата консульского сбора' => [
			{
				page_ord => 3050,
				progress => 13,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'VType',
						value => '1, 2, 5, 7, 13, 14, 15',
					},
					only_if => {
						table => 'Appointments',
						name => 'CenterID',
						value => '41, 44',
					},
					only_if_citizenship => {
						value => '70, 76, 268, 16, 20', 
					}
				},
				page_db_id => 500034,
			},
			{
				type => 'text',
				name => 'concil1_text',
				label => 'Для Вашего удобства Вы можете оплатить консульский сбор онлайн на сайте АО Банк Интеза, следуя инструкциям Банка. Документ с кодом проверки платежа, отправленный Банком на указанный адрес электронной почты, необходимо распечатать и предоставить при подаче документов.', 
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'concil2_text',
				label => '<a target = "_blank" class = "dotted_link_big" href="">Для продолжения оплаты нажмите здесь</a>', 
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'concil3_text',
				label => 'Пожалуйста, ознакомьтесь со <a target = "_blank" class = "dotted_link_middle" href="/lgotnye-kategorii/">льготными категориями граждан</a>, освобождаемых от оплаты консульского сбора.', 
			},
			
		],
		
		'Подтвердить запись' => [
			{
				page_ord => 3100,
				progress => 13,
				page_db_id => 500035,
			},
			# {
			#	type => 'captcha',
			# },
		],
		
		'Запись успешно создана!' => [
			{
				page_ord => 3200,
				progress => 14,
				page_db_id => 500036,
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
			label => 'Личные данные',
			font => 'bold',
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
			type => 'input',
			name => 'brhplace',
			label => 'Место рождения',
			comment => 'Укажите место рождения латинскими буквами в соответствии с информацией в загранпаспорте, населенный пункт должен быть указан обязательно',
			example => [
				'Pushkino, Moscowskaya',
				'Moscow',
				'Belgorod, Belgorodskaya',
			],
			check => 'zWN\s\-\,\;',
			db => {
				table => 'AppData',
				name => 'BrhPlace',
			},
			format => 'capslock'
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
			example => 'VMS',
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
			label => 'Адрес места пребывания',
			comment => 'Укажите адрес гостиницы или приглашающего, или временного места пребывания',
			example => 'Rome, Via Esempio 1',
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
		#		1 => 'туризм', 
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
			label => 'Адрес места работы',
			comment => 'Укажите адрес места своей работы',
			example => '119017 Moscow, Malyi Tolmachevskiy 6 bld.1',
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
				4 => 'экономически зависимый родственник по восходящей линии',
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
