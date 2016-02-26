package App::test;

use Modern::Perl;
use Email::Valid;

sub process_emails {
    my ($emails) = @_;
    
    my $invalid = 0;
    my %results;
    
    foreach my $email ( @$emails ) {
        chomp $email;
        
        if ( check_email( $email ) ) {
            (my $domain = $email) =~ s/^[^@]+@//is;
            
            $results{$domain}++;
        }
        else {
            $invalid++;
        }
    }
    
    my $result;
    
    foreach my $key ( sort { $results{$b} <=> $results{$a} or $a cmp $b } keys %results ) {
        $result .= sprintf "%-40s\t%s\n", $key, $results{$key};
    }
    
    $result .= sprintf "%-40s\t%s\n", 'INVALID', $invalid;
}

sub check_email {
    my ($email) = @_;
    
    return $email !~ /\s/si && Email::Valid->address( -address => $_[0], -allow_ip => 0 ) ? 1 : 0;
}

1;
