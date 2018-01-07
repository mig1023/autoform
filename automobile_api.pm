package VCS::Site::automobile_api;
use strict;

use VCS::Vars;
use VCS::Site::autodata;

use Data::Dumper;
use JSON;

sub get_mobile_api
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;

	my $vars = $self->{ 'VCS::Vars' };
	
	my $table_id = $self->get_current_table_id();
	
	my $api = $vars->getparam( 'mobile_api' ) || '';
	
	return get_api_head( $self, 1 ) if $self->{ token } =~ /^\d\d$/;
		
	return get_values_for_api( $self ) if $api =~ /^get_appdata$/i;

	return set_values_from_api( $self ) if $api =~ /^set_appdata$/i;

	return get_api_centers( $self ) if $api =~ /^get_centers$/i;

	return get_doc_status( $self ) if $api =~ /^get_doc_status$/i;
	
	return get_advertisment() if $api =~ /^get_advertisment$/i;
	
	return get_push( $self, $1 ) if $api =~ /^push_(on|off)$/i;
	
	return get_api_head( $self, 2 ) if $api !~ /^get_token$/i;
	
	return get_api_head( $self, 0 );
}

sub get_values_for_api
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $delete_fields = VCS::Site::autodata::get_mobile_api_fields( 'to_delete' );
	
	my $tables_id = $self->get_current_table_id();
	
	my $result = get_api_head( $self, 0 );
	
	$result->{ appointments } = $self->query( 'selallkeys', __LINE__, "
		SELECT * FROM AutoAppointments WHERE ID = ?", $tables_id->{ AutoAppointments }
	)->[0];
	
	$result->{ date } = $result->{ appointments }->{ AppDate };
	
	delete $result->{ appointments }->{ $_ } for ( @{ $delete_fields->{ appointments } } );
		
	my $all_applicants = $self->query( 'selallkeys', __LINE__, "
		SELECT * FROM AutoAppData WHERE AppID = ?", $tables_id->{ AutoAppointments }
	);

	for my $app ( 0..$#$all_applicants ) {
	
		my $sch_app = {};
	
		if ( $all_applicants->[ $app ]->{ SchengenAppDataID } != 0 ) {
			
			$sch_app = $self->query( 'selallkeys', __LINE__, "
				SELECT * FROM AutoSchengenAppData WHERE ID = ?", $all_applicants->[ $app ]->{ SchengenAppDataID }
			)->[0];
			
			delete $sch_app->{ ID };
		}
		
		$result->{ schengen }->[ $app ] = $sch_app;
	
		delete $all_applicants->[ $app ]->{ $_ } for ( @{ $delete_fields->{ appdata } } );
	
		$result->{ appdata }->[ $app ] = $all_applicants->[ $app ];
	}
	
	return $result;
}

sub set_values_from_api
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $enabled_fields_array = VCS::Site::autodata::get_mobile_api_fields();
	
	my $vars = $self->{ 'VCS::Vars' };

	my $json = $vars->getparam( 'data' );
		
	my $data = decode_json( $json );

	for my $table ( keys %{ $enabled_fields_array } ) {
		
		my %field_for_table = map { $_ => 1 } @{ $enabled_fields_array->{ $table } };
		
		if ( $table =~ /^(appdata|schengen)$/ ) {
	
			for my $app ( @{ $data->{ $table } } ) {
				for my $field ( keys %{ $app } ) {
					delete $app->{ $field }	unless exists $field_for_table{ $field };
				}
			}
		}
		else {
			for my $field ( keys %{ $data->{ $table } } ) {
				delete $data->{ $table }->{ $field } unless exists $field_for_table{ $field };
			}
		}
	}

	my $app_id = $self->insert_hash_table( 'AutoAppointments', $data->{ appointments } );

	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET AutoAppID = ? WHERE Token = ?", {}, $app_id, $self->{ token }
	);
	
	my $app_max = 0;
	
	for ( 0..$#{ $data->{ appdata } } ) {	

		my $sch_id = $self->insert_hash_table( 'AutoSchengenAppData', $data->{ schengen }->[ $_ ] );
		
		$data->{ appdata }->[ $_ ]->{ AppID } = $app_id;
		$data->{ appdata }->[ $_ ]->{ SchengenAppDataID } = $sch_id;
		
		$self->insert_hash_table( 'AutoAppData', $data->{ appdata }->[ $_ ] );
	}
	
	$self->redirect( $self->{ token } . '&mobile_app=on' );
}

sub get_api_centers
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $result = {};
	
	my $all_centers = $self->query( 'selallkeys', __LINE__, "
		SELECT BName, BAddr as address, phone, email, submissionTime, collectionTime
		FROM Branches
		WHERE isDeleted = 0 AND Display = 1"
	);
	
	for ( @$all_centers ) {
	
		$result->{ $_->{ BName } } = $_;
		
		delete $result->{ $_->{ BName } }->{ BName };
	}
	
	return $result;
}

sub get_doc_status
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $result = { 'status' => "0" };
	
	my $param = get_all_param( $self, 'docnum', 'birthdate' );

	return $result if !$param->{ docnum } or !$param->{ birthdate };

	my $docid = $self->query( 'sel1', __LINE__, "
		SELECT ID FROM DocPack WHERE AgreementNo = ? AND PStatus != 7",
		$param->{ docnum }
	) || 0;
	
	return $result unless $docid;
	
	return $result unless $param->{ birthdate } =~ /^([0-9]{2})([0-9]{2})([0-9]{4})$/;
	
	my $birthdate = "$3-$2-$1";
	
	my $all_status = $self->query( 'selallkeys', __LINE__, "
		SELECT ApplID, Status, BthDate
		FROM DocPackInfo
		JOIN DocPackList ON DocPackInfo.ID = PackInfoID
		WHERE PackID = ?", $docid
	);
	
	for ( @$all_status ) {
	
		$result->{ status } = $_->{ Status } if $birthdate eq $_->{ BthDate };
	}
	
	$result->{ status } = "0" if $result->{ status } == 7;
	
	$result->{ status } = "3" if $result->{ status } > 7;
	
	return $result;
}

sub get_advertisment
# //////////////////////////////////////////////////
{
	return [
		'http://www.italyvms.ru',
	];
}

sub get_push
# //////////////////////////////////////////////////
{
	my ( $self, $swich ) = @_;
	
	my $result = get_api_head( $self, 2, 'without_token' );
	
	my $param = get_all_param( $self, 'docnum', 'mid', 'birthdate' );
	
	return $result if !$param->{ docnum } or !$param->{ mid } or !$param->{ birthdate };
	
	return $result unless $param->{ birthdate } =~ /^([0-9]{2})([0-9]{2})([0-9]{4})$/;
	
	my $birthdate = "$3-$2-$1";
	
	my $docid = $self->query( 'sel1', __LINE__, "
		SELECT DocPack.ID
		FROM DocPack
		JOIN DocPackInfo ON DocPack.ID = DocPackInfo.PackID
		JOIN DocPackList On DocPackInfo.ID = DocPackList.PackInfoID
		WHERE AgreementNo = ? AND DocPackList.BthDate = ? AND PStatus != 7",
		$param->{ docnum }, $birthdate
	);
	
	return get_api_head( $self, 3, 'without_token' ) unless $docid;
	
	$result = get_api_head( $self, 0, 'without_token' );
	
	my ( $pushid, $pushstatus ) = $self->query( 'sel1', __LINE__, "
		SELECT ID, PushStatus FROM DocPackMobilePush WHERE DocPackID = ? AND MobileID = ?",
		$docid, $param->{ mid }
	);

	if ( $swich =~ /on/i ) {
	
		$result->{ push } = 'enabled';
	
		if ( !$pushid ) {
			
			$self->query( 'query', __LINE__, "
				INSERT INTO DocPackMobilePush (DocPackID, PushStatus, MobileID) VALUES (?, 1, ?)", {}, 
				$docid, $param->{ mid }
			);
		}
		elsif ( $pushstatus != 1 ) {
			
			$self->query( 'query', __LINE__, "
				UPDATE DocPackMobilePush SET PushStatus = 1 WHERE ID = ?", {}, 
				$pushid
			);
		}
	}
	else {
		$result->{ push } = 'disabled';
	
		if ( $pushid and $pushstatus == 1 ) {
		
			$self->query( 'query', __LINE__, "
				UPDATE DocPackMobilePush SET PushStatus = 0 WHERE ID = ?", {}, 
				$pushid
			);
		}
	}
	
	return $result;
}

sub get_api_head
# //////////////////////////////////////////////////
{
	my ( $self, $error_number, $without_token ) = @_;
	
	my $error_text = [
		'',
		'ошибка токена',
		'ошибка API-запроса',
		'договор не найден',
	];
	
	my $result = { 
		'error' => {
			'error' => $error_number,
			'error_text' => $self->lang( $error_text->[ $error_number ] ),
		}
	};
	
	$result->{ token } = $self->{ token } unless $without_token;
	
	return $result;
}

sub get_all_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $param = {};
	
	for ( @_ ) {
	
		$param->{ $_ } = $self->{ vars }->getparam( $_ ) || '';
		
		$param->{ $_ } =~ s/[^0-9]//g;
	}
	
	return $param;
}

1;
