package VCS::Site::autocheckdoc;
use strict;

use VCS::Vars;
use VCS::Site::autodata;

use Data::Dumper;
use Date::Calc;
use JSON;

sub new
# //////////////////////////////////////////////////
{
	my ( $class, $pclass, $vars ) = @_;
	
	my $self = bless {}, $pclass;
	
	$self->{ 'VCS::Vars' } = $vars;
	
	return $self;
}

sub autocheckdoc
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template, $entry ) = @_;
		
	$self->{ $_ } = $self->{ af }->{ $_ } for ( 'vars', 'token' );
	
	$self->{ vars }->{ session }->{ login } = 'website';

	my $lang_param = $self->{ vars }->getparam( 'lang' ) || 'ru';

	$self->{ vars }->{ session }->{ langid } = $lang_param if $lang_param =~ /^(ru|en|it)$/i ;

	$_ = $self->{ vars }->getparam( 'action' );
	
	s/[^a-z_]//g;
	
	# return $self->print_appointment() if /^print$/i;
	
	# return autoinfopage_entry( @_ ) if $entry;
	
	return get_checkdocpage( @_ );
}

sub get_checkdocpage
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;

	my $app_info = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT CreatedApp, AppNum as new_app_num, AppDate as new_app_date,
		TimeslotID as new_app_timeslot,	CenterID as new_app_branch, VName as new_app_vname, category
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
	
	$app_info->{ new_app_timeslot } =~ s/\s.+//g;

	$self->{ vars }->get_system->pheader( $self->{ vars } );

	my $tvars = {
		'langreq'	=> sub { return $self->{ vars }->getLangSesVar( @_ ) },
		'title' 	=> 1,
		'yandex_key'	=> $self->{ autoform }->{ yandex_map }->{ api_key },
		'app_info'	=> $app_info,
		'app_list'	=> $self->get_app_list(),
		'map_in_page' 	=> $self->{ af }->get_geo_info( 'app_already_created' ),
		'token' 	=> $self->{ token },
		'center_msk'	=> $center_msk,
		'vcs_tools' 	=> $self->{ af }->{ paths }->{ addr_vcs },
		'static'	=> $self->{ autoform }->{ paths }->{ static },
		'lang_in_link'	=> $self->{ vars }->{ session }->{ langid } || 'ru',
		
	};
	$template->process( 'autoform_checkdoc.tt2', $tvars );
}

sub get_app_list
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $app_list = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT AppData.ID, DocUploaded.ID as DocID, AppData.FName, AppData.LName, AppData.BirthDate,
		DocUploaded.DocType, DocUploaded.Name, DocUploaded.Ext, DocUploaded.CheckStatus
		FROM AutoToken 
		JOIN AppData ON AppData.AppID = AutoToken.CreatedApp
		JOIN DocUploaded ON DocUploaded.AppDataID = AppData.ID
		WHERE Token = ? AND AppData.Status = 1", $self->{ token }
	);
	
	$_->{ 'BirthDate' } =~ s/(\d\d\d\d)\-(\d\d)\-(\d\d)/$3.$2.$1/ for @$app_list;
	
	my $doc_types_tmp = VCS::Site::autodata::get_doc_list();
	
	my %doc_types = map { $_->{ id } => $_->{ title } } @$doc_types_tmp;
	
	my $doc_comments_tmp = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT DocID, CommentText, CommentDate
		FROM AutoToken 
		JOIN AppData ON AppData.AppID = AutoToken.CreatedApp
		JOIN DocUploaded ON DocUploaded.AppDataID = AppData.ID
		JOIN DocUploadedComment ON DocUploaded.ID = DocUploadedComment.DocID
		WHERE Token = ? AND AppData.Status = 1", $self->{ token }
	);
	
	my $doc_comments = {};
	
	for ( @$doc_comments_tmp ) {
		
		$doc_comments->{ $_->{ DocID } } = [] unless exists $doc_comments->{ $_->{ DocID } };
		
		push( @{ $doc_comments->{ $_->{ DocID } } }, { id => $_->{ DocID }, text => $_->{ CommentText }, date => $_->{ CommentDate } } );
	}

	my $doc_list = {};
	
	for my $app ( @$app_list ) {
		
		my $file = {};

		$file->{ $_ } = $app->{ $_ } for ( 'DocType', 'Name', 'Ext', 'CheckStatus' );
		
		$file->{ TypeStr } = $doc_types{ $file->{ DocType } }; 
		
		$file->{ comments } = $doc_comments->{ $app->{ DocID } };
		
		if ( exists $doc_list->{ $app->{ ID } } ) {
			
			push( @{ $doc_list->{ $app->{ ID } }->{ files } }, $file  );
		}
		else {
			$doc_list->{ $app->{ ID } } = {};
			
			$doc_list->{ $app->{ ID } }->{ $_ } = $app->{ $_ } for ( 'FName', 'LName', 'BirthDate' );

			$doc_list->{ $app->{ ID } }->{ files } = [ $file ];
		};
	}
	
	#warn Dumper( $doc_list );

	return $doc_list;
}
	
1;
