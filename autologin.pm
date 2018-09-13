package VCS::Site::autologin;
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

sub login
# //////////////////////////////////////////////////
{
	my ( $self, $task, $id, $template ) = @_;
	
	my $vars = $self->{ 'VCS::Vars' };
	my $login_error = undef;
	my $title = 'Вход в личный кабинет';
	my $appointments = [];
	my $auto_appointments = [];

	my ( $login, $login_id, $type ) = $self->get_login_session();
	
	my $stage = 'login';

	if ( lc( $vars->getparam( 'action' ) ) eq "new_app" ) {
	
		my $token = $self->{ af }->save_new_token_in_db( $self->{ af }->token_generation(), $login_id );
		
		$self->{ af }->create_clear_form( $token );
		
		return $vars->get_system->redirect( 
			$vars->getform('fullhost') . $self->{ autoform }->{ paths }->{ addr } . 
			'?t=' . $token
		);
	}
	
	if ( lc( $vars->getparam( 'action' ) ) eq "new_reg" ) {
	
		$stage = $self->reg_login( $vars );
	}
	
	( $appointments, $auto_appointments, $title ) = $self->get_login_main( $login_id ) if $type eq 'workflow';

	$login_error = 1 if $type eq 'login_pass_error';
	
	$vars->get_system->pheader( $vars );
	
	my $progress = $self->{ af }->get_progressbar( ( $login ? 2 : 1 ), $self->{ af }->get_progressbar_hash_opt() );

	my $tvars = {
		'langreq' => sub { return $vars->getLangSesVar(@_) },
		'title' => $title,
		'addr' => $vars->getform('fullhost') . $self->{ autoform }->{ paths }->{ login },
		'appointments' => $appointments,
		'appointments_length' => scalar @$appointments,
		'auto_appointments' => $auto_appointments,
		'login' => $login || $vars->getparam( 'loginField'),
		'login_found' => ( $type ne 'login_pass_error' ? 1 : 0 ),
		'login_done' => ( $type eq 'workflow' ? 1 : 0 ),
		'login_error' => $login_error,
		'stage' => $stage,
		'progress' => $progress,
	};

	$template->process( 'autoform_login.tt2', $tvars );
}

sub get_login_session
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $vars = $self->{ 'VCS::Vars' };

	my ( $login, $login_id, $session ) = $self->get_session_from_memcached( $self->get_session_from_cookies() );
	
	my $login_status = 'login_form';

	if ( $login ) {

		$self->update_in_memcached( $login, $login_id, $session );
		
		return ( $login, $login_id, 'workflow' );
	}

	if ( $vars->getparam( 'login' ) ) {
	
		( $login, $login_id ) = $self->check_pass_from_param();
		
		if ( $login ) {

			$session = $self->session_generation( $login );
		
			$self->update_in_cookies( $self->update_in_memcached( $login, $login_id, $session ) );
			
			return;
		}
		else {
			$login_status = 'login_pass_error';
		}
	}
	
	if ( $vars->getparam( 'loginField' ) ) {
	
		$login = $self->check_login_from_param();
		
		if ( $login ) {
		
			$login_status = 'login_form';
		}
		else {
			$login_status = 'login_pass_error';
		}
	}
	
	return ( undef, undef, $login_status );
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
		
		$session_data->{ $name } = $value if $name =~ /auto_session|auto_login/;
	}
	
	return ( $session_data->{ auto_session }, $session_data->{ auto_login } );
}

sub get_session_from_memcached
# //////////////////////////////////////////////////
{
	my ( $self, $session_id, $login ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };
	
	my $login_id = $vars->get_memd->get( "autologin|$login|$session_id" );

	return undef unless $login_id;
	
	return ( $login, $login_id, $session_id );
}

sub update_in_memcached
# //////////////////////////////////////////////////
{
	my ( $self, $login, $login_id, $session_id ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };
	
	$vars->get_memd->set( "autologin|$login|$session_id", "$login_id", 
		$self->{ autoform }->{ memcached }->{ session_duration } );

	return ( $session_id, $login );
}

sub update_in_cookies
# //////////////////////////////////////////////////
{
	my ( $self, $session_id, $login ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };

	print "HTTP/1.0 302 Moved Temporarily\n";
	print "Location: ".$vars->getform('fullhost') . $self->{ autoform }->{ paths }->{ login }."\n";
	print "Content-Type: text/html; charset=utf-8\n";
	print "Set-Cookie: auto_session='".$session_id."'\n";
	print "Set-Cookie: auto_login='".$login."'\n";
	print "\n";
	return;
}

sub session_generation
# //////////////////////////////////////////////////
{
	my ( $self, $login ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };

	my $session_existing = 1;
	my $session = 's';
	
	do {
		$session = 's' . $self->key_generation(18);
		$session_existing = $vars->get_memd->get( "autologin|$login|$session" );
			
	} while ( $session_existing );
	
	return $session;
}

sub key_generation
# //////////////////////////////////////////////////
{
	my ( $self, $len ) = @_;
	
	my @alph = split //, '0123456789abcdefghigklmnopqrstuvwxyz';
		
	my $key = '';	
		
	for ( 1..$len ) {
		$key .= @alph[ int( rand( 35 ) ) ];
	}
	
	return $key;
}

sub reg_login
# //////////////////////////////////////////////////
{
	my ( $self, $vars ) = @_;
	
	my $login_param = $vars->getparam( 'login' ) || '';
	
	my $pass_param = $vars->getparam( 'pass_reg1' ) || '';
	
	my $activation = $self->key_generation( 10 );
	
	$self->{ af}->query( 'query', __LINE__, "
		INSERT INTO AutoLogin (Login, Pass, Activation, RegDate) VALUES (?, PASSWORD(?), ?, now())", {}, 
		$login_param, $pass_param, $activation
	);

	return 'reg_done';
}

sub check_login_from_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $vars =$self->{ af }->{ 'VCS::Vars' };

	my $login_param = $vars->getparam( 'loginField' ) || '';
	
	$login_param =~ s/[^A-Z0-9\_\.]//gi;

	my ( $login, $login_id ) = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT Login, ID FROM AutoLogin WHERE Login = ?",
		$login_param
	);

	return ( $login, $login_id );
}

sub check_pass_from_param
# //////////////////////////////////////////////////
{
	my $self = shift;
	
	my $vars =$self->{ af }->{ 'VCS::Vars' };

	my $login_param = $vars->getparam( 'login' ) || '';
	my $pass = $vars->getparam( 'pass' ) || '';
	
	$login_param =~ s/[^A-Z0-9\_\.]//gi;

	my ( $login, $login_id ) = $self->{ af }->query( 'sel1', __LINE__, "
		SELECT Login, ID FROM AutoLogin WHERE Login = ? AND Pass = PASSWORD(?)",
		$login_param, $pass
	);

	return ( $login, $login_id );
}

sub get_login_main
# //////////////////////////////////////////////////
{
	my ( $self, $login_id ) = @_;
	
	my $vars = $self->{ af }->{ 'VCS::Vars' };
	
	my $appointments = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT Appointments.ID, AppNum, Appointments.Status
		FROM Appointments
		JOIN AutoToken ON Appointments.ID = AutoToken.CreatedApp
		WHERE AutoToken.Login = ? 
		ORDER BY ID DESC LIMIT 10", $login_id
	);
	
	for ( @$appointments ) {
		
		$_->{ AppNum } = $self->{ 'VCS::Vars' }->get_system->appnum_to_str( $_->{ AppNum } );
	}
	
	my $auto_appointments = $self->{ af }->query( 'selallkeys', __LINE__, "
		SELECT StartDate, Token FROM AutoToken WHERE Login = ? AND Finished = 0 
		ORDER BY ID DESC  LIMIT 10", $login_id
	);
	
	my $months = [ '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря' ];
	
	$_->{ StartDate } =~ s/(\d{4})\-(\d{2})\-(\d{2})/$3 $months->[$2] $1/ for @$auto_appointments;
	
	return ( $appointments, $auto_appointments, undef );
}

1;
