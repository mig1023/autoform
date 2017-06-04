package VCS::Site::autodata;
use strict;

sub get_tables_controled_by_AutoToken
# //////////////////////////////////////////////////
{
	my $tables_controled_by_AutoToken = {
		'AutoAppointments' => 'AutoAppID',
		'AutoAppData' => 'AutoAppDataID',
		'AutoSchengenAppData' => 'AutoSchengenAppDataID',
	};
	
	return $tables_controled_by_AutoToken;
}

sub get_progressline
# //////////////////////////////////////////////////
{
	my $progress_line = [ '',
		'Начало',
		'Заявители',
		'Оформление',
		'Готово!',
	];
	
	return $progress_line;
}

sub get_content_rules_hash
# //////////////////////////////////////////////////
{

	my $content_rules = {
	
		'Начало записи' => [
			{
				'page_ord' => 1,
				'progress' => 1,
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
				'db' => {},
				'special' => 'nearest_date',
			},
			{
				'type' => 'input',
				'name' => 'email',
				'label' => 'Email',
				'comment' => 'Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре',
				'example' => 'mail@mail.ru',
				'check' => 'z',
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
				'label_for' => 'я согласен на условия работы с мобильными',
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
				'progress' => 1,
			},
			{
				'type' => 'input',
				'name' => 's_date',
				'label' => 'Дата начала поездки',
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'Appointments',
					'name' => 'SDate',
				},
				'special' => 'datepicker',
			},
			{
				'type' => 'input',
				'name' => 'f_date',
				'label' => 'Дата окончания поездки',
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'Appointments',
					'name' => 'FDate',
				},
				'special' => 'datepicker',
			},
		],
		
		'Список заявителей' => [
			{
				'page_ord' => 3,
				'progress' => 2,
				'replacer' => '[list_of_applicants]',
			},
		],
		
		'Данные внутреннего паспорта' => [
			{
				'page_ord' => 4,
				'progress' => 2,
			},
			{
				'type' => 'input',
				'name' => 'rulname',
				'label' => 'Фамилия',
				'comment' => 'Введите фамилию на русском языке так, как она указана во внутреннем паспорте',
				'example' => 'Иванов',
				'check' => 'zЁ',
				'db' => {
					'table' => 'AppData',
					'name' => 'RLName',
				},
			},
			{
				'type' => 'input',
				'name' => 'rufname',
				'label' => 'Имя',
				'comment' => 'Введите имя на русском языке так, как она указана во внутреннем паспорте',
				'example' => 'Иван',
				'check' => 'zЁ',
				'db' => {
					'table' => 'AppData',
					'name' => 'RFName',
				},
			},
			{
				'type' => 'input',
				'name' => 'rumname',
				'label' => 'Отчество',
				'comment' => 'Введите отчество на русском языке так, как она указана во внутреннем паспорте',
				'example' => 'Иванович',
				'check' => 'zЁ',
				'db' => {
					'table' => 'AppData',
					'name' => 'RMName',
				},
			},
			{
				'type' => 'input',
				'name' => 'birthdate',
				'label' => 'Дата рождения',
				'comment' => 'Введите дату рождения',
				'example' => '01.01.1980',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'BirthDate',
				},
				'special' => 'mask',
			},
			{
				'type' => 'input',
				'name' => 'rupassnum',
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
				'name' => 'passdate',
				'label' => 'Дата выдачи',
				'comment' => 'Введите дату выдачи, указанную в паспорте',
				'example' => '01.01.2010',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'RPWhen',
				},
				'special' => 'mask',
			},
			{
				'type' => 'input',
				'name' => 'rupasswhere',
				'label' => 'Кем выдан',
				'comment' => 'Укажите полное название выдавшей организации, так, как она указана в паспорте',
				'example' => 'ОВД по району Беговой города Москвы',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'RPWhere',
				},
			},
			{
				'type' => 'input',
				'name' => 'phone',
				'label' => 'Телефон',
				'comment' => 'Введите контактный телефон, сотовый или городской, с кодом оператора, без пробелов и разделителей',
				'example' => '79161234567',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'AppPhone',
				},
			},
			{
				'type' => 'input',
				'name' => 'address',
				'label' => 'Адрес',
				'comment' => 'Полный адрес, включая индекс',
				'example' => '105203, г.Москва, ул.Ленина, д.1, кв.1',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'FullAddress',
				},
			},
		],
		
		'Данные загранпаспорта' => [
			{
				'page_ord' => 5,
				'progress' => 2,
			},	
			{
				'type' => 'input',
				'name' => 'lname',
				'label' => 'Фамилия',
				'comment' => '',
				'check' => 'zW',
				'db' => {
					'table' => 'AppData',
					'name' => 'LName',
				},
			},
			{
				'type' => 'input',
				'name' => 'fname',
				'label' => 'Имя',
				'comment' => '',
				'check' => 'zW',
				'db' => {
					'table' => 'AppData',
					'name' => 'FName',
				},
			},
			{
				'type' => 'input',
				'name' => 'rupassnum',
				'label' => '№ загранпаспорта',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'PassNum',
				},
			},
			{
				'type' => 'input',
				'name' => 'passdate',
				'label' => 'Дата выдачи',
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
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
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
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
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'PassWhom',
				},
			},
			{
				'type' => 'checkbox',
				'name' => 'ischild',
				'label' => '',
				'label_for' => 'вписан в паспорт',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'isChild',
				},
				'relation' => {},
			},
			{
				'type' => 'checkbox',
				'name' => 'nres',
				'label' => '',
				'label_for' => 'не резидент',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'NRes',
				},
				'relation' => {},
			},
		],
		
		'Персональные данные' => [
			{
				'page_ord' => 6,
				'progress' => 2,
			},
			{
				'type' => 'input',
				'name' => 'brhplace',
				'label' => 'Место рождения',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'BrhPlace',
				},
			},
			{
				'type' => 'select',
				'name' => 'brhcountry',
				'label' => 'Страна рождения',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'BrhCountry',
				},
				'param' => '[brh_countries]',
				'first_elements' => '70',
			},
			{
				'type' => 'select',
				'name' => 'сitizenshipype',
				'label' => 'Гражданство в настоящее время',
				'comment' => '',
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
				'name' => 'prev_сitizenshipype',
				'label' => 'Гражданство при рождении',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'PrevCitizenship',
				},
				'param' => '[prevcitizenship_countries]',
				'first_elements' => '70',
			},
			{
				'type' => 'radiolist',
				'name' => 'gender',
				'label' => 'Пол',
				'comment' => '',
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
				'type' => 'select',
				'name' => 'family',
				'label' => 'Семейное положение',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'Family',
				},
				'param' => {
					0 => 'Не указано',
					1 => 'Холост/не замужем',
					2 => 'Женат/замужем',
					3 => 'Не проживает с супругом',
					4 => 'Разведен/-а',
					5 => 'Вдовец/вдова',
					6 => 'Иное'
				},
			},
		],
		
		'Уточнение по семейному положению' => [
			{
				'page_ord' => 7,
				'progress' => 2,
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
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'FamilyOther',
				},
			},
		],
		
		'Персональные данные по адресам' => [
			{
				'page_ord' => 8,
				'progress' => 2,
			},
			{
				'type' => 'input',
				'name' => 'kinderdata',
				'label' => 'Для несовершеннолетних',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'KinderData',
				},
			},
			{
				'type' => 'input',
				'name' => 'workdata',
				'label' => 'Профессиональная деятельность',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'ProfActivity',
				},
			},
			{
				'type' => 'input',
				'name' => 'workaddr',
				'label' => 'Работодатель: адрес, телефон',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'WorkOrg',
				},
			},
			{
				'type' => 'radiolist',
				'name' => 'n_rezident',
				'label' => 'Страна пребывания',
				'comment' => '',
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
			
		],
		
		'Уточнение по стране пребывания' => [
			{
				'page_ord' => 9,
				'progress' => 2,
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
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'VidNo',
				},
			},
			{
				'type' => 'input',
				'name' => 'brhplace',
				'label' => 'Действителен до',
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'FamilyOther',
				},
				'special' => 'mask',
			},
		],
		
		'Информация о поездке' => [
			{
				'page_ord' => 10,
				'progress' => 2,
			},
			{
				'type' => 'radiolist',
				'name' => 'purpose',
				'label' => 'Основная цель поездки',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'VisaPurpose',
				},
				'param' => { 
					1 => 'Туризм', 
					2 => 'Деловая',
					3 => 'Учёба',
					4 => 'Официальная',
					5 => 'Культура',
					6 => 'Спорт',
					7 => 'Транзит',
					8 => 'Лечение',
					9 => 'Посещение родственников',
					10 => 'Иная',
				},
				'special' => 'save_info_about_hastdatatype',
			},
		],
		
		'Иная цель посещения' => [
			{
				'page_ord' => 11,
				'progress' => 2,
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
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'VisaOther',
				},
			},
		],
		
		'Страна и город назначения' => [
			{
				'page_ord' => 12,
				'progress' => 2,
			},
			{
				'type' => 'input',
				'name' => 'city',
				'label' => 'Город назначения',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'City',
				},
			},
			{
				'type' => 'select',
				'name' => 'nulla',
				'label' => 'Страна первого въезда',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'Nulla',
				},
				'param' => '[first_countries]',
				'first_elements' => '133',
			},
			{
				'type' => 'input',
				'name' => 'nullacity',
				'label' => 'Город первого въезда',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'NullaCity',
				},
			},
		],
		
		'Данные для визы' => [
			{
				'page_ord' => 13,
				'progress' => 2,
			},
			{
				'type' => 'select',
				'name' => 'visanum',
				'label' => 'Виза запрашивается для',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'VisaNum',
				},
				'param' => {
					0 => 'Однократного въезда',
					1 => 'Двукратного въезда',
					2 => 'Многократного въезда',
				},
			},
			{
				'type' => 'input',
				'name' => 'apps_date',
				'label' => 'Дата начала поездки',
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'AppSDate',
				},
				'special' => 'datepicker',
			},
			{
				'type' => 'input',
				'name' => 'appf_date',
				'label' => 'Дата окончания поездки',
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'AppFDate',
				},
				'special' => 'datepicker',
			},
			{
				'type' => 'input',
				'name' => 'calcdur',
				'label' => 'Продолжительность пребывания',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'CalcDuration',
				},
			},
		],
		
		'Шенгенские визы' => [
			{
				'page_ord' => 14,
				'progress' => 2,
			},
			{
				'type' => 'radiolist',
				'name' => 'prevvisa',
				'label' => 'Шенгенские визы, выданные за последние три года',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'PrevVisa',
				},
				'param' => { 
					1 => 'Нет', 
					2 => 'Да',
				},
			},
		],
		
		'Сроки действия последней визы' => [
			{
				'page_ord' => 15,
				'progress' => 2,
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
				'comment' => '',
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
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'AppData',
					'name' => 'PrevVisaED',
				},
				'special' => 'mask',
			},
		],
		
		'Отпечатки пальцев' => [
			{
				'page_ord' => 16,
				'progress' => 2,
			},
			{
				'type' => 'radiolist',
				'name' => 'fingers',
				'label' => 'Предоставлены при прошлой визе',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'Fingers',
				},
				'param' => { 
					0 => 'Нет', 
					1 => 'Да',
				},
			},
		],
		
		'Дата сдачи отпечатков' => [
			{
				'page_ord' => 17,
				'progress' => 2,
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
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'FingersDate',
				},
				'special' => 'mask',
			},
		],
		
		'Разрешение на въезд, если необходимо' => [
			{
				'page_ord' => 18,
				'progress' => 2,
			},
			{
				'type' => 'input',
				'name' => 'premesso',
				'label' => 'Кем выдано',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'Permesso',
				},
			},
			{
				'type' => 'input',
				'name' => 'premessofd',
				'label' => 'Действительно с',
				'comment' => '',
				'check' => '',
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
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'PermessoED',
				},
				'special' => 'mask',
			},
		],
		
		'Проживание' => [
			{
				'page_ord' => 19,
				'progress' => 2,
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
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataType',
				},
				'param' => { 
					'H' => 'Гостиница/аренда/собственность', 
					'P' => 'Приглашение',
				},
			},
		],
		
		'Гостиница' => [
			{
				'page_ord' => 20,
				'progress' => 2,
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
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'Hotels',
				},
			},
			{
				'type' => 'input',
				'name' => 'hotelsaddr',
				'label' => 'Адрес ',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'HotelAdresses',
				},
			},
			{
				'type' => 'input',
				'name' => 'hotelpho',
				'label' => 'Телефон',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'HotelPhone',
				},
			},
		],
		
		'Приглашение' => [
			{
				'page_ord' => 21,
				'progress' => 2,
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
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataName',
				},
			},
			{
				'type' => 'input',
				'name' => 'p_last_name',
				'label' => 'Фамилия',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataDenomination',
				},
			},
			{
				'type' => 'input',
				'name' => 'p_birthdate',
				'label' => 'Дата рождения',
				'comment' => '',
				'check' => 'z',
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
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataProvince',
				},
				'param' => '[schengen_provincies]',
			},
			{
				'type' => 'input',
				'name' => 'p_city',
				'label' => 'Город',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataCity',
				},
			},
			{
				'type' => 'input',
				'name' => 'p_adress',
				'label' => 'Адрес (без города)',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataAddress',
				},
			},
			{
				'type' => 'input',
				'name' => 'p_phone',
				'label' => 'Телефон',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataPhoneNumber',
				},
			},
			{
				'type' => 'input',
				'name' => 'p_email',
				'label' => 'Email',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataEmail',
				},
			},
		],
	
		'Приглашение организации' => [
			{
				'page_ord' => 22,
				'progress' => 2,
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
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataProvince',
				},
				'param' => '[schengen_provincies]',
			},
			{
				'type' => 'input',
				'name' => 'a_city',
				'label' => 'Город',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'SchengenAppData',
					'name' => 'HostDataCity',
				},
			},
			{
				'type' => 'input',
				'name' => 'a_company',
				'label' => 'Название приглашающей компании',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACompanyName',
				},
			},
			{
				'type' => 'input',
				'name' => 'a_companyaddr',
				'label' => 'Адрес приглашающей компании',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACompanyAddress',
				},
			},
			{
				'type' => 'input',
				'name' => 'a_phone',
				'label' => 'Телефон компании',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACompanyPhone',
				},
			},
			{
				'type' => 'input',
				'name' => 'a_fax',
				'label' => 'Факс компании',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACompanyFax',
				},
			},
			{
				'type' => 'input',
				'name' => 'a_person',
				'label' => 'ФИО, адрес, телефон, email контактного лица',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'ACopmanyPerson',
				},
			},
		],
		
		'Расходы заявителя' => [
			{
				'page_ord' => 23,
				'progress' => 2,
			},
			{
				'type' => 'radiolist',
				'name' => 'mezziwhom',
				'label' => 'Расходы заявителя оплачивает',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'MezziWhom',
				},
				'param' => { 
					0 => 'сам заявитель', 
					1 => 'упомянутый ранее спонсор (приглашающее лицо, компания)',
					2 => 'иной спонсор',
				},
			},
		],
		
		'Уточните спонсора' => [
			{
				'page_ord' => 24,
				'progress' => 2,
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
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'MezziWhomOther',
				},
			},
		],
		
		'Средства заявителя' => [
			{
				'page_ord' => 25,
				'progress' => 2,
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
				'comment' => '',
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
				'page_ord' => 26,
				'progress' => 2,
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
				'comment' => '',
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
				'page_ord' => 27,
				'progress' => 2,
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
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'MezziOtherSrc',
				},
			},
		],
				
		'Родственники в ЕС' => [
			{
				'page_ord' => 28,
				'progress' => 2,
			},
			{
				'type' => 'radiolist',
				'name' => 'femrel',
				'label' => 'Степень родства',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'FamRel',
				},
				'param' => { 
					0 => 'Нет', 
					1 => 'Супруг',
					2 => 'Ребёнок',
					3 => 'Иные близкие родственники',
					4 => 'Иждивенец',
				},
			},
		],
		
		'Данные родственника' => [
			{
				'page_ord' => 29,
				'progress' => 2,
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
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuLName',
				},
			},
			{
				'type' => 'input',
				'name' => 'eu_fname',
				'label' => 'Имя',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuFName',
				},
			},
			{
				'type' => 'input',
				'name' => 'eu_bdate',
				'label' => 'Дата рождения',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuBDate',
				},
				'special' => 'mask',
			},
			{
				'type' => 'input',
				'name' => 'eu_citizenship',
				'label' => 'Гражданство',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuCitizen',
				},
			},
			{
				'type' => 'input',
				'name' => 'eu_idnum',
				'label' => 'Номер паспорта',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'EuPassNum',
				},
			},
		],
		
		'Вы успешно добавили заявителя. Что теперь?' => [	
			{
				'page_ord' => 30,
				'progress' => 3,
				'replacer' => '[app_finish]',
			},
		],
		
		'Выберите лицо на которое будет оформлен договор' => [
			{
				'page_ord' => 31,
				'progress' => 3,
				
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
		
		'Укажите данные данные доверенного лица' => [
			{
				'page_ord' => 32,
				'progress' => 3,
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
				'comment' => '',
				'check' => 'zЁ',
				'db' => {
					'table' => 'Appointments',
					'name' => 'LName',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovfname',
				'label' => 'Имя',
				'comment' => '',
				'check' => 'zЁ',
				'db' => {
					'table' => 'Appointments',
					'name' => 'FName',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovmname',
				'label' => 'Отчество',
				'comment' => '',
				'check' => 'zЁ',
				'db' => {
					'table' => 'Appointments',
					'name' => 'MName',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovpassnum',
				'label' => '№ паспорта',
				'comment' => '',
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
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
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
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'Appointments',
					'name' => 'PassWhom',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovphone',
				'label' => 'Телефон',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'Appointments',
					'name' => 'Phone',
				},
			},
			{
				'type' => 'input',
				'name' => 'dovaddress',
				'label' => 'Адрес',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'Appointments',
					'name' => 'Address',
				},
			},
		],
		
		'Дополнительные услуги' => [
			{
				'page_ord' => 33,
				'progress' => 3,
			},
			{
				'type' => 'input',
				'name' => 'sms',
				'label' => 'SMS уведомление',
				'comment' => '',
				'check' => 'N',
				'db' => {
					'table' => 'Appointments',
					'name' => 'Mobile',
				},
			},
			{
				'type' => 'input',
				'name' => 'shipping',
				'label' => 'Адрес доставки',
				'comment' => '',
				'check' => 'Ё',
				'db' => {
					'table' => 'Appointments',
					'name' => 'ShAddress',
				},
			},
		],
				
		'Предпочтительный офис выдачи документов' => [
			{
				'page_ord' => 34,
				'progress' => 3,
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
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'OfficeToReceive',
				},
				'param' => { 
					0 => 'Малый Толмачёвский, д.6 стр.1',
					1 => 'ул. Киевская, вл. 2, 3 этаж',
				},
			},
		],
		
		
		'Страховка' => [
			{
				'page_ord' => 35,
				'progress' => 3,
			},
			{
				'type' => 'checklist_insurer',
				'name' => 'insurance',
				'label' => 'Включить заявителей в полис',
				'comment' => '',
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
				'comment' => '',
				'check' => 'N',
				'db' => {
					'table' => 'Appointments',
					'name' => 'Duration',
				},
			},
			
		],
		
		'Дата и время записи' => [
			{
				'page_ord' => 36,
				'progress' => 3,
			},
			{
				'type' => 'input',
				'name' => 'app_date',
				'label' => 'Дата записи',
				'comment' => '',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'db' => {
					'table' => 'Appointments',
					'name' => 'AppDate',
				},
				'special' => 'datepicker',
				'uniq_code' => 'onchange="update_timeslots();"',
			},
			{
				'type' => 'select',
				'name' => 'timeslot',
				'label' => 'Время',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'Appointments',
					'name' => 'TimeslotID',
				},
				'param' => '[free]',
				'special' => 'timeslots',
			},
		],
		
		'Подтверждение записи' => [
			{
				'page_ord' => 37,
				'progress' => 3,
			},
			{
				'type' => 'captcha',
				'name' => 'captcha_picture',
				'label' => '',
				'comment' => '',
				'check' => '',
				'db' => {},
			},
			{
				'type' => 'input',
				'name' => 'captcha',
				'label' => 'Введите текст с картинки',
				'comment' => '',
				'check' => 'captcha_input',
				'db' => {},
			},
		],
		
		'Поздравляем!' => [
			{
				'page_ord' => 38,
				'progress' => 4,
			},
			{
				'type' => 'text',
				'name' => 'visa_text',
				'label' => 'Всё, запись создана!',
				'comment' => '',
				'check' => '',
				'db' => {},
			},
		],
	};
	
	return $content_rules;
}

1;