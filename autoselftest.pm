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
				'expected' => '[token]:AutoToken:Token:[token]',
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
	{ 	'func' 	=> \&{ VCS::Site::autoform::simple_array_clone },
		'comment' => 'simple_array_clone',
		'test' => { 	
			1 => { 	'tester' => \&test_array_ref,
				'args' => [ [ '1', 'A', '2', 'B' ] ],
				'expected' => [ '1', 'A', '2', 'B' ],
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::get_autoform_content },
		'comment' => 'get_autoform_content',
		'test' => { 	
			1 => { 	'tester' => \&test_array,
				'prepare' => \&pre_content_1,
				'args' => [ '[token]' ],
				'expected' => [
					'1', 
					'Начало записи', 
					'[first_page]', 
					'',
					'autoform.tt2',
					{},
				],
			},
			2 => { 	'tester' => \&test_array,
				'prepare' => \&pre_content_1,
				'args' => [ '[token]' ],
				'param' => [
					{ 'name' => 'action', 'value' => 'forward' },
					
					{ 'name' => 'center', 'value' => '1' },
					{ 'name' => 'vtype', 'value' => '13' },
					{ 'name' => 'email', 'value' => 'mail@mail.ru' },
				
					{ 'name' => 'pers_info', 'value' => 'pers_info' },
					{ 'name' => 'mobil_info', 'value' => 'mobil_info' },
				],
				'expected' => [
					'2', 
					'Данные поездки', 
					'[second_page]', 
					'',
					'autoform.tt2',
					{},
				],
			},
			3 => { 	'tester' => \&test_array,
				'prepare' => \&pre_content_2,
				'args' => [ '[token]' ],
				'param' => [
					{ 'name' => 'action', 'value' => 'back' },
				],
				'expected' => [
					'1', 
					'Начало записи', 
					'[first_page]', 
					'',
					'autoform.tt2',
					{},
				],
			},
			
			# .......
			
		},
	},
	
	{ 	'func' 	=> \&{ VCS::Site::autoform::insert_hash_table },
		'comment' => 'insert_hash_table',
		'test' => { 	
			1 => { 	'tester' => \&test_write_db,
				'args' => [ 'AutoToken', { Token => 'Token', AutoAppID => 999 } ],
				'expected' => 'Token:AutoToken:AutoAppID:999',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::mezzi_assembler },
		'comment' => 'mezzi_assembler',
		'test' => { 	
			1 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { 
					Mezzi1 => '1',
					Mezzi2 => '0',
					Mezzi3 => '1',
					Mezzi4 => '0',
					Mezzi5 => '1',
					Mezzi6 => '0',
					Mezzi7 => '1',
				} ],
				'expected' => 'Mezzi:1|0|1|0|1|0|1',
			},
			2 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { 
					Mezzi1 => '0',
					Mezzi2 => '1',
					Mezzi3 => '0',
					Mezzi4 => '1',
					Mezzi5 => '0',
					Mezzi6 => '1',
					Mezzi7 => '0',
				} ],
				'expected' => 'Mezzi:0|1|0|1|0|1|0',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::visapurpose_assembler },
		'comment' => 'visapurpose_assembler',
		'test' => { 	
			1 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { VisaPurpose => '13' } ],
				'expected' => 'VisaPurpose:0|0|0|0|0|0|0|0|0|0|0|0|1|0|0|0|0',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::mod_hash },
		'comment' => 'mod_hash',
		'test' => { 	
			1 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { VisaPurpose => '13' } ],
				'expected' => 'VisaPurpose:0|0|0|0|0|0|0|0|0|0|0|0|1|0|0|0|0',
			},
			2 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { ID => '1' } ],
				'expected' => 'ID:',
			},
			3 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { Status => '3' } ],
				'expected' => 'Status:1',
			},
			4 => { 	'tester' => \&test_line_in_hash,
				'args' => [ { Status => '3' }, 'TableName', {}, '999' ],
				'expected' => 'AppID:999',
			},
			
			# .......
		},
	},
	
	{ 	'func' 	=> \&{ VCS::Site::autoform::text_error },
		'comment' => 'text_error',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ 0, { 'name' => 'test' },  ],
				'expected' => 'test|Поле "test" не заполнено',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ 1, { 'name' => 'test', 'label' => 'label' },  ],
				'expected' => 'test|В поле "label" указана неверная дата',
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ 2, { 'name' => 'test', 'label_for' => 'label_for' }, 'ABC' ],
				'expected' => 'test|В поле "label_for" введены недопустимые символы: ABC',
			},
			4 => { 	'tester' => \&test_line,
				'args' => [ 4 ],
				'expected' => '|Вы должны полностью закончить все анкеты',
			},
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::check_param },
		'comment' => 'check_param',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'z' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '' },
				],
				'expected' => 'test|Поле "test" не заполнено',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'zW' } ],
				'param' => [
					{ 'name' => 'test', 'value' => 'ABC5АБВ9' },
				],
				'expected' => 'test|В поле "test" введены недопустимые символы: 5АБВ9',
			},
			3 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'zЁ' } ],
				'param' => [
					{ 'name' => 'test', 'value' => 'ABC5АБВ9' },
				],
				'expected' => 'test|В поле "test" введены недопустимые символы: ABC59',
			},
			4 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'zN' } ],
				'param' => [
					{ 'name' => 'test', 'value' => 'ABC5АБВ9' },
				],
				'expected' => 'test|В поле "test" введены недопустимые символы: ABCАБВ',
			},
			
			# .......
		},
	},
	{ 	'func' 	=> \&{ VCS::Site::autoform::check_chkbox },
		'comment' => 'check_chkbox',
		'test' => { 	
			1 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => 'true' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '' },
				],
				'expected' => 'test|Вы должны указать поле "test"',
			},
			2 => { 	'tester' => \&test_line,
				'args' => [ { 'name' => 'test', 'check' => '' } ],
				'param' => [
					{ 'name' => 'test', 'value' => '' },
				],
				'expected' => '',
			},
		},
	},
	
];

my $first_page = '<tr ><td ><label id="text" >Визовый центр</label></td><td ><select size = "1" name="center" id="center" onchange="update_nearest_date_free_date();"></select></td></tr><tr ><td ><label id="text" >Тип визы</label></td><td ><select size = "1" name="vtype" id="vtype" ></select></td></tr><tr ><td ><label id="text" >Ближайшее доступное время</label></td><td ><label id="free_date" ></label></td></tr><tr ><td ><label id="text" >Email</label></td><td ><input type="text" value="" name="email" id="email" title="" ></td></tr><tr ><td>&nbsp;</td><td style="vertical-align:top;"><span style="color:gray; font-size:0.7em;">mail@mail.ru</span></td></td><tr ><td ><label id="text" ></label></td><td ><input type="checkbox" value="pers_info" name="pers_info" id="pers_info" [checked] ><label for="pers_info" >я согласен на обработку персональных данных</label></td></tr><tr ><td ><label id="text" ></label></td><td ><input type="checkbox" value="mobil_info" name="mobil_info" id="mobil_info" [checked] ><label for="mobil_info" >я согласен на условия работы с мобильными</label></td></tr>';

my $second_page = '<tr ><td ><label id="text" >Дата начала поездки</label></td><td ><input type="text" value="" name="s_date" id="s_date" title="" ></td></tr><tr ><td ><label id="text" >Дата окончания поездки</label></td><td ><input type="text" value="" name="f_date" id="f_date" title="" ></td></tr>';

sub selftest 
# //////////////////////////////////////////////////
{
	my $self = shift;
	my $vars = $self->{ 'VCS::Vars' };
	my $config = $vars->getConfig('db');
	
	my $result = [];
	
	$vars->db->query("USE fake_vcs");

	my $test_token = $self->get_token_and_create_new_form_if_need();
	
	push @$result, get_tests( $self, $vars, $test_token );
	
	$vars->db->query( "USE " . $config->{"dbname"} );	

	return show_result($result);
}

sub get_tests
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
			
			for (	@{ $t->{args} }, @{ $t->{param} },
				( ref( $t->{expected} ) eq 'ARRAY' ? @{ $t->{expected} } : $t->{expected} )
			) {
				s/\[token\]/$test_token/g;
				s/\[first_page\]/$first_page/g;
				s/\[second_page\]/$second_page/g;
				
				if ( ref($_) eq 'HASH' ) {
					$_->{value} =~ s/\[token\]/$test_token/g if exists $_->{value};
				}
			}
			
			for ( @{ $t->{param} } ) {
				$vars->setparam( $_->{name} ,$_->{value} );
			}

			unless ( $err_tmp ) {
				$err_tmp = &{ $t->{tester} }( 
					$t->{expected}, $test->{comment}, $self, 
					&{ $test->{func} }( $self, @{ $t->{args} } ) 
				);
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
	$result_line .= self_test_htm( 'br' ) . self_test_htm( 'span', ( $fails ? 'red' : 'green' ), "$test_num тест(ов)" );
	
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
	my ( $expected, $comm, undef, $result ) = @_;

	if ( lc( $expected ) ne lc( $result ) ) { 
		return $comm;
	};
}

sub test_line_in_hash
# //////////////////////////////////////////////////
{
	my ( $expected, $comm, undef, $result ) = @_;
	my ( $key, $value ) = split /:/, $expected;

	if ( lc( $result->{ $key } ) ne lc( $value ) ) { 
		return $comm;
	};
}

sub test_array
# //////////////////////////////////////////////////
{
	my $array_2 = shift;
	my $comm = shift;
	my $self = shift;
	my @array_1 = @_;

	my $eq = 1;
	
	for ( 1..$#array_1 ) {
		next if ref( $array_1[$_] ) and ref( $array_2->[$_] );
		$eq = 0 if $array_1[$_] ne $array_2->[$_];
	}
	
	if ( !$eq ) { 
		return $comm;
	};
}

sub test_array_ref
# //////////////////////////////////////////////////
{
	my $array_2 = shift;
	my $comm = shift;
	my $self = shift;
	my $array_1 = shift;

	my $eq = 1;
	
	for ( 1..$#{$array_1} ) {
		$eq = 0 if $array_1->[$_] ne $array_2->[$_];
	}
	
	if ( !$eq ) { 
		return $comm;
	};
}

sub test_regexp
# //////////////////////////////////////////////////
{
	my ( $regexp, $comm, undef, $result ) = @_;
	
	if ( $result !~ /$regexp/ ) {
		return $comm;
	}
}

sub test_write_db
# //////////////////////////////////////////////////
{
	my ( $test_token, $db_table, $db_name, $db_value ) = split /:/, shift;
	my $comment = shift;
	my $self = shift;
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

sub pre_content_1
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $test = shift;
	my $num = shift;
	my $token = shift;
	my $vars = shift;
	
	$vars->db->query( "UPDATE AutoToken SET Step = 1 WHERE Token = '$$token'" );
}

sub pre_content_2
# //////////////////////////////////////////////////
{
	my $type = shift;
	my $test = shift;
	my $num = shift;
	my $token = shift;
	my $vars = shift;
	
	my $appid = $vars->db->sel1( "SELECT AutoAppID FROM AutoToken WHERE Token = '$$token'" );
		
	$vars->db->query( 
		"UPDATE AutoAppointments SET PersonalDataPermission = 0,
		MobilPermission = 0, EMail = '' WHERE ID = '$appid'" );
		
	$vars->db->query( "UPDATE AutoToken SET Step = 2 WHERE Token = '$$token'" );
}

1;
