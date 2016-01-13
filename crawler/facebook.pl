use strict;
use warnings;
use 5.010;
use Data::Dumper;
 
use WWW::Crawler::Mojo;
use Mojo::UserAgent::CookieJar;

my $bot = WWW::Crawler::Mojo->new;

$bot->ua_name('Mozilla/5.0 (X11; Linux x86_64; rv:29.0) Gecko/20100101 Firefox/29.0');

$bot->on(start => sub {
    my ($self) = @_;
    
    $self->say_start;
});

$bot->on(req => sub {
    my ($bot, $job, $req, $tx) = @_;
    
    $req->headers->accept('text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
    $req->headers->accept_language('en-US,en;q=0.5');
    $req->headers->accept_encoding('gzip, deflate');
    $req->headers->dnt('1');
    $req->headers->connection('keep-alive');
    $req->headers->cache_control('no-cache');
    
    $bot->ua->cookie_jar->prepare($tx);
    
    say $req->to_string;
    #say Dumper($bot->ua->cookie_jar);
});
 
$bot->on(res => sub {
    my ($bot, $scrape, $job, $res) = @_;
    my $content = $res->to_string;
    
    
    
    say $res->to_string, "\n\n";
});
 
$bot->enqueue('https://m.facebook.com');
$bot->crawl;
