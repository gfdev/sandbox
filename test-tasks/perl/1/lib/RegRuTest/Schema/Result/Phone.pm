use utf8;
package RegRuTest::Schema::Result::Phone;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

RegRuTest::Schema::Result::Phone

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<phones>

=cut

__PACKAGE__->table("phones");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 phone

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "phone",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<phone_unique>

=over 4

=item * L</phone>

=back

=cut

__PACKAGE__->add_unique_constraint("phone_unique", ["phone"]);

=head1 RELATIONS

=head2 persons

Type: has_many

Related object: L<RegRuTest::Schema::Result::Person>

=cut

__PACKAGE__->has_many(
  "persons",
  "RegRuTest::Schema::Result::Person",
  { "foreign.phone_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-03-02 06:06:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DgVm2FnOB1NUp5DkXwj8rA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
