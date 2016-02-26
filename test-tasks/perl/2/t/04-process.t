#!/usr/bin/env perl

use utf8;

use Modern::Perl;
use Test::More;
use IPC::Cmd qw( run );

plan tests => 5;

subtest "check counters" => sub {
    open my $fh, ">", "temp.txt" or BAIL_OUT "Can't open temp.txt: $!";
    
    (my $emails = <<'LST') =~ s/^\s+|\s+$//gim;
        test0@example.com
        test1@example.com
        test2@example.com
        test0@test.com
        test1@test.com
        test@bar.com
LST
    print $fh $emails;
    
    close $fh;
    
    my ($s, $out, $error) = command( "perl test.pl temp.txt" );
    
    unlink "temp.txt";

    is( $s, 1, "success" );
    like( $out, qr/example.com\s+3\ntest.com\s+2\nbar.com\s+1\nINVALID\s+0/, "output" );
    is( $error, "", "error" );
};

subtest "check utf8" => sub {
    open my $fh, ">:encoding(UTF-8)", "temp.txt" or BAIL_OUT "Can't open temp.txt: $!";
    
    (my $emails = <<'LST') =~ s/^\s+|\s+$//gim;
        test@example.com
        иван@иванов.рф
LST
    print $fh $emails;
    
    close $fh;
    
    my ($s, $out, $error) = command( "perl test.pl temp.txt" );
    
    unlink "temp.txt";

    is( $s, 1, "success" );
    like( $out, qr/example.com\s+1\nINVALID\s+1/, "output" );
    is( $error, "", "error" );
};

subtest "check spaces" => sub {
    open my $fh, ">", "temp.txt" or BAIL_OUT "Can't open temp.txt: $!";
    
    (my $emails = <<'LST') =~ s/^\s+|\s+$//gim;
        test@example.com
        test @example.com
        t est@example.com
LST
    print $fh $emails;
    
    close $fh;
    
    my ($s, $out, $error) = command( "perl test.pl temp.txt" );
    
    unlink "temp.txt";

    is( $s, 1, "success" );
    like( $out, qr/example.com\s+1\nINVALID\s+2/, "output" );
    is( $error, "", "error" );
};

subtest "check invalid" => sub {
    open my $fh, ">:encoding(UTF-8)", "temp.txt" or BAIL_OUT "Can't open temp.txt: $!";
    
    (my $emails = <<'LST') =~ s/^\s+|\s+$//gim;
        test@example.com
        test @example.com
        иван@иванов.рф
        example@localhost
        ivan@[127.0.0.1]
LST
    print $fh $emails;
    
    close $fh;
    
    my ($s, $out, $error) = command( "perl test.pl temp.txt" );
    
    unlink "temp.txt";

    is( $s, 1, "success" );
    like( $out, qr/example.com\s+1\nINVALID\s+4/, "output" );
    is( $error, "", "error" );
};

subtest "check IDN" => sub {
    open my $fh, ">:encoding(UTF-8)", "temp.txt" or BAIL_OUT "Can't open temp.txt: $!";
    
    (my $emails = <<'LST') =~ s/^\s+|\s+$//gim;
        test@example.com
        ivan@xn--c1ad6a.xn--p1ai
LST
    print $fh $emails;
    
    close $fh;
    
    my ($s, $out, $error) = command( "perl test.pl temp.txt" );
    
    unlink "temp.txt";

    is( $s, 1, "success" );
    like( $out, qr/example.com\s+1\nxn--c1ad6a.xn--p1ai\s+1\nINVALID\s+0/, "output" );
    is( $error, "", "error" );
};

sub command {
    my ($cmd) = @_;
    
    my ($s, $out, $error) = ( run( command => $cmd, verbose => 0 ) )[0, 3, 4];
    
    return ( $s, join( "", @$out ), join( "", @$error ) );
}
