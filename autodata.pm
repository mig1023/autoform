package VCS::Site::autodata;
use strict;
use Data::Dumper;

sub get_settings
# //////////////////////////////////////////////////
{
	return {
		general => {
			max_applicants => 10,
			max_file_upload_size => ( 15 * 1024 * 1024 ), # <--- 15 mb
			maps_type => 'embedded', # <--- embedded / geo
			technical_work => 0, 
			anti_injection => 0,
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
		
		payment => {
			url => '',
			back_url => '',
			
			user_name => '',
			password => '',
		},
		
		sms => {
			send_url => '',
			project => '', 
			sender => '',
			key => '',
			
			do_not_send_sms => 0,	
		},
		
		cloud => {	
			url => '',
			
			ssl_cert => '',
			ssl_key => '',
			ssl_pwd => '',
			
			rsa_key => '',
			
			inn => '',
		},
		
		concil => {
			payment => '',
		},
		
		fox => {
			addr => '',
			calc => '',
			order => '',
			pay => '',
			pay_status => '',
			track => '',
			
			login => '',
			password => '',
			urgency => '',
			cargo => '',
			service => '',
			
			description => '',
			senderInfo => '',
			recipient => '',
			recipientIndex => '',
			recipientOfficial => '',
			recipientGeography => '',
			recipientAddress => '',
			recipientPhone => '',
			recipientEMail => '',
			recipientInfo => '',
		},
		
		yandex_map => {
			api_key => '',
		},
		
		captcha => {
			public_key => '',
			private_key => '',
			widget_api => 'https://google.com/recaptcha/api.js',
			verify_api => 'https://google.com/recaptcha/api/siteverify',
		},
		
		confirm => {
			tt => '',
			pers_data => '',
			link_image => '',
			link_site => '',
			html_website => '',
			html_email => '',
			spb_html_email => '',
		},
	};
}

sub get_app_version_list
# //////////////////////////////////////////////////
{
	return [
		'расширенный шенген экспорт',
		'расширенный шенген экспорт (мобильная версия)',
		'расширенный шенген экспорт (мобильное приложение)',
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
		'запись успешно отменена<br><a class="dotted_link" href="/autoform/">создать новую запись</a>',
		'извините, ведутся технические работы!<br>в целях сохранности данных, работа системы записи временно приостановлена<br>обновите страницу через несколько минут',
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
		'Для продолжения необходимо поставить галочку в поле "[name]"',
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
		'"[name]" не может быть больше, чем [relation]',
		'"[name]" не может быть меньше, чем [relation]',
	#30
		'Пожалуйста, не дублируйте текст из примеров',
		'Для данного типа визы необходимо загрузить документ "[relation]"',
	];
}

sub get_payment_error
# //////////////////////////////////////////////////
{
	return [
		'Заказ не оплачен',
		'Предавторизованная сумма захолдирована',
		'Проведена полная авторизация суммы заказа ',
		'Авторизация отменена',
		'По транзакции была проведена операция возврата',
		'Инициирована авторизация через ACS банка-эмитента',
		'Авторизация отклонена',
	];
}

sub get_concil_types
# //////////////////////////////////////////////////
{
	return {
		1 => 35,
		2 => 40,
		3 => 50,
		4 => 80,
		5 => 116,
		6 => 0,
	};
}


sub get_remote_progressline
# //////////////////////////////////////////////////
{
	return [ '',
		{ big => 1, name => 'Начало оформления', },
		{ big => 0, name => 'Ознакомление с договором', },
		{ big => 0, name => 'Страховка', },
		{ big => 0, name => 'Покупка страховки', },
		{ big => 1, name => 'Консульский сбор', },
		{ big => 0, name => 'SMS-оповещение', },
		{ big => 1, name => 'Сервисный сбор', },
		{ big => 1, name => 'Подписание договора', },
		{ big => 0, name => 'Получение договора', },
		{ big => 1, name => 'Адрес доставки', },
		{ big => 0, name => 'Оплата доставки', },
		{ big => 1, name => 'Готово!', }, 
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
		
		disclaimer	=> '<div id="disc" class="disclaimer"><br>[comment]<br><br>'.
				'<a class = "dotted_link_big" href = "javascript:openDisclaimer()">[close]</a><br><br></div>' .
				'<input type="checkbox" value="[name]" name="[name]" id="[name]" [checked] [u]>' .
				'<script>function openDisclaimer() { if ( $("#disc").css("display") == "none" )' .
				'{ $("#disc").show(); } else { $("#disc").hide(); } }</script>',
		
		oferta		=> '<div id="disc" class="oferta"><br>[comment]<br></div>' .
				'<br><input type="checkbox" value="[name]" name="[name]" id="[name]" [checked] [u]>',
		
		select		=> '<select class="input_width select_gen" size = "1" ' .
				'name="[name]" title="[comment]" id="[name]" [u]>[options]</select>',
				
		m_select	=> '<select class="select_gen" multiple="multiple" width="20em" placeholder="[holder]" ' .
				'name="[name]" title="[comment]" id="[name]" [u]>[options]</select>',
					
		radiolist	=> '<div id="[name]">[options]</div>',
		
		text		=> '<td class="left" colspan="3" [u]>[value]</td>',
		
		example		=> '<tr [u]><td class="exam_td_gen left">' .
				'<span class="exam_span_gen"><table class="no_border"><tr><td class="no_mobile_transform exam_td_gen">[example]:</td><td class="no_mobile_transform">[value]</td></tr></table></span></td></tr>',

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
		
		biometric_data	=> '<div class="biometric_box"><div class="biometric_left"><div class="biometric_left_inner">' .
				'<img src="/vcs/static/images/biometric_pass.png">&nbsp;&nbsp;</div></div>'.
				'<div class="biometric_right"><a href="/autoform/scan/" class="nfc_link">[text]</a></div></div><br>',
				
		edit_app_button => '<a moz-do-not-send="true" href="[%link_site%]/autoform/?t=[%app_token%]" style="width:177px;' .
				'text-decoration:none;text-align:center;display:block;padding:1px 0px;border:1px solid #cad3d9;' .
				'border-radius:4px;color: #33c3ba;background:#f7f9fa;margin-bottom: 7px;">[%edit_btn%]</a>',
				
		payment 	=> '<div class="captcha_container" id="payment_container">[pay_text] [pay_amount] руб</div>',
		
		pay_confirm	=> '<td class="left" colspan="3" [u]>[value]</td>',
	}
}

sub get_app_date_pseudo_element
# //////////////////////////////////////////////////
{
	return {
		name => 'appdate',
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
	};
}

sub get_tables_controled_by_AutoToken
# //////////////////////////////////////////////////
{
	return {
		AutoAppointments => 'AutoAppID',
		AutoAppData => 'AutoAppDataID',
		AutoSchengenAppData => 'AutoSchengenAppDataID',
		AutoSpbAlterAppData => 'AutoSpbDataID',
		AutoSchengenExtData => 'AutoSchengenExtID',
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

sub get_embedded_maps
# //////////////////////////////////////////////////
{
	return {
		1 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2670.908755099672!2d37.61597124228185!3d55.74186571800983!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x46b54affd9094bff%3A0x96edb30455a9b2a3!2z0JzQsNC70YvQuSDQotC-0LvQvNCw0YfQtdCy0YHQutC40Lkg0L_QtdGALiwgNtGBMSwg0JzQvtGB0LrQstCwLCAxMTkwMTc!5e0!3m2!1sru!2sru!4v1507287664868',
		},
		2 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2390.4639703799044!2d50.093784115670765!3d53.19159479399259!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x41661e3e203802c1%3A0xecfb7dbe32aff018!2z0YPQuy4g0JvRjNCy0LAg0KLQvtC70YHRgtC-0LPQviwgMjksINCh0LDQvNCw0YDQsCwg0KHQsNC80LDRgNGB0LrQsNGPINC-0LHQuy4sIDQ0MzAxMA!5e0!3m2!1sru!2sru!4v1507184997617',
		},
		3 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d1409.355644965661!2d38.957289422550346!3d45.0510803015121!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x40f04f6f668a23d5%3A0xf120c3d0af780015!2z0YPQuy4g0JrRgNCw0YHQvdGL0YUg0J_QsNGA0YLQuNC30LDQvSwgMTUyLCDQmtGA0LDRgdC90L7QtNCw0YAsINCa0YDQsNGB0L3QvtC00LDRgNGB0LrQuNC5INC60YDQsNC5LCAzNTAwNDk!5e0!3m2!1sru!2sru!4v1545661862994',
		},
		4 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d3366.082407824613!2d60.59971102228466!3d56.83506126508861!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x43c16e8b5f8ac771%3A0xbe86e24aa791a4bb!2z0YPQuy4g0JLQvtC10LLQvtC00LjQvdCwLCA4LCDQldC60LDRgtC10YDQuNC90LHRg9GA0LMsINCh0LLQtdGA0LTQu9C-0LLRgdC60LDRjyDQvtCx0LsuLCA2MjAwMTQ!5e0!3m2!1sru!2sru!4v1545656551391',
		},
		5 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5336.3034966631785!2d49.12628122335797!3d55.78213722804083!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x415ead0f53431109%3A0x5edc1ff305beb11a!2z0YPQuy4g0J7RgdGC0YDQvtCy0YHQutC-0LPQviwgODcsINCa0LDQt9Cw0L3RjCwg0KDQtdGB0L8uINCi0LDRgtCw0YDRgdGC0LDQvSwgNDIwMTA3!5e0!3m2!1sru!2sru!4v1506952021696',
		},
		6 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2740.575416719489!2d20.495179290504097!3d54.717715025426095!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x46e316026984b447%3A0x758087eae20bd255!2z0KLQtdCw0YLRgNCw0LvRjNC90LDRjyDRg9C7LiwgMzUsINCa0LDQu9C40L3QuNC90LPRgNCw0LQsINCa0LDQu9C40L3QuNC90LPRgNCw0LTRgdC60LDRjyDQvtCx0LsuLCDQoNC-0YHRgdC40Y8sIDIzNjAyMg!5e0!3m2!1sru!2sus!4v1507017964745',
		},
		7 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2423.483672359161!2d39.56490665396935!3d52.597027754069344!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x413a14b7f23e8931%3A0xa7455e55c7a3335e!2z0J_QvtCx0LXQtNGLINC_0YDQvtGB0L8uLCAyOSwg0JvQuNC_0LXRhtC6LCDQm9C40L_QtdGG0LrQsNGPINC-0LHQuy4sINCg0L7RgdGB0LjRjywgMzk4MDI0!5e0!3m2!1sru!2sus!4v1507115332524',
		},
		8 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d1860.3280882083777!2d44.02299793403522!3d56.324387651739116!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0xa97598ec37db9eea!2z0JLQuNC30L7QstGL0Lkg0YbQtdC90YLRgCDQmNGC0LDQu9C40Lg!5e0!3m2!1sru!2sus!4v1507118302854',
		},
		9 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2719.80607812909!2d82.91806527224412!3d55.02437475371322!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x42dfe5d6e828d6d5%3A0xe68a3cc4011b6b66!2z0JLQuNC30L7QstGL0Lkg0YbQtdC90YLRgCDQmNGC0LDQu9C40Lgg0JLQuNC30LAg0JzQtdC90LXQtNC20LzQtdC90YIg0KHQtdGA0LLQuNGB!5e0!3m2!1sru!2sus!4v1507119579640',
		},
		11 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5036.634742618291!2d30.318217275097204!3d59.935629223540865!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x469630ffd933da03%3A0x7d386bb2d2959b57!2z0JLQuNC30L7QstGL0Lkg0YbQtdC90YLRgCDQmNGC0LDQu9C40Lg!5e0!3m2!1sru!2sru!4v1507204883829',
		},
		12 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d3874.60768071978!2d55.938371750184494!3d54.72975631631248!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x43d93a5d6cccb7bd%3A0xea3b19356293b83f!2z0YPQuy4g0KfQtdGA0L3Ri9GI0LXQstGB0LrQvtCz0L4sIDgyLCDQo9GE0LAsINCg0LXRgdC_LiDQkdCw0YjQutC-0YDRgtC-0YHRgtCw0L0sIDQ1MDA3Ng!5e0!3m2!1sru!2sru!4v1507193658459',
		},
		13 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d3851.3253490119305!2d73.39918849873813!3d54.97289304405158!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x43aafde0be19edf3%3A0x8d2a74edfc17ad5c!2z0YPQuy4g0JzQsNGP0LrQvtCy0YHQutC-0LPQviwgODEsINCe0LzRgdC6LCDQntC80YHQutCw0Y8g0L7QsdC7LiwgNjQ0MDEw!5e0!3m2!1sru!2sru!4v1507125860200',
		},
		14 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d34275.202418300236!2d43.09398859722409!3d44.2174832487165!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x4057a3132c88fff9%3A0xa7139c7fc69bb96e!2z0JzQtdC20LTRg9C90LDRgNC-0LTQvdGL0Lkg0LDRjdGA0L7Qv9C-0YDRgiDQnNC40L3QtdGA0LDQu9GM0L3Ri9C1INCS0L7QtNGL!5e0!3m2!1sru!2sus!4v1507116858646',
		},
		15 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d1611.468175586749!2d61.40528548976603!3d55.16647334691504!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x43c5ed497505e481%3A0xc98f04ef1d158fa4!2z0YPQuy4g0KHQvtCy0LXRgtGB0LrQsNGPLCAyNSwg0KfQtdC70Y_QsdC40L3RgdC6LCDQp9C10LvRj9Cx0LjQvdGB0LrQsNGPINC-0LHQuy4sIDQ1NDA5MQ!5e0!3m2!1sru!2sru!4v1507202655838',
		},
		16 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5641.628644413466!2d41.923866931891375!3d45.008392363481526!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x40f9aa5a84dc15a3%3A0xf062d156f16a693a!2z0YPQuy4g0JTQvtCy0LDRgtC-0YDRhtC10LIsIDU1LCDQodGC0LDQstGA0L7Qv9C-0LvRjCwg0KHRgtCw0LLRgNC-0L_QvtC70YzRgdC60LjQuSDQutGA0LDQuSwgMzU1MDQy!5e0!3m2!1sru!2sru!4v1507186108974',
		},
		17 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d4408.317981720527!2d39.209547254855515!3d51.676590851201055!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x413b2f04463b7331%3A0x964c2b28904d7da6!2z0YPQuy4g0JDRgNGB0LXQvdCw0LvRjNC90LDRjywgMywg0JLQvtGA0L7QvdC10LYsINCS0L7RgNC-0L3QtdC20YHQutCw0Y8g0L7QsdC7LiwgMzk0MDM2!5e0!3m2!1sru!2sru!4v1506335849015',
		},
		18 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2767.315409826377!2d48.39884609399884!3d54.32117864959835!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x415d3768fb51db29%3A0x8b22687ff147b55!2z0YPQuy4g0JPQvtC90YfQsNGA0L7QstCwLCAyNywg0KPQu9GM0Y_QvdC-0LLRgdC6LCDQo9C70YzRj9C90L7QstGB0LrQsNGPINC-0LHQuy4sIDQzMjAxMQ!5e0!3m2!1sru!2sru!4v1507192380982',
		},
		19 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2709.847935668461!2d39.710548215469146!3d47.21955762262761!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x40e3b90d801c8ca7%3A0x40413178692f8749!2z0JLQuNC30L7QstGL0Lkg0KbQtdC90YLRgCDQmNGC0LDQu9C40Lg!5e0!3m2!1sru!2sru!4v1507184061525',
		},
		20 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5266.62184375198!2d44.50141563268069!3d48.699537879272256!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x411acb4ce302cf63%3A0x31f8ffcc4cf9b6f5!2z0YPQuy4gSE0uINCa0LDQu9C40L3QuNC90LAsIDEzLCDQktC-0LvQs9C-0LPRgNCw0LQsINCS0L7Qu9Cz0L7Qs9GA0LDQtNGB0LrQsNGPINC-0LHQuy4sIDQwMDAwMQ!5e0!3m2!1sru!2sru!4v1506338460449',
		},
		21 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2052.2856879850624!2d104.28547126251219!3d52.28709525184141!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x5da83b35efcbca21%3A0xbba70529616e4b77!2z0YPQuy4g0KHQstC10YDQtNC70L7QstCwLCAzNiwg0JjRgNC60YPRgtGB0LosINCY0YDQutGD0YLRgdC60LDRjyDQvtCx0LsuLCA2NjQwMTE!5e0!3m2!1sru!2sru!4v1506951318361
',
		},
		22 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2203.298726995764!2d84.94636361579009!3d56.47984144315068!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x432693367a35f3ab%3A0x78f7c32839f5bd46!2z0JLQuNC30L7QstGL0Lkg0YbQtdC90YLRgCDQmNGC0LDQu9C40Lg!5e0!3m2!1sru!2sru!4v1507187779295',
		},
		23 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d4758.769162249326!2d131.9063048486937!3d43.115145389433685!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x5fb3927406259831%3A0x2676d756b5590197!2z0JHQuNC30L3QtdGBLdGG0LXQvdGC0YAgItCk0YDQtdCz0LDRgiI!5e0!3m2!1sru!2sru!4v1545643904945',
		},
		24 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2230.4307354816337!2d92.85450461577277!3d56.01121267949959!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x5cd7ae1380bb8b27%3A0xccbf404f8af9a807!2z0JLQmNCX0J7QktCr0Jkg0KbQldCd0KLQoCDQmNCi0JDQm9CY0Jgg0JIg0JMuINCa0KDQkNCh0J3QntCv0KDQodCa0JUsINCe0J7QniAi0JLQuNC30LAg0JzQtdC90LXQtNC20LzQtdC90YIg0KHQtdGA0LLQuNGBIg!5e0!3m2!1sru!2sus!4v1507032135636',
		},
		25 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2175.415729385683!2d56.2371413350174!3d58.01347319955967!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x43e8c7275fbeff59%3A0x3454d8bb475dfa7!2z0J_QtdGC0YDQvtC_0LDQstC70L7QstGB0LrQsNGPINGD0LsuLCA0MSwg0J_QtdGA0LzRjCwg0J_QtdGA0LzRgdC60LjQuSDQutGA0LDQuSwgNjE0MDQ1!5e0!3m2!1sru!2sru!4v1507127980173',
		},
		26 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d4384.373752867295!2d36.589233853071924!3d50.59461772699955!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x41266a595251c35d%3A0x65a2aaa166082075!2z0JPRgNCw0LbQtNCw0L3RgdC60LjQuSDQv9GALiwgNDcsINCR0LXQu9Cz0L7RgNC-0LQsINCR0LXQu9Cz0L7RgNC-0LTRgdC60LDRjyDQvtCx0LsuLCAzMDgwMDk!5e0!3m2!1sru!2sru!4v1506329219920',
		},
		27 => {
			type => 'yandexwidget',
			code => 'CBRzaWGS9C',
		},
		29 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5036.634742618291!2d30.318217275097204!3d59.935629223540865!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x469630ffd933da03%3A0x7d386bb2d2959b57!2z0JLQuNC30L7QstGL0Lkg0YbQtdC90YLRgCDQmNGC0LDQu9C40Lg!5e0!3m2!1sru!2sru!4v1507204883829',
		},
		30 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5036.634742618291!2d30.318217275097204!3d59.935629223540865!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x469630ffd933da03%3A0x7d386bb2d2959b57!2z0JLQuNC30L7QstGL0Lkg0YbQtdC90YLRgCDQmNGC0LDQu9C40Lg!5e0!3m2!1sru!2sru!4v1507204883829',
		},
		31 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2246.7159099818205!2d37.61065748657057!3d55.72868910989216!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x46b54b0fe9fb25%3A0xf7bafeda82d7866a!2z0YPQuy4g0JzRi9GC0L3QsNGPLCAx0YExLCDQnNC-0YHQutCy0LAsIDExOTA0OQ!5e0!3m2!1sru!2sru!4v1463477662381',
		},
		32 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2246.7159099818205!2d37.61065748657057!3d55.72868910989216!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x46b54b0fe9fb25%3A0xf7bafeda82d7866a!2z0YPQuy4g0JzRi9GC0L3QsNGPLCAx0YExLCDQnNC-0YHQutCy0LAsIDExOTA0OQ!5e0!3m2!1sru!2sru!4v1463477662381',
		},
		33 => {
			type => 'googlemap',
			code => 'b1c1f%3A0x7fd64f2b9446473b!2z0YPQuy4g0KHQstC10YDQtNC70L7QstCwLCAxOCwg0J_QtdGC0YDQvtC30LDQstC-0LTRgdC6LCDQoNC10YHQvy4g0JrQsNGA0LXQu9C40Y8sIDE4NTAzNQ!5e0!3m2!1sru!2sru!4v1507211550774',
		},
		34 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5036.634742618291!2d30.318217275097204!3d59.935629223540865!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x469630ffd933da03%3A0x7d386bb2d2959b57!2z0JLQuNC30L7QstGL0Lkg0YbQtdC90YLRgCDQmNGC0LDQu9C40Lg!5e0!3m2!1sru!2sru!4v1507204883829',
		},
		35 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2670.908755099672!2d37.61597124228185!3d55.74186571800983!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x46b54affd9094bff%3A0x96edb30455a9b2a3!2z0JzQsNC70YvQuSDQotC-0LvQvNCw0YfQtdCy0YHQutC40Lkg0L_QtdGALiwgNtGBMSwg0JzQvtGB0LrQstCwLCAxMTkwMTc!5e0!3m2!1sru!2sru!4v1507287664868',
		},
		36 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d2670.908755099672!2d37.61597124228185!3d55.74186571800983!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x46b54affd9094bff%3A0x96edb30455a9b2a3!2z0JzQsNC70YvQuSDQotC-0LvQvNCw0YfQtdCy0YHQutC40Lkg0L_QtdGALiwgNtGBMSwg0JzQvtGB0LrQstCwLCAxMTkwMTc!5e0!3m2!1sru!2sru!4v1507287664868',
		},
		37 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5036.634742618291!2d30.318217275097204!3d59.935629223540865!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x469630ffd933da03%3A0x7d386bb2d2959b57!2z0JLQuNC30L7QstGL0Lkg0YbQtdC90YLRgCDQmNGC0LDQu9C40Lg!5e0!3m2!1sru!2sru!4v1507204883829',
		},
		38 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5054.669918165643!2d28.3447489572605!3d57.81446769668274!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x46c01930cf622a79%3A0xccf366d2aac3dda5!2z0JTQtdC70L7QstC-0Lkg0YbQtdC90YLRgCAi0KPQvtC70Lst0YHRgtGA0LjRgiI!5e0!3m2!1sru!2sru!4v1543853587315',
		},
		39 => {
			type => 'yandexconstructor',
			code => '3A3d7ed7da855c4018a82cf0479114d00d5478ac5a72d18ba5a42ca9d83f019591',
		},
		40 => {
			type => 'yandexconstructor',
			code => '3A3d7ed7da855c4018a82cf0479114d00d5478ac5a72d18ba5a42ca9d83f019591',
		},
		41 => {
			type => 'yandexconstructor',
			code => '3A3d7ed7da855c4018a82cf0479114d00d5478ac5a72d18ba5a42ca9d83f019591',
		},
		43 => {
			type => 'googlemap',
			code => '!1m18!1m12!1m3!1d5036.634742618291!2d30.318217275097204!3d59.935629223540865!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x469630ffd933da03%3A0x7d386bb2d2959b57!2z0JLQuNC30L7QstGL0Lkg0YbQtdC90YLRgCDQmNGC0LDQu9C40Lg!5e0!3m2!1sru!2sru!4v1507204883829',
		},
		44 => {
			type => 'yandexconstructor',
			code => '3A3d7ed7da855c4018a82cf0479114d00d5478ac5a72d18ba5a42ca9d83f019591',
		},
		45 => {
			type => 'yandexconstructor',
			code => '3A3d7ed7da855c4018a82cf0479114d00d5478ac5a72d18ba5a42ca9d83f019591',
		},
		
	};
};

sub get_doc_list
# //////////////////////////////////////////////////
{
	return {
		1 => [ 
			{ 
				id => 1001,
				title => 'Действующий загранпаспорт',
				comment => 'Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 1002,
				title => 'Второй действующий загранпаспорт',
				optional => 1,
				comment => 'При наличии, предоставляется обязательно. Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 1003,
				title => 'Аннулированный загранпаспорт',
				optional => 1,
				comment => 'По желанию (показать визовую историю/наличие ранее сданных отпечатков пальцев). Необходимо загрузить все страницы одним файлом.',
			},
			{
				id => 1004,
				title => 'Справка с работы',
				multiple => 3,
			},
			{
				id => 1005,
				title => 'Свидетельство ЕГРЮЛ/ЕГРИП',
				multiple => 2,
				optional => 1,
				comment => 'Для сотрудников пресс-служб и государственных учреждений необязательно.',
			},
			{
				id => 1006,
				title => 'Финансовая гарантия',
				multiple => 10,
			},
			{
				id => 1007,
				title => 'Внутренний паспорт',
				multiple => 5,
				comment => 'Для граждан РФ: страница с личными данными и прописка. Для иностранных граждан: регистрация/РВП/ВНЖ, действующая виза РФ, Миграционная карта/патент/разрешение на работу.',
			},
			{
				id => 1008,
				title => 'Приглашение от организации',
				multiple => 10,
				help => {
					base => {
						ru => '/priglashenie/',
						en => '/invitation-letter/',
						it => '/lettera-dinvito/',
					},
				},
				comment => 'Приглашение должно быть установленного образца.',
			},
			{
				id => 1009,
				title => 'Документы приглашающего лица',
				multiple => 2,
				comment => 'Страница с личной подписью обязательна.',
			},
			{
				id => 1010,
				title => 'Выписка из Торговой Палаты',
				optional => 1,
				comment => 'Загружается СТРОГО одним файлом.',
			},
			{
				id => 1011,
				title => 'Подтверждение проживания',
				multiple => 10,
				optional => 1,
				comment => 'Необходимо предоставить, если не указано в приглашении от организации.',
			},
			{ 
				id => 1012,
				title => 'Медицинская страховка',
				help => {
					base => {
						ru => '/medicinskaya-straxovka/',
						en => '/international-medical-insurance-valid-for-all-the-schengen-territory-3/',
						it => '/assicurazione-medica-valida-per-i-paesi-dello-spazio-schengen-3/',
					},
				},
			},
			{ 
				id => 1013,
				title => 'Документы подтверждающие льготную категорию по оплате консульского сбора',
				optional => 1,
				multiple => 10,
				help => {
					base => {
						ru => '/lgotnye-kategorii/',
						en => '/lgotnye-kategorii/',
						it => '/lgotnye-kategorii/',
					},
				},
			},
			{
				id => 1014,
				title => 'Доверенность на подачу',
				optional => 1,
				multiple => 3,
			},
		],
		15 => [ 
			{ 
				id => 15001,
				title => 'Действующий загранпаспорт',
				comment => 'Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 15002,
				title => 'Второй действующий загранпаспорт',
				optional => 1,
				comment => 'При наличии, предоставляется обязательно. Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 15003,
				title => 'Аннулированный загранпаспорт',
				optional => 1,
				comment => 'По желанию (показать визовую историю/наличие ранее сданных отпечатков пальцев). Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 15004,
				title => 'Действующее водительское удостоверение',
				multiple => 2,
			},
			{
				id => 15005,
				title => 'Финансовая гарантия',
				multiple => 5,
				comment => 'В дополнение к личной финансовой гарантии можно предоставить гарантийное письмо от транспортной компании.',
			},
			{
				id => 15006,
				title => 'Справка с работы или трудовой договор',
				multiple => 3,
				comment => 'В справке с работы должно быть указано, что перевозка грузов осуществляется на транспортном средстве, не зарегистрированном в странах Шенгенского соглашения. Если не указано, то необходимо сопроводительное письмо от транспортной компании, с указанием данной информации.',
			},
			{
				id => 15007,
				title => 'Копия свидетельства о внесении в ЕГРЮЛ',
			},
			{
				id => 15008,
				title => 'Действующее удостоверение допуска Министерства Транспорта РФ к осуществлению международных автомобильных перевозок.',
			},
			{
				id => 15009,
				title => 'Копия членского билета или свидетельства АСМАП',
				optional => 1,
				multiple => 3,
				comment => 'Если организация является действующим членом АСМАП.',
			},
			{
				id => 15010,
				title => 'Внутренний паспорт',
				multiple => 5,
				comment => 'Для граждан РФ: страница с личными данными и прописка. Для иностранных граждан: регистрация/РВП/ВНЖ, действующая виза РФ, Миграционная карта/патент/разрешение на работу.',
			},
			{
				id => 15011,
				title => 'Приглашение от итальянской транспортной компании',
				multiple => 2,
			},
			{
				id => 15012,
				title => 'Документы приглашающего лица',
				multiple => 2,
				comment => 'Страница с личной подписью обязательна.',
			},
			{
				id => 15013,
				title => 'Выписка из Торговой Палаты',
				optional => 1,
				comment => 'Загружается СТРОГО одним файлом.',
			},
			{ 
				id => 15014,
				title => 'Страховка',
			},
			{
				id => 15015,
				title => 'Объяснительное письмо от компании',
				optional => 1,
				comment => 'Если виза использовалась не по назначению — пересечение границы поездом или самолетом.',
			},
		],
		2 => [ 
			{ 
				id => 2001,
				title => 'Действующий загранпаспорт',
				comment => 'Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 2002,
				title => 'Второй действующий загранпаспорт',
				optional => 1,
				comment => 'При наличии, предоставляется обязательно. Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 2003,
				title => 'Аннулированный загранпаспорт',
				optional => 1,
				comment => 'По желанию (показать визовую историю/наличие ранее сданных отпечатков пальцев). Необходимо загрузить все страницы одним файлом.',
			},
			{
				id => 2004,
				title => 'Внутренний паспорт',
				multiple => 5,
				comment => 'Для граждан РФ: страница с личными данными и прописка. Для иностранных граждан: регистрация/РВП/ВНЖ, действующая виза РФ, Миграционная карта/патент/разрешение на работу.',
			},
			{ 
				id => 2005,
				title => 'Приглашение от государственной или частной клиники',
				multiple => 5,
			},
			{ 
				id => 2006,
				title => 'Лицензия клиники или аккредитация от Национальной Службы Здравоохранения',
				multiple => 5,
				optional => 1,
				comment => 'Если приглашение от частной клиники',
			},
			{ 
				id => 2007,
				title => 'Подтверждение оплаты курса лечения от клиники',
				multiple => 3,
				comment => 'Минимум 30% от стоимости курса лечения/гарантия госучреждения/организации оплатить расходы',
			},
			{ 
				id => 2008,
				title => 'Медицинская документация, подтверждающая диагноз, эпикриз',
				multiple => 10,
			},
			{
				id => 2009,
				title => 'Финансовая гарантия',
				multiple => 10,
				comment => 'Демонстрация достаточных средств на оплату оставшихся 70% стоимости курса лечения.',
			},
			{ 
				id => 2010,
				title => 'Сведения о занятости',
				multiple => 5,
				optional => 1,
				comment => 'Необходимо предоставить сопровождающим лицам.',
			},
			{
				id => 2011,
				title => 'Подтверждение проживания',
				multiple => 10,
				optional => 1,
				comment => 'Необходимо предоставить, если не указано в приглашении от организации.',
			},
			{
				id => 2012,
				title => 'Бронь авиабилета в одну сторону',
				multiple => 3,
				comment => 'Бронь билета туда и обратно.',
			},
			{ 
				id => 2013,
				title => 'Страховка',
				comment => 'На первые 8-30 дней пребывания.',
			},
		],
		3 => [ 
			{ 
				id => 3001,
				title => 'Действующий загранпаспорт',
				comment => 'Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 3002,
				title => 'Второй действующий загранпаспорт',
				optional => 1,
				comment => 'При наличии, предоставляется обязательно. Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 3003,
				title => 'Аннулированный загранпаспорт',
				optional => 1,
				comment => 'По желанию (показать визовую историю/наличие ранее сданных отпечатков пальцев). Необходимо загрузить все страницы одним файлом.',
			},
			{
				id => 3004,
				title => 'Внутренний паспорт',
				multiple => 5,
				comment => 'Для граждан РФ: страница с личными данными и прописка. Для иностранных граждан: регистрация/РВП/ВНЖ, действующая виза РФ, Миграционная карта/патент/разрешение на работу.',
			},
			{ 
				id => 3005,
				title => 'Приглашение от государственной или частной клиники',
				multiple => 5,
			},
			{ 
				id => 3006,
				title => 'Лицензия клиники или аккредитация от Национальной Службы Здравоохранения',
				multiple => 5,
				optional => 1,
				comment => 'Если приглашение от частной клиники',
			},
			{ 
				id => 3007,
				title => 'Подтверждение оплаты курса лечения от клиники',
				multiple => 3,
				comment => 'Минимум 30% от стоимости курса лечения/гарантия госучреждения/организации оплатить расходы',
			},
			{ 
				id => 3008,
				title => 'Медицинская документация, подтверждающая диагноз, эпикриз',
				multiple => 10,
			},
			{
				id => 3009,
				title => 'Финансовая гарантия',
				multiple => 10,
				comment => 'Демонстрация достаточных средств на оплату оставшихся 70% стоимости курса лечения.',
			},
			{ 
				id => 3010,
				title => 'Сведения о занятости',
				multiple => 5,
				optional => 1,
				comment => 'Необходимо предоставить сопровождающим лицам.',
			},
			{
				id => 3011,
				title => 'Подтверждение проживания',
				multiple => 10,
				optional => 1,
				comment => 'Необходимо предоставить, если не указано в приглашении от организации.',
			},
			{
				id => 3012,
				title => 'Бронь авиабилета в одну сторону',
				multiple => 3,
				comment => 'Бронь билета в одну сторону.',
			},
			{ 
				id => 3013,
				title => 'Страховка',
				comment => 'На первые 8-30 дней пребывания.',
			},
		],
		10 => [ 
			{ 
				id => 10001,
				title => 'Действующий загранпаспорт',
				comment => 'Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 10002,
				title => 'Второй действующий загранпаспорт',
				optional => 1,
				comment => 'При наличии, предоставляется обязательно. Необходимо загрузить все страницы одним файлом.',
			},
			{ 
				id => 10003,
				title => 'Аннулированный загранпаспорт',
				optional => 1,
				comment => 'По желанию (показать визовую историю/наличие ранее сданных отпечатков пальцев). Необходимо загрузить все страницы одним файлом.',
			},
			{
				id => 10004,
				title => 'Внутренний паспорт',
				multiple => 5,
				comment => 'Для граждан РФ: страница с личными данными и прописка. Для иностранных граждан: регистрация/РВП/ВНЖ, действующая виза РФ, Миграционная карта/патент/разрешение на работу.',
			},
			{ 
				id => 10005,
				title => 'Заявление  с указанием причины подачи документов на повторный въезд установленного образца',
				help => {
					base => {
						ru => '/wp-content/uploads/2018/07/Modulo_richiesta_visto_reingresso.pdf',
						en => '/wp-content/uploads/2018/07/Modulo_richiesta_visto_reingresso.pdf',
						it => '/wp-content/uploads/2018/07/Modulo_richiesta_visto_reingresso.pdf',
					},
				},
			},
			{ 
				id => 10006,
				title => 'Копия квитанции на получение/продление вида на жительство',
				multiple => 2,
				optional => 1,
				comment => 'Если Ricevuta не была проштампована при выезде из Италии.',
			},
			{ 
				id => 10007,
				title => 'Копия просроченного вида на жительство с обеих сторон',
				multiple => 2,
				optional => 1,
				comment => 'Если причина повторного въезда — восстановление просроченного вида на жительство.',
			},
			{ 
				id => 10008,
				title => 'Копия справки из полиции с переводом на итальянский язык ',
				multiple => 5,
				optional => 1,
				comment => 'В случае кражи документов.',
			},
			{
				id => 10009,
				title => 'Копия документа с указанием даты выезда из Италии',
				multiple => 3,
				comment => 'Разворот загранпаспорта с выездным штампом или справка из Посольства на выезд из страны.',
			},
		],
	};
}

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
	my $type = shift;
	
	if ( $type == 3 ) {
		
		return [ '',
			{ big => 1, name => 'Доставка курьером', },
			{ big => 1, name => 'Документы получены', },
			{ big => 1, name => 'Переданы в Консульство', },
			{ big => 1, name => 'Готовы для получения', },
			{ big => 1, name => 'В доставке', },
			{ big => 1, name => 'Получены', },
		];
	}
	else {
		return [ '',
			{ big => 1, name => 'Ожидает оплаты', },
			{ big => 1, name => 'Документы приняты', },
			{ big => 1, name => 'Переданы в Консульство', },
			{ big => 1, name => 'Готовы для получения', },
			{ big => 1, name => 'В доставке', },
			{ big => 1, name => 'Получены', },
		];
	}
}

sub get_link_text_head
# //////////////////////////////////////////////////
{
	return {
		1 => 'Вы начали запись на подачу документов на визу',
		2 => 'Вы начали онлайн проверку документов на визу',
	};
};

sub get_services
# //////////////////////////////////////////////////
{
	return {
		'check' => 2,
	};
};

sub get_link_text
# //////////////////////////////////////////////////
{
	return {
		1 => {
			1 => 'Уважаемый заявитель!<br>Вы начали создание записи на сайте <b>Итальянского Визового центра</b>.<br>Вы в любой момент можете продолжить запись перейдя по ссылке:',
			2 => '<br><br><a href="/autoform/?t=[token]" style="display: inline-block; font-family: arial,sans-serif; font-size: 14px; font-weight: bold; color: #444444; text-decoration: none; user-select: none; padding: .2em 1.2em; outline: none; border: 1px solid #c0c0c0; border-radius: 2px; background: #F5F5F5; target="_blank">',
			3 => 'Информация о записи',
			4 => '</a><br><br>',
			5 => 'Перейдя по этой записи Вы сможете:<br>1. Продолжить запись в Визовый центр, которую Вы начали не более 14 дней назад.<br>2. После завершения записи Вы сможете получать информацию о своей записи, отменить её или перенесети на другое время, распечатать уже заполненную шенгенскую анкету.<br>3. После подачи Вы сможете отслеживать статус документов, их отправку в Консульство и готовность к получению.<br><br>',
			6 => '<b>Внимание! Это письмо сформировано автоматически, пожалуйста, не отвечайте на него.</b><br><br>',
			7 => 'С уважением,<br>Итальянский визовый центр',
		},
		2 => {
			1 => 'Уважаемый заявитель!<br>Вы начали оформление записи на услугу <b>«Онлайн проверка документов»</b> на сайте <b>Итальянского Визового центра</b>.<br>Вы в любой момент, в течение 14 дней, Вы можете продолжить запись перейдя по ссылке:',
			2 => '<br><br><a href="/autoform/?t=[token]" style="display: inline-block; font-family: arial,sans-serif; font-size: 14px; font-weight: bold; color: #444444; text-decoration: none; user-select: none; padding: .2em 1.2em; outline: none; border: 1px solid #c0c0c0; border-radius: 2px; background: #F5F5F5; target="_blank">',
			3 => 'Информация о записи',
			4 => '</a><br><br>',
			5 => 'После завершения записи и загрузки документов на Вашу электронную почту придет сообщение о статусе проверки.<br>После оплаты данной услуги у Вас будет возможность, внести корректировки и загрузить исправленный вариант файла в течение <b>3-х рабочих дней</b>.<br><br>',
			6 => '<b>Внимание! Это письмо сформировано автоматически, пожалуйста, не отвечайте на него.</b><br><br>',
			7 => 'С уважением,<br>Итальянский визовый центр',
		}
	};
};

sub get_checkdoc_text
# //////////////////////////////////////////////////
{
	return {
		1 => {
			1 => 'Уважаемый заявитель!<br>Ваши документы отправлены на проверку. Результат будет отправлен Вам в течение одного рабочего дня (с 9:00-18:00, по московскому времени), с момента оплаты.',
			2 => '<br><br><a href="/autoform/?t=[token]" style="display: inline-block; font-family: arial,sans-serif; font-size: 14px; font-weight: bold; color: #444444; text-decoration: none; user-select: none; padding: .2em 1.2em; outline: none; border: 1px solid #c0c0c0; border-radius: 2px; background: #F5F5F5; target="_blank">',
			3 => 'Узнать статус проверки доументов',
			4 => '</a><br><br>',
			5 => '<b>Внимание! Это письмо сформировано автоматически, пожалуйста, не отвечайте на него.</b><br><br>',
			6 => 'С уважением,<br>Итальянский визовый центр',
		},
		2 => {
			1 => 'Уважаемый заявитель!<br>Ваши документы были проверены. С результатом Вы можете ознакомиться по следующей ссылке:',
			2 => '<br><br><a href="/autoform/?t=[token]" style="display: inline-block; font-family: arial,sans-serif; font-size: 14px; font-weight: bold; color: #444444; text-decoration: none; user-select: none; padding: .2em 1.2em; outline: none; border: 1px solid #c0c0c0; border-radius: 2px; background: #F5F5F5; target="_blank">',
			3 => 'Узнать статус проверки доументов',
			4 => '</a><br><br>',
			5 => 'В случае, если предоставленные Вами документы не соответствуют требованиям Консульства, у Вас будет возможность загрузить исправленную версию документа в течение <b>3-х рабочих дней</b>. Если по истечении <b>3-х рабочих дней</b> с Вашей стороны не будет предпринято никаких действий, услуга будет считаться оказанной полностью.',
			6 => '</a><br><br>',
			7 => '<b>Внимание! Это письмо сформировано автоматически, пожалуйста, не отвечайте на него.</b><br><br>',
			8 => 'С уважением,<br>Итальянский визовый центр',
		},
		3 => {
			1 => 'Уважаемый заявитель!<br>Спасибо что воспользовались услугой «Онлайн проверка документов».',
			2 => '<br><br>Обращаем Ваше внимание на то, что на момент посещения Визового центра необходимо иметь <a href="/documentformsk/dokumenty-na-delovuyu-vizu-2/">актуальный комплект документов</a> в оригинале, фото (при необходимости можно сделать в ВЦ), заполненное Согласие на обработку персональных данных.',
			3 => '<br><br>',
			5 => '<b>Внимание! Это письмо сформировано автоматически, пожалуйста, не отвечайте на него.</b><br><br>',
			6 => 'С уважением,<br>Итальянский визовый центр',
		},
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
		vms_tx => 'С уважением',
		info_btn => 'Информация о записи',
		resh_btn => 'Изменить время записи',
		canc_btn => 'Отменить запись',
		prnt_btn => 'Распечатать запись',
		branch_tx => 'Визовый центр Италии',
		dis_head => 'Отказ от ответственности',
		dis_tx => 'Информация в этом сообщении предназначена исключительно для конкретных лиц, которым она адресована. В сообщении может содержаться конфиденциальная информация, которая не может быть раскрыта или использована кем-либо кроме адресатов. Если вы не адресат этого сообщения, то использование, переадресация, копирование или распространение содержания сообщения или его части незаконно и запрещено. Если Вы получили это сообщение ошибочно, пожалуйста, незамедлительно сообщите отправителю об этом и удалите со всем содержимым само сообщение и любые возможные его копии и приложения.',
		no_reply_head => 'Внимание!',
		no_reply => 'Это письмо сформировано автоматически, пожалуйста, не отвечайте на него.',
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
