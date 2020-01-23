package Fountain::Parser;
# ABSTRACT: A parser for Fountain screenplay markup

use Fountain::Util::String qw(
  trimsplit
);
use Moo;
use Types::Standard qw(
  Bool
  Int
  Str
  InstanceOf
);
use Scalar::Util 'blessed';
use Fountain::Parser::Title;
use Fountain::Parser::Body;
use Fountain::Boilerplate;
use namespace::autoclean;

our $VERSION = .01;

with 'Fountain::Role::Commmon';

has title => (
    is  => 'rwp',
    isa => InstanceOf ['Fountain::Parser::Title'],
);

has body => (
    is  => 'rwp',
    isa => InstanceOf ['Fountain::Parser::Body'],
);

has '_number_of_lines' => (
    is  => 'rw',
    isa => Int,
);

sub BUILD ( $self, @args ) {
    my $raw_text = $self->text;
    my ( $title, $screenplay ) = trimsplit( qr/===*/, $raw_text, 2 );
    $self->_set_title( Fountain::Parser::Title->new( text => $title ) );
    $self->_set_body(
        Fountain::Parser::Body->new(
            text  => $screenplay,
            debug => $self->debug
        )
    );
    $self->_number_of_lines( $raw_text =~ tr/\n// );
}

sub to_string($self) {
    return join "\n" => $self->title->to_string, $self->body->to_string;
}

sub report ($self) {
    return $self->body->report;
}

1;

__END__

=encoding utf8

=head1 SYNOPSIS

    use Fountain::Parser;
    my $parser = Fountain::Parser->new(
        text => $fountain_text,
    );
    say $parser->to_string;    # screenplay in text format
    say $parser->report;       # screenplay statistics

=head1 DESCRIPTION

Fountain is a Markdown inspired syntax for writing screenplays.  This module
provides parsing capabilities for the Fountain screenplay format.  It also
provides a text output for a quick scan, and statistics.

It should be assumed that there are no user-serviceable parts inside and the
C<Fountain::Parser> module is the I<only> public interface.

=head1 METHODS

=head2 C<new>

    my $parser = Fountain::Parser->new( text => $fountain_text );

Returns a C<Fountain::Parser> instance.

=head2 C<to_string>

    say $parser->to_string;

Prints out the document in a text format that is visually similar to what the professional screenplay would look like. For example, this:

	**FADE IN:**

	EXT. ORCHARD - DAY (1882)

	MARY HUGHES, age 8, sits on the legs of her father, WILLIAM HUGHES.

	WILLIAM
	(reading)
	Backwards up the mossy glen
	Turn’d and troop’d the goblin men,
	With their shrill repeated cry,
	"Come buy, come buy."

	MARY
	Do you think goblins ever existed, father?

	WILLIAM
	(laughing)
	Why, Mary Hughes! What does the church have to say about goblins and other fantastical beasts?

Becomes this:

    FADE IN:

    EXT. ORCHARD - DAY (1882)
    MARY HUGHES, age 8, sits on the legs of her father, WILLIAM HUGHES.

                        WILLIAM
                   (reading)
               Backwards up the mossy glen
               Turn’d and troop’d the goblin men,
               With their shrill repeated cry,
               "Come buy, come buy."

                        MARY
              Do you think goblins ever existed,
              father?

                        WILLIAM
                   (laughing)
              Why, Mary Hughes! What does the
              church have to say about goblins and
              other fantastical beasts?

=head2 C<report>

	say $parser->report;

As of version .01, this prints:

=over 4

=item * The names of the characters and number of dialogues

=item * A list of all places and the number of times they appear

=item * A B<rough> estimate of the final page count

=back

=head1 SEE ALSO

=over 4

=item * See L<the Fountain website|https://fountain.io/> for syntax details.

=item * The L<afterwriting|https://afterwriting.com/> web site can convert your Fountain to a PDF.

=item * L<Afterwriting|https://github.com/ifrost/afterwriting-labs/blob/master/docs/clients.md> can also be installed locally.

=item * L<Vim syntax for Fountain|https://github.com/vim-scripts/fountain.vim>.

=back

=head1 TODO

=head2 Formatters

Currently we only have a simple text output. Later, we'll want custom formatters
to allow us output the format as MS Word or PDFs.
