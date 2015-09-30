use Mojolicious::Lite;
use Data::Dumper;

any '/' => sub {
    my ($c) = @_;

    my $h = $c->req->headers;

    my $headers = {
        'Access-Control-Allow-Origin' => $h->header('origin') ? $h->header('origin') : '*',
        'Access-Control-Max-Age' => '0',
        'Cache-Control' => 'no-cache',
        'Pragma' => 'no-cache',
        'Set-Cookie' => 'cookie=cookie'
    };

    $c->res->headers->header($_ => $headers->{$_}) for keys %$headers;

    warn Dumper $c->req;
    warn Dumper $c->res;

    $c->render(json => {
        request => {
            method => $c->req->method,
        },
        response => {},
    });
};

app->start;
