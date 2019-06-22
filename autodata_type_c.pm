package VCS::Site::autodata_type_c;
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
		{ big => 0, name => 'Добавление нового заявителя', },
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
				comment => 'Укажите количество заявителей',
				example => '1',
				check => 'zN',
				uniq_code => 'onkeyup="update_nearest_date_free_date(1);"',
				check_logic => [
					{
						condition => 'less_than',
						offset => '10',
					},
				],
				db => {
					table => 'Appointments',
					name => 'NCount',
				},
			},
			{
				type => 'info',
				name => 'free_date',
				label => 'Ближайшая доступная дата',
				special => 'nearest_date',
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
				comment => 'Обратите внимание, что адрес электронной почты необходимо вводить вручную, не копируя его из предыдущего поля. Это поможет Вам избежать ошибки и возможной отправки подтверждения Вашей записи не тому адресату.',
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
			{
				type => 'include',
				place => 'out',
				template => 'vip_form.tt2',
			},
		],
		
		'Обращаем Ваше внимание' => [
			{
				page_ord => 140,
				progress => 2,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'CenterID',
						value => '3, 6, 14',
					}
				},
			},
			{
				type => 'text',
				name => 'booking_warning',
				label => 'Заявителям, запрашивающим шенгенскую визу впервые, необходимо предоставить предоплаченное/полностью оплаченное подтверждение проживания.',
			},
		],
		
		'Услуга Primetime' => [
			{
				page_ord => 150,
				progress => 2,
				primetime_price => 1,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'CenterID',
						value => '41',
					}
				},
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
				db => {
					table => 'Appointments',
					name => 'PrimetimeAlert',
				},
			},
		],
		
		'Даты поездки' => [
			{
				page_ord => 200,
				progress => 2,
				collect_date => 1,
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
				all_app_in_title => 1,
				goto_link => 'back_to_appdata',
				replacer => '[list_of_applicants]',
			},
		],
		
		'Данные паспортов' => [
			{
				page_ord => 400,
				progress => 4,
				all_app_in_title => 1,
				param => 1,
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
				example => 'Иванов',
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
				example => 'Иван',
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
				example => 'Иванович',
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
				name => 'rupass_text',
				label => 'Данные загранпаспорта',
				font => 'bold',
			},
			{
				type => 'biometric_data',
				comment => 'сканировать данные<br>биометрического паспорта',
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
				],
				db => {
					table => 'AppData',
					name => 'PassNum',
				},
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
				type => 'input',
				name => 'passwhere',
				label => 'Кем выдан',
				comment => 'Укажите латинскими буквами орган, выдавший паспорт, в соответствии с информацией в загранпаспорте',
				example => 'FMS 12345',
				check => 'zWN\s\-\_\.\,\;\'\"\/',
				complete_check => 'not_empty',
				db => {
					table => 'AppData',
					name => 'PassWhom',
				},
				format => 'capslock'
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
					6 => 'иное'
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
					'Giudice' => 'Прокурор',
					'Procuratore' => 'Судья',
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
				check => 'N\s\-',
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
				example => 'info@italyvms.ru',
				check => 'WN\@\-\_\.',
				check_logic => [
					{
						condition => 'free_only_if_eq',
						table => 'SchengenExtData',
						name => 'Occupation',
						values => 'Freelancer; Pensionata; Disoccupato; Casalinga; Imprenditore individuale; Studente, apprendista, scolaro',
						error => 'Без профессии / Фрилансер / Домохозяйка / ИП',
					},
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
					name => 'JobAddress',
				},
				format => 'capslock'
			},
			{
				type => 'free_line',
			},
			{
				type => 'text',
				name => 'purpose_text',
				label => 'Цель поездки',
				font => 'bold',
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
				copy_from_other_applicants => 'now',
				
				relation => {
					only_if_younger => {
						table => 'AppData',
						name => 'BirthDate',
						value => '18',
					}
				},
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
				page_ord => 900,
				progress => 5,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '10',
					}
				},
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
				page_ord => 1000,
				progress => 6,
				all_app_in_title => 1,
				param => 1,
				
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
				param => '[first_countries]',
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
				load_if_free_field => {
					table => 'Appointments',
					name => 'FDate',
				},
				special => 'datepicker, mask',
				minimal_date => 'apps_date',
			},
			{
				type => 'input',
				name => 'calcdur',
				label => 'Продолжительность пребывания',
				comment => {
					'1,31,2,3,4,5,6,7,8,9,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,39,40,42,44,45' =>
						'При запросе многократной визы на год необходимо указать 180 дней, при запросе визы на 2 года — 360 дней',
					'27,33,38,11,30,34,29,43,37' =>
						'Если Вы запрашиваете визу на год, укажите 180, если на два, то 180+180, на три - 180+180+180',
				},
				example => '14',
				check => 'zWN\s\+',
				db => {
					table => 'AppData',
					name => 'CalcDuration',
				},
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
				name => 'prevvisa',
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
				page_ord => 1100,
				progress => 6,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '7',
					}
				},
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
				check => 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
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
				check => 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				db => {
					table => 'AppData',
					name => 'PermessoED',
				},
				special => 'mask',
			},
		],
		
		'Сроки действия последней визы' => [
			{
				page_ord => 1200,
				progress => 6,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'PrevVisa',
						value => '2',
					}
				},
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
			},
			{
				type => 'input',
				name => 'prevvisafd',
				label => 'Дата сдачи отпечатков, если известна',
				comment => 'Укажите, если помните, дату, когда сдавались отпечатки пальцев для предыдущей визы',
				example => '31.12.1900',
				check => 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
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
		],
		
		'Проживание' => [
			{
				page_ord => 1400,
				progress => 7,
				all_app_in_title => 1,
				relation => {
					only_if => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '1',
					}
				},
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
				page_ord => 1500,
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
			},
			{
				type => 'input',
				name => 'hotels',
				label => 'Название гостиницы или ФИО приглашающего',
				comment => 'Укажите полное название гостиницы и данные приглашающего лица. Укажите только одно место проживания, в котором планируете провести большее количество дней, при равном количестве дней - укажите первое.',
				example => 'VMS',
				check => 'zW\s\-\.',
				db => {
					table => 'AppData',
					name => 'Hotels',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotelcity',
				label => 'Город места пребывания',
				comment => 'Укажите город, в котором расположена гостиница',
				example => 'Rome',
				check => 'zWN\s\-\_\.\,\;\'\"\@',
				db => {
					table => 'SchengenExtData',
					name => 'HotelCity',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hoteladdr',
				label => 'Адрес места пребывания',
				comment => 'Укажите адрес гостиницы',
				example => 'Via Esempio 1',
				check => 'zWN\s\-\_\.\,\;\'\"\@',
				db => {
					table => 'SchengenExtData',
					name => 'HotelAddress',
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
				check => 'zN',
				db => {
					table => 'AppData',
					name => 'HotelPhone',
				},
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotelmail',
				label => 'Email',
				comment => 'Введите адрес почты, по которому можно будет связаться с гостиницей',
				example => 'info@italyvms.ru',
				check => 'WN\@\-\_\.',
				check_logic => [
					{
						condition => 'this_is_email',
					},
				],
				db => {
					table => 'SchengenExtData',
					name => 'HotelEmail',
				},
				format => 'capslock'
			},
		],
		
		'Информация о месте проживания' => [
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
					only_if => {
						table => 'AppData',
						name => 'VisaPurpose',
						value => '7',
					}
				},
			},
			{
				type => 'input',
				name => 'hotels_tr',
				label => 'Название гостиницы или ФИО приглашающего',
				comment => 'Укажите полное название гостиницы и данные приглашающего лица',
				example => 'VMS',
				check => 'W\s\-\.',
				db => {
					table => 'AppData',
					name => 'Hotels',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotelcity_tr',
				label => 'Город места пребывания',
				comment => 'Укажите город, в котором расположена гостиница',
				example => 'Rome',
				check => 'WN\s\-\_\.\,\;\'\"\@',
				db => {
					table => 'SchengenExtData',
					name => 'HotelCity',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hoteladdr_tr',
				label => 'Адрес места пребывания',
				comment => 'Укажите адрес гостиницы',
				example => 'Via Esempio 1',
				check => 'WN\s\-\_\.\,\;\'\"\@',
				db => {
					table => 'SchengenExtData',
					name => 'HotelAddress',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'hotelpho_tr',
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
				page_ord => 1700,
				progress => 7,
				param => 1,
				all_app_in_title => 1,
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
				check => 'zWN\s\-\_\.\,\;\'\"\@',
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
				example => 'info@italyvms.ru',
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
				page_ord => 1800,
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
				name => 'a_name',
				label => 'Имя приглашающего',
				comment => 'Укажите имя контактного лица приглашающей организации',
				example => 'Ivan',
				check => 'zW\s\-',
				db => {
					table => 'SchengenExtData',
					name => 'InvitName',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'a_surname',
				label => 'Фамилия приглашающего',
				comment => 'Укажите фамилию контактного лица приглашающей организации',
				example => 'Ivanov',
				check => 'zW\s\-',
				db => {
					table => 'SchengenExtData',
					name => 'InvitSurname',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'birthdate',
				label => 'Дата рождения',
				comment => 'Введите дату рождения кантактного лица приглашающей организации',
				example => '31.12.1900',
				check => $standart_date_check,
				check_logic => [
					{
						condition => 'now_or_earlier',
					},
				],
				db => {
					table => 'SchengenExtData',
					name => 'InvitBthDate',
				},
				special => 'mask, copy_from_other_applicants',
			},
			{
				type => 'input',
				name => 'p_email',
				label => 'Email',
				comment => 'Укажите адрес электронной почты',
				example => 'info@italyvms.ru',
				check => 'zWN\@\s\-\_\.',
				check_logic => [
					{
						condition => 'this_is_email',
					},
				],
				db => {
					table => 'SchengenExtData',
					name => 'InvitEmail',
				},
				format => 'capslock',
				special => 'copy_from_other_applicants',
			},
			
		],
		
		'Расходы заявителя' => [
			{
				page_ord => 1900,
				progress => 8,
				all_app_in_title => 1,
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
			},
		],
		
		'Выберите лицо на которое будет оформлен договор' => [
			{
				page_ord => 2600,
				progress => 10,
				persons_in_page => 1,
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
				progress => 11,
				relation => {
					only_if_not => {
						table => 'Appointments',
						name => 'PersonForAgreements',
						value => '-1',
					}
				},
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
				page_ord => 2800,
				progress => 11,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'PersonForAgreements',
						value => '-1',
					}
				},
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
				page_ord => 2900,
				progress => 12,
				persons_in_page => 1,
				goto_link => 'back_to_appdate',
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
						condition => 'equal_or_later',
						table => 'Appointments',
						name => 'SDate',
						offset => -90,
						full_error => 'Запись в Визовый центр более чем за [offset] до начала поездки не осуществляется',
					},
					{
						condition => 'now_or_earlier',
						offset => 90,
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
				page_ord => 3000,
				progress => 13,
				relation => {
					only_if => {
						table => 'Appointments',
						name => 'CenterID',
						value => '1',
					}
				},
				
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
				page_ord => 3100,
				progress => 14,
			},
			{
				type => 'captcha',
			},
		],
		
		'Запись успешно создана!' => [
			{
				page_ord => 3200,
				progress => 15,
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