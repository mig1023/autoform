package VCS::Site::autoselftest;
use strict;

use VCS::Vars;
use Data::Dumper;

my $tests = [
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_token_and_create_new_form_if_need },
		'comment' => 'get_token_and_create_new_form_if_need',
		'tester' => \&test_regexp,
		'test' => { 	
			1 => { 	'args' => [],
				'param' => [ 
					{ 'name' => '', 'value' => ''},
				],
				'expected' => '^A[a-z0-9]{63}$',
				},
			},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::token_generation },
		'comment' => 'token_generation',
		'tester' => \&test_regexp,
		'test' => { 	
			1 => { 	'args' => [],
				'expected' => '^A[a-z0-9]{63}$',
				},
			},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::save_new_token_in_db },
		'comment' => 'save_new_token_in_db',
		'tester' => \&test_db,
		'test' => { 	
			1 => { 	'args' => [ '[self]', '[token]' ],
				'expected' => 'AutoToken:Token:[token]',
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
			
			for ( @{ $test->{test}->{$_}->{args} }, $test->{test}->{$_}->{expected} ) {
				s/\[token\]/$test_token/g;
				$_ = $self if /\[self\]/;
			}
			
			my $tmp_result = &{ $test->{func} }( $self, @{ $test->{test}->{$_}->{args} } );
			
#warn "$tmp_result <=> $test->{test}->{$_}->{expected}";			
		
			$err_tmp = &{ $test->{tester} }( $tmp_result, $test->{test}->{$_}->{expected}, 
					$test->{comment}, $self, $test_token ) if !$err_tmp;
					
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
	
	my $fails = 0;

	for ( @$result ) {
		$fails++ if $_->{status};
	}
	
	$result_line = self_test_htm( 'span', ( $fails ? ( 'red', "Присутствуют ошибки" ) : ( 'green', "Всё нормально" ) ) );
	
	for ( @$result ) {
		$result_line .= $_->{text} . ' ' . 
			( !$_->{status} ? 
				self_test_htm( 'font', 'green', "-- ok" ) : 
				self_test_htm( 'font', 'red', "-- fail ( test: $_->{status} )" )
			) . '<br>';
	}
	
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
	};
	
	my $html_line = $html->{$type};
	
	$html_line =~ s/\[param\]/$param/g;
	$html_line =~ s/\[line\]/$line/g;
	
	return $html_line;
}

sub test_line
# //////////////////////////////////////////////////
{
	if (shift ne shift) { 
		return shift;
	};
}

sub test_regexp
# //////////////////////////////////////////////////
{
	my $line = shift;
	my $regexp = shift;
	
	if ( $line !~ /$regexp/ ) {
		return shift;
	}
}

sub test_db
# //////////////////////////////////////////////////
{
	my $result = shift;
	my ( $db_table, $db_name, $db_value ) = split /:/, shift;
	my $comment = shift;
	my $self = shift;
	my $test_token = shift;
	
	my $vars = $self->{ 'VCS::Vars' };
	
	my $value = $vars->db->sel1( "SELECT $db_name FROM $db_table WHERE Token = '$test_token'" );

	if ( $db_value ne $value ) {
		return $comment;
	}
}

1;
