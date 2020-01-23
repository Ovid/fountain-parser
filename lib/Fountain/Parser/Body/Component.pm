package Fountain::Parser::Body::Component;

use Fountain::Util::String qw(
  trimsplit
  num_lines
);
use String::Util 'trim';
use Moo;
use Types::Standard qw(
  Str
  InstanceOf
);
use Scalar::Util 'blessed';
use Fountain::Boilerplate;
use namespace::autoclean;

sub create ( $class, %args ) {
    my @sections = qw(
      fade_in
      cut
      header
      dialogue
      action
    );
    foreach my $section (@sections) {
        if ( my $instance = $class->matches( $section, %args ) ) {
            return $instance;
        }
    }
    return Fountain::Parser::Body::Component::Default->new(%args);
}

sub matches ( $class, $section, %args ) {
    my $method = "_parse_$section";
    return $class->$method(%args);
}

package Fountain::Parser::Body::Component::Base {
    use Moo;
    with 'Fountain::Role::Commmon';
    use open ':std', ':encoding(UTF-8)';
    use String::Util 'trim';
    use Sub::Install;
    use Fountain::Boilerplate;

    has 'previous' => ( is => 'ro', weak_ref => 1 );

    around BUILDARGS => sub ( $orig, $class, %args ) {
        foreach my $arg ( keys %args ) {
            next if 'text' eq $arg;    # must always be pristine
            $args{$arg} = trim( $args{$arg} );
        }
        $class->$orig(%args);
    };

    INIT {

        # let's just pretend this never happened
        # Essentally, we read every Fountain::Parser::Body::Component::*
        # package name and create an is_$name method for it, but converting
        # from CamelCase to camel_case. This type of symbol table hacking is
        # generally not recommended, but here it allows us to define a new
        # parser without hardcoding the preciate methods.
        no strict;
        my $base = "Fountain::Parser::Body::Component::";
        *stash = *$base;
        while ( my ( $key, $value ) = each %stash ) {
            next unless $key =~ /(\w+)::$/;
            my $last_package_fragment = $1;
            my $package = join '::' => $base, $last_package_fragment;
            my $name    = $last_package_fragment;

            # underscore and lower-case any letter that is capitalized and
            # preceded by a letter
            $name =~ s/(?<=[[:alpha:]])([[:upper:]])/_\l$1/;
            my $predicate = "is_\L$name";
            Sub::Install::install_sub(
                {
                    code => sub ($self) {
                        $DB::single = 1;
                        return ( ref $self ) eq
                          "${base}$last_package_fragment";
                    },
                    into => __PACKAGE__,
                    as   => $predicate,
                }
            );
        }
    }

    sub BUILD ( $self, @args ) {
        if ( $self->debug ) {
            my $class = ref $self;
            my $text  = $self->text;
            say STDERR '/======================================\\';
            say STDERR "<$class>: $text";
            say STDERR '----------------------------------------';
            say STDERR np $self;
            say STDERR '----------------------------------------';
            say STDERR $self->to_string;
            say STDERR "\\======================================/\n";
        }
    }
    sub to_string($self) { die trim( '****** ' . $self->text . ' ******' ) }
}

package Fountain::Parser::Body::Component::Default {
    use Moo;
    extends 'Fountain::Parser::Body::Component::Base';
}

package Fountain::Parser::Body::Component::FadeIn {
    use Moose;
    extends 'Fountain::Parser::Body::Component::Base';
    sub to_string {'FADE IN:'}
}

sub _parse_fade_in ( $self, %args ) {
    if ( $args{text} =~ /^[[:punct:]]*FADE IN[[:punct:]]/ ) {
        return Fountain::Parser::Body::Component::FadeIn->new(%args);
    }
    return;
}

package Fountain::Parser::Body::Component::Header {
    use Moo;
    extends 'Fountain::Parser::Body::Component::Base';
    use String::Util 'trim';
    use Fountain::Boilerplate;
    has [qw/int_ext location/]   => ( is => 'ro', required => 1 );
    has [qw/time time_extended/] => ( is => 'ro', default  => '' );

    sub to_string( $self) {
        my $loc = trim( join ' ' => map { $self->$_ } qw/int_ext location/ );
        if ( $self->time || $self->time_extended ) {
            $loc .= ' - '
              . trim( join ' ' => map { $self->$_ } qw/time time_extended/ );
        }
        return $loc;
    }
    sub is_interior($self) { return 'INT' eq $self->int_ext }
    sub is_exterior($self) { return 'EXT' eq $self->int_ext }
}

sub _parse_header ( $class, %args ) {
    return unless 1 == num_lines( $args{text} );
    state $is_header = qr{
        ^
        (?<int_ext>INT\.|EXT\.|INT\./EXT\.)
        \s+
        (?<location>[^-(\\n]+)
        (?:
            \s*
            -?
            \s*
            (?<time>\(?[^)]+\)?)
            (?:
                \s*
                (?<time_extended>\([^\)]+\))
                \s*
            )?
        )?
    $}x;
    if ( $args{text} =~ $is_header ) {
        return Fountain::Parser::Body::Component::Header->new(
            %args,
            map { $_ => trim( $+{$_} ) // '' }
              qw/int_ext location time time_extended/
        );
    }
    return;
}

package Fountain::Parser::Body::Component::Dialogue {
    use Moo;
    extends 'Fountain::Parser::Body::Component::Base';
    use String::Util 'trim';
    use Text::Wrap;
    use Fountain::Boilerplate;
    has [qw/character dialogue/]     => ( is => 'ro', required => 1 );
    has [qw/extended parenthetical/] => ( is => 'ro', default  => '' );

    sub to_string( $self) {
        my $text = ' ' x 20;
        $text .= $self->character;
        if ( $self->extended ) {
            $text .= ' ' . $self->extended;
        }
        $text .= "\n";
        if ( my $parenthetical = $self->parenthetical ) {
            $text .= ( ' ' x 15 ) . $parenthetical;
            $text .= "\n";
        }
        local $Text::Wrap::columns = 50;
        my $spaces = ' ' x 10;
        $text .= wrap( $spaces, $spaces, $self->dialogue );
        return $text;
    }
}

sub _parse_dialogue ( $class, %args ) {

    # character cues are not allowed to follow headers
    my $previous = $args{previous} or return;
    if ( $previous->is_header ) {
        return;
    }

    my ( $head, $tail ) = trimsplit( "\n", $args{text}, 2 );

    if ( $head =~ /[[:lower:]]/ ) {

        # any lower case characters in the first part means it's not a dialog
        return;
    }

    state $is_dialogue = qr{^
        (?<character>[[:upper:]][[:upper:] ]+)
        (?:
            (?<extended>[^\n]+)
        )?
        (?<parenthetical>
            \n
            \s*\([^)]+\)\s*
        )?
    }x;

    if ( $args{text} =~ $is_dialogue ) {
        my $character     = $+{character};
        my $extended      = $+{extended};
        my $parenthetical = $+{parenthetical};

        # no character may have two dialogs in a row
        if ( $previous->is_dialogue && $previous->character eq $character ) {
            return;
        }

        my $dialogue;
        if ($parenthetical) {
            ( undef, undef, $dialogue ) = trimsplit( "\n", $args{text}, 3 );
        }
        else {
            ( undef, $dialogue ) = trimsplit( "\n", $args{text}, 2 );
        }
        return Fountain::Parser::Body::Component::Dialogue->new(
            %args,
            character     => $character,
            extended      => $extended,
            parenthetical => $parenthetical,
            dialogue      => $dialogue,
        );
    }
    return;
}

package Fountain::Parser::Body::Component::Action {
    use Moo;
    extends 'Fountain::Parser::Body::Component::Base';
    use Text::Wrap;
    use Fountain::Boilerplate;

    sub to_string($self) {
        local $Text::Wrap::columns = 59;
        return wrap( '', '', $self->text );
    }
}

sub _parse_action ( $class, %args ) {
    my $previous = $args{previous} or return;
    if (   $previous->is_dialogue
        || $previous->is_header
        || $previous->is_action
        || $previous->is_cut )
    {

        # We don't have any other matches, so it's safe to assume this is an
        # action section. Action must not follow fade in (must be a scene
        # header)
        return Fountain::Parser::Body::Component::Action->new(%args);
    }
    return;
}

package Fountain::Parser::Body::Component::Cut {
    use Moo;
    extends 'Fountain::Parser::Body::Component::Base';
    use Fountain::Boilerplate;

    sub to_string($self) {
        my $padding = ' ' x ( 59 - length( $self->text ) );
        return $padding . $self->text;
    }
}

sub _parse_cut ( $class, %args ) {
    return unless 1 == num_lines( $args{text} );
    my $previous = $args{previous} or return;
    return if $previous->is_cut;
    if ( $args{text} =~ / TO:$/ ) {
        return Fountain::Parser::Body::Component::Cut->new(%args);
    }
    return;
}

1;
