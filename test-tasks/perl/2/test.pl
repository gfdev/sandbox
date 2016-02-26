#!/usr/bin/env perl

use Modern::Perl;
use FindBin qw( $Bin );
use lib "$Bin/lib";
use App::test;

main();
exit;

sub main {
    die "Usage: $0 file_with_emails\n" if @ARGV != 1;
    
    my $file = $ARGV[0];
    
    die "Can't open $file for reading: $!" unless -e $file;
    die "File $file is empty" unless -s $file;
    
    my @emails;
    
    open my $fh, "<:encoding(UTF-8)", $file or die "Can't open $file for reading: $!";
    @emails = <$fh>;
    close $fh;
    
    print App::test::process_emails( \@emails );
}
