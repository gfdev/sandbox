use strict;
use warnings;
use Test::More;


use Catalyst::Test 'RegRuTest';
use RegRuTest::Controller::Phones;

ok( request('/phones')->is_success, 'Request should succeed' );
done_testing();
