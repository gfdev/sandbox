#!/usr/bin/env perl

use Mojolicious::Lite;
use Digest::MD5 qw(md5_hex);
use DBI;

my $dbh = DBI->connect("dbi:Pg:dbname=w_m_test", '', '', {
  AutoCommit     => 1,
  RaiseError     => 1,
});

get '/' => sub {
  my $self = shift;
  
  if ($self->session->{id}) {
    return $self->redirect_to('/logged');
  }
} => 'index';

get '/login' => sub {
  my $self = shift;
  
  if ($self->session->{id}) {
    return $self->redirect_to('/logged');
  }
} => 'login';

post '/login' => sub {
  my $self = shift;
  
  if ($self->session->{id}) {
    return $self->redirect_to('/logged');
  }
  
  my $user = $self->param('user') || return $self->render(json => { error => "User can't be empty!" });
  my $pass = $self->param('pass') || return $self->render(json => { error => "Password can't be empty!" });
  
  if (my $id = $dbh->selectrow_array('SELECT id FROM users WHERE name = ? AND password = ?', undef, $user, md5_hex($pass))) {
    $dbh->do("UPDATE users SET login_time = NOW() WHERE id = ?", undef, $id);
    $dbh->do("DELETE FROM users WHERE NOW()::date - login_time::date > 90");
    
    $self->session->{id} = $id;
    
    $self->render(json => { id => $id });
  } else {
    $self->render(json => { error => "Can't login!" });
  }
};

get '/register' => sub {
  my $self = shift;
  
  if ($self->session->{id}) {
    return $self->redirect_to('/logged');
  }
} => 'register';

post '/register' => sub {
  my $self = shift;
  
  if ($self->session->{id}) {
    return $self->redirect_to('/logged');
  }
  
  my $user = $self->param('user') || return $self->render(json => { error => "User can't be empty!" });
  my $pass = $self->param('pass') || return $self->render(json => { error => "Password can't be empty!" });
  
  if ($dbh->selectrow_array('SELECT id FROM users WHERE name = ?', undef, $user)) {
    $self->render(json => { error => "User exists!" });
  }
  
  $dbh->do("INSERT INTO users (name, password, login_time) VALUES(?, ?, NOW())", undef, $user, md5_hex($pass));
  
  my $id = $dbh->last_insert_id(undef,undef,"users",undef);;
  
  $self->session->{id} = $id;
  
  $self->render(json => { id => $id });
};

get '/logged' => sub {
  my $self = shift;
  
  my $user = $dbh->selectrow_hashref('SELECT * FROM users WHERE id = ?', { Slice => {} }, $self->session->{id});
  
  $self->stash->{user} = $user;
  
} => 'logged';

get '/logout' => sub {
  my $self = shift;
  
  $self->session(expires => 1);
};

app->start;

__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title>Access is Denied</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  </head>
  <body>
    <div style="text-align: center; font-size: 5em; color: red;">
      Access is Denied!
    </div>
    <div style="text-align: center; margin-top: 20px;">
      <input type="button" value="Login" onclick="window.location.href='/login'" />
      <input type="button" value="Register" onclick="window.location.href='/register'" />
    </div>
  </body>
</html>

@@ login.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title>User Login</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script>
      $(document).ready(function() {
        var $form = $("#form"),
          $submit = $("#submit"),
          $error = $("#error");
        
        $submit.click(function(e) { 
          e && e.preventDefault();
          
          $error.text("").closest("div").hide(0);
          $submit.attr("disabled", true);
          
          $.post($form.attr("action"), $form.serialize(), function() {}, "json").done(function(data) {
            if (data.id) {
              window.location.reload();
            } else if (data.error) {
              $error.text(data.error).closest("div").show(0);
            }
          }).fail(function(data) {
            $error.text("Something went wrong!").closest("div").show(0);
          }).always(function() {
            $submit.attr("disabled", false);
          });
        });
      });
    </script>
  </head>
  <body>
    <div style="text-align: center;">
      <form id="form" action="/login" method="POST">
        User: <input name="user" type="text" />
        Password: <input name="pass" type="text" />
        <input id="submit" type="submit" value="Login" />
        <input type="button" value="Home" onclick="window.location.href='/'" />
      </form>
      <div style="color: red; display: none;">Error: <span id="error"></span></div>
    </div>
  </body>
</html>

@@ register.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title>Registration</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script>
      $(document).ready(function() {
        var $form = $("#form"),
          $submit = $("#submit"),
          $error = $("#error");
        
        $submit.click(function(e) { 
          e && e.preventDefault();
          
          $error.text("").closest("div").hide(0);
          $submit.attr("disabled", true);
          
          $.post($form.attr("action"), $form.serialize(), function() {}, "json").done(function(data) {
            if (data.id) {
              window.location.reload();
            } else if (data.error) {
              $error.text(data.error).closest("div").show(0);
            }
          }).fail(function(data) {
            $error.text("Something went wrong!").closest("div").show(0);
          }).always(function() {
            $submit.attr("disabled", false);
          });
        });
      });
    </script>
  </head>
  <body>
    <div style="text-align: center;">
      <form id="form" action="/register" method="POST">
        <table width="100%" cellpadding="0" cellspacing="5">
          <tr>
            <td style="text-align: right; width: 50%;">User:</td>
            <td style="text-align: left;"><input name="user" type="text" /></td>
          </tr>
          <tr>
            <td style="text-align: right;">Password:</td>
            <td style="text-align: left;"><input name="pass" type="text" /></td>
          </tr>
          <tr >
            <td colspan="2" style="text-align: center; padding-top: 10px;">
            <input id="submit" type="submit" value="Register" />
            <input type="button" value="Home" onclick="window.location.href='/'" />
            </td>
          </tr>
        </table>
      </form>
      <div style="color: red; display: none;">Error: <span id="error"></span></div>
    </div>
  </body>
</html>

@@ logged.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title>Logged</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  </head>
  <body>
    <div style="text-align: center; font-size: 5em; color: green;">
      <%= $user->{name} %> logged!
    </div>
    <div style="text-align: center; margin-top: 20px; font-weight: bold;">
      Registration date: <%= $user->{auto_ctime} %><br />
      Last login date: <%= $user->{login_time} %>
    </div>
    <div style="text-align: center; margin-top: 20px;">
      <input type="button" value="Logout" onclick="window.location.href='/logout'" />
    </div>
  </body>
</html>

@@ logout.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title>Bye!</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  </head>
  <body>
    <div style="text-align: center; font-size: 5em; color: green;">
      Good luck!
    </div>
    <div style="text-align: center; margin-top: 20px;">
      <input type="button" value="Home" onclick="window.location.href='/'" />
    </div>
  </body>
</html>
