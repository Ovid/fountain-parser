package Fountain::Parser::Body;

use Fountain::Util::String qw(
  trimsplit
  num_lines
);
use Moo;
use Types::Standard qw(
  ArrayRef
  Int
  Num
  HashRef
  Str
);

use Fountain::Parser::Body::Component;
use Fountain::Boilerplate;
use namespace::autoclean;

with 'Fountain::Role::Commmon';

has '_sections' => (
    is  => 'rw',
    isa => ArrayRef,
);

has '_max_length' => (
    is      => 'rw',
    isa     => Num,
    default => sub {10}
);

has [ '_characters', '_locations' ] => (
    is      => 'ro',
    has     => HashRef,
    default => sub { {} },
);

has '_number_of_lines' => (
    is      => 'rw',
    isa     => Int,
    default => sub {0},
);

has 'estimated_page_count' => (
    is  => 'lazy',
    isa => Int,
);

sub _build_estimated_page_count($self) {

    # XXX This heuristic is very, very rough perhaps should be fixed. Some of
    # other numbers that we tweak should be taken into consideration.  Also,
    # we appear to have 57 lines per page, but this heuristic assumes a much
    # smaller number, so I've missed something. For smaller scripts, it can be
    # off by a page. For longer scripts, it can be off by 4 or 5 pages.
    return int( $self->_number_of_lines / 40 ) + 1;
}

sub BUILD ( $self, @ ) {
    my $in_note    = 0;
    my $in_comment = 0;

    # we actually strip comments and notes
    my ( $start_note, $start_comment ) = ( qr/^\[\[/,    qr/^\s*\/\*/ );
    my ( $end_note,   $end_comment )   = ( qr/\]\]\s*$/, qr/.*\*\/\s*$/ );

    my @raw_screenplay = trimsplit( qr/\n\n+/, $self->text // '' );
    my @screenplay;

    # strip all single and multi line comments and notes
    LINE: foreach (@raw_screenplay) {
        next LINE if /^\s+#/;    # strip all single-line comments

        # this are single token comments or notes
        if ( /$start_comment.*$end_comment/s || /$start_note.*$end_note/s ) {
            next LINE;
        }

        if (/$end_note/) {
            $in_note = 0;
            next LINE;
        }
        elsif (/$end_comment/) {
            $in_comment = 0;
            next LINE;
        }
        elsif (/$start_note/) {
            $in_note = 1;
            next LINE;
        }
        elsif (/$start_comment/) {
            $in_comment = 1;
            next LINE;
        }

        unless ( $in_note || $in_comment ) {
            my $component = Fountain::Parser::Body::Component->create(
                text     => $_,
                debug    => $self->debug,
                previous => $screenplay[-1],
            );
            $self->_record_statistics($component);
            push @screenplay => $component;
            my $text = $component->to_string;

            $self->_number_of_lines(
                $self->_number_of_lines + num_lines($text) );
        }
    }
    $self->_sections( \@screenplay );
}

sub _record_statistics ( $self, $component ) {
    if ( $component->is_dialogue ) {
        my $character = $component->character;
        $self->_update_max_length($character);
        $self->_characters->{$character}++;
    }

    if ( $component->is_header ) {
        my $location = $component->location;
        $self->_update_max_length($location);
        $self->_locations->{$location}++;
    }
}

sub _update_max_length ( $self, $string ) {
    my $length = length($string);
    if ( $length > $self->_max_length ) {
        $self->_max_length($length);
    }
}

sub to_string($self) {
    my $text = '';
    foreach my $component ( $self->_sections->@* ) {
        $text .= $component->to_string . "\n\n";
    }
    return $text;
}

sub report ($self) {

# TODO:
#    Track number of scenes per character
#        We can attempt to track character mentions in action sections to note
#        they're there, even if they have no dialogue.
#    Add INT/EXT count
    my $report = '';

    my $length = $self->_max_length;
    my $format = "%-${length}s   %s\n";

    my $separator = "\n" . ( '-' x ( $length + 12 ) ) . "\n\n";

    foreach my $section (
        [ 'Character', 'Dialogues', '_characters' ],
        [ 'Location',  'Scenes',    '_locations' ],
      )
    {
        $report .= $separator;
        my ( $description, $seen, $method ) = $section->@*;
        my $things = $self->$method;
        my @names  = sort { $things->{$b} <=> $things->{$a} || $a cmp $b }
          keys $things->%*;
        $report .= sprintf $format => $description, $seen;
        foreach my $name (@names) {
            $report .= sprintf $format => $name, $things->{$name};
        }
    }
    $report .= $separator;
    $report .= sprintf "Rough (!) page count estimate: %d\n" =>
      $self->estimated_page_count;

    return $report;
}

1;
