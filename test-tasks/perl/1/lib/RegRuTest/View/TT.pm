package RegRuTest::View::TT;

use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    CATALYST_VAR       => 'c',
    ENCODING           => 'utf-8',
    render_die         => 1,
);

1;
