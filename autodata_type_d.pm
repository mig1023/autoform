package VCS::Site::autodata_type_d;
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
				'special' => 'cach_this_value',
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
				'special' => 'cach_this_value',
			},
			{
				'type' => 'info',
				'name' => 'free_date',
				'label' => 'Ближайшая доступная дата',
				'comment' => 'Вы сможете выбрать удобную для Вас дату подачи документов во время оформления записи',
				'special' => 'nearest_date',
			},
			{
				'type' => 'input',
				'name' => 'email',
				'label' => 'Email',
				'comment' => 'Введите существующий адрес почты. На него будет выслано подтверждение и запись в визовый центре',
				'example' => 'info@italyvms.ru',
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
				'label_for' => 'я согласен с <a target = "_blank" class = "dotted_link_big" href = "/pers_data_agreement.pdf">условиями</a> обработки персональных данных визовым центром',
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
				'label_for' => 'я согласен с <a target = "_blank" class = "dotted_link_big" href = "/vazhnaya-informaciya/">условиями</a> работы с мобильными телефона на территории визового центра',
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
				'example' => '31.12.1900',
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
				'example' => '31.12.1900',
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
		
		'Данные паспорта' => [
			{
				'page_ord' => 4,
				'progress' => 4,
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
				'example' => '31.12.1900',
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
		],
		
		'Данные загранпаспорта' => [
			{
				'page_ord' => 5,
				'progress' => 5,
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
				'example' => '650000001',
				'check' => 'zWN',
				'check_logic' => [
					{
						'condition' => 'unique_in_pending',
						'table' => 'AppData',
						'name' => 'PassNum',
					},
				],
				'db' => {
					'table' => 'AppData',
					'name' => 'PassNum',
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
		],
		
		'Вы успешно добавили заявителя. Что теперь?' => [	
			{
				'page_ord' => 6,
				'progress' => 6,
				'replacer' => '[app_finish]',
			},
		],
		
		'Выберите лицо на которое будет оформлен договор' => [
			{
				'page_ord' => 7,
				'progress' => 7,
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
		
		'Укажите данные документа, удостоверяющего личность' => [
			{
				'page_ord' => 8,
				'progress' => 8,
				'relation' => {
					'only_if_not' => {
						'table' => 'Appointments',
						'name' => 'PersonForAgreements',
						'value' => '0',
					}
				},
			},
			{
				'type' => 'text',
				'name' => 'rupass_text',
				'label' => 'Для граждан РФ необходимо указать данные внутреннего паспорта',
			},
			{
				'type' => 'free_line',
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
				'example' => '4510ХХХХХХ',
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
				'example' => '31.12.1900',
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
				'label' => 'Адрес регистрации',
				'comment' => 'Укажите адрес регистрации',
				'example' => 'г.Москва, М.Толмачевский пер., д. 6, стр.1',
				'check' => 'zЁN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'AppData',
					'name' => 'RAddress',
					'transfer' => 'nope',
				},
			},
			{
				'type' => 'free_line',
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
				'page_ord' => 9,
				'progress' => 8,
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
				'example' => '31.12.1900',
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
				'name' => 'dovaddress',
				'label' => 'Адрес',
				'comment' => 'Полный адрес, включая индекс',
				'example' => '119017, г.Москва, М.Толмачевский пер., д. 6, стр.1',
				'check' => 'zЁN\s\-\_\.\,\;\'\"',
				'db' => {
					'table' => 'Appointments',
					'name' => 'Address',
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
		],
		
		'Оформление записи' => [
			{
				'page_ord' => 10,
				'progress' => 9,
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
				'comment' => 'Введите дату, когда собираетесь посетить Визовый центр для подачи документов',
				'example' => '31.12.1900',
				'check' => 'zD^(([012]\d|3[01])\.((0\d)|(1[012]))\.(19\d\d|20[0-2]\d))$',
				'check_logic' => [
					{
						'condition' => 'equal_or_later',
						'table' => 'Appointments',
						'name' => 'SDate',
						'offset' => 90,
						'error' => 'Дата начала поездки',
					},
				],
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
				'example' => '10:00 — 10:30',
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
				'type' => 'free_line',
			},
			{
				'type' => 'text',
				'name' => 'services_text',
				'label' => 'СМС-оповещение о готовности документов ( <a target = "_blank" class = "dotted_link_big" href="/dopolnitelnye-uslugi/">платная услуга</a> )',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'input',
				'name' => 'sms',
				'label' => 'Номер телефона для<br>SMS-уведомления',
				'comment' => 'Введите номер сотового телефона для получения СМС о готовности документов; услуга платная, оставьте поле пустым, если в ней нет необходимости',
				'example' => '79XXXXXXXXX',
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
				'label' => 'Доставка документов DHL ( <a target = "_blank" class = "dotted_link_big" href="/dopolnitelnye-uslugi/">платная услуга</a> )',
				'font' => 'bold',
			},
			{
				'type' => 'free_line',
			},
			{
				'type' => 'input',
				'name' => 'ship_index',
				'label' => 'Индекс доставки',
				'comment' => 'Введите первые цифры индекса или первые буквы города для доставки документов; выберите из списка подходящий индекс и город; услуга платная, оставьте поле пустым, если в ней нет необходимости',
				'example' => '119017, Москва',
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
				'example' => 'Малый Толмачёвский пер., д.6 стр.1',
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
				'label' => 'Страховка ( <a target = "_blank" class = "dotted_link_big" href="/dopolnitelnye-uslugi/">платная услуга</a> )',
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
		
		'Предпочтительный офис получения готовых документов' => [
			{
				'page_ord' => 11,
				'progress' => 10,
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
				'label' => 'Выберите офис, в котором будет осуществляться выдачи готовых документов',
				'check' => 'N',
				'db' => {
					'table' => 'Appointments',
					'name' => 'OfficeToReceive',
				},
				'param' => { 
					0 => '<b>м.Третьяковская</b>, Малый Толмачёвский пер., д.6 стр.1',
					39 => '<b>м.Киевская</b>, ул. Киевская, вл. 2, 3 этаж',
				},
			},
		],
		
		'Подтверждение записи' => [
			{
				'page_ord' => 12,
				'progress' => 11,
			},
			{
				'type' => 'captcha',
			},
		],
		
		'Запись успешно создана!' => [
			{
				'page_ord' => 13,
				'progress' => 12,
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

1;