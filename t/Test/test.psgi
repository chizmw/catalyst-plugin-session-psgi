#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use FindBin;
use lib "$FindBin::Bin/lib";

# TODO: Winxle::Plack::Builder
use Plack::Builder;
use Class::Load qw();
use Plack::Middleware::Session;
use Plack::Session::Store::File;


my $app_name = 'Test';
Class::Load::load_class($app_name);
my $app = $app_name->apply_default_middlewares($app_name->psgi_app(@_));

builder {
    enable 'Session';
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
                [ "Hello, PLACK $plack_requests, of all $all_requests via
                    session ".' <a href="/cat/">see catalyst</a>' ],
            ];
        };
    };
    mount '/cat' => builder {
        $app;
    };
};

