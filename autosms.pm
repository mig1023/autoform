package VCS::Site::autosms;
use strict;
use utf8;

use Math::Random::Secure qw(irand);
use Digest::MD5 qw (md5_hex);

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
	my $self = shift;
	
	my $phone = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT AppPhone FROM AppData
		JOIN AutoToken ON AppData.AppID = AutoToken.CreatedApp
		WHERE Token = ? ORDER BY appdata.ID LIMIT 1", $self->{ token }
	);
	
	return $phone;
}

sub get_code_from_db
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my ( $remote_id, $sms_code ) = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT AutoRemote.ID, SMScode FROM AutoRemote
		JOIN AutoToken ON AutoToken.CreatedApp = AutoRemote.AppID
		WHERE Token = ?", $self->{ token }
	);
	
	return ( $remote_id, $sms_code );
}

sub get_code_for_sms
# //////////////////////////////////////////////////
{
	my ( $self, $phone ) = @_;
	
	my ( $remote_id, $sms_code ) = get_code_from_db( $self );
	
	return md5_hex( $sms_code ) if $sms_code;
	
	my $new_code = int( irand( 10000 ) );
	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE AutoRemote SET SMScode = ? WHERE ID = ?", {}, $new_code, $remote_id
	);

	return md5_hex( $new_code );
}

sub code_from_sms_is_ok
# //////////////////////////////////////////////////
{
	my ( $self, $code ) = @_;
	
	my ( $remote_id, $sms_code ) = get_code_from_db( $self );
	
	return 0 unless $sms_code eq $code;
	
	$self->{ af }->query( 'query', __LINE__, "
		UPDATE AutoRemote SET SMSsigned = now() WHERE ID = ?", {}, $remote_id
	);
	
	return 1;
}

1;