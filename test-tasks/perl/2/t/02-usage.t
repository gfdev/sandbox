#!/usr/bin/env perl

use Modern::Perl;
use Test::More;
use IPC::Cmd qw( run );

plan tests => 6;

ok(-e "test.pl", "script exists");

subtest "error if no agruments" => sub {
    my ($s, $out, $error) = command( "perl test.pl" );

    is( $s, undef, "not success" );
    is( $out, "", "output" );
    like( $error, qr/Usage: test.pl file_with_emails/, "error" );
};

subtest "error if many agruments" => sub {
    my ($s, $out, $error) = command( "perl test.pl 1 2" );

    is( $s, undef, "not success" );
    is( $out, "", "output" );
    like( $error, qr/Usage: test.pl file_with_emails/, "error" );
};

subtest "error if no file" => sub {
    my ($s, $out, $error) = command( "perl test.pl no_file" );

    is ( $s, undef, "not success" );
    is( $out, "", "output" );
    like( $error, qr/Can't open no_file for reading: No such file or directory/, "error" );
};

subtest "error if file size is 0" => sub {
    open my $fh, ">", "temp.txt" or BAIL_OUT "Can't open temp.txt: $!";
    close $fh;
    
    my ($s, $out, $error) = command( "perl test.pl temp.txt" );
    
    unlink "temp.txt";

    is( $s, undef, "not success" );
    is( $out, "", "output" );
    like( $error, qr/File temp.txt is empty/, "error" );
};

subtest "all is ok" => sub {
    open my $fh, ">", "temp.txt" or BAIL_OUT "Can't open temp.txt: $!";
    print $fh "test\@example.com\n";
    close $fh;
    
    my ($s, $out, $error) = command( "perl test.pl temp.txt" );
    
    unlink "temp.txt";

    is( $s, 1, "success" );
    like( $out, qr/example.com\s+1\nINVALID\s+0/, "output" );
    is( $error, "", "error" );
};

sub command {
    my ($cmd) = @_;
    
    my ($s, $out, $error) = ( run( command => $cmd, verbose => 0 ) )[0, 3, 4];
    
    return ( $s, join( "", @$out ), join( "", @$error ) );
}
