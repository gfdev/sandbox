use strict;
use warnings;
use 5.010;

use IO::Handle;
use Data::Dumper;
use Storable;
use Digest::MD5 qw(md5_hex);

use Mojo::URL;
use Mojo::Util qw(html_unescape);
use Mojo::UserAgent;
use Mojo::IOLoop::Delay;

my $login       = $ARGV[0];
my $password    = $ARGV[1];
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

my (@links, %seen);

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
        #say shift->to_string, "\n\n";
        
        store $ua->cookie_jar, $cookie_file;
    });
});

my $content = _get_content();
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
    
    my $tx = $ua->start($ua->build_tx(POST => $action => form => $params));
    
    $content = $tx->res->body;
}

my ($path) = $content =~ m{<a[^>]+href="([^"]+)">Profile</a>}si;

open my $fh_data, '>', 'data.txt' or die "Cannot open file for writing: $!";
open my $fh_users, '>', 'users.txt' or die "Cannot open file for writing: $!";
open my $fh_links, '>', 'links.txt' or die "Cannot open file for writing: $!";

$_-> autoflush(1) for $fh_data, $fh_users, $fh_links;

_add_link($path) if $path;

while (my $url = shift @links) {
    my $link = $url->{url};
    my $type = _get_page_type($link);
    my $path;
    
    $content = _get_content($link);
    
    for ($type) {
        /profile/ && do {
            ($path) = $content =~ m{<a[^>]+href="([^"]+)">Friends</a>}s;
            
            my ($user_id)   = $content =~ m{<a[^>]+href="[^"]+owner_id=(\d+)[^"]+">More</a>}si;
            $user_id      ||= 0;
            my ($name)      = $content =~ m{<div[^>]+><span><strong[^>]+>([^<]+)</strong>}si;
            my ($user_name) = $link    =~ m{/([^/]+)\?}si;
            $user_name      = $user_name eq 'profile.php' ? '' : $user_name;
            my ($feed)      = $content =~ m{(<div[^>]+id="recent">.*?>Report</a></div></div></div></div></div></div>)}si;
            
            open my $fh_feed, '>', $user_id . '_feed.txt' or die "Cannot open file for writing: $!";
                print $fh_feed $feed;
            close $fh_feed;
            
            print $fh_users join(',', $user_id || '0', $user_name, $name) . "\n";
            
            _add_link($path, $link, { user_id => $user_id, user_name => $user_name })
                if $path;
        };
        /friends/ && do {
            ($path) = $content =~ m{<a[^>]+href="([^"]+)"><span>See More Friends</span>}s;
            
            _add_link($path, $link, { user_id => $url->{user_id}, user_name => $url->{user_name} })
                if $path;
            
            while ($content =~ m{<table[^>]*?>.*?<img[^>]+src="([^"]+)"[^>]*?>.*?<a[^>]+href="(/([^\?]+)\?[^"]+)"[^>]*?>([^<]+)</a>}sig) {
                next if $3 eq 'home.php';
                next if $3 eq 'help/';
                
                my $id = $3 eq 'profile.php' ? (split('&', substr($2, index($2, '?id=') + 4)))[0] : $3;
                
                print $fh_data join("\n",
                    "URL: $link",
                    'Avatar: ' . ($1 || ''),
                    'ProfileURL: ' . ($2 || ''),
                    'ID: ' . ($id || ''),
                    'Name: ' . ($4 || ''),
                    'FriendName: ' . ($url->{user_name} || ''),
                    "FriendID: @{[ $url->{user_id} || '' ]}\n\n"
                );
                
                _add_link($2, $link) if $2 && not $url->{user_id};
            }
        };
    }
}

close $fh_data;
close $fh_links;
close $fh_users;

sub _get_page_type {
    my ($url) = @_;
    
    for ($url) {
        m{[=/]friends[&?]}s && return 'friends';
        return 'profile';
    }
}

sub _add_link {
    my ($path, $ref, $params) = @_;
    my $url    = _get_link($path);
    my $hash   = md5_hex $url;
    
    if (not exists $seen{$hash}) {
        push @links, { url => $url, ref => $ref, ($params ? (params => $params) : ()) };
        
        $seen{$hash}++;
    
        print $fh_links "$url (@{[ $ref || '' ]})\n";
    }
}

sub _get_content {
    my ($link) = @_;
    my $delay  = [2, 15];
    
    Mojo::IOLoop->delay(sub {
        Mojo::IOLoop->timer($delay->[0] + int(rand($delay->[1] - $delay->[0])) => shift->begin);
    })->wait;
    
    return $ua->start($ua->build_tx(GET => $link || _get_link()))->res->body;
}

sub _get_link {
    my ($path) = @_;
    
    return $url->clone->to_string if not $path;
    
    my ($endpoint, $query) = split(/\?/, $path);
    
    $query = html_unescape $query || '';
    
    return $url->clone->path($endpoint)->query($query)->to_string;
}
