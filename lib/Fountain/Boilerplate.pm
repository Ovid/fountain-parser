package Fountain::Boilerplate;

use 5.26.0;
use strict;
use warnings;
use feature ();
use utf8::all;
use autodie ();
use Carp;
use Try::Tiny;

use Import::Into;

sub import {
    my ($class) = @_;

    my $caller = caller;

    warnings->import;
    warnings->unimport('experimental::signatures');
    strict->import;
    feature->import(qw/signatures :5.26/);
    utf8::all->import;
    Try::Tiny->import::into( $caller, qw(try catch finally) );
    autodie->import(':all');
    Carp->import::into( $caller, qw(carp croak) );
}

sub unimport {
    warnings->unimport;
    strict->unimport;
    feature->unimport;
    utf8::all->unimport;
    Try::Tiny->unimport;
    autodie->unimport;
    Carp->unimport;
}

1;

__END__

=head1 NAME

Fountain::Boilerplate - Use modern Perl features

=head1 SYNOPSIS

    use Fountain::Boilerplate;

=head1 DESCRIPTION

This module is a replacement for the following:

    use strict;
    use warnings;
    use v5.26;
    use feature "signatures';
    no warnings 'experimental::signatures';
    use utf8::all;
    use Carp qw(carp croak);
