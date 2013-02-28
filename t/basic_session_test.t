use 5.010;
use strict;
use warnings;
use lib 't';
use lib 't/Test/lib';
use utf8;

use Test::Most;
use Plack::Test;
use Test::WWW::Mechanize::PSGI;



use Plack::Builder;
use Class::Load qw();
use Plack::Middleware::Session;
use Plack::Session::Store::File;


my $app_name = 'Test';
Class::Load::load_class($app_name);
my $app = $app_name->apply_default_middlewares($app_name->psgi_app(@_));

my $mech = Test::WWW::Mechanize::PSGI->new(
    app => builder {
        enable 'Session',
            store => Plack::Session::Store::File->new( dir => '/tmp/');

        mount '/plack' => builder {
            my $app = sub {
                my $env = shift;
                my $session = $env->{'psgix.session'};
                my $all_requests   = $session->{count}++;
                my $plack_requests = $session->{count_plack}++;
                return [
                    200,
                    [ 'Content-Type' => 'text/html' ],
                    [ "Hello, PLACK $plack_requests of your $all_requests via
                        session ".' <a href="/cat/">see catalyst</a>' ],
                ];
            };
        };
        mount '/cat' => builder {
            $app;
        };
    }
);


$mech->get_ok('/cat/');
$mech->get_ok('/plack/');
$mech->get_ok('/cat/');
$mech->content_contains('1 of your 2') or diag($mech->content);
$mech->get_ok('/plack/');
$mech->get_ok('/plack/');
$mech->get_ok('/plack/');
$mech->content_contains('3 of your 5') or diag($mech->content);


done_testing();



