package VCS::Site::autoinfopage;
use strict;

use VCS::Vars;
use VCS::Site::autodata;

use Data::Dumper;
use Date::Calc;
use JSON;
use Image::Resize;
use Digest::MD5 qw( md5_hex );

sub new
# //////////////////////////////////////////////////
{
	my ( $class, $pclass, $vars ) = @_;
	
	my $self = bless {}, $pclass;
	
	$self->{ 'VCS::Vars' } = $vars;
	
	return $self;
}

sub autoinfopage
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template, $entry ) = @_;
		
	$self->{ $_ } = $self->{ af }->{ $_ } for ( 'vars', 'token' );
	
	$self->{ autodata } = VCS::Site::autodata::get_settings();
	
	$self->{ vars }->{ session }->{ login } = 'website';
	
	$self->{ vars }->{ session }->{ langid } = 'en' if $self->{ vars }->getparam( 'lang' ) =~ /^en$/i ;
		
	$_ = $self->{ vars }->getparam( 'action' );
	
	s/[^a-z_]//g;
	
	return $self->print_appointment() if /^print$/i;
	
	return $self->print_appdata() if /^print_a$/i;
	
	return autoinfopage_entry( @_ ) if $entry;

	return reschedule( @_ ) if /^reschedule$/i;
	
	return cancel( @_ ) if /^cancel$/i;
	
	return upload_doc( @_ ) if /^upload_doc$/i;
	
	return upload_file( @_ ) if /^upload_file$/i;
	
	return download_file( @_ ) if /^download_file$/i;
	
	return get_infopage( @_ );
}

sub autoinfopage_entry
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $param = {};
	
	for ( "action", "appnum", "passnum" ) {
	
		$param->{ $_ } = $self->{ vars }->getparam( $_ ) || undef;
		
		$param->{ $_ } =~ s/[^A-Za-z0-9]//g;
	}

	if ( $param->{ action } and ( !$param->{ appnum } or !$param->{ passnum } or $self->{ af }->check_captcha() ) ) {
	
		return $self->{ af }->redirect( 'no_field' );
	}
	elsif ( $param->{ action } ) {

		my $appdata = $self->{ af }->query( 'selallkeys', __LINE__, "
			SELECT Token, AppData.PassNum as passnum
			FROM AutoToken
			JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
			JOIN AppData ON Appointments.ID = AppData.AppID
			WHERE AppNum = ?", $param->{ appnum }
		);

		for my $app ( @$appdata ) {
		
			my $passnum = $app->{ passnum };

			return $self->{ af }->redirect( $app->{ Token } ) if $param->{ passnum } =~ /^$passnum$/i;
		}
			
		return $self->{ af }->redirect( 'no_app' );
	}
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq' 	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'addr' 		=> $self->{ vars }->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'widget_api'	=> $self->{ autoform }->{ captcha }->{ widget_api },
		'public_key'	=> $self->{ autoform }->{ captcha }->{ public_key },
	};
	$template->process( 'autoform_info_entry.tt2', $tvars );
}

sub get_infopage
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my $app_info = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT CreatedApp, AppNum as new_app_num, AppDate as new_app_date,
		TimeslotID as new_app_timeslot,	CenterID as new_app_branch, VName as new_app_vname
		FROM AutoToken
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		JOIN VisaTypes ON Appointments.VType = VisaTypes.ID
		WHERE Token = ?", $self->{ token }
	)->[0];

	my @new_date = split( /\-/, $app_info->{ new_app_date } );
	
	my $months = VCS::Site::autodata::get_months();
	
	$app_info->{ new_app_date } = [ $new_date[2], $months->{ $new_date[1] }, $new_date[0] ];
	
	$app_info->{ new_app_num } =~ s!(\d{3})(\d{4})(\d{2})(\d{2})(\d{4})!$1/$2/$3/$4/$5!;

	my $center_msk = ( $app_info->{ new_app_branch } == 1 ? 1 : 0 );

	$self->{ af }->correct_values( \$app_info );

	$self->{ vars }->get_system->pheader( $self->{ vars } );

	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 1,
		'app_info'	=> $app_info,
		'app_list'	=> $self->get_app_list(),
		'map_in_page' 	=> $self->{ af }->get_geo_info( 'app_already_created' ),
		'token' 	=> $self->{ token },
		'center_msk'	=> $center_msk,
		'vcs_tools' 	=> $self->{ af }->{ paths }->{ addr_vcs },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub print_appointment
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
	);

	my $appointment = VCS::Docs::appointments->new( 'VCS::Docs::appointments', $self->{ vars } );
	
	my $report = VCS::Reports::reports->new( 'VCS::Reports::reports', $self->{ vars } );
	
	$report->printReport( $appointment->createPDF( $app_id ), 'pdf', "appointment" );
}

sub print_appdata
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $appdata = lc( $self->{ vars }->getparam( 'appdata' ) );
	
	$appdata =~ s/[^0-9]//g;

	return $self->{ af }->redirect( 'current' ) unless $self->check_existing_id_in_token( $appdata );

	my $print = VCS::Docs::docs->new( 'VCS::Docs::docs', $self->{ vars } );
	
	$self->{ vars }->setparam( 'appid', $appdata );
	
	$print->print_anketa();
}

sub reschedule
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $new = {};

	my $id_or_error;
	
	my $appinfo_for_timeslots = $self->get_same_info_for_timeslots_from_app();

	$new->{ $_ } = $self->{ vars }->getparam( $_ ) for ( 'appdate', 'apptime' );

	if (
		$new->{ apptime } =~ /^\d+$/
		and
		$new->{ appdate } =~ /\d\d\.\d\d\.\d\d\d\d/
	) {

		$appinfo_for_timeslots->{ $_  } = $new->{ appdate } for ( 'appdate', 'appdate_iso' );

		$appinfo_for_timeslots->{ appdate_iso } =~ s/(\d\d)\.(\d\d)\.(\d\d\d\d)/$3-$2-$1/;

		if (
			$new->{ apptime } > 0
			and
			$self->check_timeslots_already_full( $appinfo_for_timeslots, $new->{ apptime } )
			and
			Date::Calc::check_date( $3, $2, $1 )
		) {

			$id_or_error = $self->set_new_appdate( $new );
			
			return $self->{ af }->redirect( 'current' ) if $id_or_error =~ /^\d+$/;
		}

	}

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 2,
		'appinfo'	=> $appinfo_for_timeslots,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'vcs_tools' 	=> $self->{ autoform }->{ paths }->{ addr_vcs },
		'error'		=> $id_or_error,
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub cancel
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $app_list = $self->get_app_list();

	my $ncount_correction = 0;
	
	for my $app ( @$app_list ) {

		next unless $self->{ vars }->getparam( 'cancel' . $app->{ ID } );
	
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE AppData SET Status = 2 WHERE ID = ?", {}, $app->{ ID }
		);

		$ncount_correction = 1;
	}
	
	if ( $ncount_correction ) {
	
		my $list_after_cancel = $self->get_app_list();
		
		my $app_id = $self->{ af }->query( 'sel1', __LINE__, "
			SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
		);
		
		my $ncount = scalar @$list_after_cancel;
		
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE Appointments SET NCount = ? WHERE ID = ?", {},
			$ncount, $app_id
		);
		
		$self->{ af }->query( 'query', __LINE__, "
			UPDATE Appointments SET Status = 2 WHERE ID = ?", {}, $app_id
		) if $ncount < 1;
		
		return $self->{ af }->redirect( ( $ncount < 1 ) ? 'canceled' : 'current' );
	}
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 3,
		'app_list'	=> $app_list,
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub upload_doc
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $conf = $self->{ vars }->getConfig('general');
	my $appdata_id = $self->{ vars }->getparam( 'appdata' );

	my $doc_list = VCS::Site::autodata::get_doc_list();
	
	my $visa_type = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT VType FROM Appointments JOIN AppData ON AppData.AppID = Appointments.ID WHERE AppData.ID = ?", $appdata_id
	);
	
	my $all_docs = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT DocType FROM DocUploaded WHERE AppDataID = ?", $appdata_id
	) if $appdata_id;
	
	my $index = 0;
	
	for ( my $index = $#$doc_list; $index >= 0; --$index ) {
	
		my %visas = map { $_ => 1 } split /,\s?/, $doc_list->[ $index ]->{ visa };

		unless ( exists $visas{ $visa_type } ) {

			splice( @$doc_list, $index, 1 );
		}
		else {
			for my $doc ( @$all_docs ) {
				$doc_list->[ $index ]->{ stat } = 1 if $doc_list->[ $index ]->{ id } == $doc->{ DocType };
			}
		}
	}

	$self->{ vars }->get_system->pheader( $self->{ vars } );
	
	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 4,
		'app_id'	=> $appdata_id,
		'doc_list'	=> $doc_list,
		'max_size'	=> $self->{ autodata }->{ general }->{ max_file_upload_size },
		'token' 	=> $self->{ token },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
	};
	$template->process( 'autoform_info.tt2', $tvars );
}

sub upload_file
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $file_content;

	my $appdata_id = $self->{ vars }->getparam( 'appdata' );
	
	my $doc_type = $self->{ vars }->getparam( 'type' );
	
	$_ =~ s/[^0-9]//g for ( $appdata_id, $doc_type );
	
	my $file = $self->{ vars }->getparam( 'file' );
	
	my $filename = $self->{ vars }->getparam( 'filename' );
	
	$filename =~ s/[^A-Za-z0-9_\-\.]//g;
	
	$self->{ vars }->get_system->pheader( $self->{ vars } );

	return print 'error' if ( !$file or !$appdata_id or !$doc_type );
	
	my ( $path_name, $date_name ) = $self->get_folder_name();
	
	my $file_name = $path_name . $appdata_id . '_' . $doc_type;;
	
	$file_content .= $_ while ( <$file> );
	
	return print 'error' unless $self->set_file_content( $file_name, $file_content );
	
	if ( -s $file_name > $self->{ autodata }->{ general }->{ max_file_upload_size } ) {
	
		unlink $file_name;
		
		return print 'error';
	}
	
	my $image = Image::Resize->new( $file_name );
	my $preview = $image->resize( 200, 200 );
	 
	return print 'error' unless $self->set_file_content( $file_name . '_preview.jpg', $preview->jpeg() ); 
		
	$self->{ af }->query( 'query', __LINE__, "
		INSERT INTO DocUploaded (AppDataID, DocType, md5, UploadDate, Folder) VALUES (?, ?, ?, now(), ?)",
		{}, $appdata_id, $doc_type, md5_hex( $file_content ), $date_name
	);

	return print 'ok';
}

sub download_file
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $preview = ( $self->{ vars }->getparam( 'preview' ) ? 1 : 0 );
	
	my $conf = $self->{ vars }->getConfig('general');
	
	my $appdata_id = $self->{ vars }->getparam( 'appdata' );
	
	my $doc_type = $self->{ vars }->getparam( 'type' );
	
	$_ =~ s/[^a-z0-9]//g for ( $appdata_id, $doc_type );
	
	my $folder = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT Folder FROM DocUploaded
		WHERE AppDataID = ? AND DocType = ?", $appdata_id, $doc_type
	) . '/' unless $appdata_id eq 'simple';
	
	my $file_name = $conf->{ tmp_folder } . 'doc/' . $folder . $appdata_id . '_' . $doc_type . ( $preview ? '_preview.jpg' : '' );
	
	print "HTTP/1.1 200 Ok\nContent-Type: image/jpeg name=\"preview.jpg\"\nContent-Disposition: attachment; filename=\"preview.jpg\"\n\n";
	
	my $file_content = $self->{ af }->get_file_content( $file_name );
	
	print $file_content;
}

sub get_same_info_for_timeslots_from_app
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app = {};

	( $app->{ persons }, $app->{ center }, $app->{ fdate }, $app->{ timeslot }, $app->{ appdate } ) = 
		$self->{ af }->query( 'sel1', __LINE__, "
			SELECT count(AppData.ID), CenterID, SDate, TimeslotID, AppDate
			FROM AutoToken 
			JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
			JOIN AppData ON AppData.AppID = Appointments.ID
			WHERE Token = ?", $self->{ token }
		);
	
	for ( 'fdate', 'appdate' ) {
	
		$app->{ $_ . '_iso' } = $app->{ $_ };
		
		$app->{ $_ } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/;
	}

	return $app;
}

sub check_timeslots_already_full
# //////////////////////////////
{
	my ( $self, $app, $timeslot ) = @_;

	my $appobj = VCS::Docs::appointments->new( 'VCS::Docs::appointments', $self->{ vars } );

	my $timeslots = $appobj->get_timeslots_arr( $app->{ center }, $app->{ persons }, $app->{ appdate_iso } );

	for ( @$timeslots ) {

		return 1 if $_->{id} == $timeslot;
	}
}

sub get_app_list
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app_list = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppData.ID, AppData.AppID, AppData.FName, AppData.LName, AppData.BirthDate
		FROM AutoToken 
		JOIN AppData ON AppData.AppID = AutoToken.CreatedApp
		WHERE Token = ? AND AppData.Status = 1", $self->{ token }
	);

	$_->{ 'BirthDate' } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/ for @$app_list;

	return $app_list;
}

sub set_new_appdate
# //////////////////////////////////////////////////
{
	my ( $self, $new ) = @_;

	my $appid = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT CreatedApp FROM AutoToken WHERE Token = ?", $self->{ token }
	);

	my ( $newnum, $new_app_id );

	my $urgent = VCS::Site::newapps::getUrgent( $self, $new->{ fdate }, $new->{ app_date }, $new->{ center } );

	my $docobj = VCS::Docs::docs->new( 'VCS::Docs::docs', $self->{ vars } );

	my $error = $docobj->reschApp( $appid, $urgent, \$newnum, \$new_app_id );

	$self->{ af }->query( 'query', __LINE__, "
		UPDATE AutoToken SET CreatedApp = ? WHERE Token = ?", {},
		$new_app_id, $self->{ token }
	) unless $error;

	return ( $error ? $error : $new_app_id );
}

sub check_existing_id_in_token
# //////////////////////////////////////////////////
{
	my ( $self, $appdata_id ) = @_;
	
	my $exist = 0;
	
	my $list_of_app_in_token = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppData.ID
		FROM AutoToken 
		JOIN Appointments ON AutoToken.CreatedApp = Appointments.ID
		JOIN AppData ON Appointments.ID = AppData.AppID
		WHERE Token = ?", $self->{ token }
	);

	for my $app ( @$list_of_app_in_token ) {
		$exist = 1 if ( $app->{ID} == $appdata_id );
	}
	
	return $exist;
}

sub set_file_content
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $name = shift;
	
	my $content = shift;
	
	open( my $file, '>', $name ) or return undef;
	
	binmode $file;
	
	print $file $content;
	
	close $file;
	
	return 1;
}

sub get_folder_name
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $conf = $self->{ vars }->getConfig('general');

	my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime( time );
	
	$year += 1900;
	
	$mon++;
	
	for ( $mday, $mon, $year ) {
		
		$_ = "0$_" if $_ < 10;
	};
	
	my $folder_name = $conf->{ tmp_folder } . "doc/$year-$mon-$mday/";
	
	mkdir $folder_name unless -d $folder_name;
	
	return ( $folder_name, "$year-$mon-$mday" );
}
	
1;
