use strict;
use warnings;
use 5.010;

use Data::Dumper; 
use Mojo::UserAgent;
use Mojo::IOLoop::Delay;

my $ua = Mojo::UserAgent->new(max_redirects => 5);

$ua->proxy->detect;

#$bot->ua_name('Mozilla/5.0 (X11; Linux x86_64; rv:29.0) Gecko/20100101 Firefox/29.0');
#$req->headers->accept('text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
#$req->headers->accept_language('en-US,en;q=0.5');
#$req->headers->accept_encoding('gzip, deflate');
#$req->headers->dnt('1');
#$req->headers->connection('keep-alive');
#$req->headers->cache_control('no-cache');
#$bot->enqueue('https://m.facebook.com');

Mojo::IOLoop->recurring(1 => sub {
    say 'Main loop: ', time;
    
    Mojo::IOLoop->timer(1 => sub {
        say 'Sub loop: ', time;
    });
});

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

#my $ticker = Mojo::IOLoop->recurring(0.5 => sub { warn "tick\n" });
#
#my $value;
#my $delay = Mojo::IOLoop->delay(
#    sub {
#        Mojo::IOLoop->timer(2 => shift->begin);
#    },
#    sub {
#        warn "timer fired\n";
#        $value = 'foobar';
#    }
#);
#warn "value not set yet (value = '$value')\n";
#$delay->wait;
#warn "value set now (value = '$value')\n";
