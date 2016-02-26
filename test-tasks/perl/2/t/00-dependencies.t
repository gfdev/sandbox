#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

plan tests => 3;

BEGIN {
    use_ok( 'Modern::Perl' );
    use_ok( 'Email::Valid' );
    use_ok( 'IPC::Cmd' );
}
