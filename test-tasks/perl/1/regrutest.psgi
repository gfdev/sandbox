use strict;
use warnings;

use RegRuTest;

my $app = RegRuTest->apply_default_middlewares(RegRuTest->psgi_app);
$app;

