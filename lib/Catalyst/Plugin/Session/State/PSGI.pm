package Catalyst::Plugin::Session::State::PSGI;
use strict;
use warnings;

use base qw/Catalyst::Plugin::Session::State/;

sub prepare_action {
    my $c = shift;
    # we don't actually need to do anything here
    $c->maybe::next::method( @_ );
}

sub get_session_id {
    my $c = shift;
    my $psgi_env = $c->request->{_psgi_env};

    return
        unless defined $psgi_env;

    my $sid = $psgi_env->{'psgix.session.options'}{id};
    return $sid if $sid;

    $c->maybe::next::method( @_ );
}

sub get_session_expires {
    my $c = shift;
    my $expires = $c->_session_plugin_config->{expires} || 0;
    return time() + $expires;
}

sub set_session_id      { die 'spanish inquisition' } # unsupported
sub set_session_expires { } # unsupported
sub delete_session_id   { } # unsupported

1;
# ABSTRACT: Session plugin for access to PSGI/Plack session
__END__
# vim: ts=8 sts=4 et sw=4 sr sta
