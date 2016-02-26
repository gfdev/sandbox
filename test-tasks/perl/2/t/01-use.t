#!/usr/bin/env perl

use Modern::Perl;
use Test::More;
use FindBin qw( $Bin );
use lib "$Bin/../lib";

plan tests => 1;

use_ok( 'App::test' );
