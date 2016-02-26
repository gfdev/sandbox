package RegRuTest;

use Moose;
use namespace::autoclean;
use Catalyst::Runtime 5.80;
use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Unicode::Encoding
/;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name                                        => 'RegRuTest',
    disable_component_resolution_regex_fallback => 1,
    'View::TT'                                  => {
        INCLUDE_PATH => [
            __PACKAGE__->path_to( 'root' ),
        ],
    },
);

__PACKAGE__->setup();

1;
