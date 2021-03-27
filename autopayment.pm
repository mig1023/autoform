package VCS::Site::autopayment;
use strict;
use utf8;

use LWP::UserAgent;
use HTTP::Request;
use Crypt::OpenSSL::RSA;
use Data::Dumper;
use Date::Calc;
use JSON;
use Encode qw(decode encode);
use MIME::Base64;

sub new
# //////////////////////////////////////////////////
{
	my ( $class, $pclass, $vars ) = @_;
	
	my $self = bless {}, $pclass;
	
	$self->{ 'VCS::Vars' } = $vars;
	
	return $self;
}

sub return_url
# //////////////////////////////////////////////////
{
	
	my $self = shift;
	
	return decode( 'utf8', $self->{ autoform }->{ payment }->{ back_url } . $self->{ autoform }->{ paths }->{ addr } . '?t=' . $self->{ token } );
}
	
sub payment
# //////////////////////////////////////////////////
{

	my ( $self, $order_number, $amount, $type ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $amount_in_kopek = $amount * 100;

	my $data = {
		userName	=> $config->{ payment }->{ user_name },
		password	=> $config->{ payment }->{ password },
		orderNumber 	=> $order_number,
		amount 		=> $amount_in_kopek,
		returnUrl 	=> return_url( $self ),
	};

	my $response = LWP::UserAgent->new( timeout => 30 )->post( join( '/', $config->{ payment }->{ url } , 'register.do' ), $data );

	return ( undef, undef ) unless $response->is_success;
	
	my $payment = JSON->new->pretty->decode( $response->decoded_content );

	return ( $payment->{ orderId }, $payment->{ formUrl } );
}

sub status
# //////////////////////////////////////////////////
{
	
	my ( $self, $order_id, $type ) = @_;

	my $config = VCS::Site::autodata::get_settings();
	
	my $data = {
		userName	=>  $config->{ payment }->{ user_name },
		password	=> $config->{ payment }->{ password },
		orderId 	=> $order_id,
	};

	my $response = LWP::UserAgent->new(timeout => 30)->post( join( '/', $config->{ payment }->{ url }, 'getOrderStatus.do' ), $data );

	return -1 unless $response->is_success;
	
	my $status = JSON->new->pretty->decode( $response->decoded_content );
	
	$status->{ OrderStatus } =~ s/[^0-9]+//g;

	return $status->{ OrderStatus };
}

sub cloud_payment
# //////////////////////////////////////////////////	
{
	
	my ( $self, $data ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $ua = LWP::UserAgent->new( timeout => 30 );
	
	$ua->ssl_opts(
		SSL_cert_file	=> $config->{ cloud }->{ ssl_cert },
		SSL_key_file	=> $config->{ cloud }->{ ssl_key },
		SSL_passwd_cb	=> sub { return $config->{ cloud }->{ ssl_pwd }; }  
	);
	
	my $content = encode( 'utf8', JSON->new->pretty->encode( $data ) );
	
	my $request = HTTP::Request->new( 'POST', $config->{ cloud }->{ url } );
	
	$request->header('Content-Type' => 'application/json');
	
	$request->header('X-Signature' => signature( $content ) );
	
	$request->content( $content );
	
	my $response = $ua->request( $request );

	my $responses = {
		201 => "OK",
		401 => "ERROR: certificate",
		409 => "ERROR: duplicate",
		400 => "ERROR: validation",
		503 => "ERROR: queue",
	};
	
	my $response_line = $responses->{ $response->{ _rc } };
	
	return ($response_line ? $response_line : "ERROR: unknown type (" . $response->{ _rc }  . ")" );
}

sub cloud_status
# //////////////////////////////////////////////////
{
	
	my ( $self, $company, $docid ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $ua = LWP::UserAgent->new( timeout => 30 );
	
	$ua->ssl_opts(
		SSL_cert_file	=> $config->{ cloud }->{ ssl_cert },
		SSL_key_file	=> $config->{ cloud }->{ ssl_key },
		SSL_passwd_cb	=> sub { return $config->{ cloud }->{ ssl_pwd }; }    
	);

	my $response = $ua->get( $config->{ cloud }->{ url } . "$company/status/$docid" );

	return $response->{ _rc };
}

sub signature
# //////////////////////////////////////////////////
{
	my $data = shift;
	
	my $config = VCS::Site::autodata::get_settings();

	open( my $file, '<', $config->{ cloud }->{ rsa_key } ) or return;
	
	my $key_string;
	
	$key_string .= $_ while <$file>;	
	
	close $file;

	my $rsa = Crypt::OpenSSL::RSA->new_private_key( $key_string );
	
	$rsa->use_pkcs1_padding();
	
	$rsa->use_sha256_hash();
	
	return encode_base64( $rsa->sign( $data ) );
}

sub fox_pay_status_req
# //////////////////////////////////////////////////
{
	my ( $self, $order_number ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();

	my $response = LWP::UserAgent->new( timeout => 30 )->get( $config->{ fox }->{ pay_status } . $order_number );

	return 0 unless $response->is_success;
	
	my $result = decode( 'utf8', $response->{ _content } );

	return ( $result =~ /Документ\s+$order_number\s+оплачен/i ? 1 : 0 );
}

sub fox_pay_status
# //////////////////////////////////////////////////
{
	my ( $self, $order_number_from, $order_number_to ) = @_;

	my $form_payment_ok = fox_pay_status_req( $self, $order_number_from );
	
	my $to_payment_ok = fox_pay_status_req( $self, $order_number_to );
	
	return $form_payment_ok && $to_payment_ok;
}

sub fox_pay_document
# //////////////////////////////////////////////////
{
	my ( $self, $order_number ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $url_param = "login=" . $config->{ fox }->{ login } . "&password=" . $config->{ fox }->{ password } .
		"&documentType=order&number=" . $order_number . "&numberType=internalnumber&formName=Накладная";
		
	my $response = LWP::UserAgent->new( timeout => 30 )->get( $config->{ fox }->{ document } . $url_param );

	return "" unless $response->is_success;	

	my $content = JSON->new->pretty->decode( $response->decoded_content );

	my $document = $content->{ List }->[ 0 ]->{ BData }->[ 0 ];

	return decode_base64($document)
}

sub fox_status
# //////////////////////////////////////////////////
{
	my ( $self, $order_number_from, $order_number_to ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $url_param = "login=" . $config->{ fox }->{ login } . "&password=" . $config->{ fox }->{ password } .
		"&documentType=order&number=" . $order_number_from;
		
	my $response = LWP::UserAgent->new( timeout => 30 )->get( $config->{ fox }->{ track } . $url_param );

	return "" unless $response->is_success;	

	my $status = JSON->new->pretty->decode( $response->decoded_content );

	my $line = "";

	$line = $status->{ documents }->[ 0 ]->{ history }->[ -1 ]->{ eventState }
		if ( length( $status->{ documents }->[ 0 ]->{ history } ) > 0 );

	return $line;
}

1;