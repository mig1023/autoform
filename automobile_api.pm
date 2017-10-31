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
	elsif ( $vars->getparam( 'mobile_api' ) ne 'get_token' ) {
		
		$result = get_api_head( $self, 2 );
	}
	
	return $result;
}

sub get_values_for_api
# //////////////////////////////////////////////////
{
	my ( $self, $result ) = @_;
	
	my $delete_fields = {
		'appointments' => [
			'ID', 'PersonalDataPermission', 'MobilPermission', 'PersonForAgreements', 'TimeslotID', 
			'AppDate', 'Status', 'Login', 'BankID', 'SessionID', 'CompanyID', 'Draft', 'Duration', 'Notes'
		],
		'appdata' => [
			'ID', 'AppID', 'Finished', 'InsurerID', 'DListID', 'PolicyID', 'SchengenAppDataID', 
			'AppDateBM', 'TimeslotBMID'
		],
	};
	
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
	
	my $enabled_fields_array = {
		'appointments' => [
			'SMS', 'CenterID', 'FName', 'Frontiera', 'Shipping', 'PolicyType', 'PrintSrv',
			'ShAddress', 'FDate', 'PassNum', 'Phone', 'PacketID', 'NCount', 'LName', 'Urgent',
			'OfficeToReceive', 'MName', 'ShIndex', 'Address', 'PassDate', 'PassWhom', 'EMail',
			'TFName', 'SDate', 'TBDate', 'Itinerario', 'dwhom', 'Mobile', 'TLName', 'Vettore',
			'RDate', 'Cost', 'VType', 
		],
		'appdata' => [
			'Citizenship', 'ACompanyName', 'AnkDate', 'FirstCity', 'DocType', 'Family', 'Fingers',
			'PolicyType', 'Countries', 'Mezzi4', 'MezziWhom', 'PassTill', 'RMName', 'RFName',
			'PassNum', 'Permesso', 'RPassNum', 'NullaCity', 'AppSDate', 'AnketaC', 'LName','PrevLNames',
			'Mezzi3', 'AnketaSrv', 'ProfActivity', 'FullAddress', 'AMobile', 'PassWhom', 'EuPassNum',
			'Gender', 'FingersDate', 'ACompanyFax', 'RLName', 'EuBDate', 'PolicyNum', 'Mezzi7',
			'ConcilFree', 'ACompanyPhone', 'AppEMail', 'ACopmanyPerson', 'MezziWhomOther', 'DocTypeOther',
			'VisaNum', 'MezziOtherSrc', 'AppFDate', 'Mezzi1', 'PolicyErr', 'BrhPlace', 'NoRMName',
			'FamilyOther', 'Short', 'Status', 'Hotels', 'Mezzi2', 'NRes', 'ASAddr', 'VisaOther', 'FName',
			'PermessoED', 'Mezzi6', 'IDNumber', 'RPWhen', 'EuCitizen', 'VidNo', 'isChild', 'PrevCitizenship',
			'CalcDuration', 'BrhCountry', 'RAddress', 'Nulla', 'Mezzi5', 'WorkOrg', 'HotelPhone', 'FamRel',
			'EuLName', 'CountryRes', 'PassDate', 'City', 'FirstCountry', 'PermessoFD', 'VidTill', 'RPWhere',
			'HotelAdresses', 'KinderData', 'BirthDate', 'PrevVisaFD', 'AppPhone', 'VisaPurpose', 'PrevVisa',
			'PrevVisaED', 'ACompanyAddress', 'EuFName', 'CountryLive', 'PhotoSrv',
		],
		'schengen' => [
			'HostDataAddress', 'HostDataDateOfBirth', 'HostDataName', 'VisaDataPurposeTravel',
			'HostDataType', 'HostDataPostalCode', 'HostDataEmail', 'VisaDataMainDestination',
			'VisaDataType', 'VisaDataBorderFirstEntry', 'VisaDataBorderEntryCity', 'VisaDataBeginningTravel',
			'HostDataPhoneNumber', 'VisaDataDuration', 'VisaDataNumberEntries', 'HostDataCity',
			'VisaDataEndTravel', 'HostDataProvince', 'HostDataFax', 'VisaDataIBorderEntry',
			'VisaDataCityDestination', 'HostDataDenomination',
		]
	};
	
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
