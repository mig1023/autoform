package VCS::Site::autodata;
use strict;
use Data::Dumper;

sub get_settings
# //////////////////////////////////////////////////
{
	return {
		general => {
			max_applicants => 10,
			max_file_upload_size => ( 10 * 1024 * 1024 ), # <--- 10 mb
		},
	
		paths => {
			addr => '/autoform/',
			addr_vcs => '/vcs/',
			static => '/vcs/static',
		},
		
		age => {
			age_for_agreements => 18,
		},
		
		memcached => {
			memcached_exptime => ( 12 * 3600 ), # <--- 12 hours
			mutex_exptime => 30,
		},
		
		captcha => {
			public_key => '',
			private_key => '',
			widget_api => 'https://www.google.com/recaptcha/api.js',
			verify_api => 'https://www.google.com/recaptcha/api/siteverify',
		},
		
		confirm => {
			tt => '/usr/local/www/data/htdocs/vcs/templates/autoform/autoform_confirm.tt2',
			pers_data => '/usr/local/www/data/htdocs/pers_data_agreement.pdf',
			link_image => '',
			link_site => '',
			html_website => '',
			html_email => '',
			spb_html_email => '',
		}
	};
}

sub get_app_version_list
# //////////////////////////////////////////////////
{
	return [
		'новая форма записи',
		'новая форма записи (мобильная версия)',
		'новая форма записи (мобильное приложение)',
	];
}

sub get_page_error
# //////////////////////////////////////////////////
{
	return [
		'для работы анкеты необходимо,<br>чтобы в браузере был включён javascript',
		'неправильный токен',
		'запись не найдена',
		'не все поля были заполнены',
		'cрок действия черновика истек; пожалуйста, сделайте новую запись',
		'запись успешно отменена',
	];
}

sub get_text_error
# //////////////////////////////////////////////////
{
	return [
	#0
		'Поле "[name]" не заполнено',
		'В поле "[name]" указана неверная дата',
		'В поле "[name]" введены недопустимые символы',
		'Вы должны указать поле "[name]"',
		'Вы должны полностью заполнить анкеты или удалить ненужные черновики',
	#5
		'Вы должны добавить по меньшей мере одного заявителя',
		'"[name]" не может быть раньше, чем "[relation]"',
		'"[name]" не может быть раньше, чем "[relation]" более, чем на [offset]',
		'"[name]" не может быть позднее, чем "[relation]"',
		'"[name]" не может быть позднее, чем "[relation]" более, чем на [offset]',
	#10
		'Поле "[name]" уже встречается в актуальных записях',
		'В поле "[name]" нужно выбрать хотя бы одно значение',
		'Недопустимая дата в поле "[name]"',
		'Необходимо заполнить поле "[name]" или указать "[relation]"',
		'Необходимо заполнить поле "[name]", если заполнено "[relation]"',
	#15
		'Введён недопустимый индекс или город в поле "[name]", попробуйте указать другой',
		'Вы ввели недопустимый адрес электронной почты',
		'Этот электронный адрес был заблокирован.<br>Вы превысили допустимое количество записей',
		'Капча введена неверно.<br>Пожалуйста, попробуйте ещё раз',
		'Анкеты заполнены для другого типа визы, проверьте правильность их заполнения',
	#20
		'Выбранный Вами временной интервал занят, пожалуйста выберите другое время',
		'Указать данное поле можно только для заявителей младше [relation] лет',
		'Анкеты заполнены для другого визового центра, проверьте правильность их заполнения',
		'"[name]" не может быть ближе к "[relation]" менее, чем на [offset]',
		'Один из указанных загранпаспортов уже присутствует в активной записи',
	#25
		'В анкетах присутствуют ошибки. Пожалуйста, перепроверьте правильность заполнения всех необходимых полей',
		'Поля "[relation]" и "[name]" не совпадают',
		'Загранпаспорт [relation] не может повторяться. Для детей, вписанных в паспорта родителей, укажите соответствующую галочку',
	];
}

sub get_html_elements
# //////////////////////////////////////////////////
{
	return { 
		start_line	=> '<tr [u]>',
		
		end_line	=> '</tr>',
		
		start_cell	=> '<td class="left" [u]>',
		
		end_cell	=> '</td>',
		
		new_line	=> '<br>',
		
		new_and_bold	=> '<br><br><b>[name]</b>',
		
		input 		=> '<input class="input_width input_gen" type="text" value="[value]" name="[name]"'.
				' id="[name]" title="[comment]" [u]>',
					
		checkbox 	=> '<input type="checkbox" value="[name]" name="[name]" id="[name]" [checked] [u]>',
		
		select		=> '<select class="input_width select_gen" size = "1" ' .
				'name="[name]" title="[comment]" id="[name]" [u]>[options]</select>',
					
		radiolist	=> '<div id="[name]">[options]</div>',
		
		text		=> '<td class="left" colspan="3" [u]>[value]</td>',
		
		example		=> '<tr [u]><td class="exam_td_gen left">' .
				'<span class="exam_span_gen">[example]: [value]</span></td></tr>',

		info		=> '<label class="info" title="[comment]" id="[name]" [u]>[text]</label>',
		
		checklist	=> '<div id="[name]">[options]</div>',
		
		captcha		=> '<script src="[widget_api]?hl=[lang]" async defer></script><div id="captha_div" class="captcha_container">' .
				'<div id="[captch_id]" class="g-recaptcha" data-sitekey="[public_key]"></div></div>',
		
		label		=> '<label data-id="[name]" [u]>[value]</label>',
		
		label_for	=> '&nbsp;<label for="[name]" [u]>[value]</label>',
		
		progress	=> '<td class="pr_size_gen pr_[file]_gen center"><div class="[format] centered" ' .
				'title="[title]"><div class="pr_in_gen">[name]</div></div></td>',
					
		stages		=> '<td class="stage_gen">[progress_stage]</td>',
		
		free_line	=> '<tr class="mobil_hide"><td colspan="3">&nbsp;</td></tr>',
		
		biometric_data	=> '<div class="biometric_box"><div class="biometric_left">'.
				'<img src="/vcs/static/images/biometric_pass.png">&nbsp;&nbsp;</div>'.
				'<div class="biometric_right"><a href="/autoform/scan/" class="nfc_link">[text]</a></div></div><br>',
	}
}

sub get_tables_controled_by_AutoToken
# //////////////////////////////////////////////////
{
	return {
		AutoAppointments => 'AutoAppID',
		AutoAppData => 'AutoAppDataID',
		AutoSchengenAppData => 'AutoSchengenAppDataID',
		AutoSpbAlterAppData => 'AutoSpbDataID',
	};
}

sub get_inner_ip
# //////////////////////////////////////////////////
{
	return [
		'127.0.0.1',
	];
};

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
		11 => [ '59.935322', '30.323576', ],
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
		29 => [ '59.935322', '30.323576', ],
		30 => [ '59.935322', '30.323576', ],
		33 => [ '61.7903448', '34.3707563', ],
		34 => [ '59.935322', '30.323576', ],
		37 => [ '59.935322', '30.323576', ],
		38 => [ '57.816866', '28.3087423', ],
		39 => [ '55.743218', '37.562883', ],
		40 => [ '55.743218', '37.562883', ],
		41 => [ '55.743218', '37.562883', ],
		42 => [ '43.315049', '45.697579', ],
		43 => [ '59.935322', '30.323576', ],
		44 => [ '55.743218', '37.562883', ],
		45 => [ '55.743218', '37.562883', ],
	};
};

sub get_blocked_emails
# //////////////////////////////////////////////////
{
	return [
		{
			for_centers => [],
			show_truth => 1,
			emails => [
				'blocked_mail@mail.com',
			],
		},
		{
			for_centers => [],
			show_truth => 0,
			emails => [
				'blocked_mail@mail.com',
			],
		},
	];
};

sub get_months
# //////////////////////////////////////////////////
{
	return {
		'01' => 'января',
		'02' => 'февраля',
		'03' => 'марта',
		'04' => 'апреля',
		'05' => 'мая',
		'06' => 'июня',
		'07' => 'июля',
		'08' => 'августа',
		'09' => 'сентября',
		'10' => 'октября',
		'11' => 'ноября',
		'12' => 'декабря',
	}
}

sub get_symbols_help
# //////////////////////////////////////////////////
{
	return {
		's' => 'пробела',
		'.' => 'точки',
		',' => 'запятой',
		':' => 'двоеточия',
		';' => 'точки с запятой',
		'-' => 'дефиса',
		'_' => 'нижнего подчёркивания',
		'"' => 'кавычек',
		'/' => 'косой черты',
		'+' => 'плюса',
		'(' => 'скобок',
		'\\' => 'обратной косой черты',
		'*' => 'звёздочки',
	};
};

sub get_symbols_error
# //////////////////////////////////////////////////
{
	return {
		' ' => 'пробел',
		'.' => 'точка',
		',' => 'запятая',
		':' => 'двоеточие',
		';' => 'точка с запятой',
		'-' => 'дефис',
		'_' => 'нижнее подчёркивание',
		'"' => 'кавычка',
		"'" => 'одинарная кавычка',
		'/' => 'косая черта',
		'|' => 'вертикальная черта',
		'+' => 'плюс',
		'(' => 'скобка',
		')' => 'скобка',
		'[' => 'квадратная скобка',
		']' => 'квадратная скобка',
		'\\' => 'обратной косая черта',
		'*' => 'звёздочка',
	};
};

sub get_docstatus_progress
# //////////////////////////////////////////////////
{
	return [ '',
		{ big => 1, name => 'Приняты визовым центром', },
		{ big => 1, name => 'Сборы оплачены', },
		{ big => 1, name => 'Переданы в Консульство', },
		{ big => 1, name => 'Готовы для получения', },
		{ big => 1, name => 'В доставке', },
		{ big => 1, name => 'Получены', },
	];
}

sub get_link_text
# //////////////////////////////////////////////////
{
	return {
		1 => 'Уважаемый заявитель!<br>Вы начали создание записи на сайте <b>Итальянского Визового центра</b>.<br>Вы в любой момент можете продолжить запись перейдя по ссылке:',
		2 => '<br><br><a href="/autoform/?t=[token]" style="display: inline-block; font-family: arial,sans-serif; font-size: 14px; font-weight: bold; color: #444444; text-decoration: none; user-select: none; padding: .2em 1.2em; outline: none; border: 1px solid #c0c0c0; border-radius: 2px; background: #F5F5F5; target="_blank">',
		3 => 'Информация о записи',
		4 => '</a><br><br>',
		5 => 'Перейдя по этой записи Вы сможете:<br>1. Продолжить запись в Визовый центр, которую Вы начали не более 14 дней назад.<br>2. После завершения записи Вы сможете получать информацию о своей записи, отменить её или перенесети на другое время, распечатать уже заполненную шенгенскую анкету.<br>3. После подачи Вы сможете отслеживать статус документов, их отправку в Консульство и готовность к получению.<br><br>С уважением,<br>Итальянский визовый центр',
	};
};

sub get_appointment_text
# //////////////////////////////////////////////////
{
	return {
		subject => 'Вы зарегистрированы для подачи документов на визу',
		pers => 'лично',
		by_the_doc => 'по доверенности на имя',
		app_tx => 'Запись в визовый центр.',
		date_tx => 'Дата и время записи:',
		num_tx => 'Номер записи:',
		doc_tx => 'Документы подаются:',
		list_tx => 'Список заявителей:',
		vms_tx => 'С уважением, VMS',
		info_btn => 'Информация о записи',
		resh_btn => 'Изменить время записи',
		canc_btn => 'Отменить запись',
		prnt_btn => 'Распечатать запись',
		branch_tx => 'Визовый центр Италии',
		dis_head => 'Отказ от ответственности',
		dis_tx => 'Информация в этом сообщении предназначена исключительно для конкретных лиц, которым она адресована. В сообщении может содержаться конфиденциальная информация, которая не может быть раскрыта или использована кем-либо кроме адресатов. Если вы не адресат этого сообщения, то использование, переадресация, копирование или распространение содержания сообщения или его части незаконно и запрещено. Если Вы получили это сообщение ошибочно, пожалуйста, незамедлительно сообщите отправителю об этом и удалите со всем содержимым само сообщение и любые возможные его копии и приложения.',
	};
};

sub get_mobile_api_fields
# //////////////////////////////////////////////////
{
	return {
		appointments => [
			'ID',
			'PersonalDataPermission',
			'MobilPermission',
			'PersonForAgreements',
			'PrimetimeAlert',
			'TimeslotID', 
			'AppDate',
			'Status',
			'Login',
			'BankID',
			'SessionID',
			'CompanyID',
			'Draft',
			'Duration',
			'Notes'
		],
		appdata => [
			'ID',
			'AppID',
			'FinishedVType',
			'FinishedCenter',
			'InsurerID',
			'DListID',
			'PolicyID',
			'SchengenAppDataID', 
			'AppDateBM',
			'TimeslotBMID'
		],
	} if ( shift eq 'to_delete');
	
	return {
		appointments => [
			'SMS',
			'CenterID',
			'FName',
			'Frontiera',
			'Shipping',
			'PolicyType',
			'PrintSrv',
			'ShAddress',
			'FDate',
			'PassNum',
			'Phone',
			'PacketID',
			'NCount',
			'LName',
			'Urgent',
			'OfficeToReceive',
			'MName',
			'ShIndex',
			'Address',
			'PassDate',
			'PassWhom',
			'EMail',
			'TFName',
			'SDate',
			'TBDate',
			'Itinerario',
			'dwhom',
			'Mobile',
			'TLName',
			'Vettore',
			'RDate',
			'Cost',
			'VType', 
		],
		appdata => [
			'Citizenship',
			'ACompanyName',
			'AnkDate',
			'FirstCity',
			'DocType',
			'Family',
			'Fingers',
			'PolicyType',
			'Countries',
			'Mezzi4',
			'MezziWhom',
			'PassTill',
			'RMName',
			'RFName',
			'PassNum',
			'Permesso',
			'RPassNum',
			'NullaCity',
			'AppSDate',
			'AnketaC',
			'LName',
			'PrevLNames',
			'Mezzi3',
			'AnketaSrv',
			'ProfActivity',
			'FullAddress',
			'AMobile',
			'PassWhom',
			'EuPassNum',
			'Gender',
			'FingersDate',
			'ACompanyFax',
			'RLName',
			'EuBDate',
			'PolicyNum',
			'Mezzi7',
			'ConcilFree',
			'ACompanyPhone',
			'AppEMail',
			'ACopmanyPerson',
			'MezziWhomOther',
			'DocTypeOther',
			'VisaNum',
			'MezziOtherSrc',
			'AppFDate',
			'Mezzi1',
			'PolicyErr',
			'BrhPlace',
			'NoRMName',
			'FamilyOther',
			'Short',
			'Status',
			'Hotels',
			'Mezzi2',
			'NRes',
			'ASAddr',
			'VisaOther',
			'FName',
			'PermessoED',
			'Mezzi6',
			'IDNumber',
			'RPWhen',
			'EuCitizen',
			'VidNo',
			'isChild',
			'PrevCitizenship',
			'CalcDuration',
			'BrhCountry',
			'RAddress',
			'Nulla',
			'Mezzi5',
			'WorkOrg',
			'HotelPhone',
			'FamRel',
			'EuLName',
			'CountryRes',
			'PassDate',
			'City',
			'FirstCountry',
			'PermessoFD',
			'VidTill',
			'RPWhere',
			'HotelAdresses',
			'KinderData',
			'BirthDate',
			'PrevVisaFD',
			'AppPhone',
			'VisaPurpose',
			'PrevVisa',
			'PrevVisaED',
			'ACompanyAddress',
			'EuFName',
			'CountryLive',
			'PhotoSrv',
		],
		schengen => [
			'HostDataAddress',
			'HostDataDateOfBirth',
			'HostDataName',
			'VisaDataPurposeTravel',
			'HostDataType',
			'HostDataPostalCode',
			'HostDataEmail',
			'VisaDataMainDestination',
			'VisaDataType',
			'VisaDataBorderFirstEntry',
			'VisaDataBorderEntryCity',
			'VisaDataBeginningTravel',
			'HostDataPhoneNumber',
			'VisaDataDuration',
			'VisaDataNumberEntries',
			'HostDataCity',
			'VisaDataEndTravel',
			'HostDataProvince',
			'HostDataFax',
			'VisaDataIBorderEntry',
			'VisaDataCityDestination',
			'HostDataDenomination',
		],
	};
};

sub this_is_spb_center
# //////////////////////////////////////////////////
{
	my %spb_centers = map { $_ => 1 } split /,\s?/, '11, 27, 29, 30, 33, 34, 38, 43';

	return exists $spb_centers{ $_[0] };
}

1;
