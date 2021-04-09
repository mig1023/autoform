#!/usr/bin/perl
use strict;

use LWP::Simple;
use XML::Simple;
use Data::Dumper;
use Date::Calc;
use Cwd "abs_path";

use lib '/usr/local/www/data/htdocs/vcs/lib';

use VCS::Config;
use VCS::Vars;
use VCS::SQL;
use VCS::System;
use VCS::Memcache;
use VCS::AdminFunc;
use VCS::Site::autopayment;
use VCS::Site::autodata;


	log_file();
	log_file("Включение скрипта");	
	log_file("/////////////////");
	
	my $vars = new VCS::Vars(qw( VCS::Config VCS::SQL VCS::System VCS::Memcache VCS::AdminFunc ));
		
	$vars->db->db_connect( $vars );
	
	my $all_docs_in_fox_status = $vars->db->selallkeys("
		SELECT DocPack.ID, DocPack.AgreementNo, AutoRemote.FoxIDto FROM DocPack
		JOIN AutoRemote ON DocPack.AppID = AutoRemote.AppID
		WHERE PStatus = 27
	");

	for my $doc ( @$all_docs_in_fox_status ) {
		
		log_file( "запрос: $doc->{ AgreementNo } ( квитанция $doc->{ FoxIDto } )" );
		
		my $status = VCS::Site::autopayment::fox_status( $vars, $doc->{ FoxIDto } );

		log_file( "статус: $status" );
		
		if ( $status eq "Груз доставлен" ) {
			
			log_file( "-----> " . close_doc( $vars, $doc->{ ID }, $doc->{ AgreementNo } ) );
			
			log_file( "-----> " . close_app( $vars, $doc->{ ID } ) );
		}
	}
	
	log_file( "Скрипт выключен" );
	
	

sub close_doc {

	my ( $vars, $doc_id, $agr ) = @_;
	
	my $doc_lists = $vars->db->selallkeys("
		SELECT DocPackList.ID, PassNum, CBankID FROM DocPackList
		JOIN DocPackInfo ON DocPackList.PackInfoID = DocPackInfo.ID
		WHERE DocPackInfo.PackID = ? AND DocPackList.Status != 7",
		$doc_id
	);
	
	$vars->db->{ dbh }->do( "UPDATE DocPack SET PStatus = 6 WHERE ID = ?", {}, $doc_id );
	
	for ( @$doc_lists ) {
	
		$vars->db->{ dbh }->do( "UPDATE DocPackList SET Status = 6 WHERE ID = ?", {}, $_->{ ID } );
		
		$vars->db->{ dbh }->do( "
			INSERT INTO DocHistory (DocID, PassNum, Login, HDate, StatusID, BankID )
			VALUES ( ?, ?, ?, now(), 6, ? )", {},
			$doc_id, $_->{ PassNum }, 'remote_script', $_->{ CBankID } );
	}
	
	return $agr;
}

sub close_app {

	my ( $vars, $doc_id ) = @_;
	
	my $app_id = $vars->db->sel1( "SELECT AppID FROM DocPack WHERE ID = ?", $doc_id );
	
	my $app_num = $vars->db->sel1( "SELECT AppNum FROM Appointments WHERE ID = ?", $app_id );
	
	$vars->db->{ dbh }->do( "UPDATE AppData SET Status = 4 WHERE AppID = ? AND Status != 2", {}, $app_id );
	
	return $app_num;
}

sub log_file {

	my $msg = shift || '';
	
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );
	$year += 1900; $mon++;
	
	for ( $sec, $min, $hour, $mday, $mon, $year ) { 
		$_ = '0'.$_ if $_ < 10; 
	};
	
	open my $file_log, '>>', '/var/log/autoform_fox.log';
	
	print $file_log "$year-$mon-$mday $hour:$min:$sec " . $msg . "\n";
	
	close $file_log;
}
