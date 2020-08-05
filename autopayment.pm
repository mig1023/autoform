package VCS::Site::autoinfopage;
use strict;
use utf8;

use LWP::UserAgent;
use Data::Dumper;
use Date::Calc;
use JSON;

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
	
	return "127.0.0.1/" . $self->{ token };
}
	
sub payment {
	
	my ( $self, $order_number ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $tmp_amount = 100;
	
	my $data = {
		userName	=>  $config->{ payment }->{ user_name },
		password	=> $config->{ payment }->{ password },
		orderNumber 	=> $order_number,
		amount 		=> $tmp_amount,
		returnUrl 	=> return_url(),
	};
	
	my $res = LWP::UserAgent->new( timeout => 30 )->post( join( '/', $config->{ payment }->{ url } , 'register.do' ), $data );
	
	if ($res->is_success) {
		return $res->decoded_content;
	} else {
		$res = '{}';
		print "ERR";
	}
	
	my $result = JSON->new->pretty->decode( $res );
	
	print "orderId: " . $result->{ orderId } . "\n";
	print "link: " . $result->{ formUrl } . "\n";
	print "ErrorCode: " . ( $result->{ errorCode } ? $result->{ errorCode } : 'nope' ) . "\n";
	
	return $res;
}

sub status {
	
	my ( $self, $order_id ) = @_;
	
	my $config = VCS::Site::autodata::get_settings();
	
	my $data = {
		userName	=>  $config->{ payment }->{ user_name },
		password	=> $config->{ payment }->{ password },
		orderId 	=> $order_id,
	};
	
	my $res = LWP::UserAgent->new(timeout => 30)->post( join( '/', $url , 'getOrderStatus.do' ), $data );
	
	if ($res->is_success) {
		$res = $res->decoded_content;
	} else {
		$res = '{}';
		print "ERR";
	}

	my $result = JSON->new->pretty->decode( $res );
	
	print "STATUS: " . $result->{ OrderStatus } . "\n";
	print "RESULT: " . ( $result->{ OrderStatus } == 2 ? 'success' : 'ERR' ) . "\n";
	print "ErrorCode: " . $result->{ ErrorCode } . "\n";
	
	return $res;
}
