package VCS::Site::autoagency;
use strict;

use VCS::Vars;
use Data::Dumper;


sub new
# //////////////////////////////////////////////////
{
	my ( $class, $pclass, $vars ) = @_;
	my $self = bless {}, $pclass;
	$self->{ 'VCS::Vars' } = $vars;
	return $self;
}

sub agency
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $login_error = undef;
	my $title = 'Вход в личный кабинет';
	my $appointments = [];
	my $auto_appointments = [];

	my ( $login, $company, $type ) = $self->get_agency_session();
		
	if ( $type eq 'workflow' ) {
		$title = '';
		( $appointments, $auto_appointments ) = $self->get_agency_main( $company );
	}
	
	( $title, undef, $login_error ) = $self->{ af }->get_page_error( 4 ) if $type eq 'login_pass_error';
	
	$vars->get_system->pheader( $vars );
	
	my $tvars = {
		'langreq' => sub { return $vars->getLangSesVar(@_) },
		'title' => $title,
		'addr' => $vars->getform('fullhost') . $self->{ autoform }->{ paths }->{ agency },
		'appointments' => $appointments,
		'auto_appointments' => $auto_appointments,
		'login' => $login,
		'login_error' => $login_error,
	};
	$template->process( 'autoform_agency.tt2', $tvars );
}

sub get_agency_session
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $vars = $self->{ 'VCS::Vars' };

	my ( $login, $company, $session ) = $self->get_session_from_memcached( $self->get_session_from_cookies() );

	if ( $login ) {

		$self->update_in_memcached( $login, $company, $session );
		
		return ( $login, $company, 'workflow' );
	}

	if ( $vars->getparam( 'login' ) ) {
	
		( $login, $company ) = $self->check_login_from_param();
		
		if ( $login ) {

			$session = $self->session_generation( $login );
		
			$self->update_in_cookies( $self->update_in_memcached( $login, $company, $session ) );
			
			return;
		}
		else {
			return ( undef, undef, 'login_pass_error' );
		}
	}
	return ( undef, undef, 'login_form' );
}

sub get_session_from_cookies
# //////////////////////////////////////////////////
{
	my @cookies = split /;/, $ENV{ HTTP_COOKIE };
	
	my $session_data = {};
	
	for my $pair ( @cookies ) {
	
		my ( $name, $value ) = split /=/, $pair;
		$name =~ s/^\s+|\s+$//g;
		$value =~ s/^'|'$//g;
		
		$session_data->{ $name } = $value if $name =~ /agency_session|agency_login/;
	}
	
	return ( $session_data->{ agency_session }, $session_data->{ agency_login } );
}

sub get_session_from_memcached
# //////////////////////////////////////////////////
{
	my ( $self, $session_id, $login ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };
	
	my $company = $vars->get_memd->get( "autoagency|$login|$session_id" );

	return undef unless $company;
	
	return ( $login, $company, $session_id );
}

sub update_in_memcached
{
	my ( $self, $login, $company, $session_id ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };
	
	$vars->get_memd->set( "autoagency|$login|$session_id", "$company", 
		$self->{ autoform }->{ memcached }->{ session_duration } );

	return ( $session_id, $login );
}

sub update_in_cookies
{
	my ( $self, $session_id, $login ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };

	print "HTTP/1.0 302 Moved Temporarily\n";
	print "Location: ".$vars->getform('fullhost') . $self->{ autoform }->{ paths }->{ agency }."\n";
	print "Content-Type: text/html; charset=utf-8\n";
	print "Set-Cookie: agency_session='".$session_id."'\n";
	print "Set-Cookie: agency_login='".$login."'\n";
	print "\n";
	return;
}

sub session_generation()
# //////////////////////////////////////////////////
{
	my ( $self, $login ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };

	my $session_existing = 1;
	my $session = 's';
	
	do {
		my @alph = split //, '0123456789abcdefghigklmnopqrstuvwxyz';
		
		for ( 1..18 ) {
			$session .= @alph[ int( rand( 35 ) ) ];
		}
		$session_existing = $vars->get_memd->get( "autoagency|$login|$session" );
			
	} while ( $session_existing );
	
	return $session;
}

sub check_login_from_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $vars =$self->{ af }->{ 'VCS::Vars' };

	my $login_param = $vars->getparam( 'login' ) || '';
	my $pass = $vars->getparam( 'pass' ) || '';
	
	$login_param =~ s/[^A-Z0-9\_\.]//gi;

	my ( $login, $company ) = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT Login, Companies.ID FROM Users JOIN Companies ON Users.CompanyID = Companies.ID
		WHERE Login = ? AND Pass = PASSWORD(?)", $login_param, $pass
	);
	
	return ( $login, $company );
}

sub get_agency_main
# //////////////////////////////////////////////////
{
	my ( $self, $company ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };
	
	my $appointments = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT ID, AppNum, Status FROM Appointments WHERE CompanyID = ? LIMIT 10", $company
	);
	
	my $auto_appointments = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT RDate, Token FROM AutoToken JOIN AutoAppointments ON AutoToken.AutoAppID = AutoAppointments.ID 
		WHERE CompanyID = ? AND Finished = 0 LIMIT 10", $company
	);
	
	return ( $appointments, $auto_appointments );
}

1;
