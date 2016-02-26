#!/usr/bin/env perl

BEGIN {
  $ENV{MOJO_INACTIVITY_TIMEOUT} = 60 * 5; # Keep alive 5 minutes
}

use Mojolicious::Lite;
use Mojo::IOLoop;
use JSON::XS qw(encode_json);

my %CLIENTS = ();

get '/' => sub {
  shift->render_static('index.html');
};

websocket '/ws' => sub {
  my ($self) = @_;
  
  my $id = $self->tx->connection;
  
  $CLIENTS{$id}{tx} = $self->tx;
  
  $self->on(json => sub {
    my ($self, $hash) = @_;
    
    if ($hash->{cmd} eq 'reg') {
      _send($self, 'reg', { id => $id });
    } elsif ($hash->{cmd} eq 'list') {
      my $data;
      
      push @$data, { %{$CLIENTS{$_}{data}}, id => $_ }
        for grep $_ ne $id && ref $CLIENTS{$_}{data}, keys %CLIENTS;
      
      _send($self, 'list', ref $data eq 'ARRAY' ? $data : []);
    } elsif ($hash->{cmd} eq 'add') {
      $CLIENTS{$id}{data} = {
        x     => int $hash->{x},
        y     => int $hash->{y},
        color => $hash->{color},
      };
      
      _send_to_all($self, $id, 'add', { %{$CLIENTS{$id}{data}}, id => $id });
    } elsif ($hash->{cmd} eq 'del') {
      delete $CLIENTS{$id}{data};
      
      _send_to_all($self, $id, 'del', { id => $id });
    } elsif ($hash->{cmd} eq 'clr') {
      $CLIENTS{$id}{data}{color} = $hash->{color};
      
      _send_to_all($self, $id, 'clr', { color => $hash->{color}, id => $id });
    } elsif ($hash->{cmd} eq 'move') {
      $CLIENTS{$id}{data}{$_} = $hash->{$_} for qw(x y);
      
      _send_to_all($self, $id, 'move', { x => $hash->{x}, y => $hash->{y}, id => $id });
    }
  });
  
  $self->on(finish => sub {
    delete $CLIENTS{$id};
  });
};

sub _send {
  my ($self, $cmd, $data) = @_;
  
  $self->send(encode_json { data => $data, cmd => $cmd });
}

sub _send_to_all {
  my ($self, $id, $cmd, $data) = @_;
  
  _send($CLIENTS{$_}{tx}, $cmd, $data) for grep $_ ne $id, keys %CLIENTS;
}

app->start;
