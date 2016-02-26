#!/usr/bin/env perl

use utf8;

use Modern::Perl;
use Test::More;
use FindBin qw( $Bin );
use lib "$Bin/../lib";
use App::test;

plan tests => 9;

is( App::test::check_email( 'test@example.com' ), 1, "email is ok" );
is( App::test::check_email( 'test@example.co.uk' ), 1, "email is ok" );
is( App::test::check_email( 'test.test@example.co.uk' ), 1, "email is ok" );
is( App::test::check_email( 'testexample.com' ), 0, "RFC822 check" );
is( App::test::check_email( 'иван@иванов.рф' ), 0, "UTF8 check" );
is( App::test::check_email( 'test @example.com' ), 0, "Spaces check" );
is( App::test::check_email( 'example@localhost' ), 0, "FQDN check" );
is( App::test::check_email( 'ivan@xn--c1ad6a.xn--p1ai' ), 1, "IDN check" );
is( App::test::check_email( 'ivan@[127.0.0.1]' ), 0, "IP check" );
