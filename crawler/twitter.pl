use strict;
use warnings;
use 5.010;
 
use Net::Twitter;
use Config::Tiny;
use Data::Dumper 'Dumper';
use File::HomeDir;
 
my $config_file = ".twitter";
die "$config_file not found!\n" if not -e $config_file;
my $config = Config::Tiny->read($config_file, 'utf8');
 
my $nt = Net::Twitter->new(
    ssl      => 1,
    traits   => [qw/API::RESTv1_1 OAuth/],
    map { $_ => $config->{test}{$_} } qw(
        consumer_key
        consumer_secret
        access_token
        access_token_secret
    )
);    

my $tweets = $nt->search('perlmaven');

foreach my $e (@{$tweets->{statuses}}) {
    say "$e->{user}{screen_name}:  $e->{text}";
}