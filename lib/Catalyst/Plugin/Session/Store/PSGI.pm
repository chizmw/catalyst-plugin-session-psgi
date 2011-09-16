package Catalyst::Plugin::Session::Store::PSGI;
use strict;
use warnings;

use base qw/Catalyst::Plugin::Session::Store/;

sub get_session_data {
    my ($c, $id) = @_;

    # grab the PSGI environment
    my $psgi_env = $c->request->{_psgi_env};
    return
        unless defined $psgi_env;

    # TODO: work out correct place to initialise this
    $psgi_env->{'psgix.session.expires'}
        ||= $c->get_session_expires;

    # grab the relevant data from the PSGI environment
    my $data = $psgi_env->{_psgi_section($id)};
    return $data if $data;

    # no session retrieved - hope this isn't too painful
    return;
}

sub store_session_data {
    my ($c, $id, $data) = @_;

    # grab the PSGI environment
    my $psgi_env = $c->request->{_psgi_env};
    return
        unless defined $psgi_env;

    # grab the relevant data from the PSGI environment
    $psgi_env->{_psgi_section($id)} = $data;
}

sub delete_session_data     { } # unsupported
sub delete_expired_sessions { } # unsupported

sub _psgi_section {
    my $id = shift;

    # default to using 'psgi.session'
    my $psgi_section = 'psgix.session';
    # add supposert for things like expire: and flash:
    if (my ($section, $sid) = ($id =~ m{\A(\w+):(\w+)\z})) {
        if ('session' ne $section) {
            $psgi_section .= ".${section}";
        }
    }

    return $psgi_section;
}

1;
# ABSTRACT: Session plugin for access to PSGI/Plack session
__END__
# vim: ts=8 sts=4 et sw=4 sr sta
