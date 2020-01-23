package Fountain::Role::Commmon;
# ABSTRACT: Common methods needed in Fountain parsing.

use Moose::Role;
use Types::Standard qw(
  Bool
  Str
);
use Scalar::Util 'blessed';
use Fountain::Boilerplate;

has text => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has 'debug' => (
    is      => 'ro',
    isa     => Bool,
    default => sub {0},
);

1;

__END__

=head1 SYNOPSIS

    package FOu
