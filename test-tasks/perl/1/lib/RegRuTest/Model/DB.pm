package RegRuTest::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'RegRuTest::Schema',
    connect_info => [
        'dbi:SQLite:data/test.db', '', '',
        {
            AutoCommit     => 1,
            RaiseError     => 1,
            sqlite_unicode => 1,
        },
    ]
);

1;
