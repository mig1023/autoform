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
	
	$self->query( 'query', __LINE__, "
		LOCK TABLES
			DocHistory WRITE, BlackList WRITE, PriceRate WRITE, PriceList WRITE,
			ServicesPriceRates WRITE, DocPack WRITE, DocPackInfo WRITE, DocPackList WRITE,
			DocPackOptional WRITE, Services WRITE, ServicesBranches WRITE, ServiceFields WRITE,
			ServiceFieldValuesINT WRITE, ServiceFieldValuesFLOAT WRITE, ServiceFieldValuesDATE WRITE,
			ServiceFieldValuesVARCHAR WRITE, DocPackService WRITE, UserLog WRITE, Templates WRITE,
			Appointments WRITE, AppData WRITE, CurRates WRITE, DocRequest WRITE, VisaTypes WRITE,
			DocComments WRITE"
	);
	
	my $now = $self->{ vars }->get_system->now_date();
	
	my $agreementNo = $self->{ vars }->admfunc->getAgrNumber( $self->{ vars }, 47, $now );
	
	my $rate = $self->{ vars }->admfunc->getRate( $self->{ vars }, 'RUR', $now, 47 );
	
	( $sms_price, undef ) = $self->{ af }->get_payment_price( "sms" );
		
	( $service_fee, undef ) = $self->{ af }->get_payment_price( "service" );
		
	my $dsum = $service_fee + ( $sms ? $sms_price : 0 );
	
	my $app = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT FoxAddress, FName, LName, MName, Appointments.VType,
		Appointments.ID, SMS, Phone, Mobile, PassNum, PassDate, PassWhom,
		Appointments.Address, FoxID, AutoRemote.BankID
		FROM AutoToken
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		JOIN AutoRemote ON Appointments.ID = AutoRemote.AppID
		WHERE Token = ?", $self->{ token }
	)->[0];
	
	my $template = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT ID FROM Templates WHERE TDate <= curdate() AND isJur=0 AND CenterID=47 ORDER BY TDate DESC LIMIT 1"
	)->[0];
	
	$self->{ af }->query( 'query', __LINE__, "
		INSERT INTO DocPack (
			LastUpdate, Cur, RateID, Address, FName, LName, MName, DSum, ADate, PDate,
			PStatus, Login, AgreementNo, PType, Urgent, VisaType, AppID, Shipping, SMS, Phone,
			DovDate, DovNum, Template, CenterID, Mobile, PassNum, PassDate, PassWhom, ShippingAddress, XeroxPage,
			AnketaSrv, PrintSrv, PhotoSrv, VIPSrv, InsSum, ServSum, ShipNum, SkipIns, Translate, PersonalNo,
			TShipSum, isNewDHL, ConcilPaymentDate, officeToReceive, ShippingPhone, InsData, NoReceived
		) VALUES (
			curdate(), 'RUR', ?, ?, ?, ?, ?, ?, now(), now(),
			1, ?, ?, 2, 0, ?, ?, 1, ?, ?,
			?, ?, ?, 47, ?, ?, ?, ?, ?, 0,
			0, 0, 0, 0, 0, ?, ?, 0, 0, ?,
			0, 0, now(), ?, ?, 0, 0
		)", {},
			$rate, $app->{ Address }, $app->{ FName }, $app->{ LName }, $app->{ MName }, $dsum,
			'remote_script', $agreementNo, $app->{ VType }, $app->{ ID }, $app->{ SMS }, $app->{ Phone },
			'0000-00-00', 0, $template, $app->{ Mobile }, $app->{ PassNum }, $app->{ PassDate }, $app->{ PassWhom }, $app->{ FoxAddress },
			$service_fee, $app->{ FoxID }, 0,
			0, $app->{ Mobile },
	);
	
	my $doc_id = $vars->db->sel1('SELECT last_insert_id()') || 0;
	
	my @alph = split( //, '0123456789abcdefghigklmnopqrstuvwxyz' );
	my $feedback_token = "";
	$feedback_token .= $alph[ int( irand( 36 ) ) ] for ( 1..24 );

	$self->{ af }->query("
		INSERT INTO DocPackOptional (DocPackID, ShippingFree, Reject, FeedbackKey) VALUES (?, 0, 0, ?)", {},
		$doc_id, $feedback_token
	);
	
	$self->{ af }->query("
		INSERT INTO DocComments (DocID, Login, CommentText, CommentDate) VALUES (?, ?, ?, now())",{},
		$doc_id, 'remote_script', 'Договор сформирован автоматически системой удалённой подачи; договор был оплачен картой через платёжный шлюз'
	);
	
	my @bankids_arr = split( /\|/, $app->{ BankID } );
	

	$self->query( 'query', __LINE__, "UNLOCK TABLES" );
}

1;