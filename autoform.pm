package VCS::Site::autoform;
use strict;

use VCS::Vars;

use Data::Dumper;
use Date::Calc qw/Add_Delta_Days/;


sub get_content_rules_hash
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page = shift;
	
	my $content_rules = {
	
		'Начало записи' => [
			{
				'page_ord' => 1,
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
				'comment' => '',
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
				'replacer' => '[list_of_applicants]',
			},
		],
		
		'Данные внутреннего паспорта' => [
			{
				'page_ord' => 4,
			},
			{
				'type' => 'input',
				'name' => 'rulname',
				'label' => 'Фамилия',
				'comment' => '',
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
				'comment' => '',
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
				'comment' => '',
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
				'comment' => '',
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
				'comment' => '',
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
				'comment' => '',
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
				'label' => 'Выдан',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'RPWhere',
				},
			},
		],
		
		'Данные загранпаспорта' => [
			{
				'page_ord' => 5,
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
			{
				'type' => 'input',
				'name' => 'phone',
				'label' => 'Телефон',
				'comment' => '',
				'check' => 'z',
				'db' => {
					'table' => 'AppData',
					'name' => 'AppPhone',
				},
			},
		],
		
		'Уточнение по семейному положению' => [
			{
				'page_ord' => 7,
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
				'type' => 'input',
				'name' => 'brhplace',
				'label' => 'Домашний адрес',
				'comment' => '',
				'check' => '',
				'db' => {
					'table' => 'AppData',
					'name' => 'FullAddress',
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
			},
			{
				'type' => 'radiolist',
				'name' => 'purpose',
				'label' => 'Основная цель поездки',
				'comment' => '',
				'check' => 'zN',
				'db' => {
					'table' => 'AppData',
					'name' => 'VisaPurpose1',
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
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'VisaPurpose1',
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
			},
		],
		
		'Проживание' => [
			{
				'page_ord' => 19,
				'relation' => {
					'only_if' => {
						'table' => 'AppData',
						'name' => 'VisaPurpose1',
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
				'relation' => {
					'only_if_not' => {
						'table' => 'SchengenAppData',
						'name' => 'HostDataType',
						'value' => 'H',
					},
					'only_if' => {
						'table' => 'AppData',
						'name' => 'VisaPurpose1',
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
				'relation' => {
					'only_if_not' => {
						'table' => 'AppData',
						'name' => 'VisaPurpose1',
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
		
		# ===================================================================
		
		'Вы успешно добавили заявителя. Что теперь?' => [	
			{
				'page_ord' => 30,
				'replacer' => '[app_finish]',
			},
		],
		
		'Данные3внутреннего3паспорта' => [
			{
				'page_ord' => 31,
			},
			{
				'type' => 'text',
				'name' => 'visa_text',
				'label' => 'Это уже информация по паспорту.',
				'comment' => '',
				'check' => '',
				'db' => {},
			},
		],
		
		'Подтверждение записи' => [
			{
				'page_ord' => 32,
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
			},
			{
				'type' => 'text',
				'name' => 'visa_text',
				'label' => 'Это просто текст, который расположен в анкете. Это просто текст, который расположен в анкете.',
				'comment' => '',
				'check' => '',
				'db' => {},
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
				'page_ord' => 33,
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
}

sub get_content_rules
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page = shift;
	my $full = shift;
	
	my $content = $self->get_content_rules_hash();
	
	my $new_content = {};
	for my $page ( sort { $content->{$a}->[0]->{page_ord} <=> $content->{$b}->[0]->{page_ord} } keys %$content) {
		
		my $page_ord = $content->{$page}->[0]->{page_ord};
		
		$new_content->{ $page_ord } = $content->{$page};
		if (!$full) {
			if ( $content->{ $page }->[0]->{replacer} ) {
				$new_content->{ $page_ord } = $content->{ $page }->[0]->{replacer};
			} else {
				delete $new_content->{ $page_ord }->[0];
				@{ $new_content->{ $page_ord } } = grep defined, @{ $new_content->{ $page_ord } };
			}
		} else {
			$new_content->{ $page_ord }->[0]->{ page_name } = $page;
		}
	}
	$content = $new_content;

	$content = $self->init_add_param($content);
	
	if (!$page) {
		return $content;
	} elsif ($page =~ /length/i) {
		return scalar(keys %$content);
	} else {
		return $content->{$page};
	};
}

sub new
# //////////////////////////////////////////////////
{
	my ($class,$pclass,$vars) = @_;
	my $self = bless {}, $pclass;
	$self->{'VCS::Vars'} = $vars;
	return $self;
}

sub getContent 
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $task = shift;
	my $id = shift;
	my $template = shift;

	my $vars = $self->{'VCS::Vars'};
	
	$self->{'autoform'}->{'addr'} = '/autoform/';
	$self->{'autoform'}->{'addr_captcha'} = '/vcs/static/files/';
	$self->{'autoform'}->{'addr_vcs'} = '/vcs/';
  
    	my $dispathcher = {
    		'index' => \&autoform,
    	};
    	
    	my $disp_link = $dispathcher->{$id};
    	$vars->get_system->redirect($vars->getform('fullhost').$self->{'autoform'}->{'addr'}.'index.htm')
    		if !$disp_link;
    	&{$disp_link}($self, $task, $id, $template);
    	
    	return 1;	
}

sub autoform
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $task = shift;
	my $id = shift;
	my $template = shift;

	my $vars = $self->{'VCS::Vars'};
	my $page_content;
	my $step = 0;
	my $last_error = '';
	my $special;
	my $template_file;
	my $title;
	
	my $token = $self->get_token_and_create_new_form_if_need();
	
	if ($token =~ /^\d\d$/) {
		($title, $page_content) = $self->get_token_error($token);
	} else {
		($step, $title, $page_content, $last_error, $template_file, $special) = $self->get_autoform_content($token);
	}

	my ($last_error_name, $last_error_text) = split /\|/, $last_error;
	
	$vars->get_system->pheader($vars);
	my $tvars = {
		'langreq' => sub { return $vars->getLangSesVar(@_) },
		'vars' => {
				'lang' => $vars->{'lang'},
				'page_title'  => 'Autoform'
				},
		'form' => {
				'action' => $vars->getform('action')
				},
		'title' => $title,
		'content_text' => $page_content,
		'token' => $token,
		'step' => $step,
		'max_step' => $self->get_content_rules('length'),
		'addr' => $vars->getform('fullhost').$self->{'autoform'}->{'addr'},
		'last_error_name' => $last_error_name,
		'last_error_text' => $last_error_text,
		'special' => $special,
		'vcs_tools' => $self->{'autoform'}->{'addr_vcs'},
	};
	$template->process($template_file, $tvars);
}

sub init_add_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $content_rules = shift;
	my $vars = $self->{'VCS::Vars'};
	my $country_code='RUS';
	
	my $info_from_db = {
		'[centers_from_db]' => [],
		'[visas_from_db]' => [],
		'[brh_countries]' => [],
		'[citizenship_countries]' => [],
		'[prevcitizenship_countries]' => [],
		'[first_countries]' => [],
		'[schengen_provincies]' => [],
	};
	
	$info_from_db->{'[centers_from_db]'} = $vars->db->selall("
		SELECT ID, BName FROM Branches WHERE Display = 1 AND isDeleted = 0");
	$info_from_db->{'[visas_from_db]'} = $vars->db->selall("
		SELECT ID, VName FROM VisaTypes WHERE OnSite = 1");
	$info_from_db->{'[brh_countries]'} = [
		@{ $vars->db->selall('SELECT ID, EnglishName FROM Countries WHERE CODE in(?,"SUN")', $country_code) },
		@{ $vars->db->selall('SELECT ID, EnglishName FROM Countries WHERE CODE not in(?,"SUN") ORDER BY EnglishName', $country_code) }
	];
	$info_from_db->{'[citizenship_countries]'} = [
		@{ $vars->db->selall('SELECT ID, EnglishName FROM Countries WHERE CODE in(?) AND Ex=0', $country_code) },	    
		@{ $vars->db->selall('SELECT ID, EnglishName FROM Countries WHERE Ex=0 AND CODE NOT in(?) ORDER BY EnglishName', $country_code) },
	];
	$info_from_db->{'[prevcitizenship_countries]'} = [
		@{ $vars->db->selall('SELECT ID, EnglishName FROM Countries WHERE CODE in(?,"SUN")', $country_code) },
		@{ $vars->db->selall('SELECT ID, EnglishName FROM Countries WHERE CODE not in(?,"SUN")', $country_code) },
	];
	$info_from_db->{'[first_countries]'} = $vars->db->selall("
		SELECT ID, Name FROM Countries WHERE MemberOfEU=1 order by EnglishName");
	$info_from_db->{'[schengen_provincies]'} = $vars->db->selall("
		SELECT ID, Name FROM SchengenProvinces");
	
	for my $page ( keys %$content_rules ) {
		next if $content_rules->{$page} =~ /^\[/;
		for my $element ( @{ $content_rules->{$page} } ) {
			if ( ref($element->{param}) ne 'HASH' ) {
				my $param_array = $info_from_db->{ $element->{param} };
				my $param_result = {};

				for my $row (@$param_array) {
					$param_result->{ $row->[0] } = $row->[1];
				};
				$element->{param} = $param_result;
			}
		}
	}

	return $content_rules;
}	

sub get_token_and_create_new_form_if_need
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{'VCS::Vars'};
	
	my $token = $vars->getparam('t');
	$token = lc($token);
	$token =~ s/[^a-z0-9]//g;
	
	if ($token eq '') {
		$token = $self->token_generation();
		$token = $self->save_new_token_in_db($token);
	}
	else {
		my ($token_exist, $finished) = $vars->db->sel1("
			SELECT ID, Finished FROM AutoToken WHERE Token = ?", $token);
	
		if (length($token) != 64) {
			$token = '01';
		}
		elsif (!$token_exist) {
			$token = '02';
		}
		elsif ($finished) {
			$token = '03';
		}
	}
	
	return $token;
}

sub create_clear_form
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $centerid = shift;
	my $vars = $self->{'VCS::Vars'};
	
	$vars->db->query("
		INSERT INTO AutoAppointments (RDate, Login, Draft) VALUES (now(), ?, 1)", {}, 
		$vars->get_session->{'login'});
		
	my $app_id = $vars->db->sel1('SELECT last_insert_id()') || 0;
	
	$vars->db->query("
		UPDATE AutoToken SET AutoAppID = ? WHERE Token = ?", {}, 
		$app_id, $token);
}
	
sub save_new_token_in_db
# //////////////////////////////////////////////////
{	
	my $self = shift;
	my $token = shift;
	my $vars = $self->{'VCS::Vars'};

	$vars->db->query("
		INSERT INTO AutoToken (Token, AutoAppID, AutoAppDataID, AutoSchengenAppDataID, Step, LastError, Finished, Draft) 
		VALUES (?, 0, 0, 0, 1, '', 0, 0)", {}, 
		$token);
	
	return $token;
}

sub token_generation
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{'VCS::Vars'};

	my $token_existing = 1;
	my $token = '';
	
	do {
		my @alph = split //, '0123456789abcdefghigklmnopqrstuvwxyz';
		for (1..64) {
			$token .= @alph[int(rand(35))];
		}
		$token_existing = $vars->db->sel1("
			SELECT ID FROM AutoToken WHERE Token = ?", $token) || 0;
	} while ($token_existing);
	
	return $token;
}

sub get_token_error
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $error_num = shift;
	
	my $error_type = [
		'internal data error',
		'token corrupted',
		'token not existing',
		'app already finished',
	];
	
	my $content = 'your token has error: ' . $error_type->[$error_num];
	my $title = 'token error';
	
	return ($title, $content);
}

sub get_autoform_content
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $last_error = '';
	my $title;
	
	my $vars = $self->{'VCS::Vars'};
	
	my ($step, $app_id) = $vars->db->sel1("
		SELECT Step, AutoAppID FROM AutoToken WHERE Token = ?", $token);

	my $action = $vars->getparam('action');
	$action = lc($action);
	$action =~ s/[^a-z]//g;
	
	my $appdata_id = $vars->getparam('person');
	$appdata_id =~ s/[^0-9]//g;
	
	if ( ($action eq 'back') and ($step > 1) ) {
		$step = $self->get_back($step, $token);
	}

	if ( ($action eq 'forward') and ($step < $self->get_content_rules('length')) ) {
		($step, $last_error) = $self->get_forward($step, $token);
	}

	if ( ($action eq 'edit') and $appdata_id ) {
		$step = $self->get_edit($step, $appdata_id, $token);
	}
	
	if ( ($action eq 'delapp') and $appdata_id ) {
		$self->get_delete($appdata_id, $token);
	}
	
	if ($action eq 'addapp') {
		$step = $self->get_add($app_id, $token);
	}
	
	if ($action eq 'tofinish') {
		my $app_status = $self->check_all_app_finished_and_not_empty($token);
		
		if ( $app_status == 0 ) {
			$step = $self->set_step_by_content($token, '[app_finish]', 'next');
		} else {
			$step = $self->set_step_by_content($token, '[list_of_applicants]');
			
			if ( $app_status == 1 ) {	
				$last_error = $self->text_error(4, undef, undef);
			} else {
				$last_error = $self->text_error(5, undef, undef);
			}
		}
	}
	
	if ($action eq 'tolist') {
		$step = $self->set_step_by_content($token, '[list_of_applicants]');
	}
	
	
	my $page = $self->get_content_rules($step, 'full');
	my $back = ($action eq 'back' ? 'back' : '');
	
	if ( !$last_error and (exists $page->[0]->{relation}) ) {
		($step, $page) = $self->check_relation($step, $page, $step, $token, $back);
	}
	
	if ($page !~ /\[/) { 
		$title = $page->[0]->{page_name};
	}

	my ($content, $template) = $self->get_html_page($step, $token);
	
	my ($special) = $self->get_specials_of_element($step);
	
	return ($step, $title, $content, $last_error, $template, $special);
}

sub check_relation
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $page = shift;
	my $step = shift; 
	my $token = shift;
	my $moonwalk = shift;

	my $vars = $self->{'VCS::Vars'};

	my $skip_this_page;
	my $at_least_one_page_skipped = 0;
	
	my $current_table_id = $self->get_current_table_id($step, $token); 
	
	do {
	
		$skip_this_page = 0;

		for my $relation (keys %{ $page->[0]->{relation} }) {
			$skip_this_page += $self->skip_page_by_relation( $relation, $page->[0]->{relation}->{$relation}, $step, $token );
		}
		
		if ($skip_this_page) {
		
			$at_least_one_page_skipped = 1;
			
			if ($moonwalk) {
				$step--;
			} else {
				$step++;
			}
			
			$page = $self->get_content_rules($step, 'full');
			
			my $current_table_id = $self->get_current_table_id($step, $token); 
			
			if ( $step == $self->get_step_by_content($token, '[app_finish]') ) {
				$self->set_current_app_finished( $current_table_id->{AutoAppData} );
			}
		}
	
	} while ($skip_this_page);

	if ($at_least_one_page_skipped) {
		$vars->db->query("
			UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
			$step, $token);
	}

	return ($step, $page);
}

sub skip_page_by_relation
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $condition = shift;
	my $relation = shift;
	my $step = shift;
	my $token = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	my $current_table_id = $self->get_current_table_id($step, $token); 
	
	my $value = $vars->db->sel1("
		SELECT $relation->{name} FROM Auto$relation->{table} WHERE ID = ?", $current_table_id->{ 'Auto'. $relation->{table} });
	
	return $self->skip_by_condition( $value, $relation->{value}, $condition ); 
}

sub skip_by_condition
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $value = shift;
	my $relation = shift;
	my $condition = shift;
	
	my $skip_it = 0;
	
	my %relation = map { $_ => 1 } split /,/, $relation; 

	if ($condition eq 'only_if') {
		$skip_it = 1 unless exists $relation{$value};
	}
	
	if ($condition eq 'only_if_not') {
		$skip_it = 1 if exists $relation{$value};
	}
	
	return $skip_it;
}

sub get_forward
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $token = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	my $current_table_id = $self->get_current_table_id($step, $token);
	$self->create_clear_form($token, $self->get_center_id()) if !$current_table_id->{AutoAppointments};
	$self->save_data_from_form($step, $current_table_id);
	
	my $last_error = $self->check_data_from_form($step);
	
	if ($last_error) {
		$vars->db->query("
			UPDATE AutoToken SET Step = ?, LastError = ? WHERE Token = ?", {}, 
			$step, $last_error, $token);
	} else {
		$step++;
		
		$vars->db->query("
			UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
			$step, $token);
	}

	if ( !$last_error and ( $step == $self->get_step_by_content($token, '[app_finish]') ) ) {
		$self->set_current_app_finished( $current_table_id->{AutoAppData} );
	}
	
	return ($step, $last_error);
}

sub set_current_app_finished
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $appdata_id = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	$vars->db->query("
		UPDATE AutoAppData SET Finished = 1 WHERE ID = ?", {}, 
		$appdata_id);
}

sub get_step_by_content
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $content = shift;
	my $next = shift;
	
	my $vars = $self->{'VCS::Vars'};

	my $page_content = $self->get_content_rules();
	my $step;

	for my $page (keys %$page_content) {
		$step = $page if ( $page_content->{$page} eq $content);
	}

	$step++ if $next;
			
	return $step;
}

sub set_step_by_content
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $content = shift;
	my $next = shift;
	
	my $vars = $self->{'VCS::Vars'};

	my $step = $self->get_step_by_content($token, $content, $next);

	$vars->db->query("
			UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
			$step, $token);
			
	return $step;
}

sub get_edit
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $appdata_id = shift; 
	my $token = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	if ( $self->check_existing_id_in_token($appdata_id, $token) ) {
		
		$step = $self->get_step_by_content($token, '[list_of_applicants]', 'next');;
		
		my $sch_id = $vars->db->sel1("
			SELECT SchengenAppDataID FROM AutoAppData WHERE ID = ?", $appdata_id);
		
		$vars->db->query("
			UPDATE AutoToken SET Step = ?, AutoAppDataID = ?, AutoSchengenAppDataID = ? WHERE Token = ?", {}, 
			$step, $appdata_id, $sch_id, $token);
		
		$vars->db->query("
			UPDATE AutoAppData SET Finished = 0 WHERE ID = ?", {}, 
			$appdata_id);
	}
	
	return $step;
}

sub get_delete
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $appdata_id = shift; 
	my $token = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	if ( $self->check_existing_id_in_token($appdata_id, $token) ) {
	
		my $sch_id = $vars->db->sel1("
			SELECT SchengenAppDataID FROM AutoAppData WHERE ID = ?", $appdata_id);
	
		$vars->db->query("
			DELETE FROM AutoAppData WHERE ID = ?", {}, 
			$appdata_id);
		
		$vars->db->query("
			DELETE FROM AutoSchengenAppData WHERE ID = ?", {}, 
			$sch_id);
	}
}

sub check_existing_id_in_token
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $appdata_id = shift; 
	my $token = shift;
	
	my $exist = 0;
	
	my $vars = $self->{'VCS::Vars'};
	
	my $list_of_app_in_token = $vars->db->selallkeys("
		SELECT AutoAppData.ID FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
		WHERE Token = ?", $token );
		
	for my $app (@$list_of_app_in_token) {
		$exist = 1 if ($app->{ID} == $appdata_id);
	}
	
	return $exist;
}

sub check_all_app_finished_and_not_empty
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	
	my $all_finished = 0;
	
	my $vars = $self->{'VCS::Vars'};
	
	my ( $app_count, $app_finished ) = $vars->db->sel1("
		SELECT COUNT(AutoAppData.ID), SUM(AutoAppData.Finished) FROM AutoToken 
		JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
		JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
		WHERE Token = ?", $token );
		
	$all_finished = 1 if $app_finished < $app_count;
	
	$all_finished = 2 if $app_count < 1;
	
	return $all_finished;
}

sub get_add
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $app_id = shift;
	my $token = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	$vars->db->query("
		INSERT INTO AutoSchengenAppData (HostDataCity) VALUES (NULL);");
		
	my $sch_id = $vars->db->sel1('SELECT last_insert_id()') || 0;
	
	$vars->db->query("
		INSERT INTO AutoAppData (AnkDate, AppID, SchengenAppDataID) VALUES (now(), ?, ?)", {}, 
		$app_id, $sch_id);
	
	my $appdata_id = $vars->db->sel1('SELECT last_insert_id()') || 0;
	
	my $step = $self->get_step_by_content($token, '[list_of_applicants]', 'next');
	
	$vars->db->query("
		UPDATE AutoToken SET Step = ?, AutoAppDataID = ?, AutoSchengenAppDataID =? WHERE Token = ?", {}, 
		$step, $appdata_id, $sch_id, $token);
	
	return $step;
}

sub get_back
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $token = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	$self->save_data_from_form($step, $self->get_current_table_id($step, $token));
	$step--;
	
	if ( $step == $self->get_step_by_content($token, '[app_finish]') ) {
		$step = $self->set_step_by_content($token, '[list_of_applicants]');
	}
	
	$vars->db->query("
		UPDATE AutoToken SET Step = ? WHERE Token = ?", {}, 
		$step, $token);
		
	return $step;
}

sub get_html_page
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $token = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	my $content = '';
	my $template = 'autoform.tt2';
	
	my $page_content = $self->get_content_rules($step);

	if ( $page_content eq '[list_of_applicants]') {
		return $self->get_list_of_app($token);
	}
	
	if ( $page_content eq '[app_finish]') {
		return $self->get_finish();
	}
	
	my $current_values = $self->get_all_values($step, $self->get_current_table_id($step, $token));
	
	for my $element (@$page_content) {
		$content .= $self->get_html_line($element, $current_values);
	}
	return ($content, $template);
}

sub get_list_of_app
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $token = shift;
	my $vars = $self->{'VCS::Vars'};
	
	my $content = $vars->db->selallkeys("
			SELECT AutoAppData.ID, AutoAppData.FName, AutoAppData.LName, AutoAppData.BirthDate,  AutoAppData.Finished
			FROM AutoToken 
			JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID
			JOIN AutoAppData ON AutoAppointments.ID = AutoAppData.AppID
			WHERE Token = ?", $token );
		
	if (scalar(@$content) < 1) {
		$content->[0]->{ID} = 'X';
	} else {
		for my $app (@$content) {
			$app->{BirthDate} =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
		}
	}
	
	my $template = 'autoform_list.tt2';
	
	return ($content, $template);
}

sub get_finish
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $template = 'autoform_finish.tt2';
	
	return (undef, $template);
}

sub get_specials_of_element
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page_content = $self->get_content_rules(shift);
	
	return if $page_content =~ /^\[/;
	
	my $special = {
		'datepickers' => [],
		'masks' => [],
		'nearest_date' => [],
	};
	
	for my $element (@$page_content) {
		push( $special->{datepickers}, $element->{name} ) if $element->{special} eq 'datepicker';
		push( $special->{masks}, $element->{name} ) if $element->{special} eq 'mask';
		push( $special->{nearest_date}, $element->{name} ) if $element->{special} eq 'nearest_date';
	}
	
	return ($special);
}

sub get_html_line
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	my $values = shift;
	
	my $content = $self->get_html_for_element('start_line');
	
	if ( $element->{type} eq 'text' ) {
		$content .= $self->get_html_for_element('text', $element->{name}, $element->{label});
		$content .= $self->get_html_for_element('end_line');
	
		return $content;
	}	
	
	my $label_for_need = ( $element->{label_for} ? $self->get_html_for_element( 'label_for', $element->{name}, $element->{label_for} ) : '' );
	
	my $current_value = $values->{ $element->{name} };

	if ( $element->{db}->{name} eq 'complex' ) {
		for my $sub_value ( keys %{ $element->{param} } ) {
			$current_value->{$sub_value} = $values->{ $sub_value };
		}
	}
	
	$content .= $self->get_cell(
			$self->get_html_for_element(
				'label', 'text', $element->{label}
			) 
		) .
		$self->get_cell(
			$self->get_html_for_element(
				'helper', 'helper',  $element->{label}
			)
		) .
		$self->get_cell(
			$self->get_html_for_element(
				$element->{type}, $element->{name}, $current_value, $element->{param}, $element->{uniq_code}
			) . $label_for_need
		);
	
	$content .= $self->get_html_for_element('end_line');

	return $content;
}

sub get_cell
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	
	return $self->get_html_for_element('start_cell') . $element . $self->get_html_for_element('end_cell');
}

sub get_html_for_element
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $type = shift;
	my $name = shift;
	my $value = shift;
	my $param = shift;
	my $uniq_code = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	my $elements = {
		'start_line'	=> '<tr [u]>',
		'end_line'	=> '</tr>',
		'start_cell'	=> '<td [u]>',
		'end_cell'	=> '</td>',
		
		'input' 	=> '<input type="text" value="[value]" name="[name]" id="[name]" [u]>',
		'checkbox' 	=> '<input type="checkbox" value="[name]" name="[name]" id="[name]" [checked] [u]>',
		'select'	=> '<select size = "1" name="[name]" id="[name]" [u]>[options]</select>',
		'radiolist'	=> '[options]',
		'text'		=> '<td colspan="3" [u]>[value]</td>',
		'info'		=> '<label id="[name]" [u]></label>',
		'checklist'	=> '[options]',
		'captcha'	=> '<img src="[captcha_file]"><input type="hidden" name="code" value="[captcha_code]" [u]>',
		
		'helper'	=> '[?] ', # value вписать в текст хелпа
		'label'		=> '<label id="[name]" [u]>[value]</label>',
		'label_for'	=> '<label for="[name]" [u]>[value]</label>',
	};
	
	my $content = $elements->{$type};
	
	$content =~ s/\[name\]/$name/gi;
	$content =~ s/\[value\]/$value/gi;
	$content =~ s/\[u\]/$uniq_code/gi;
	
	if ($type eq 'checkbox') {
		$content =~ s/\[checked\]/checked/gi if $value;
	}
	
	if ($type eq 'select') {
		my $list = '';
		for my $opt (sort keys %$param) {
			my $selected = ( $value == $opt ? 'selected' : '' );
			$list .= '<option ' . $selected . ' value=' . $opt . '>' . $param->{$opt} . '</option>'; 
		}
		$content =~ s/\[options\]/$list/gi;
	}
	
	if ($type eq 'radiolist') {
		my $list = '';
		for my $opt (sort keys %$param) {
			my $checked = ( $value == $opt ? 'checked' : '' );
			$list .= '<input type="radio" name="' . $name . '" value="' . $opt . '" ' . $checked . '>' . $param->{$opt} . '<br>';
		}
		$content =~ s/\[options\]/$list/gi;
		
	}
	
	if ($type eq 'checklist') {
		my $list = '';

		for my $opt (sort {$a cmp $b} keys %$param) {
			
			my $checked = ( $value->{$opt} ? 'checked' : '' );
			$list .= '<input type="checkbox" value="' . $opt . '" name="' . $opt . '" id="' . $opt . '" ' . $checked . '>'.
			'<label for="' . $opt . '">' . $param->{$opt}->{label_for} . '</label><br>';
		}
		$content =~ s/\[options\]/$list/gi;
	}

	if ($type eq 'captcha') {
		my $config = $vars->getConfig('captcha');
		my $addr_captcha = $self->{'autoform'}->{'addr_captcha'};
		
		my $captcha = $vars->getcaptcha();
		my $ccode = $captcha->generate_code($config->{'code_nums'});
	
		$content =~ s!\[captcha_file\]!$addr_captcha$ccode.png!;
		$content =~ s/\[captcha_code\]/$ccode/;
	}
	
	return $content;
}

sub get_center_id
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{'VCS::Vars'};
	
	my $center_id = $vars->getparam('center');
	
	return $center_id;
}

sub save_data_from_form
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $table_id = shift;
	
	my $vars = $self->{'VCS::Vars'};

	my $request_tables = $self->get_names_db_for_save_or_get($self->get_content_rules($step));
	
	for my $table (keys %$request_tables) {
		
		next if !$table_id->{$table};
	
		my $request = '';
		my @values = ();
	
		for my $row (keys %{$request_tables->{$table}}) { 

			$request .=  "$row = ?, ";
			my $value = $vars->getparam($request_tables->{$table}->{$row});
			push (@values, $self->encode_data_for_db($step, $request_tables->{$table}->{$row}, $value));
		}
		$request =~ s/,\s$//;			

		$vars->db->query("
			UPDATE $table SET $request WHERE ID = ?", {}, 
			@values, $table_id->{$table});
		
	}
	
	$self->check_special_in_rules($step, $table_id);
}

sub check_special_in_rules
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $table_id = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $elements = $self->get_content_rules($step);
	
	return if $elements =~ /\[/;
	
	for my $element (@$elements) {
		if ($element->{special} eq 'save_info_about_hastdatatype') {
			
			my $visa_type = $vars->db->sel1("
				SELECT VisaPurpose1 FROM AutoAppData WHERE ID = ?", $table_id->{AutoAppData});

				if ($visa_type != 1) {
				$vars->db->query("
					UPDATE AutoSchengenAppData SET HostDataType = 'S' WHERE ID = ?", {}, 
					$table_id->{AutoSchengenAppData});
			}
		}
	}
}

sub get_all_values
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $table_id = shift;
	
	my $vars = $self->{'VCS::Vars'};
	
	my $all_values = {};
	my $request_tables = $self->get_names_db_for_save_or_get($self->get_content_rules($step));

	for my $table (keys %$request_tables) {
		
		next if !$table_id->{$table};
	
		my $request = join ',', keys %{$request_tables->{$table}};
		
		my $result = $vars->db->selallkeys("
			SELECT $request FROM $table WHERE ID = ?", $table_id->{$table} );
		$result = $result->[0];
		
		for my $value (keys %$result) {
			$all_values->{$request_tables->{$table}->{$value} } = 
				$self->decode_data_from_db($step, $request_tables->{$table}->{$value}, $result->{$value});
		}
	}

	return $all_values;
}

sub decode_data_from_db
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $element_name = shift;
	my $value = shift;
	
	my $page_content = $self->get_content_rules($step);
	
	$value =~ s/^(\d\d\d\d)\-(\d\d)\-(\d\d)$/$3.$2.$1/;
	
	return $value;
}

sub encode_data_for_db
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $element_name = shift;
	my $value = shift;
	
	my $element = $self->get_element_by_name( $step, $element_name );
	
	$value =~ s/^\s+|\s+$//g;

	if ($element->{type} =~ /checkbox|checklist/) {
		if ($value eq $element_name) {
			$value = 1;
		} else {
			$value = 0;
		};
	};
	
	$value =~ s/^(\d\d)\.(\d\d)\.(\d\d\d\d)$/$3-$2-$1/;
	
	return $value;
}

sub get_element_by_name
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $element_name = shift;
	
	my $page_content = $self->get_content_rules($step);
	my $element;
	for my $element_search  (@$page_content) {
		if ($element_search->{name} eq $element_name) {
			$element = $element_search;
		};
		
		if ( $element_search->{db}->{name} eq 'complex' ) {
			for my $sub_element (keys %{ $element_search->{param} }) {
				if ($sub_element eq $element_name) {
					$element = $element_search;
				}
			}
		};
	};
	
	return $element;
}

sub get_names_db_for_save_or_get
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $page_content = shift;
	my $request_tables = {};

	return if $page_content =~ /^\[/;
	
	for my $element (@$page_content) {
		if ( $element->{db}->{name} eq 'complex' ) {
			for my $sub_element (keys %{ $element->{param} }) {
			$request_tables->{ 'Auto' . $element->{db}->{table} }->{ $element->{param}->{$sub_element}->{db} } = $sub_element;
			}
		}
		else { 
			$request_tables->{ 'Auto' . $element->{db}->{table} }->{ $element->{db}->{name} } = $element->{name};
		}
	}
	return $request_tables;
}

sub get_current_table_id
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	my $token = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $tables_id = {};
	my $request_tables = '';
	my $tables_list = [];
	
	my $tables_controled_by_AutoToken = {
		'AutoAppointments' => 'AutoAppID',
		'AutoAppData' => 'AutoAppDataID',
		'AutoSchengenAppData' => 'AutoSchengenAppDataID',
	};
	
	for my $table_controlled (keys %$tables_controled_by_AutoToken) {
		$request_tables .= $tables_controled_by_AutoToken->{$table_controlled} . ', ';
		push @$tables_list, $table_controlled;
	}
	$request_tables =~ s/,\s$//;

	my @ids = $vars->db->sel1("
		SELECT $request_tables FROM AutoToken WHERE Token = ?", $token);
	
	my $max_index = scalar( keys %$tables_controled_by_AutoToken ) - 1;
	
	for my $id (0..$max_index) {
		$tables_id->{ $tables_list->[$id] } = $ids[$id];
	};

	return $tables_id;
}

sub check_data_from_form
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $step = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $page_content = $self->get_content_rules($step);

	return if $page_content =~ /^\[/;
	
	my $first_error = '';
	
	for my $element (@$page_content) {
		last if $first_error;
		next if !$element->{check};
		if ( $element->{type} =~ /checkbox/ ) {
			$first_error = $self->check_chkbox( $element );
		}
		elsif ( ( $element->{type} =~ /input/ ) and ( $element->{check} =~ /captcha_input/ ) ) {
			$first_error = $self->check_captcha( $element );
			$first_error = "$element->{name}|$first_error" if $first_error;
			}
		else {
			$first_error = $self->check_param( $element );
			}
	}
	
	return $first_error;
}

sub check_chkbox
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $value = $vars->getparam($element->{name});
	my $rules = $element->{check};
	
	return $self->text_error(3, $element) if ( ($element->{check} =~ /true/) and ($value eq '') );
}

sub check_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $value = $vars->getparam($element->{name});
	my $error = '';
	my $rules = $element->{check};
	
	$value =~ s/^\s+|\s+$//g;

	return $self->text_error(0, $element) if ($rules =~ /z/) and ($value eq '');
	return if $rules eq 'z'; 

	if ($rules =~ /D/) {
		$rules =~ s/(z|D)//g;
		return $self->text_error(1, $element) if (!($value =~ /$rules/) and ($value ne ''));
	}
	else {
		my $regexp = '';
		$regexp .= 'A-Za-z' if $rules =~ /W/; 
		$regexp .= 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя' if $rules =~ /Ё/;
		$regexp .= '0-9' if $rules =~ /N/;
		$rules =~ s/(z|W|Ё|N)//g;
		my $revers_regexp = '[' . $regexp . $rules . ']';
		$regexp = '[^' . $regexp . $rules . ']';

		if (($value =~ /$regexp/) and ($value ne '')) {
			$value =~ s/$revers_regexp//gi;
			return $self->text_error(2, $element, $value);
		}
	}
}

sub check_captcha
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $element = shift;
	
	my $vars = $self->{'VCS::Vars'};
	my $config = $vars->getConfig('captcha');
	my $captcha = $vars->getcaptcha();
	
	my $capverify = $vars->getparam( $element->{name} ) || '';
	my $rcode = $vars->getparam('code') || '';
	my $c_status = $captcha->check_code( $capverify, $rcode );
	
	return $vars->getCaptchaErr($c_status);
}

sub text_error
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $error_code = shift;
	my $element = shift;
	my $incorrect_symbols = shift;
	
	my $text = [
		'Поле "[name]" не заполнено',
		'В поле "[name]" указана неверная дата',
		'В поле "[name]" введены недопустимые символы',
		'Вы должны дать указать поле "[name]"',
		'Вы должны полностью закончить все анкеты',
		'Вы должны добавить по меньшей мере одного заявителя',
	];
	
	if (!defined($element)) {
		return "|$text->[$error_code]";
	}
	
	my $name_of_element = (	$element->{label} ? $element->{label} : ( 
				$element->{label_for} ? $element->{label_for } : $element->{name} ) );
	
	my $current_error = $text->[$error_code];
	$current_error =~ s/\[name\]/$name_of_element/;
	
	my $text_error = "$element->{name}|$current_error";
	$text_error .= ': ' . $incorrect_symbols if $error_code == 2;

	return $text_error;	
}
	
1;
