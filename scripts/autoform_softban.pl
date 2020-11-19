#!/usr/bin/perl

use LWP::Simple;
use XML::Simple;
use Data::Dumper;
use Cwd "abs_path";
use strict;

use lib '/usr/local/www/data/htdocs/vcs/lib';

use VCS::Config;
use VCS::Vars;
use VCS::SQL;
use VCS::System;
use VCS::Memcache;
use VCS::AdminFunc;
use Date::Calc;

	my $log_name = '/var/log/autoform_softban.log';
		
	my $warn_connection = 50;
		
	my $inner_ip = {
		'127.0.0.1' => 1,
	};
		
	log_file();
	log_file("Включение скрипта подавления подозрительной активности");	
	log_file("//////////////////////////////////////////////////////");
	
	my $vars = new VCS::Vars(qw( VCS::Config VCS::SQL VCS::System VCS::Memcache VCS::AdminFunc ));
		
	$vars->db->db_connect($vars);

	my $already_banned_array = $vars->db->selallkeys("
		SELECT IP FROM SoftBan
	");
	
	my %already_banned = map { $_->{ IP } => 1 } @$already_banned_array;
	
	my $connections = $vars->db->selallkeys("
		SELECT LastIP AS IP, count(ID) AS ConnectionNumber, MIN(StartDate) AS Start, MAX(StartDate) AS End
		FROM AutoToken
		WHERE DATE(StartDate) = CURDATE() AND Email IS NULL
		GROUP BY LastIP ORDER BY ConnectionNumber DESC;
	");
	
	for my $row ( @$connections ) {
	
		next if $row->{ ConnectionNumber } < $warn_connection;

		next if $already_banned{ $row->{ IP } };
		
		next if exists $inner_ip->{ $row->{ IP } };
		
		$vars->db->query("
			INSERT INTO SoftBan (IP, BanDate, Reason) VALUES (?, now(), ?)",
			{}, $row->{ IP }, "autoform empty forms"
		);
		
		log_file( $row->{ IP } . " --> " . $row->{ ConnectionNumber } );
	}
	
	log_file( "Скрипт выключен" );
	

sub log_file {

	my $msg = shift || '';
	
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );
	$year += 1900; $mon++;
	
	for ( $sec, $min, $hour, $mday, $mon, $year ) { 
		$_ = '0'.$_ if $_ < 10; 
	};
	
	open my $file_log, '>>', $log_name;
	
	print $file_log "$year-$mon-$mday $hour:$min:$sec " . $msg . "\n";
	
	close $file_log;
}
