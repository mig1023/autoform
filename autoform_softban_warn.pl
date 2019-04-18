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

	# лог для контроля
		my $log_name = '/var/log/autoform_softban_warn.log';
		
	# список рассылки
		my @addresses = (
			'mail@mail.com',
		);
	
	# подпись письма
		my $signature = 
			'Скрипт отчёта о подозрительной активности';
	
	log_file();
	log_file("Включение скрипта проверки заблокированной активности");	
	log_file("/////////////////////////////////////////////////////");

	my $vars = new VCS::Vars(qw( VCS::Config VCS::SQL VCS::System VCS::Memcache VCS::AdminFunc ));
		
	$vars->db->db_connect($vars);

	my $connections = $vars->db->selallkeys("
		SELECT IP, BanDate FROM SoftBan WHERE DATE(BanDate) = (CURDATE() - INTERVAL 1 DAY) ORDER BY BanDate
	");
	
	my $table = create_table( $connections );
	
	unless ( defined $table ) {
	
		log_file( "Ничего подозрительного НЕ было" );
	}
	else {
		my $subject = 'Отчёт о подавлении подозрительной внешней активности';
		my $body = $table . "<br>Данные за прошедшие сутки<br>Все указанные адреса заблокированы<br><br>" . $signature;
		
		for ( @addresses ) {
			$vars->get_system->send_mail( $vars, $_, $subject, $body );
			log_file( "Отправлено сообщение на $_" );
		}
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

sub create_table {

	my $connections = shift;
	
	my $table = '<table style="border-collapse:collapse;border: solid 1px #000000;"><tr>';
	
	my $tdheadstyle = 'style="border:1px solid black;padding:5px;background-color: lightgray;"';
	my $tdstyle = 'style="border:1px solid black;padding:5px;"';
	
	my $n = 0;
	
	$_->{ N } = ++$n for @$connections;  
	
	my @heads = ( 'N', 'IP', 'BanDate' );
	
	$table .= "<td $tdheadstyle>$_ </td>" for ( @heads );
	
	$table .= "</tr>";
	
	my $line = 0;
	
	for my $row ( @$connections ) {
	
		$line += 1;
		
		log_file( $row->{ IP } );
	
		$table .= "<tr>";
		
		for my $column ( @heads ) {
		
			$table .= "<td $tdstyle>" . $row->{ $column } . "</td>";
		}
		
		$table .= "</tr>";
	}
	
	$table .= "</tr></table>";
	
	return undef if $line == 0;
	
	return $table;
}
