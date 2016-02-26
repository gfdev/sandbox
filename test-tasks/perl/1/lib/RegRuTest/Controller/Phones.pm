package RegRuTest::Controller::Phones;

use utf8;

use Readonly;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

Readonly::Hash my %errors => (
    NO_PHONE        => 'Необходимо ввести номер телефона!',
    NO_NAME         => 'Необходимо ввести имя абонента!',
    NO_ADDR         => 'Необходимо ввести адрес абонента!',
    SHORT_PHONE     => 'Минимальная длинна номера телефона 3 символа!',
    LONG_PHONE      => 'Максимальная длинна номера телефона 18 символов!',
    SHORT_NAME      => 'Минимальная длинна имени абонента 3 символа!',
    LONG_NAME       => 'Максимальная длинна имени абонента 40 символов!',
    SHORT_ADDR      => 'Минимальная длинна адреса абонента 3 символа!',
    LONG_ADDR       => 'Максимальная длинна адреса абонента 40 символов!',
    LONG_NOTE       => 'Максимальная длинна примечания 40 символов!',
    INCORRECT_PHONE => 'Номер телефона некорректный!',
    INCORRECT_NAME  => 'Имя абонента некорректно!',
    NO_RECORD       => 'Нет записи в базе данных!',
);

sub read :Private {
    my ($self, $c) = @_;
    
    $c->stash->{phones} = [
        $c->model( 'DB::Phone' )->search(
            {},
            {
                join     => 'persons',
                prefetch => 'persons',
                order_by => {
                    -desc => 'ctime',
                },
            }
        )
    ];
}

sub create :Path('/create') :Args(0) POST {
    my ($self, $c) = @_;
    
    my %param = map { $_ => $c->req->params->{$_} } qw(phone name addr note);
    
    if ( my $error_id = _check_params( \%param ) ) {
        $c->stash->{error} = $errors{$error_id};
        $c->go( 'read' );
    }
    
    my $phone = $c->model( 'DB::Phone' )->find_or_create( { phone => $param{phone} } );
    
    $phone->create_related( 'persons',
        {
            name    => $param{name},
            address => $param{addr},
            note    => $param{note},
        }
    );
    
    $c->res->redirect( $c->uri_for( '/' ) );
    $c->detach();
}

sub update :Path('/update') :Args(1) {
    my ($self, $c, $person_id) = @_;
    
    if ( my $person = $c->model( 'DB::Person' )->find( $person_id ) ) {
        my $phone = $c->model( 'DB::Phone' )->find( $person->phone_id );
        
        if ( $c->req->method eq 'POST' ) {
            my %param = map { $_ => $c->req->params->{$_} } qw(name addr note);
            
            if ( my $error_id = _check_params( \%param ) ) {
                $c->stash->{error} = $errors{$error_id};
                $c->req->method( 'GET' );
                $c->go( 'update' );
            }
            
            $person->update(
                {
                    name    => $param{name},
                    address => $param{addr},
                    note    => $param{note},
                }
            );
            
            $c->res->redirect( $c->uri_for( '/' ) );
            $c->detach();
        }
        else {
            $c->stash->{person} = $person;
            $c->stash->{phone}  = $phone;
        }
    }
    else {
        $c->stash->{error} = $errors{NO_RECORD};
        $c->go( 'read' );
    }
}

sub delete :Path('/delete') :Args(1) {
    my ($self, $c, $person_id) = @_;
    
    if ( my $person = $c->model( 'DB::Person' )->find( $person_id ) ) {
        # Удалить запить телефона, если в таблице persons на него ссылается только одна запись
        $c->model( 'DB::Phone' )->find( $person->phone_id )->delete
            if $c->model( 'DB::Person' )->search( { phone_id => $person->phone_id } )->count == 1;
        $person->delete;
        
        $c->res->redirect( $c->uri_for( '/' ) );
        $c->detach();
    }
    else {
        $c->stash->{error} = $errors{NO_RECORD};
        $c->go( 'read' );
    }
}

# Проверить входные данные на валидность и сделать некоторые корректировки
# %param: phone, name, addr, note
sub _check_params {
    my $param = $_[0];
    
    if (exists $param->{phone}) {
        return 'NO_PHONE'    if ! $param->{phone};
        return 'SHORT_PHONE' if length $param->{phone} < 3;
        return 'LONG_PHONE'  if length $param->{phone} > 18;
        
        # Удалить из номера телефона все не цифры
        $param->{phone} =~ s/[^0-9]//sig;
    }
    
    return 'NO_NAME'         if ! $param->{name};
    return 'NO_ADDR'         if ! $param->{addr};
    return 'SHORT_NAME'      if length $param->{name} < 3;
    return 'LONG_NAME'       if length $param->{name} > 40;
    return 'SHORT_ADDR'      if length $param->{addr} < 3;
    return 'LONG_ADDR'       if length $param->{addr} > 40;
    return 'LONG_NOTE'       if length $param->{note} > 40;
    return 'INCORRECT_PHONE' if $param->{phone} =~ /[^0-9\(\)\-\+\s]/sig;
    return 'INCORRECT_NAME'  if $param->{name} =~ /[^a-zа-я\s\.]/sig;
    
    # Удалить пробелы в начеле и конце строки и заменить группы пробелов одним
    for ( $param->{name}, $param->{addr}, $param->{note} ) {
        s/^\s+|\s+$//sig;
        s/\s{2,}/ /sig;
    }
    
    return;
}

__PACKAGE__->meta->make_immutable;

1;
