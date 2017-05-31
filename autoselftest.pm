package VCS::Site::autoselftest;
use strict;

use VCS::Vars;
use Data::Dumper;

my $tests = [
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_token_and_create_new_form_if_need },
		'comment' => 'get_token_and_create_new_form_if_need',
		'test' => {	
			1 => { 	'tester' => \&test_regexp,
				'args' => [],
				'expected' => '^A[a-z0-9]{63}$',
			},
			2 => {	'tester' => \&test_line,
				'args' => [],
				'param' => [ 
					{ 'name' => 't', 'value' => '[token]' },
				],
				'expected' => '[token]',
			},
			3 => {	'tester' => \&test_line,
				'args' => [],
				'param' => [
					{ 'name' => 't', 'value' => 'F[token]' },
				],
				'expected' => '01',
			},
			4 => {	'tester' => \&test_line,
				'prepare' => \&pre_corrupt_token,
				'args' => [],
				'param' => [
					{ 'name' => 't', 'value' => '[token]' },
				],
				'expected' => '02',
			},
			5 => {	'tester' => \&test_line,
				'prepare' => \&pre_finished,
				'args' => [],
				'param' => [
					{ 'name' => 't', 'value' => '[token]' },
				],
				'expected' => '03',
			},
		}
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::token_generation },
		'comment' => 'token_generation',
		'test' => { 	
			1 => { 	'tester' => \&test_regexp,
				'args' => [],
				'expected' => '^A[a-z0-9]{63}$',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::save_new_token_in_db },
		'comment' => 'save_new_token_in_db',
		'test' => { 	
			1 => { 	'tester' => \&test_write_db,
				'args' => [ '[token]' ],
				'expected' => 'AutoToken:Token:[token]',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_token_error },
		'comment' => 'get_token_error',
		'test' => { 	
			1 => { 	'tester' => \&test_array,
				'args' => [ '0' ],
				'expected' => [ 'token error', 'your token has error: internal data error', 'autoform.tt2' ],
			},
			2 => { 	'tester' => \&test_array,
				'args' => [ '1' ],
				'expected' => [ 'token error', 'your token has error: token corrupted', 'autoform.tt2' ],
			},
			3 => { 	'tester' => \&test_array,
				'args' => [ '2' ],
				'expected' => [ 'token error', 'your token has error: token not existing', 'autoform.tt2' ],
			},
			4 => { 	'tester' => \&test_array,
				'args' => [ '3' ],
				'expected' => [ 'token error', 'your token has error: app already finished', 'autoform.tt2' ],
			},
		},
	},
	
	
];

sub selftest 
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{ 'VCS::Vars' };
	my $config = $vars->getConfig('db');
	
	my $result = [];
	
	$vars->db->query("USE fake_vcs");

	my $test_token = $self->get_token_and_create_new_form_if_need();
	
	push @$result, get_ordinary_tests( $self, $vars, $test_token );
	
	$vars->db->query( "USE " . $config->{"dbname"} );	

	return show_result($result);
}

sub get_ordinary_tests
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = shift;
	my $test_token = shift;
	
	my @result = ();
	
	for my $test (@$tests) {
	
		my $err_tmp = 0;
		my $test_num = 0;
		
		for( sort { $a <=> $b } keys %{ $test->{test} } ) {
	
			$test_num++ if !$err_tmp;
			
			my $t = $test->{test}->{$_};
			
			&{ $t->{prepare} }( 'PREPARE', \$test, $_, \$test_token, $vars ) if ref( $t->{prepare} ) eq 'CODE';
			
			for ( 	@{ $t->{args} }, @{ $t->{param} }, $t->{expected} ) {
				s/\[token\]/$test_token/g;
				
				if ( ref($_) eq 'HASH' ) {
					$_->{value} =~ s/\[token\]/$test_token/g;
				}
			}
			
			for ( @{ $t->{param} } ) {
				$vars->setparam( $_->{name} ,$_->{value} );
			}

			unless ( $err_tmp ) {
				$err_tmp = &{ $t->{tester} }( $t->{expected}, $test->{comment}, $self, 
					$test_token, &{ $test->{func} }( $self, @{ $t->{args} } ) );
			}
			
			&{ $t->{prepare} }( 'CLEAR', \$test, $_, \$test_token, $vars ) if ref( $t->{prepare} ) eq 'CODE';
		} 
		$test_num = 0 unless $err_tmp;
		
		push @result, { 'text' => "$test->{comment}", 'status' => $test_num };
	}
	
	return @result;
}

sub show_result
# //////////////////////////////////////////////////
{
	my $result = shift;
	my $result_line;
	
	my $test_num = 0;
	my $fails = 0;

	for my $test (@$tests) {
		for( keys %{ $test->{test} } ) {
			$test_num++;
		}
	}
	
	for ( @$result ) {
		$fails++ if $_->{status};
	}
	
	$result_line = self_test_htm( 'span', ( $fails ? ( 'red', "Присутствуют ошибки" ) : ( 'green', "Всё нормально" ) ) );
	
	for ( @$result ) {
		$result_line .= $_->{text} . ' ' . 
			( !$_->{status} ? 
				self_test_htm( 'font', 'green', "-- ok" ) : 
				self_test_htm( 'font', 'red', "-- fail ( test: $_->{status} )" )
			) . self_test_htm( 'br' );
	}
	$result_line .= self_test_htm( 'br' ) . self_test_htm( 'span', ( $fails ? 'red' : 'green' ), "$test_num тестов" );
	
	return $result_line;
}

sub self_test_htm
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $param = shift;
	my $line = shift;
	
	my $html = {
		'span' => '<span style="width:auto; color:white; background-color:[param]">&nbsp;[line]&nbsp;</span><br><br>',
		'font' => '<font color="[param]">[line]</font>',
		'br' => '<br>',
	};
	
	my $html_line = $html->{$type};
	
	$html_line =~ s/\[param\]/$param/g;
	$html_line =~ s/\[line\]/$line/g;
	
	return $html_line;
}

sub test_line
# //////////////////////////////////////////////////
{
	my ( $expected, $comm, undef, undef, $result ) = @_;
	
	if ( lc( $expected ) ne lc( $result ) ) { 
		return $comm;
	};
}

sub test_array
# //////////////////////////////////////////////////
{
	my $array_2 = shift;
	my $comm = shift;
	my $self = shift;
	my $token = shift;
	my @array_1 = @_;

	my $eq = 1;
	
	for (1..$#array_1) {
		$eq = 0 if $array_1[$_] ne $array_2->[$_];
	}
	
	if ( !$eq ) { 
		return $comm;
	};
}

sub test_regexp
# //////////////////////////////////////////////////
{
	my ( $regexp, $comm, undef, undef, $result ) = @_;
	
	if ( $result !~ /$regexp/ ) {
		return $comm;
	}
}

sub test_write_db
# //////////////////////////////////////////////////
{
	my ( $db_table, $db_name, $db_value ) = split /:/, shift;
	my $comment = shift;
	my $self = shift;
	my $test_token = shift;
	my $result = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $value = $vars->db->sel1( "SELECT $db_name FROM $db_table WHERE Token = '$test_token'" );

	if ( lc( $db_value ) ne lc( $value ) ) {
		return $comment;
	}
}

sub pre_corrupt_token
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $test = shift;
	my $num = shift;
	my $token = shift;
	
	if ( $type eq 'PREPARE' ) { 
		$$token =~ s/^A/F/;
	}
	else {
		$$token =~ s/^F/A/;
	}	
}

sub pre_finished
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $test = shift;
	my $num = shift;
	my $token = shift;
	my $vars = shift;
	
	if ( $type eq 'PREPARE' ) { 
		$vars->db->query( "UPDATE AutoToken SET Finished = 1 WHERE Token = '$$token'" );
	} 
	else {
		$vars->db->query( "UPDATE AutoToken SET Finished = 0 WHERE Token = '$$token'" );
	}
}

1;
