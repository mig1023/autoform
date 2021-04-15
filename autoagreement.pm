package VCS::Site::autoagreement;
use strict;
use utf8;

use Math::Random::Secure qw(irand); 
use Data::Dumper;

sub new
# //////////////////////////////////////////////////
{
	my ( $class, $pclass, $vars ) = @_;
	
	my $self = bless {}, $pclass;
	
	$self->{ 'VCS::Vars' } = $vars;
	
	return $self;
}

sub create_online_appointment
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
	);

	$self->{ af }->log(
		"autoinfo_remote", "удалённая запись после проверки документов", $app_id
	);
	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE Appointments SET Status = 13, AppDate = now(), CenterID = 47 WHERE ID = ?", {}, $app_id
	);
	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE AutoToken SET ServiceType = 3 WHERE Token = ?", {}, $self->{ token }
	);
}

sub create_online_agreement
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	$self->{ af }->query( 'query', __LINE__, "
		LOCK TABLES
			DocHistory WRITE, DocPack WRITE, DocPackInfo WRITE, DocPackList WRITE,
			DocPackOptional WRITE, UserLog WRITE, Templates WRITE,
			Appointments WRITE, AppData WRITE, DocRequest WRITE, DocComments WRITE, AutoRemote WRITE,
			AutoPayment READ, AutoToken READ, VisaTypes READ, PriceRate READ, PriceList READ"
	);

	my $now = $self->{ vars }->get_system->now_date();
	
	my $agreementNo = $self->{ vars }->admfunc->getAgrNumber( $self->{ vars }, 47, $now );
	
	my $rate = $self->{ vars }->admfunc->getRate( $self->{ vars }, 'RUR', $now, 47 );

	my ( $sms_price, undef ) = $self->{ af }->get_payment_price( "sms" );

	my ( $service_fee, $count ) = $self->{ af }->get_payment_price( "service" );

	my $app = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT Appointments.ID as AppID, FoxAddress, FName, LName, MName,
		Appointments.VType, Appointments.ID, SMS, Phone, Mobile, PassNum, PassDate,
		PassWhom, Appointments.Address,	AutoRemote.BankID, AutoRemote.PVC,
		AutoToken.EMail, AutoRemote.ID as AutoRemoteID
		FROM AutoToken
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		JOIN AutoRemote ON Appointments.ID = AutoRemote.AppID
		WHERE Token = ?", $self->{ token }
	)->[0];
	
	my $sms = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT AutoPayment.ID FROM AutoPayment
		JOIN AutoToken ON AutoPayment.AutoID = AutoToken.CreatedApp
		WHERE Token = ? AND AutoPayment.`Type` = 'sms' AND PaymentStatus = 2",
		$self->{ token }
	);
	
	$sms = ( $sms ? 1 : 0 );

	my $dsum = ( $service_fee * $count ) + ( $sms ? $sms_price : 0 );

	my $template = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT ID FROM Templates WHERE TDate <= curdate() AND isJur=0 AND CenterID=47 ORDER BY TDate DESC LIMIT 1"
	);
	
	$self->{ af }->query( 'query', __LINE__, "
		INSERT INTO DocPack (
			LastUpdate, Cur, RateID, Address, FName, LName, MName, DSum, ADate, PDate, PStatus, Login,
			AgreementNo, PType, Urgent, VisaType, AppID, Shipping, SMS, Phone, DovDate, DovNum, Template,
			CenterID, Mobile, PassNum, PassDate, PassWhom, ShippingAddress, XeroxPage, AnketaSrv, PrintSrv,
			PhotoSrv, VIPSrv, InsSum, ServSum, ShipNum, SkipIns, Translate, PersonalNo, TShipSum, isNewDHL,
			ConcilPaymentDate, officeToReceive, ShippingPhone, InsData, NoReceived
		) VALUES (
			curdate(), 'RUR', ?, ?, ?, ?, ?, ?, now(), now(), 25, ?, ?, 2, 0, ?, ?, 0, ?, ?, ?, ?, ?, 47,
			?, ?, ?, ?, ?, 0, 0, 0, 0, 0, 0, ?, ?, 0, 0, '', 0, 0, now(), ?, ?, 0, 0
		)", {},
			$rate, $app->{ Address }, $app->{ FName }, $app->{ LName }, $app->{ MName }, $dsum, 'remote_script',
			$agreementNo, $app->{ VType }, $app->{ ID }, $sms, $app->{ Phone }, '0000-00-00', 0, $template,
			$app->{ Phone }, $app->{ PassNum }, $app->{ PassDate }, $app->{ PassWhom }, 'адрес ещё не указан',
			$service_fee, 0, 0, 0, $app->{ Mobile },
	);

	my $doc_id = $self->{ af }->query( 'sel1', __LINE__, "SELECT last_insert_id()") || 0;
	
	my @alph = split( //, '0123456789abcdefghigklmnopqrstuvwxyz' );
	my $feedback_token = "";
	$feedback_token .= $alph[ int( irand( 36 ) ) ] for ( 1..24 );

	$self->{ af }->query( 'query', __LINE__, "
		INSERT INTO DocPackOptional (DocPackID, ShippingFree, Reject, FeedbackKey, SendInfoEmail) VALUES (?, 0, 0, ?, ?)", {},
		$doc_id, $feedback_token, $app->{ EMail }
	);
	
	$self->{ af }->query( 'query', __LINE__, "
		INSERT INTO DocComments (DocID, Login, CommentText, CommentDate) VALUES (?, ?, ?, now())", {},
		$doc_id, 'remote_script', 'Договор сформирован автоматически системой удалённой подачи; договор был оплачен картой через платёжный шлюз'
	);

	my $bankids = parse_complex_data( $self, $app->{ BankID } );

	my $appdata = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT ID, RFName, RMName, RLName, PassNum, BirthDate, AppSDate
		FROM AppData WHERE AppID = ? AND Status != 2", $app->{ AppID }
	);
	
	my $docpackinfo = {};
	
	for ( @$appdata ) {

		my $id = $bankids->{ $_->{ ID } } || " ";
		
		$docpackinfo->{ $id } = [] unless ref( $docpackinfo->{ $id } ) eq 'ARRAY';
				
		push( @{ $docpackinfo->{ $id } }, $_ );
	}
	
	for my $info_bankid ( keys %$docpackinfo ) {
		
		$self->{ af }->query( 'query', __LINE__, "
			INSERT INTO DocPackInfo (PackID, BankID, VisaCnt) VALUES (?, ?, ?)", {},
			$doc_id, $info_bankid, scalar( @{ $docpackinfo->{ $info_bankid } } )
		);
		
		my $info_id = $self->{ af }->query( 'sel1', __LINE__, "SELECT last_insert_id()") || 0;
		
		for ( @{ $docpackinfo->{ $info_bankid } } ) {
		
			$self->{ af }->query( 'query', __LINE__, "
				INSERT INTO DocPackList (
					PackInfoID, CBankID, FName, LName, MName, isChild, PassNum, SDate, Login,
					Status, ApplID, iNRes, Concil, MobileNums, ShipAddress, ShipNum, RTShipSum,
					FlyDate, ShipPhone, ShipMail, BthDate, AgeCatA
				) VALUES (
					?, ?, ?, ?, ?, ?, ?, ?, now(), 25, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
				)", {},
					$info_id, $info_bankid, $_->{ RFName }, $_->{ RLName }, $_->{ RMName }, 0,
					$_->{ PassNum }, 'remote_script', $_->{ ID }, 0, 0, ' ', ' ', 0, 0,
					$_->{ AppSDate }, 0, 0, $_->{ BirthDate }, 0
			);
			
			my $list_id = $self->{ af }->query( 'sel1', __LINE__, "SELECT last_insert_id()") || 0;
			
			$self->{ af }->query( 'query', __LINE__, "
				INSERT INTO DocRequest (PackListID, VisaDataNumberEntries, VisaDataPurposeTravel,
				VisaDataDuration, VisaDataMainDestination)
				VALUES (?, 'M', 'TU', '90', 'I')", {},
				$list_id, 
			);
			
			my $secons_shift = 0;
			
			for my $sec ( 1, 2, 25 ) {
				
				$self->{ af }->query( 'query', __LINE__, "
					INSERT INTO DocHistory (DocID, PassNum, Login, HDate, StatusID, BankID)
					VALUES (?, ?, ?, DATE_ADD(now(), INTERVAL ? SECOND), ?, ?)", {},
					$doc_id, $_->{ PassNum }, 'remote_script', $secons_shift, $sec, $info_bankid
				);
				
				$secons_shift += 1;
			};
		}
	}

	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE AutoRemote SET Agreement = ? WHERE ID = ?", {},
		$doc_id, $app->{ AutoRemoteID }
	);

	$self->{ af }->query( 'query', __LINE__, "UNLOCK TABLES" );
	
	$agreementNo =~ s/^([0-9]{2})([0-9]{6})([0-9]{6})$/$1.$2.$3/;
	
	return $agreementNo;
}

sub parse_complex_data
# //////////////////////////////////////////////////
{
	my ( $self, $data ) = @_;
	
	my @data_arr = split( /\|/, $data );

	my $data = {};
	
	for ( @data_arr ) {
		
		my @data_pair = split( /:/, $_ );
		
		$data->{ $data_pair[0] } = $data_pair[1];
	}

	return $data;
}

1;