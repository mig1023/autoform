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

sub return_url {
	
	my $self = shift;
	
	return decode( 'utf8', '127.0.0.1' . $self->{ autoform }->{ paths }->{ addr } . '?t=' . $self->{ token } );
}
	
sub payment {
	
	my ( $self, $order_number, $amount ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $amount_in_kopek = $amount * 100;
	
	my $data = {
		userName	=>  $config->{ payment }->{ user_name },
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

sub status {
	
	my ( $self, $order_id ) = @_;
	
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

sub cloud_payment {
	
	my ( $self, $data ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $ua = LWP::UserAgent->new( timeout => 30 );
	
	$ua->ssl_opts(
		SSL_cert_file	=> $config->{ payment }->{ cloud_ssl_cert },
		SSL_key_file	=> $config->{ payment }->{ cloud_ssl_key },
		SSL_passwd_cb	=> sub { return $config->{ payment }->{ cloud_ssl_pwd }; }  
	);
	
	my $content = encode( 'utf8', JSON->new->pretty->encode( $data ) );
	
	my $request = HTTP::Request->new( 'POST', $config->{ payment }->{ cloud_url } );
	
	$request->header('Content-Type' => 'application/json');
	
	$request->header('X-Signature' => signature( $content ) );
	
	$request->content( $content );
	
	my $response = $ua->request( $request );

	return $response->{ "_rc" };
}

sub cloud_status {
	
	my ( $self, $company, $docid ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $ua = LWP::UserAgent->new( timeout => 30 );
	
	$ua->ssl_opts(
		SSL_cert_file	=> $config->{ payment }->{ cloud_ssl_cert },
		SSL_key_file	=> $config->{ payment }->{ cloud_ssl_key },
		SSL_passwd_cb	=> sub { return $config->{ payment }->{ cloud_ssl_pwd }; }    
	);

	my $response = $ua->get( $config->{ payment }->{ cloud_url } . "$company/status/$docid" );

	return $response->{ "_rc" };
}

sub signature
{
	my ( $self, $data ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	open( $file, '<', $config->{ payment }->{ cloud_rsa_key } ) or return;
	
	my $key_string;
	
	$key_string .= $_ while <$file>;	
	
	close $file;

	my $rsa = Crypt::OpenSSL::RSA->new_private_key( $key_string );
	
	$rsa->use_pkcs1_padding();
	
	$rsa->use_sha256_hash();
	
	return encode_base64( $rsa->sign( $data ) );
}

1;
