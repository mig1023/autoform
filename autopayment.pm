package VCS::Site::autopayment;
use strict;
use utf8;

use LWP::UserAgent;
use Data::Dumper;
use Date::Calc;
use JSON;
use Encode qw(decode encode);

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
	
	my $data = {
		userName	=>  $config->{ payment }->{ user_name },
		password	=> $config->{ payment }->{ password },
		orderNumber 	=> $order_number,
		amount 		=> $amount,
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

1;
