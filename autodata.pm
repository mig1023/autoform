package VCS::Site::autodata;
use strict;

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

sub get_page_error
# //////////////////////////////////////////////////
{
	return [
		'для правильной работы анкеты необходимо, чтобы в браузере был включён javascript',
		'неправильный токен',
		'такого токена не существует',
		'запись уже завершена',
	];
}

sub get_text_error
# //////////////////////////////////////////////////
{
	return [
		'Поле "[name]" не заполнено',
		'В поле "[name]" указана неверная дата',
		'В поле "[name]" введены недопустимые символы',
		'Вы должны указать поле "[name]"',
		'Вы должны полностью заполнить анкеты или удалить ненужные черновики',
		'Вы должны добавить по меньшей мере одного заявителя',
		'"[name]" не может быть раньше, чем "[relation]"',
		'"[name]" не может быть раньше, чем "[relation]" на [offset]',
		'"[name]" не может быть позднее, чем "[relation]"',
		'"[name]" не может быть позднее, чем "[relation]" на [offset]',
		'Поле "[name]" уже встречается в актуальных записях',
		'В поле "[name]" нужно выбрать хотя бы одно значение',
		'Недопустимая дата в поле "[name]"',
		'Необходимо заполнить поле "[name]" или указать "[relation]"',
		'Необходимо заполнить поле "[name]", если заполнено "[relation]"',
		'Введён недопустимый индекс или город в поле "[name]", попробуйте указать другой',
		'Вы ввели недопустимый адрес электронной почты',
		'Этот электронный адрес был заблокирован.<br>Вы превысили допустимое количество записей',
		'Капча введена неверно.<br>Пожалуйста, попробуйте ещё раз',
		'Анкеты заполнены для другого типа визы, проверьте правильность их заполнения',
	];
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