package VCS::Site::autosms;
use strict;
use utf8;

use Math::Random::Secure qw( irand );
use Digest::MD5 qw( md5_hex );
use Digest::SHA1 qw( sha1_hex );
use HTTP::Request::Common;
use Data::Dumper;

sub new
# //////////////////////////////////////////////////
{
	my ( $class, $pclass, $vars ) = @_;
	
	my $self = bless {}, $pclass;
	
	$self->{ 'VCS::Vars' } = $vars;
	
	return $self;
}

sub get_phone_for_sms
# //////////////////////////////////////////////////
{
	my ( $self, $without_app ) = @_;
	
	my $relatons = "Appointments JOIN AutoToken ON Appointments.ID = AutoToken.CreatedApp";
	
	$relatons = "AutoAppointments JOIN AutoToken ON AutoAppointments.ID = AutoToken.AutoAppID" if $without_app;	
	
	my $phone = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT Phone FROM $relatons WHERE AutoToken.Token = ?", $self->{ token }
	);

	return $phone;
}

sub get_code_from_db
# //////////////////////////////////////////////////
{
	my ( $self, $without_app ) = @_;
	
	my ( $remote_id, $sms_code ) = ( 0, 0 );
	
	if ( $without_app ) {

		( $remote_id, $sms_code ) = $self->{ af }->query( 'sel1', __LINE__, "
			SELECT DocUploadedAgreements.ID, SMScode FROM DocUploadedAgreements
			JOIN AutoToken ON AutoToken.ID = DocUploadedAgreements.Token
			WHERE AutoToken.Token = ?", $self->{ token }
		);
	}
	else {	
		( $remote_id, $sms_code ) = $self->{ af }->query( 'sel1', __LINE__, "
			SELECT AutoRemote.ID, SMScode FROM AutoRemote
			JOIN AutoToken ON AutoToken.CreatedApp = AutoRemote.AppID
			WHERE Token = ?", $self->{ token }
		);
	}
	
	return ( $remote_id, $sms_code );
}

sub get_code_for_sms
# //////////////////////////////////////////////////
{
	my ( $self, $phone, $without_app ) = @_;
	
	my $config = VCS::Site::autodata::get_settings()->{ sms };
	
	my ( $remote_id, $sms_code ) = get_code_from_db( $self, $without_app );
	
	return md5_hex( $sms_code ) if $sms_code;
	
	my $new_code = int( irand( 9000 ) ) + 1000;
	
	my $sms_id = 0;
	
	$sms_id = sending_sms( $self, $phone, "Vash kod dogovora $new_code" ) unless $config->{ do_not_send_sms };
		
	my $table = ( $without_app ? "DocUploadedAgreements" : "AutoRemote" );
		
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE $table SET SMScode = ?, SMSmsgID = ? WHERE ID = ?", {}, $new_code, $sms_id, $remote_id
	);

	return md5_hex( $new_code );
}

sub code_from_sms_is_ok
# //////////////////////////////////////////////////
{
	my ( $self, $code, $without_app ) = @_;
	
	my ( $remote_id, $sms_code ) = get_code_from_db( $self, $without_app );
	
	return 0 unless $sms_code eq $code;
	
	my $table = ( $without_app ? "DocUploadedAgreements" : "AutoRemote" );
	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE $table SET SMSsigned = now() WHERE ID = ?", {}, $remote_id
	);

	
	return 1;
}

sub sending_sms
# //////////////////////////////////////////////////
{
	my ( $self, $phone, $message ) = @_;
		
	my $sms = VCS::Site::autodata::get_settings()->{ sms };
	
	my $sms_sign = join( ';', sort ( $sms->{ project },  $sms->{ sender }, $message, $phone ) ) . ';' . $sms->{ key };

	$sms_sign = md5_hex( sha1_hex( $sms_sign ) );
	
	my $ua = LWP::UserAgent->new;
	
	$ua->agent('Mozilla/4.0 (compatible; MSIE 6.0; X11; Linux i686; en) Opera 7.60');
	
	my $request_url = $sms->{ send_url } . '?project=' . $sms->{ project } . '&sender=' . $sms->{ sender } .
		'&message=' . $message . '&recipients=' . $phone . '&sign=' . $sms_sign;

	my $response = LWP::UserAgent->new( timeout => 30 )->get( $request_url );

	return 0 unless $response->is_success;
	
	return 0 unless $response->content =~ /\"status\"\:\"success\"/;
	
	return 0 unless $response->content =~ /\"messages\_id\"\:\[([0-9]+)\]/;
	
	return $1;
}

1;