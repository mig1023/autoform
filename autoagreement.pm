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
			DocHistory WRITE, BlackList WRITE, PriceRate WRITE, PriceList WRITE,
			ServicesPriceRates WRITE, DocPack WRITE, DocPackInfo WRITE, DocPackList WRITE,
			DocPackOptional WRITE, UserLog WRITE, Templates WRITE, Appointments WRITE,
			AppData WRITE, CurRates WRITE, DocRequest WRITE, VisaTypes WRITE,
			DocComments WRITE, AutoToken READ, AutoRemote READ"
	);

	my $now = $self->{ vars }->get_system->now_date();
	
	my $agreementNo = $self->{ vars }->admfunc->getAgrNumber( $self->{ vars }, 47, $now );
	
	my $rate = $self->{ vars }->admfunc->getRate( $self->{ vars }, 'RUR', $now, 47 );

	my ( $sms_price, undef ) = $self->{ af }->get_payment_price( "sms" );

	my ( $service_fee, undef ) = $self->{ af }->get_payment_price( "service" );

	my $app = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT FoxAddress, FName, LName, MName, Appointments.VType, Appointments.ID,
		SMS, Phone, Mobile, PassNum, PassDate, PassWhom, Appointments.Address, FoxID,
		AutoRemote.BankID, AutoToken.EMail, AutoRemote.ID as AutoRemoteID
		FROM AutoToken
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		JOIN AutoRemote ON Appointments.ID = AutoRemote.AppID
		WHERE Token = ?", $self->{ token }
	)->[0];
	
	my $sms = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT autopayment.ID FROM autopayment
		JOIN autotoken ON autopayment.AutoID = autotoken.CreatedApp
		WHERE Token = ? AND autopayment.`Type` = 'sms' AND PaymentStatus = 2",
		$self->{ token }
	);
	
	$sms = 1 if $sms;

	my $dsum = $service_fee + ( $sms ? $sms_price : 0 );

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
	my $opt_id = $self->{ af }->query( 'sel1', __LINE__, "SELECT last_insert_id()") || 0;
	
	$self->{ af }->query( 'query', __LINE__, "
		INSERT INTO DocComments (DocID, Login, CommentText, CommentDate) VALUES (?, ?, ?, now())", {},
		$doc_id, 'remote_script', 'Договор сформирован автоматически системой удалённой подачи; договор был оплачен картой через платёжный шлюз'
	);
	my $comm_id = $self->{ af }->query( 'sel1', __LINE__, "SELECT last_insert_id()") || 0;

	my @bankids_arr = split( /\|/, $app->{ BankID } );

	my ( $apps, $bankids ) = ( {}, {} );
	
	for ( @bankids_arr ) {
		
		my @bankid = split( /:/, $_ );
		
		$apps->{ $bankid[0] } = $bankid[1];
		
		$bankids->{ $bankid[1] } += 1;
	}
	
	for ( keys %$bankids ) {
		
		my $bank_id = $_;
		
		$self->{ af }->query( 'query', __LINE__, "
			INSERT INTO DocPackInfo (PackID, BankID, VisaCnt) VALUES (?, ?, ?)", {},
			$doc_id, $bank_id, $bankids->{ $bank_id }
		);
		
		my $info_id = $self->{ af }->query( 'sel1', __LINE__, "SELECT last_insert_id()") || 0;
	
		for ( keys %$apps ) {
	
			next unless $bank_id eq $apps->{ $_ };

			my $ad = $self->{ af }->query( 'selallkeys', __LINE__, "
				SELECT ID, RFName, RMName, RLName, PassNum, BirthDate, AppSDate
				FROM AppData WHERE ID = ?", $_
			)->[0];
			
			$self->{ af }->query( 'query', __LINE__, "
				INSERT INTO DocPackList (
					PackInfoID, CBankID, FName, LName, MName, isChild, PassNum, SDate, Login,
					Status, ApplID, iNRes, Concil, MobileNums, ShipAddress, ShipNum, RTShipSum,
					FlyDate, ShipPhone, ShipMail, BthDate, AgeCatA
				) VALUES (
					?, ?, ?, ?, ?, ?, ?, ?, now(), 25, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
				)", {},
					$info_id, $bank_id, $ad->{ RFName }, $ad->{ RMName }, $ad->{ RLName }, 0,
					$ad->{ PassNum }, 'remote_script', $ad->{ ID }, 0, 0, ' ', ' ', 0, 0,
					$ad->{ AppSDate }, 0, 0, $ad->{ BirthDate }, 0
			);
			
			my $secons_shift = 0;
			
			for ( 1, 2, 25 ) {
				
				$self->{ af }->query( 'query', __LINE__, "
					INSERT INTO DocHistory (DocID, PassNum, Login, HDate, StatusID, BankID)
						VALUES (?, ?, ?, DATE_ADD(now(), INTERVAL ? SECOND), ?, ?)", {},
						$doc_id, $ad->{ PassNum }, 'remote_script', $secons_shift, $_, $bank_id
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
}

sub update_sending_info
# //////////////////////////////////////////////////
{
	my ( $self, $shipnum, $shipaddr ) = @_;
	
	my $doc_id = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT Agreement FROM AutoRemote 
		JOIN AutoToken ON AutoToken.CreatedApp = AutoRemote.AppID
		WHERE Token = ?", $self->{ token }
	);
	
	my $app_id = $self->{ af }->query( 'query', __LINE__, "
		UPDATE DocPack SET ShippingAddress = ?, ShipNum = ? WHERE ID = ?", {},
		$shipaddr, $shipnum, $doc_id
	);
}

1;