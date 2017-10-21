package VCS::Site::automobile_api;
use strict;

use VCS::Vars;

use Data::Dumper;
use JSON;

sub get_mobile_api
# //////////////////////////////////////////////////
{
	my ( $self, $token ) = @_;

	my $vars = $self->{ 'VCS::Vars' };
	
	my $table_id = $self->get_current_table_id();
	
	my $result;
	
	if ( $self->{ token } =~ /^\d\d$/ ) {
	
		$result = get_api_head( $self, 1 );
	}
	elsif ( $vars->getparam( 'mobile_app' ) eq 'get_appdata' ) {
		
		$result = get_values_for_api( $self );
	}
	elsif ( $vars->getparam( 'mobile_app' ) eq 'set_appdata' ) {
	
		$result = set_values_from_api( $self );
	}
	elsif ( $vars->getparam( 'mobile_app' ) ne 'get_token' ) {
		
		$result = get_api_head( $self, 2 );
	}
	
	return $result;
}

sub get_values_for_api
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $tables_id = $self->get_current_table_id();
	
	my $result = get_api_head( $self, 0 );
	
	$result->{ appointments } = $self->query( 'selallkeys', __LINE__, "
		SELECT * FROM AutoAppointments WHERE ID = ?", $tables_id->{ AutoAppointments }
	)->[0];
	
	$result->{ date } = $result->{ appointments }->{ AppDate };
	
	delete $result->{ appointments }->{ $_ } 
		for ( 'ID', 'PersonalDataPermission', 'MobilPermission', 'PersonForAgreements', 'TimeslotID', 'AppDate' );
		
	my $all_applicants = $self->query( 'selallkeys', __LINE__, "
		SELECT * FROM AutoAppData WHERE AppID = ?", $tables_id->{ AutoAppointments }
	);

	for my $app ( 0..$#$all_applicants ) {
	
		if ( $all_applicants->[ $app ]->{ SchengenAppDataID } != 0 ) {
			
			my $sch_app = $self->query( 'selallkeys', __LINE__, "
				SELECT * FROM AutoSchengenAppData WHERE ID = ?", $tables_id->{ AutoSchengenAppData }
			)->[0];
			
			delete $sch_app->{ ID };
		
			$result->{ "schdata_$app" } = $sch_app;
		}
	
		delete $all_applicants->[ $app ]->{ $_ } 
			for ( 'ID', 'AppID', 'Finished', 'InsurerID', 'DListID', 'PolicyID', 'SchengenAppDataID', 
				'AppDateBM', 'TimeslotBMID' );
	
		$result->{ "appdata_$app" } = $all_applicants->[ $app ];
	}
	
	return $result;
}

sub set_values_from_api
# //////////////////////////////////////////////////
{
	my $self = shift;

	my $vars = $self->{ 'VCS::Vars' };

	my $json = $vars->getparam( 'data' );
		
	my $data = decode_json( $json );
	
	my $app_id = $self->insert_hash_table( 'AutoAppointments', $data->{ appointments } );

	$self->query( 'query', __LINE__, "
		UPDATE AutoToken SET AutoAppID = ? WHERE Token = ?", {}, $app_id, $self->{ token }
	);

	my $app_max = 0;
	
	for ( keys %$data ) {
		
		/^appdata_(\d+)$/;
		$app_max = $1 if $app_max < $1;
	}
		
	for ( 0..$app_max ) {	
		
		my $sch_id = $self->insert_hash_table( 'AutoSchengenAppData', $data->{ "schdata_$_" } );
		
		$data->{ "appdata_$_" }->{ AppID } = $app_id;
		$data->{ "appdata_$_" }->{ SchengenAppDataID } = $sch_id;
		
		my $appdata_id = $self->insert_hash_table( 'AutoAppData', $data->{ "appdata_$_" } );
	}
	
	$vars->get_system->redirect( 
		$vars->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr } . '?t=' . $self->{ token }
	);
}

sub get_api_head
# //////////////////////////////////////////////////
{
	my ( $self, $error_number ) = @_;
	
	my $error_text = [
		'',
		'ошибка токена',
		'ошибка API-запроса',
	];
	
	return { 
		'token' => $self->{ token },
		'error' => {
			'error' => $error_number,
			'error_text' => $self->lang( $error_text->[ $error_number ] ),
		}
	};
}

1;
