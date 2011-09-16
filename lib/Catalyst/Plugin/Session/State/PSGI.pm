package Catalyst::Plugin::Session::State::PSGI;
use strict;
use warnings;

=head1 EXPERIMENTAL

This distribution should be considered B<experimental>. Although functional, it
may break in currently undiscovered use cases.

=cut

use base qw/Catalyst::Plugin::Session::State/;

=head1 SYNOPSIS

    use Catalyst qw/
        Session
        Session::State::PSGI
        Session::Store::PSGI
    /;

=cut

=head1 DESCRIPTION

An alternative session state plugin that allows session-id retrieval from the
PSGI/Plack session information.

=cut

=head1 METHODS

The plugin provides the following methods:

=cut


=head2 prepare_action

This method may not be required. It's almost a NOOP and may be removed in a
future release.

=cut
sub prepare_action {
    my $c = shift;
    # we don't actually need to do anything here
    $c->maybe::next::method( @_ );
}

=head2 get_session_id

This method retrieves the session-id from the PSGI/Plack environment information.

=cut
sub get_session_id {
    my $c = shift;
    my $psgi_env = $c->request->{_psgi_env};

    return
        unless defined $psgi_env;

    my $sid = $psgi_env->{'psgix.session.options'}{id};
    return $sid if $sid;

    $c->maybe::next::method( @_ );
}

=head2

This methis returns the time, in epoch seconds, when the session expires.

B<NOTE>: This is a small hack that just returns a time far enough into the
future for the session not to expire every time you attempt to access it.
Actual expiry should be handled by L<Plack::Middleware::Session>.

=cut
sub get_session_expires {
    my $c = shift;
    my $expires = $c->_session_plugin_config->{expires} || 0;
    return time() + $expires;
}

=head2 set_session_id

NOOP - unsupported

=cut
sub set_session_id      { } # unsupported

=head2 set_session_expires

NOOP - unsupported

=cut
sub set_session_expires { } # unsupported

=head2 delete_session_id

NOOP - unsupported

=cut
sub delete_session_id   { } # unsupported

=head1 SEE ALSO

L<Catalyst::Plugin::Session::PSGI>,

1;
# ABSTRACT: Session plugin for access to PSGI/Plack session
__END__
# vim: ts=8 sts=4 et sw=4 sr sta
