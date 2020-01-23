package TestsFor::Fountain::Parser;

use Test::Class::Moose;
use Fountain::Parser;
use Fountain::Boilerplate;
use namespace::autoclean;

sub test_full_example ( $test, $ ) {
    my $parser = Fountain::Parser->new( text => $test->_get_screenplay );
    ok $parser, 'We should be able to create a screenplay parser object';

    explain $parser->report;
    explain $parser->to_string;
}

sub _get_screenplay ($test) {
    return <<'END_SCREENPLAY';
Title: Some Title

====

[[
    This note will not be here,

    Because the preprocessor strips it.
]]

**FADE IN:**

EXT. SOME PLACE

Our HERO walks in.
He is not amused.

HERO
What have we here? A stupid dialogue for a test?

SMASH CUT TO:

INT. ANOTHER PLACE

Hero is regarding the VILLAIN.

VILLAIN
What amateur uses a smash cut in a spec script? It's embarassing.

HERO
Tell me about it. I just want this over.

VILLAIN
(under his breath)
And now they're forcing me to mumble.

Hero regards Villian curiously.

HERO
What did you say?

Villain mumbles something.

HERO (CONT'D)
What did you say? And if you mumble, the damned writer needs to be more explicit about what you said!

/*
    Yeah, this sucks, but it's a test.
*/

EXT. SOME PLACE (LATER)

An EXTRA walks in.

He is confused.

EXTRA
What am I doing here?
END_SCREENPLAY
}

__PACKAGE__->meta->make_immutable;

1;
