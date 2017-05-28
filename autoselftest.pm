package VCS::Site::autoselftest;
use strict;

use VCS::Vars;
use Data::Dumper;

sub selftest 
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{ 'VCS::Vars' };
	
	my $result = [];

	# reconnect to fake db
	my $db_fake = reconnect_to_fake_db($self, $vars);
	
	if ($db_fake) {
		$self->{fake_db} = $db_fake;
		push @$result, { 'text' => 'переключение БД', 'status' => 1 };
	}
	else {
		push @$result, { 'text' => 'ошибка переключения БД', 'status' => 2 };
	}

	# create test app
	my $token = $self->get_token_and_create_new_form_if_need();
	
	
	# test all subs
	
	# cleaning
	
	# reconnect to normal db
	$db_fake->do("USE vcs");
	$self->{fake_db} = 0;
	
	# show all result
	return show_result($result);
}

sub reconnect_to_fake_db
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = shift;

	my $config = $vars->getConfig('db');

	my $server = $config->{"server"};
	my $port = $config->{"port"};

	my $fake_db = DBI->connect(
		"DBI:mysql:host=$server; port=$port; database=fake_vcs", 
		$config->{'user'}, $config->{'password'}, { PrintError => 1}
	);
	
	if ( !$fake_db ) {
		return undef;
	}
	else {
		$fake_db->do("SET NAMES 'utf8'");
		$fake_db->do("SET CHARACTER SET utf8");
		$fake_db->do("USE fake_vcs");
		
		return $fake_db;
	}
}

sub show_result
# //////////////////////////////////////////////////
{
	my $result = shift;
	
	my $result_line = shift;
	
	for (@$result) {
		$result_line .= $_->{text} . ' ' . ( ( $_->{status} == 1 ) ? '-- ok' : '-- error (code: ' . $_->{status} . ')<br>' );
	}
	
	return $result_line;
}

1;
