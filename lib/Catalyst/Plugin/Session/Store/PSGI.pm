package Catalyst::Plugin::Session::Store::PSGI;
use strict;
use warnings;

use Catalyst::Plugin::Session::PSGI;

=head1 EXPERIMENTAL

This distribution should be considered B<experimental>. Although functional, it
may break in currently undiscovered use cases.

=cut

use base qw/Catalyst::Plugin::Session::Store/;

=head1 SYNOPSIS

    use Catalyst qw/
        Session
        Session::State::PSGI
        Session::Store::PSGI
    /;

=cut

=head1 DESCRIPTION

An alternative session storage plugin that allows sharing of the PSGI/Plack session information.

=cut

=head1 METHODS

The plugin provides the following methods:

=cut

=head2 get_session_data

=cut
sub get_session_data {
    my ($c, $id) = @_;

    # grab the PSGI environment
    my $psgi_env = Catalyst::Plugin::Session::PSGI::_psgi_env($c);
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

=head2 store_session_data

=cut
sub store_session_data {
    my ($c, $id, $data) = @_;

    # grab the PSGI environment
    my $psgi_env = Catalyst::Plugin::Session::PSGI::_psgi_env($c);
    return
        unless defined $psgi_env;

    # grab the relevant data from the PSGI environment
    $psgi_env->{_psgi_section($id)} = $data;
}

=head2 delete_session_data

This method is NOOP - session data should be deleted by L<Plack::Middleware::Session>

=cut
sub delete_session_data     { } # unsupported

=head2 delete_expired_sessions

This method is NOOP - sessions should be expired by L<Plack::Middleware::Session>

=cut
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
