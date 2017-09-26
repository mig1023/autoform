package VCS::Site::autodata;
use strict;

sub get_progressline
# //////////////////////////////////////////////////
{
	return [ '',
		{ big => 1, name => 'Начало', },
		{ big => 0, name => 'Даты поездки', },
		{ big => 1, name => 'Заявители', },
		{ big => 0, name => 'Данные паспортов', },
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

	return {
	
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
				'comment' => 'Выберите визовый центр для подачи документов',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'CenterID',
				},
				'param' => '[centers_from_db]',
				'uniq_code' => 'onchange="update_nearest_date_free_date();"',
				'first_elements' => '1',
			},
			{
				'type' => 'select',
				'name' => 'vtype',
				'label' => 'Тип визы',
				'comment' => 'Выберите тип запрашиваемой визы',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'VType',
				},
				'param' => '[visas_from_db]',
				'first_elements' => '13',
			},
			{
				'type' => 'info',
				'name' => 'free_date',
				'label' => 'Ближайшая доступная дата',
				'special' => 'nearest_date',
			},
			{
				'type' => 'input',
				'name' => 'email',
				'label' => 'Email',
				'comment' => 'Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре',
				'example' => 'mail@mail.ru',
				'check' => 'zWN\@\-\_\.',
				'check_logic' => [
					{
						'condition' => 'email_not_blocked',
					},
				],
				'db' => {
					'table' => 'Appointments',
					'name' => 'EMail',
				},
			},
			{
				'type' => 'checkbox',
				'name' => 'pers_info',
				'label_for' => 'я согласен на обработку персональных данных',
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
				'label_for' => 'я согласен на условия работы с мобильными телефона на территории визового центра',
				'check' => 'true',
				'db' => {
					'table' => 'Appointments',
					'name' => 'MobilPermission',
					'transfer' => 'nope',
				},
				'relation' => {},
			},
		],
		
		'Даты поездки' => [
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
		
		'Список заявителей' => [
			{
				'page_ord' => 3,
				'progress' => 3,
				'replacer' => '[list_of_applicants]',
			},
		],
		
		'Данные паспортов' => [
			{
				'page_ord' => 4,
				'progress' => 4,
			},
			{
				'type' => 'text',
				'name' => 'rupass_text',
				'label' => 'Данные внутреннего паспорта',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'input',
				'name' => 'rulname',
				'label' => 'Фамилия',
				'comment' => 'Введите фамилию на русском языке так, как она указана во внутреннем паспорте',
				'example' => 'Иванов',
				'check' => 'zЁ\s\-',
				'db' => {
					'table' => 'AppData',
					'name' => 'RLName',
				},
				'format' => 'capitalized'
			},
			{
				'type' => 'input',
				'name' => 'rufname',
				'label' => 'Имя',
				'comment' => 'Введите имя на русском языке так, как оно указано во внутреннем паспорте',
				'example' => 'Иван',
				'check' => 'zЁ\s\-',
				'db' => {
					'table' => 'AppData',
					'name' => 'RFName',
				},
				'format' => 'capitalized'
			},
			{
				'type' => 'input',
				'name' => 'rumname',
				'label' => 'Отчество',
				'comment' => 'Введите отчество на русском языке так, как оно указано во внутреннем паспорте',
				'example' => 'Иванович',
				'check' => 'Ё\s\-',
				'check_logic' => [
					{
						'condition' => 'free_only_if',
						'table' => 'AppData',
						'name' => 'NoRMName',
						'error' => 'Нет отчества',
					},
				],
				'db' => {
					'table' => 'AppData',
					'name' => 'RMName',
				},
				'format' => 'capitalized'
			},
			{
				'type' => 'checkbox',
				'name' => 'no_rumname',
				'label_for' => 'нет отчества',
				'db' => {
					'table' => 'AppData',
					'name' => 'NoRMName',
					'transfer' => 'nope',
				},
				'relation' => {},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'input',
				'name' => 'birthdate',
				'label' => 'Дата рождения',
				'comment' => 'Введите дату рождения',
				'example' => '01.01.1980',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'check_logic' => [
					{
						'condition' => 'now_or_earlier',
					},
				],
				'db' => {
					'table' => 'AppData',
					'name' => 'BirthDate',
				},
				'special' => 'mask',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'text',
				'name' => 'rupass_text',
				'label' => 'Данные загранпаспорта',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'input',
				'name' => 'lname',
				'label' => 'Фамилия',
				'comment' => 'Введите фамилию на английском языке так, как она указана в загранпаспорте',
				'example' => 'Ivanov',
				'check' => 'zW\s\-',
				'db' => {
					'table' => 'AppData',
					'name' => 'LName',
				},
				'format' => 'capslock'
			},
			{
				'type' => 'input',
				'name' => 'fname',
				'label' => 'Имя',
				'comment' => 'Введите имя на английском языке так, как оно указано в загранпаспорте',
				'example' => 'Ivan',
				'check' => 'zW\s\-',
				'db' => {
					'table' => 'AppData',
					'name' => 'FName',
				},
				'format' => 'capslock'
			},
			{
				'type' => 'input',
				'name' => 'rupassnum',
				'label' => '№ загранпаспорта',
				'comment' => 'Введите серию и номер паспорта как единый набор цифр без пробелов',
				'example' => '753500001',
				'check' => 'zWN',
				'check_logic' => [
					{
						'condition' => 'unique_in_pending',
						'table' => 'Appointments',
						'name' => 'PassNum',
					},
				],
				'db' => {
					'table' => 'AppData',
					'name' => 'PassNum',
				},
			},
			{
				'type' => 'input',
				'name' => 'passdate',
				'label' => 'Дата выдачи',
				'comment' => 'Введите дату выдачи, указанную в паспорте',
				'example' => '01.01.2010',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'check_logic' => [
					{
						'condition' => 'equal_or_later',
						'table' => 'Appointments',
						'name' => 'FDate',
						'offset' => 3650,
						'error' => 'Дата начала поездки',
					},
					{
						'condition' => 'now_or_earlier',
					},
				],
				'db' => {
					'table' => 'AppData',
					'name' => 'PassDate',
				},
				'special' => 'mask',
			},
			{
				'type' => 'input',
				'name' => 'passtill',
				'label' => 'Действителен до',
				'comment' => 'Введите дату окончания действия загранпаспорта, указанную в паспорте',
				'example' => '01.01.2010',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'check_logic' => [
					{
						'condition' => 'equal_or_later',
						'table' => 'Appointments',
						'name' => 'FDate',
						'offset' => 90,
						'error' => 'Дата окончания поездки',
					},
				],
				'db' => {
					'table' => 'AppData',
					'name' => 'PassTill',
				},
				'special' => 'mask',
			},
			{
				'type' => 'input',
				'name' => 'passwhere',
				'label' => 'Выдан',
				'comment' => 'UFMS/FMS и номер подразделения',
				'example' => 'FMS 12345',
				'check' => 'zWN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'AppData',
					'name' => 'PassWhom',
				},
				'format' => 'capslock'
			},
			{
				'type' => 'input',
				'name' => 'fulladdress',
				'label' => 'Домашний адрес',
				'comment' => 'Фактический адрес проживания заявителя',
				'example' => 'Moscow, Lermontov st., 10',
				'check' => 'zWN\s\-\_\.\,\;\'\"\/',
				'db' => {
					'table' => 'AppData',
					'name' => 'FullAddress',
				},
				'format' => 'capslock'
			},
			{
				'type' => 'input',
				'name' => 'appemail',
				'label' => 'Email',
				'comment' => 'Введите существующий адрес почты, по которому можно будет связаться с заявителем',
				'example' => 'mail@mail.ru',
				'check' => 'zWN\@\s\-\.',
				'check_logic' => [
					{
						'condition' => 'email_not_blocked',
					},
				],
				'db' => {
					'table' => 'AppData',
					'name' => 'AppEMail',
				},
				'format' => 'capslock'
			},
			{
				'type' => 'input',
				'name' => 'appphone',
				'label' => 'Телефон',
				'comment' => 'Введите контактный телефон, сотовый или городской, с кодом оператора, без пробелов и разделителей',
				'example' => '79161234567',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'AppPhone',
				},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'checkbox',
				'name' => 'ischild',
				'label' => 'Если ребёнок вписан в паспорт родителей',
				'label_for' => 'вписан в паспорт',
				'db' => {
					'table' => 'AppData',
					'name' => 'isChild',
				},
				'relation' => {},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'checkbox',
				'name' => 'nres',
				'label' => 'Если заявитель не является гражданином или резидентом страны пребывания',
				'label_for' => 'не резидент',
				'db' => {
					'table' => 'AppData',
					'name' => 'NRes',
				},
				'relation' => {},
			},
		],
		
		'Дополнительные данные' => [
			{
				'page_ord' => 5,
				'progress' => 5,
				'param' => 1,
				'ussr_or_rf_first' => 1,
			},
			{
				'type' => 'text',
				'name' => 'otherpass_text',
				'label' => 'Иные данные',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'select',
				'name' => 'brhcountry',
				'label' => 'Страна рождения',
				'comment' => 'Для тех, кто родился до 1992 необходимо указывать The Soviet Union, позднее - The Russian Federation',
				'example' => 'The Soviet Union',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'BrhCountry',
				},
				'param' => '[brh_countries]',
				'first_elements' => '70, 272', # chng in init_add_param
			},
			{
				'type' => 'input',
				'name' => 'brhplace',
				'label' => 'Место рождения',
				'comment' => 'Укажите место рождения так, как оно указано в загранпаспорте, без знака /',
				'example' => 'Moscow',
				'check' => 'zWN\s\-\,\;',
				'db' => {
					'table' => 'AppData',
					'name' => 'BrhPlace',
				},
				'format' => 'capslock'
			},
			{
				'type' => 'select',
				'name' => 'сitizenship',
				'label' => 'Гражданство в настоящее время',
				'comment' => 'Если у вас два гражданства, то укажите гражданство по паспорту той страны, который подаёте на визу',
				'example' => 'The Russian Federation',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'Citizenship',
				},
				'param' => '[citizenship_countries]',
				'first_elements' => '70',
			},
			{
				'type' => 'select',
				'name' => 'prev_сitizenship',
				'label' => 'Гражданство при рождении',
				'comment' => 'Для тех, кто родился до 1992 необходимо указывать The Soviet Union, позднее - The Russian Federation',
				'example' => 'The Russian Federation',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'PrevCitizenship',
				},
				'param' => '[prevcitizenship_countries]',
				'first_elements' => '70, 272', # chng in init_add_param
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'radiolist',
				'name' => 'gender',
				'label' => 'Пол',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'Gender',
				},
				'param' => { 
					1 => 'мужской', 
					2 => 'женский', 
				},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'select',
				'name' => 'family',
				'label' => 'Семейное положение',
				'example' => 'женат/замужем',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'Family',
				},
				'param' => {
					0 => 'не указано',
					1 => 'холост/не замужем',
					2 => 'женат/замужем',
					3 => 'не проживает с супругом',
					4 => 'разведен/-а',
					5 => 'вдовец/вдова',
					6 => 'иное'
				},
			},
			{
				'type' => 'input',
				'name' => 'kinderdata',
				'label' => 'Для несовершеннолетних',
				'comment' => 'Фамилия, имя, адрес (если отличается от адреса заявителя) и гражданство лица с полномочием родителей или законного представителя',
				'example' => 'Ivanov Ivan, The Russian Federation',
				'check' => 'WN\s\n\-\,\.\;\_\\\/\'\"',
				'db' => {
					'table' => 'AppData',
					'name' => 'KinderData',
				},
				'format' => 'capslock'
			},
			{
				'type' => 'input',
				'name' => 'workdata',
				'label' => 'Профессиональная деятельность',
				'comment' => 'Если на данный момент вы не работаете, то укажите безработный/домохозяйка, для учащихся указывается студент/школьник, для пенсионеров - пенсионер',
				'example' => 'Doctor',
				'check' => 'zWN\s_\.\,\"\'\-\(\)\#\*',
				'db' => {
					'table' => 'AppData',
					'name' => 'ProfActivity',
				},
				'format' => 'capslock'
			},
			{
				'type' => 'input',
				'name' => 'workaddr',
				'label' => 'Работодатель: адрес, телефон',
				'comment' => 'Данные заполняются в соответствии со справкой с места работы',
				'example' => 'MedCenter, Moscow, ul.Lenina 1, (095) 123-4567',
				'check' => 'zWwN\s_\.\,\"\'\-\(\)\#\*',
				'db' => {
					'table' => 'AppData',
					'name' => 'WorkOrg',
				},
				'format' => 'capslock'
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'radiolist',
				'name' => 'n_rezident',
				'label' => 'Страна пребывания',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'CountryLive',
				},
				'param' => { 
					1 => 'страна гражданства', 
					2 => 'не является страной гражданства', 
				},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'radiolist',
				'name' => 'purpose',
				'label' => 'Основная цель поездки',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'VisaPurpose',
				},
				'param' => { 
					1 => 'туризм', 
					2 => 'деловая',
					3 => 'учёба',
					4 => 'официальная',
					5 => 'культура',
					6 => 'спорт',
					7 => 'транзит',
					8 => 'лечение',
					9 => 'посещение родственников',
					10 => 'иная',
				},
				'special' => 'save_info_about_hastdatatype',
			},
		],
		
		'Уточнение по семейному положению' => [
			{
				'page_ord' => 6,
				'progress' => 5,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'Family',
						'value' => '6',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'familyother',
				'label' => 'Семейное положение',
				'check' => 'zW',
				'db' => {
					'table' => 'AppData',
					'name' => 'FamilyOther',
				},
				'format' => 'capslock'
			},
		],
		
		'Уточнение по стране пребывания' => [
			{
				'page_ord' => 7,
				'progress' => 5,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'CountryLive',
						'value' => '2',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'vidno',
				'label' => 'Вид на жительство №',
				'check' => 'zN\s\-',
				'db' => {
					'table' => 'AppData',
					'name' => 'VidNo',
				},
			},
			{
				'type' => 'input',
				'name' => 'brhplace',
				'label' => 'Действителен до',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'FamilyOther',
				},
				'special' => 'mask',
			},
		],
		
		'Уточнение по цели посещения' => [
			{
				'page_ord' => 8,
				'progress' => 5,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'VisaPurpose',
						'value' => '10',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'visaother',
				'label' => 'Основная цель поездки',
				'comment' => '',
				'check' => 'zWN\s\-',
				'db' => {
					'table' => 'AppData',
					'name' => 'VisaOther',
				},
				'format' => 'capslock',
			},
		],
		
		'Данные о поездке' => [
			{
				'page_ord' => 9,
				'progress' => 6,
				'param' => 1,
			},
			{
				'type' => 'text',
				'name' => 'otherpass_text',
				'label' => 'Данные визы',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'select',
				'name' => 'nulla',
				'label' => 'Страна первого въезда',
				'comment' => 'Укажите страну первого въезда в шенгенскую зону в рамках запланированной поездки',
				'example' => 'ITALIA',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'Nulla',
				},
				'param' => '[first_countries]',
				'first_elements' => '133',
			},
			{
				'type' => 'select',
				'name' => 'visanum',
				'label' => 'Виза запрашивается для',
				'comment' => 'Виза с однократным въездом даёт возможность пересечь границу Шенгена только один раз. После того как Вы покинете зону Шенгена по данной визе, она будет закрыта и перестанет действовать. Виза с двукратным въездом позволяет въехать и покинуть зону Шенгена два раза в период действия визы. Виза с многократным въездом даёт возможность пересекать границу зоны Шенгенского соглашения в период действия визы',
				'example' => 'двукратного въезда',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'VisaNum',
				},
				'param' => {
					0 => 'однократного въезда',
					1 => 'двукратного въезда',
					2 => 'многократного въезда',
				},
			},
			{
				'type' => 'input',
				'name' => 'apps_date',
				'label' => 'Дата начала поездки',
				'comment' => 'Укажите дату начала действия запрашивамой визы',
				'example' => '01.01.2025',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'AppSDate',
				},
				'load_if_free_field' => {
					'table' => 'Appointments',
					'name' => 'SDate',
				},
				'special' => 'datepicker, mask',
			},
			{
				'type' => 'input',
				'name' => 'appf_date',
				'label' => 'Дата окончания поездки',
				'comment' => 'Укажите дату окончания действия запрашивамой визы',
				'example' => '31.12.2025',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'AppFDate',
				},
				'load_if_free_field' => {
					'table' => 'Appointments',
					'name' => 'FDate',
				},
				'special' => 'datepicker, mask',
			},
			{
				'type' => 'input',
				'name' => 'calcdur',
				'label' => 'Продолжительность пребывания',
				'comment' => {
					'1,31,2,3,4,5,6,7,8,9,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,39,40,42,44,45' =>
						'При запросе многократной визы на год необходимо указать 180 дней, при запросе визы на 2 года — 360 дней',
					'27,33,38,11,30,34,29,43,37' =>
						'Если Вы запрашиваете визу на год, укажите 180, если на два, то 180+180, на три - 180+180+180',
				},
				'example' => '14',
				'check' => 'zN+',
				'db' => {
					'table' => 'AppData',
					'name' => 'CalcDuration',
				},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'text',
				'name' => 'permi_text',
				'label' => 'Предыдущие шенгенские визы',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'radiolist',
				'name' => 'prevvisa',
				'label' => 'Были ли визы за последние три года',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'PrevVisa',
				},
				'param' => { 
					1 => 'нет', 
					2 => 'да',
				},
			},
			{
				'type' => 'radiolist',
				'name' => 'fingers',
				'label' => 'Отпечатки предоставлены за последние 5 лет',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'Fingers',
				},
				'param' => { 
					0 => 'нет', 
					1 => 'да',
				},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'text',
				'name' => 'permi_text',
				'label' => 'Родственник в ЕС',
				'font' => 'bold',
			},
			{
				'type' => 'radiolist',
				'name' => 'femrel',
				'label' => 'Степень родства',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'FamRel',
				},
				'param' => { 
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
				'page_ord' => 10,
				'progress' => 6,
				'relation' => {
					'only_if' => {
						'table' => 'Appointments',
						'name' => 'VType',
						'value' => '14',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'premesso',
				'label' => 'Кем выдано',
				'comment' => 'Укажите, есть ли разрешение на въезд в страну конечного следования, если такое разрешение необходимо',
				'example' => 'EMBASSY OF THE REPUBLIC OF BULGARIA Consular Section Moscow 552',
				'check' => 'WN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'AppData',
					'name' => 'Permesso',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'premessofd',
				'label' => 'Действительно с',
				'comment' => 'Начало действия разрешения',
				'example' => '01.01.2025',
				'check' => 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'PermessoFD',
				},
				'special' => 'mask',
			},
			{
				'type' => 'input',
				'name' => 'premessoed',
				'label' => 'Действительно по',
				'comment' => 'окончание действия разрешения',
				'example' => '31.12.2025',
				'check' => 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'PermessoED',
				},
				'special' => 'mask',
			},
		],
		
		'Сроки действия последней визы' => [
			{
				'page_ord' => 11,
				'progress' => 6,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'PrevVisa',
						'value' => '2',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'prevvisafd',
				'label' => 'Дата начала',
				'comment' => 'Укажите дату начала действия визы',
				'example' => '01.01.2016',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'PrevVisaFD',
				},
				'special' => 'mask',
			},
			{
				'type' => 'input',
				'name' => 'prevvised',
				'label' => 'Дата окончания',
				'comment' => 'Укажите дату окончания действия визы',
				'example' => '01.06.2016',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'PrevVisaED',
				},
				'special' => 'mask',
			},
		],
		
		'Дата сдачи отпечатков' => [
			{
				'page_ord' => 12,
				'progress' => 6,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'Fingers',
						'value' => '1',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'prevvisafd',
				'label' => 'Дата сдачи отпечатков, если известна',
				'comment' => 'Укажите, если помните, дату, когда сдавались отпечатки пальцев для предыдущей визы',
				'example' => '01.06.2016',
				'check' => 'D^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'FingersDate',
				},
				'special' => 'mask',
			},
		],
		
		'Проживание' => [
			{
				'page_ord' => 13,
				'progress' => 7,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'VisaPurpose',
						'value' => '1',
					}
				},
			},
			{
				'type' => 'radiolist',
				'name' => 'hostdatatype',
				'label' => 'Вариант проживания',
				'check' => 'zW',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataType',
				},
				'param' => { 
					'H' => 'гостиница/аренда/собственность', 
					'P' => 'приглашение',
				},
			},
		],
		
		'Информация о проживании' => [
			{
				'page_ord' => 14,
				'progress' => 7,
				'relation' => {
					'only_if_not' => {
						'table' => 'SchengenAppData',
						'name' => 'HostDataType',
						'value' => 'P',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'hotels',
				'label' => 'Название гостиницы или ФИО приглашающего',
				'comment' => 'Укажите полное название гостиницы и данные приглашающего лица',
				'example' => 'Grand Hotel',
				'check' => 'zW\s\-\.',
				'db' => {
					'table' => 'AppData',
					'name' => 'Hotels',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'hotelsaddr',
				'label' => 'Адрес ',
				'comment' => 'Укажите адрес гостиницы с почтовым индексом',
				'example' => 'Via Villafranca 10, Rome, 00185',
				'check' => 'zWN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'AppData',
					'name' => 'HotelAdresses',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'hotelpho',
				'label' => 'Телефон',
				'comment' => 'Укажите контактный телефон гостиницы',
				'example' => '3964440384',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'HotelPhone',
				},
			},
		],
		
		'Приглашение' => [
			{
				'page_ord' => 15,
				'progress' => 7,
				'param' => 1,
				'relation' => {
					'only_if_not' => {
						'table' => 'SchengenAppData',
						'name' => 'HostDataType',
						'value' => 'H',
					},
					'only_if' => {
						'table' => 'AppData',
						'name' => 'VisaPurpose',
						'value' => '1',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'p_name',
				'label' => 'Имя',
				'comment' => 'Укажите имя приглашающего лица',
				'example' => 'Mike',
				'check' => 'zW\s\-',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataName',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'p_last_name',
				'label' => 'Фамилия',
				'comment' => 'Укажите фамилию приглашающего лица',
				'example' => 'Bowman',
				'check' => 'zW\s\-',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataDenomination',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'p_birthdate',
				'label' => 'Дата рождения',
				'comment' => 'Укажите дату рождения приглашающего лица',
				'example' => '01.01.1970',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataDateOfBirth',
				},
				'special' => 'mask',
			},
			{
				'type' => 'select',
				'name' => 'p_province',
				'label' => 'Провинция',
				'check' => 'zWN\.\s\-',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataProvince',
				},
				'param' => '[schengen_provincies]',
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'p_city',
				'label' => 'Город',
				'comment' => 'Укажите название города',
				'example' => 'Rome',
				'check' => 'zWN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataCity',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'p_adress',
				'label' => 'Адрес',
				'comment' => 'Укажите адрес без названия города',
				'example' => 'Via Villafranca 10',
				'check' => 'zWN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataAddress',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'p_phone',
				'label' => 'Телефон',
				'comment' => 'Укажите контактный номер телефона',
				'example' => '3964440384',
				'check' => 'zN',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataPhoneNumber',
				},
			},
			{
				'type' => 'input',
				'name' => 'p_email',
				'label' => 'Email',
				'comment' => 'Укажите адрес электронной почты',
				'example' => 'mail@mail.it',
				'check' => 'zWN\@\s\-\.\,\;',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataEmail',
				},
			},
		],
	
		'Приглашение организации' => [
			{
				'page_ord' => 16,
				'progress' => 7,
				'param' => 1,
				'relation' => {
					'only_if_not' => {
						'table' => 'AppData',
						'name' => 'VisaPurpose',
						'value' => '1',
					}
				},
			},
			{
				'type' => 'select',
				'name' => 'a_province',
				'label' => 'Провинция',
				'example' => 'Rome',
				'check' => 'zWN\.\s\-',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataProvince',
				},
				'param' => '[schengen_provincies]',
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'a_city',
				'label' => 'Город',
				'comment' => 'Укажите название города',
				'example' => 'Fiumicino',
				'check' => 'zWN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataCity',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'a_company',
				'label' => 'Название приглашающей компании',
				'comment' => 'Укажите полное название организации',
				'example' => 'Microsoft Corporation',
				'check' => 'zW\s\-\.',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACompanyName',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'a_companyaddr',
				'label' => 'Адрес приглашающей компании',
				'comment' => 'Укажите адрес организации',
				'example' => 'Via Villafranca 10, Rome, 00185',
				'check' => 'zWN\s\-\,\;',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACompanyAddress',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'a_phone',
				'label' => 'Телефон компании',
				'comment' => 'Укажите контактный телефон организации',
				'example' => '3964440384',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACompanyPhone',
				},
			},
			{
				'type' => 'input',
				'name' => 'a_fax',
				'label' => 'Факс компании',
				'comment' => 'Укажите контактный факс организации',
				'example' => '3964440384',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACompanyFax',
				},
			},
			{
				'type' => 'input',
				'name' => 'a_person',
				'label' => 'ФИО, адрес, телефон, email контактного лица',
				'comment' => 'Укажите данные кантактного лица организации',
				'example' => 'Mike Bowman, Via Villafranca 10, Rome, 00185, 3964440384, mail@mail.it',
				'check' => 'zWN\@\s\-\.\,\;',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACopmanyPerson',
				},
				'format' => 'capslock',
			},
		],
		
		'Расходы заявителя' => [
			{
				'page_ord' => 17,
				'progress' => 8,
			},
			{
				'type' => 'radiolist',
				'name' => 'mezziwhom',
				'label' => 'Расходы заявителя оплачивает',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'MezziWhom',
				},
				'param' => { 
					0 => 'сам заявитель', 
					1 => 'упомянутый ранее спонсор',
					2 => 'иной спонсор',
				},
			},
		],
		
		'Уточните спонсора' => [
			{
				'page_ord' => 18,
				'progress' => 8,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'MezziWhom',
						'value' => '2',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'mezziwhomother',
				'label' => 'Спонсор',
				'check' => 'zWN\s_\.\,\"\'\-\(\)\#\*',
				'db' => {
					'table' => 'AppData',
					'name' => 'MezziWhomOther',
				},
				'format' => 'capslock',
			},
		],
		
		'Средства заявителя' => [
			{
				'page_ord' => 19,
				'progress' => 8,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'MezziWhom',
						'value' => '0',
					}
				},
			},
			{
				'type' => 'checklist',
				'name' => 'mezzi',
				'label' => 'Средства',
				'check' => 'at_least_one',
				'db' => {
					'table' => 'AppData',
					'name' => 'complex'
				},
				'param' => {
					'mezzi1' => { 'db' => 'Mezzi1', 'label_for' => 'Наличные деньги' },
					'mezzi2' => { 'db' => 'Mezzi2', 'label_for' => 'Кредитаня карточка' },
					'mezzi3' => { 'db' => 'Mezzi3', 'label_for' => 'Предоплаченный транспорт' },
					'mezzi4' => { 'db' => 'Mezzi4', 'label_for' => 'Дорожные чеки' },
					'mezzi5' => { 'db' => 'Mezzi5', 'label_for' => 'Предоплачено место проживания' },
					'mezzi6' => { 'db' => 'Mezzi6', 'label_for' => 'Иные' },
				},
			},
		],
		
		'Средства спонсора' => [
			{
				'page_ord' => 20,
				'progress' => 8,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'MezziWhom',
						'value' => '1,2',
					}
				},
			},
			{
				'type' => 'checklist',
				'name' => 'sponsor_mezzi',
				'label' => 'Средства',
				'check' => 'at_least_one',
				'db' => {
					'table' => 'AppData',
					'name' => 'complex'
				},
				'param' => {
					'mezzi1' => { 'db' => 'Mezzi1', 'label_for' => 'Наличные деньги' },
					'mezzi2' => { 'db' => 'Mezzi2', 'label_for' => 'Оплачиваются все расходы' },
					'mezzi3' => { 'db' => 'Mezzi3', 'label_for' => 'Оплачивается транспорт' },
					'mezzi5' => { 'db' => 'Mezzi4', 'label_for' => 'Оплачивается место проживания' },
					'mezzi6' => { 'db' => 'Mezzi6', 'label_for' => 'Иные' },
				},
			},
		],
		
		'Уточните иные средства' => [
			{
				'page_ord' => 21,
				'progress' => 8,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'Mezzi6',
						'value' => '1',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'whomothersrc',
				'label' => 'Иные средства',
				'comment' => 'Укажите иные средства',
				'check' => 'zWwN\s_\.\,\"\'\-\(\)\#\*',
				'db' => {
					'table' => 'AppData',
					'name' => 'MezziOtherSrc',
				},
				'format' => 'capslock',
			},
		],
				
		'Данные родственника в ЕС' => [
			{
				'page_ord' => 22,
				'progress' => 8,
				'param' => 1,
				'relation' => {
					'only_if_not' => {
						'table' => 'AppData',
						'name' => 'FamRel',
						'value' => '0',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'eu_lname',
				'label' => 'Фамилия',
				'comment' => 'Введите фамилию на английском языке так, как она указана в паспорте',
				'example' => 'Ivanov',
				'check' => 'zW\s\-',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuLName',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'eu_fname',
				'label' => 'Имя',
				'comment' => 'Введите имя на английском языке так, как оно указано в паспорте',
				'example' => 'Ivan',
				'check' => 'zW\s\-',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuFName',
				},
				'format' => 'capslock',
			},
			{
				'type' => 'input',
				'name' => 'eu_bdate',
				'label' => 'Дата рождения',
				'comment' => 'Введите дату рождения',
				'example' => '01.01.1980',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuBDate',
				},
				'special' => 'mask',
			},
			{
				'type' => 'select',
				'name' => 'eu_citizenship',
				'label' => 'Гражданство',
				'comment' => 'Укажите гражданство родственника',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuCitizen',
				},
				'param' => '[eu_countries]',
				'first_elements' => '133',
			},
			{
				'type' => 'input',
				'name' => 'eu_idnum',
				'label' => 'Номер паспорта',
				'comment' => 'Введите серию и номер паспорта как единый набор цифр и букв без пробелов',
				'example' => '753500001',
				'check' => 'zWN',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuPassNum',
				},
				'format' => 'capslock',
			},
		],
		
		'Вы успешно добавили заявителя. Что теперь?' => [	
			{
				'page_ord' => 23,
				'progress' => 9,
				'replacer' => '[app_finish]',
			},
		],
		
		'Выберите лицо на которое будет оформлен договор' => [
			{
				'page_ord' => 24,
				'progress' => 10,
				'persons_in_page' => 1,
			},
			{
				'type' => 'select',
				'name' => 'visa_text',
				'label' => 'Выберите на кого оформляется',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'PersonForAgreements',
					'transfer' => 'nope',
				},
				'param' => '[persons_in_app]',
			},
		],
		
		'Укажите данные для договора' => [
			{
				'page_ord' => 25,
				'progress' => 11,
				'relation' => {
					'only_if_not' => {
						'table' => 'Appointments',
						'name' => 'PersonForAgreements',
						'value' => '0',
					}
				},
			},

			{
				'type' => 'info',
				'name' => 'info_rulname',
				'label' => 'Фамилия',
				'db' => {
					'table' => 'AppData',
					'name' => 'RLName',
				},
			},
			{
				'type' => 'info',
				'name' => 'info_rufname',
				'label' => 'Имя',
				'db' => {
					'table' => 'AppData',
					'name' => 'RFName',
				},
			},
			{
				'type' => 'info',
				'name' => 'info_rumname',
				'label' => 'Отчество',
				'db' => {
					'table' => 'AppData',
					'name' => 'RMName',
				},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'input',
				'name' => 'info_passnum',
				'label' => '№ паспорта',
				'comment' => 'Введите серию и номер паспорта как единый набор цифр без пробелов',
				'example' => '754300001',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'RPassNum',
				},
			},
			{
				'type' => 'input',
				'name' => 'info_passdate',
				'label' => 'Дата выдачи',
				'comment' => 'Введите дату выдачи, указанную в паспорте',
				'example' => '01.01.2010',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'check_logic' => [
					{
						'condition' => 'now_or_earlier',
					},
				],
				'db' => {
					'table' => 'AppData',
					'name' => 'RPWhen',
				},
				'special' => 'mask',
			},
			{
				'type' => 'input',
				'name' => 'info_rupasswhere',
				'label' => 'Кем выдан',
				'comment' => 'Укажите полное название выдавшей организации, так, как она указана в паспорте',
				'example' => 'ОВД по району Беговой города Москвы',
				'check' => 'zЁN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'AppData',
					'name' => 'RPWhere',
				},
			},
			{
				'type' => 'input',
				'name' => 'info_address',
				'label' => 'Адрес',
				'comment' => 'Полный адрес, включая индекс',
				'example' => '105203, г.Москва, ул.Ленина, д.1, кв.1',
				'check' => 'zЁN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'AppData',
					'name' => 'RAddress',
					'transfer' => 'nope',
				},
			},
			{
				'type' => 'info',
				'name' => 'info_phone',
				'label' => 'Телефон',
				'db' => {
					'table' => 'AppData',
					'name' => 'AppPhone',
				},
			},
		],
		
		'Укажите данные доверенного лица' => [
			{
				'page_ord' => 26,
				'progress' => 11,
				'relation' => {
					'only_if' => {
						'table' => 'Appointments',
						'name' => 'PersonForAgreements',
						'value' => '0',
					}
				},
			},
			{
				'type' => 'input',
				'name' => 'dovlname',
				'label' => 'Фамилия',
				'comment' => 'Введите фамилию на русском языке так, как она указана во внутреннем паспорте',
				'example' => 'Иванов',
				'check' => 'zЁ\s\-',
				'db' => {
					'table' => 'Appointments',
					'name' => 'LName',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovfname',
				'label' => 'Имя',
				'comment' => 'Введите имя на русском языке так, как оно указана во внутреннем паспорте',
				'example' => 'Иван',
				'check' => 'zЁ\s\-',
				'db' => {
					'table' => 'Appointments',
					'name' => 'FName',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovmname',
				'label' => 'Отчество',
				'comment' => 'Введите отчество на русском языке так, как оно указана во внутреннем паспорте',
				'example' => 'Иванович',
				'check' => 'zЁ\s\-',
				'db' => {
					'table' => 'Appointments',
					'name' => 'MName',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovpassnum',
				'label' => '№ паспорта',
				'comment' => 'Введите серию и номер паспорта как единый набор цифр без пробелов',
				'example' => '754300001',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'PassNum',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovpassdate',
				'label' => 'Дата выдачи',
				'comment' => 'Введите дату выдачи, указанную в паспорте',
				'example' => '01.01.2010',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'check_logic' => [
					{
						'condition' => 'now_or_earlier',
					},
				],
				'db' => {
					'table' => 'Appointments',
					'name' => 'PassDate',
				},
				'special' => 'mask',
			},
			{
				'type' => 'input',
				'name' => 'dovpasswhere',
				'label' => 'Кем выдан',
				'comment' => 'Укажите полное название выдавшей организации, так, как она указана в паспорте',
				'example' => 'ОВД по району Беговой города Москвы',
				'check' => 'zЁN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'Appointments',
					'name' => 'PassWhom',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovphone',
				'label' => 'Телефон',
				'comment' => 'Введите контактный телефон, сотовый или городской, с кодом оператора, без пробелов и разделителей',
				'example' => '79161234567',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'Phone',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovaddress',
				'label' => 'Адрес',
				'comment' => 'Полный адрес, включая индекс',
				'example' => '105203, г.Москва, ул.Ленина, д.1, кв.1',
				'check' => 'zЁN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'Appointments',
					'name' => 'Address',
				},
			},
		],
		
		'Оформление записи' => [
			{
				'page_ord' => 27,
				'progress' => 12,
				'persons_in_page' => 1,
			},
			{
				'type' => 'text',
				'name' => 'appdate_text',
				'label' => 'Дата записи',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'input',
				'name' => 'app_date',
				'label' => 'Дата записи в Визовый центр',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'Appointments',
					'name' => 'AppDate',
				},
				'special' => 'datepicker, mask',
				'uniq_code' => 'onchange="update_timeslots(1);"',
			},
			{
				'type' => 'select',
				'name' => 'timeslot',
				'label' => 'Время',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'TimeslotID',
				},
				'param' => '[free]',
				'special' => 'timeslots',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'text',
				'name' => 'services_text',
				'label' => 'СМС-оповещение о готовности документов (платная услуга)',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'input',
				'name' => 'sms',
				'label' => 'SMS уведомление',
				'comment' => 'Введите номер сотового телефона для получения СМС о готовности документов; услуга платная, оставьте поле пустым, если в ней нет необходимости',
				'example' => '79051234578',
				'check' => 'N',
				'db' => {
					'table' => 'Appointments',
					'name' => 'Mobile',
				},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'text',
				'name' => 'services_text',
				'label' => 'Доставка документов DHL (платная услуга)',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'input',
				'name' => 'ship_index',
				'label' => 'Индекс доставки',
				'comment' => 'Введите первые цифры индекса или первые первые буквы города для доставки документов документов; выберите из списка подходящий индекс и город; услуга платная, оставьте поле пустым, если в ней нет необходимости',
				'example' => '101000, Москва',
				'check' => 'ЁN\s\,\.\-\(\)',
				'check_logic' => [
					{
						'condition' => 'free_only_if_not',
						'table' => 'Appointments',
						'name' => 'ShAddress',
						'error' => 'Адрес доставки',
					},
					{
						'condition' => 'existing_postcode',
					}
				],
				'db' => {
					'table' => 'Appointments',
					'name' => 'ShIndex',
				},
				'special' => 'post_index',
			},
			{
				'type' => 'input',
				'name' => 'shipping',
				'label' => 'Адрес доставки',
				'comment' => 'Введите адрес для доставки документов документов, без указания индекса и города; услуга платная, оставьте поле пустым, если в ней нет необходимости',
				'example' => 'ул.Ленина, 1',
				'check' => 'ЁN\s\-\_\.\,\;\'\"',
				'check_logic' => [
					{
						'condition' => 'free_only_if_not',
						'table' => 'Appointments',
						'name' => 'ShIndex',
						'error' => 'Индекс доставки',
					},
				],
				'db' => {
					'table' => 'Appointments',
					'name' => 'ShAddress',
				},
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'text',
				'name' => 'insurance_text',
				'label' => 'Страховка (платная услуга)',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'checklist_insurer',
				'name' => 'insurance',
				'label' => 'Включить заявителей в полис',
				'check' => 'N',
				'db' => {
					'table' => 'Token',
					'name' => 'Insurance',
					'transfer' => 'nope',
					},
				'param' => '[persons_in_app_for_insurance]',
				'special' => 'insurer_many_id',
			},
			{
				'type' => 'input',
				'name' => 'ins_days',
				'label' => 'Количество дней страховки',
				'comment' => 'Укажите количество дней, на которые необходима страховка; услуга платная, оставьте поле пустым, если в ней нет необходимости',
				'example' => '14',
				'check' => 'N',
				'db' => {
					'table' => 'Appointments',
					'name' => 'Duration',
				},
			},
		],
		
		'Предпочтительный офис выдачи документов' => [
			{
				'page_ord' => 28,
				'progress' => 13,
				'relation' => {
					'only_if' => {
						'table' => 'Appointments',
						'name' => 'CenterID',
						'value' => '1',
					}
				},
				
			},
			{
				'type' => 'radiolist',
				'name' => 'mezziwhom',
				'label' => 'Выберите офис выдачи документов',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'OfficeToReceive',
				},
				'param' => { 
					0 => 'Малый Толмачёвский, д.6 стр.1',
					39 => 'ул. Киевская, вл. 2, 3 этаж',
				},
			},
		],
		
		'Подтверждение записи' => [
			{
				'page_ord' => 29,
				'progress' => 14,
			},
			{
				'type' => 'captcha',
			},
		],
		
		'Поздравляем!' => [
			{
				'page_ord' => 30,
				'progress' => 15,
			},
			{
				'type' => 'text',
				'name' => 'visa_text',
				'label' => 'Всё, запись создана!',
			},
			{
				'type' => 'text',
				'name' => 'conf_mail_text',
				'label' => 'На вашу почту отправлено письмо с подтверждением записи.',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'info',
				'name' => 'new_app_num',
				'label' => 'Номер записи',
			},
			{
				'type' => 'info',
				'name' => 'new_app_branch',
				'label' => 'Визовый центр',
				'db' => {
					'table' => 'Appointments',
					'name' => 'CenterID',
				},
				'special' => 'with_map',
			},
			{
				'type' => 'info',
				'name' => 'new_app_timedate',
				'label' => 'Дата',
				'db' => {
					'table' => 'Appointments',
					'name' => 'AppDate',
				},
			},
			{
				'type' => 'info',
				'name' => 'new_app_timeslot',
				'label' => 'Время записи',
				'db' => {
					'table' => 'Appointments',
					'name' => 'TimeslotID',
				},
			},
		],
	};
}

sub get_settings
# //////////////////////////////////////////////////
{
	return {
		'general' => {
			'max_applicants' => 10,
		},
	
		'paths' => {
			'addr' => '/autoform/',
			'addr_vcs' => '/vcs/',
		},
		
		'age' => {
			'age_for_agreements' => 18,
		},
		
		'memcached' => {
			'memcached_exptime' => 43200, # 12*3600 sec
		},
		
		'captcha' => {
			'public_key' => '',
			'private_key' => '',
			'widget_api' => 'https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit',
			'verify_api' => 'https://www.google.com/recaptcha/api/siteverify',
		},
		
		'confirm' => {
			'tt' => '/usr/local/VMS/www/htdocs/vcs/templates/autoform/autoform_confirm.tt2',
			'pers_data' => '/usr/local/www/data/htdocs/pers_data_agreement.docx',
			'link_image' => '',
			'link_site' =>  '',
			'html_website' => '',
			'html_email' => '',
			'spb_html_website' => '',
			'spb_html_email' => '',
		}
	};
}

sub get_html_elements
# //////////////////////////////////////////////////
{
	return { 
		'start_line'		=> '<tr [u]>',
		'end_line'		=> '</tr>',
		'start_cell'		=> '<td [u]>',
		'end_cell'		=> '</td>',
		
		'input' 		=> '<input class="input_width input_gen" type="text" value="[value]" name="[name]"'.
					' id="[name]" title="[comment]" [u]>',
		'checkbox' 		=> '<input type="checkbox" value="[name]" name="[name]" id="[name]" [checked] [u]>',
		'select'		=> '<select class="input_width select_gen" size = "1" ' .
					'name="[name]" title="[comment]" id="[name]" [u]>[options]</select>',
		'radiolist'		=> '<div id="[name]">[options]</div>',
		'text'			=> '<td colspan="3" [u]>[value]</td>',
		'example'		=> '<tr class="mobil_hide" [u]><td class="exam_td_gen">' .
					'<span class="exam_span_gen">[example]: [value]</span></td>',

		'info'			=> '<label class="info" id="[name]" [u]>[text]</label>',
		'checklist'		=> '<div id="[name]">[options]</div>',
		'checklist_insurer'	=> '[options]',
		'captcha'		=> '<script type="text/javascript">var onloadCallback = function(){grecaptcha.render(' .
					"'[captch_id]'" . ', [json_options]);};</script><script src="[widget_api]" ' .
					'type="text/javascript"></script><div id="captha_div"><div id="[captch_id]"></div></div>',
		
		'label'			=> '<label id="[name]" [u]>[value]</label>',
		'label_for'		=> '<label for="[name]" [u]>[value]</label>',
		
		'progress'		=> '<td align="center" class="pr_size_gen pr_[file]_gen"><div class="[format]" ' .
					'title="[title]"><div class="pr_in_gen">[name]</div></div></td>',
					
		'stages'		=> '<td class="stage_gen">[progress_stage]</td>',
		'free_line'		=> '<tr class="mobil_hide"><td colspan="3">&nbsp;</td></tr>',
	};
}

sub get_tables_controled_by_AutoToken
# //////////////////////////////////////////////////
{
	return {
		'AutoAppointments' => 'AutoAppID',
		'AutoAppData' => 'AutoAppDataID',
		'AutoSchengenAppData' => 'AutoSchengenAppDataID',
	};
}

sub get_geo_branches
# //////////////////////////////////////////////////
{
	return {
		1 => [ '55.7420115', '37.6184734', ],
		2 => [ '53.191534', '50.095994', ],
		3 => [ '45.01503599999999', '38.97375699999998', ],
		4 => [ '56.8318046', '60.615513700000065', ],
		5 => [ '55.782051', '49.129489000000035', ],
		6 => [ '54.7178522', '20.497306900000012', ],
		7 => [ '52.5968568', '39.56752210000002', ],
		8 => [ '56.323534', '44.02221499999996', ],
		9 => [ '55.0243972', '82.92012199999999', ],
		11 => [ '59.9340869', '30.3207489', ],
		12 => [ '54.7286619', '55.94788270000004', ],
		13 => [ '54.9717809', '73.40270800000008', ],
		14 => [ '44.2243358', '43.08334519999994', ],
		15 => [ '55.1661983', '61.40640499999995', ],
		16 => [ '45.0043149', '41.92712489999997', ],
		17 => [ '51.67589', '39.21556199999998', ],
		18 => [ '54.3209128', '48.400032099999976', ],
		19 => [ '47.219554', '39.71273700000006', ],
		20 => [ '48.7000669', '44.5056527', ],
		21 => [ '52.2869115', '104.28770970000005', ],
		22 => [ '56.4797551', '84.9485994', ],
		23 => [ '43.1129553', '131.9111166', ],
		24 => [ '56.01107099999999', '92.85671100000002', ],
		25 => [ '58.0135019', '56.23937339999998', ],
		26 => [ '50.594371', '36.59324800000002', ],
		27 => [ '64.5346717', '40.5237803', ],
		33 => [ '61.7903448', '34.3707563', ],
		38 => [ '57.816866', '28.3087423', ],
		42 => [ '43.315049', '45.697579', ],
	};
};

sub get_blocked_emails
# //////////////////////////////////////////////////
{
	return [
		{
			'for_centers' => [ 1 ],
			'show_truth' => 0,
			'emails' => [
				'blocked_mail@mail.com',
			],
		},
	];
};

sub get_appointment_text
# //////////////////////////////////////////////////
{
	return {
		'subject' => {
			'ru' => 'Вы зарегистрированы для подачи документов на визу', 
			'en' => 'Вы зарегистрированы для подачи документов на визу', 
			'it' => 'Вы зарегистрированы для подачи документов на визу', 
		},
	
		'months' => {
			'ru' => 'января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря',
			'en' => 'January|February|March|April|May|June|July|August|September|October|November|December',
			'it' => 'Gennaio|Febbraio|Marzo|Aprile|Maggio|Giugno|Luglio|Agosto|Settembre|Ottobre|Novembre|Dicembre',
		},
		
		'pers' => {
			'ru' => 'лично',
			'en' => 'in person',
			'it' => 'di persona',
		},
	
		'by_the_doc' => {
			'ru' => 'по доверенности на имя',
			'en' => 'with the Power of attorney',
			'it' => 'da un delegato',
		},
		
		'app_tx' => {
			'ru' => 'Запись в визовый центр.',
			'en' => 'Application appointment.',
			'it' => 'Registrazione dell`apuntamento.',
		},
		
		'date_tx' => {
			'ru' => 'Дата и время записи:',
			'en' => 'Appointment date and time:',
			'it' => 'Data e ora dell`appuntamento:',
		},
		
		'num_tx' => {
			'ru' => 'Номер записи:',
			'en' => 'Appointment number:',
			'it' => 'Numero dell`appuntamento:',
		},
		
		'doc_tx' => {
			'ru' => 'Документы подаются:',
			'en' => 'The documents are submited:',
			'it' => 'I documenti saranno consegnati:',
		},
		
		'list_tx' => {
			'ru' => 'Список заявителей:',
			'en' => 'List of application appointments:',
			'it' => 'Lista degli appuntamenti:',
		},
		
		'vms_tx' => {
			'ru' => 'С уважением, VMS',
			'en' => 'Kind regards, VMS',
			'it' => 'Cordiali saluti, VMS',
		},
		
		'dis_head' => {
			'ru' => 'Отказ от ответственности',
			'en' => 'Disclaimer',
			'it' => 'Disclaimer',
		},
		
		'dis_tx' => {
			'ru' => 'Информация в этом сообщении предназначена исключительно для конкретных лиц, которым она адресована. В сообщении может содержаться конфиденциальная информация, которая не может быть раскрыта или использована кем-либо кроме адресатов. Если вы не адресат этого сообщения, то использование, переадресация, копирование или распространение содержания сообщения или его части незаконно и запрещено. Если Вы получили это сообщение ошибочно, пожалуйста, незамедлительно сообщите отправителю об этом и удалите со всем содержимым само сообщение и любые возможные его копии и приложения.',
			'en' => 'The information contained in this message is intended solely for the use of the individual or entity to whom it is addressed . It may contain confidential or legally privileged information. The contents may not be disclosed or used by anyone other than the addressee. If you are not the intended recipient(s), any use, disclosure, copying, distribution or any action taken or omitted to be taken in reliance on it is prohibited and may be unlawful. If you have received this message in error please notify us immediately by responding to this email and then delete the e-mail and all attachments and any copies thereof.',
			'it' => 'Le informazioni contenute in questo messaggio di posta elettronica sono di carattere privato e confidenziale ed esclusivamente rivolte al destinatario sopra indicato. Nel caso aveste ricevuto questo messaggio di posta elettronica per errore, vi comunichiamo che ai sensi di Legge e vietato l`uso, la diffusione, distribuzione o riproduzione da parte di ogni altra persona. Siete pregati di segnalarlo immediatamente, rispondendo al mittente e distruggere quanto ricevuto (compresi i file allegati) senza farne copia o leggerne il contenuto.',
		},
		
		'info_btn' => {
			'ru' => 'Информация о записи',
			'en' => 'Appointment details',
			'it' => 'Informazioni sull`appuntamento',
		},
		
		'resh_btn' => {
			'ru' => 'Изменить время записи',
			'en' => 'Reschedule appointment',
			'it' => 'Cambiare l`appuntamento',
		},
		
		'canc_btn' => {
			'ru' => 'Отменить запись',
			'en' => 'Cancel an appointment',
			'it' => 'Cancellare un appuntamento',
		},
		
		'prnt_btn' => {
			'ru' => 'Распечатать запись',
			'en' => 'Print  confirmation',
			'it' => 'Stampa la conferma',
		},
		
		'branch_tx' => {
			'ru' => 'Визовый центр Италии',
			'en' => 'Italian visa center',
			'it' => 'Centro visti per l`Italia',
		},
	};
};

1;