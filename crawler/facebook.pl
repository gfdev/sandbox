use strict;
use warnings;
use 5.010;

use IO::Handle;

use Data::Dumper;
use Storable;
use Mojo::URL;
use Mojo::Util qw(html_unescape);
use Mojo::UserAgent;
use Mojo::IOLoop::Delay;

my $login       = '';
my $password    = '';
my $ua_name     = 'Mozilla/5.0 (X11; Linux x86_64; rv:29.0) Gecko/20100101 Firefox/29.0';
my $cookie_file = '.cookie';
my $url         = Mojo::URL->new('https://m.facebook.com');
my $headers     = {
    'Accept'          => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language' => 'en-US,en;q=0.5',
    'Accept-Encoding' => 'gzip, deflate',
    'DNT'             => '1',
    'Connection'      => 'keep-alive',
    'Pragma'          => 'no-cache',
    'Cache_control'   => 'no-cache',
};

my $ua = Mojo::UserAgent->new(max_redirects => 5);
$ua->transactor->name($ua_name);
$ua->cookie_jar(retrieve $cookie_file)
    if -s $cookie_file;
$ua->on(start => sub {
    my ($ua, $tx) = @_;
    
    $tx->req->headers->remove('Accept-Encoding')->from_hash($headers)
        if not $tx->req->headers->accept_language;
    
    $tx->req->on(finish => sub {
        say shift->to_string;
    });
    $tx->res->on(finish => sub {
        say shift->to_string, "\n\n";
        
        store $ua->cookie_jar, $cookie_file;
    });
});

my $links;
my $tx      = $ua->start($ua->build_tx(GET => $url->to_string));
my $content = $tx->res->body;
my ($title) = $content =~ m{<title>([^<]+)</title>}si;

if ($title eq 'Welcome to Facebook') {
    my $form_start = index($content, '<form ');
    
    my $form = \substr($content, $form_start, index($content, '</form>') - $form_start);
    
    my ($action) = $$form =~ /<form[^>]+action="([^"]+)"[^>]*?>/si;
    my ($title)  = $$form =~ m{<title>([^<]+)</title>}si;
    my $params;
    
    while ($$form =~ m{<input[^>]+name="([^"]*?)"[^>]+/>}sig) {
        my $start = index($&, 'value="') + 7;
        
        $params->{$1} = $start != 6
            ? substr($&, $start, index($&, '"', $start) - $start)
            : '';
    }
    
    $params->{email} = $login;
    $params->{pass}  = $password;
    
    $tx = $ua->start($ua->build_tx(POST => $action => form => $params));
    
    $content = $tx->res->body;
}

my (@links, $link, $type);

($link) = $content =~ m{<a[^>]+href="([^"]+)">Profile</a>}si;

push @links, { link => $link, type => 'profile' };

open my $fh, '>', 'data.txt' or die "Cannot open file for writing: $!";

$fh->autoflush(1);

while (my $url = shift @links) {
    undef $link;
    
    $content = _get_content($url->{link});
    
    if ($url->{type} eq 'profile') {
        ($link) = $content =~ m{<a[^>]+href="([^"]+)">Friends</a>}si;
    } elsif ($url->{type} eq 'friends') {
        ($link) = $content =~ m{<a[^>]+href="([^"]+)"><span>See More Friends</span>}si;
        
        while ($content =~ m{<table[^>]*?>.*?<img[^>]+src="([^"]+)"[^>]*?>.*?<a[^>]+href="(/([^\?]+)\?[^"]+)"[^>]*?>([^<]+)</a>}sig) {
            next if $3 eq 'home.php';
            next if $3 eq 'help/';
            
            my $id = $3 eq 'profile.php' ? (split('&', substr($2, index($2, '?id=') + 4)))[0] : $3;
            my $sub_id = exists  $url->{id} ? $url->{id} : '';
            
            print $fh join("\n",
                ('Avatar: ' . ($1 || ''),
                 'URL: ' . ($2 || ''),
                 'ID: ' . ($id || ''),
                 'Name: ' . ($4 || ''),
                 "SubID: $sub_id\n\n"));
            
            push @links, { link => $2, type => 'friend', id => $id }
                if $2 && not exists $url->{id};
        }
    } elsif ($url->{type} eq 'friend') {
        ($link) = $content =~ m{<a[^>]+href="([^"]+)">Friends</a>}si;
        
        push @links, { link => $link, type => 'friends', id => $url->{id} }
            if $link;
    } else {
        last;
    }
    
    push @links, { link => $link, type => 'friends' }
        if $link && $url->{type} ne 'friend';
}

close $fh;

sub _get_content {
    my ($link) = @_;
    my $delay = [2, 25];
    
    Mojo::IOLoop->delay(sub { Mojo::IOLoop->timer($delay->[0] + int(rand($delay->[1] - $delay->[0])) => shift->begin) })->wait;
    
    return $ua->start($ua->build_tx(GET => html_unescape _get_link($link)))->res->body;
}

sub _get_link {
    my ($path) = @_;
    
    return $url->clone->path(split(/\?/, $path))->query((split(/\?/, $path))[1]);
}
