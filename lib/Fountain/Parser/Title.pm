package Fountain::Parser::Title;

use Fountain::Util::String qw(
  trimsplit
);
use Moo;
use Types::Standard qw(
  Str
);
use Fountain::Boilerplate;
use namespace::autoclean;

has 'text' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has 'title' => (
    is       => 'rwp',
    isa      => Str,
    required => 1,
);

has [qw/credit author source copyright notes/] => (
    is  => 'rwp',
    isa => Str,
);

sub _allowed_section($class) {
    return qw/title credit author source copyright notes/;
}

around 'BUILDARGS' => sub ( $orig, $class, %args ) {
    my %allowed = map { $_ => 1 } $class->_allowed_section;

  # the forward lookahead won't split if the subsequent line is indented. This
  # allows for multi-line sections, such as the "Notes" section
  #
  # Notes:
  # 	FINAL PRODUCTION DRAFT
  # 	includes post-production dialogue
  # 	and omitted scenes
    my @title = split /\n(?=\w)/ => $args{text} // '';

    LINE: foreach my $line (@title) {
        my ( $section, $description ) = trimsplit( ':', $line, 2 );
        $section = lc $section;

        # disard anything we don't recognize
        next LINE unless $allowed{$section};
        $args{$section} = $description;
    }

    $class->$orig(%args);
};

# FIXME: nothing is centered properly
sub to_string ($self) {
    my $text = '';
    SECTION: foreach my $section ( $self->_allowed_section ) {
        my $this_text = $self->$section or next SECTION;
        $text .= "$this_text\n";
    }
    return $text;
}

1;
