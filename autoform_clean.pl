#!/usr/bin/perl

use strict;

use lib '/usr/local/www/data/htdocs/vcs/lib';

use VCS::Config;
use VCS::Vars;
use VCS::SQL;


	log_file();
	log_file("включение скрипта очистки autotoken");	
	log_file("///////////////////////////////////");
	log_file();

	my $vars = new VCS::Vars(qw( VCS::Config VCS::SQL ));
	
	$vars->db->db_connect( $vars );

	my ( $clear, $first_step ) = ( 0, 0 );
	
	$first_step = $vars->db->sel1("
		SELECT count(ID) FROM AutoToken
		WHERE LinkSended is NULL AND DATEDIFF(now(), StartDate) > 1"
	);
	
	$vars->db->query("
		DELETE FROM AutoToken
		WHERE LinkSended is NULL AND DATEDIFF(now(), StartDate) > 1"
	);
	
	my $alltokens = $vars->db->selallkeys("
		SELECT ID, StartDate, AutoAppID FROM AutoToken
		WHERE Deleted = 0 AND
		DATEDIFF(now(), StartDate) > 14	AND DATEDIFF(now(), LastChange) > 3"
	);

	for my $token ( @$alltokens ) {
	
		log_file( "чистим id " . $token->{ ID } );
		
		$vars->db->query("
			UPDATE AutoToken SET Deleted = 1 WHERE ID = ?", {}, $token->{ ID }
		);
		
		$clear += 1;
		
		next if $token->{ AutoAppID } == 0;
		
		$vars->db->query("
			DELETE FROM AutoAppointments WHERE ID = ?", {}, $token->{ AutoAppID } );
		
		my $alldata = $vars->db->selallkeys("
			SELECT ID, SchengenAppDataID FROM AutoAppData WHERE AppID = ?",
			$token->{ AutoAppID }
		);
		
		for my $data ( @$alldata ) {
		
			$vars->db->query("
				DELETE FROM AutoAppData WHERE ID = ?", {}, $data->{ ID } 
			);
			
			$vars->db->query("
				DELETE FROM AutoSpbAlterAppData WHERE AppDataID = ?", {}, $data->{ ID }
			);
			
			$vars->db->query("
				DELETE FROM AutoSchengenAppData WHERE ID = ?", {}, $data->{ SchengenAppDataID }
			);
		}
	}
	
	log_file();
	log_file( "всего однодневок удалено: $first_step очищено: $clear" );
	log_file( "скрипт завершился" );
	
	

sub log_file
{
	my $msg = shift;
	
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );
	
	$year += 1900;
	$mon++;
	
	for ( $sec, $min, $hour, $mday, $mon, $year) {
		
		$_ = "0$_" if $_ < 10;
	};
	
	open my $file_log, '>>', '/var/log/autotoken_del.log';
	
	print $file_log "$year-$mon-$mday $hour:$min:$sec $msg\n";
	
	close $file_log;
};