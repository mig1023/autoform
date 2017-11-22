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
	
	my $result = get_api_head( $self, 0 );
	
	if ( $self->{ token } =~ /^\d\d$/ ) {
	
		$result = get_api_head( $self, 1 );
	}
	elsif ( $vars->getparam( 'mobile_api' ) eq 'get_appdata' ) {
		
		$result = get_values_for_api( $self, $result );
	}
	elsif ( $vars->getparam( 'mobile_api' ) eq 'set_appdata' ) {
	
		$result = set_values_from_api( $self );
	}
	elsif ( $vars->getparam( 'mobile_api' ) eq 'get_centers' ) {
		
		$result = get_api_centers( $self );
	}
	elsif ( $vars->getparam( 'mobile_api' ) ne 'get_token' ) {
		
		$result = get_api_head( $self, 2 );
	}
	
	return $result;
}

sub get_values_for_api
# //////////////////////////////////////////////////
{
	my ( $self, $result ) = @_;
	
	my $delete_fields = VCS::Site::autodata::get_mobile_api_fields( 'to_delete' );
	
	my $tables_id = $self->get_current_table_id();
	
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
	
	$vars->get_system->redirect( 
		$vars->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr } . 
		'?t=' . $self->{ token } . '&mobile_app=on'
	);
}

sub get_api_centers
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $result = {};
	
	my $all_centers = $self->query( 'selallkeys', __LINE__, "
		SELECT BName, BAddr as Address, Phone, Email, SubmissionTime, CollectionTime
		FROM Branches
		WHERE isDeleted = 0 AND Display = 1"
	);
	
	for ( @$all_centers ) {
	
		$result->{ $_->{ BName } } = $_;
		
		delete $result->{ $_->{ BName } }->{ BName };
	}
	
	return $result;
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
