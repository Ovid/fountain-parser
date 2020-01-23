package TestsFor::Fountain::Parser::Body::Component;

use Test::Class::Moose;
use Fountain::Parser::Body::Component;
use Fountain::Boilerplate;
use namespace::autoclean;

package Fake::Component {
    use Moo;

    has [qw/is_header is_dialogue is_action is_cut/] => (
        is      => 'rwp',
        default => sub {0},
    );
}

sub test_is_header ( $test, $ ) {
    subtest 'Basic header' => sub {
        my $snippet = <<'END';
EXT. SOME PLACE
END
        my $component = Fountain::Parser::Body::Component->create(
            text     => $snippet,
            previous => Fake::Component->new,
        );
        ok $component->is_header, 'Header components should be headers';
        is $component->location,  'SOME PLACE',
          'Our location should be correct';
        ok !$component->time, '... but we should not have a time component';
    };

    subtest 'Header with time' => sub {
        my $snippet = <<'END';
EXT. SOME PLACE (LATER)
END
        my $component = Fountain::Parser::Body::Component->create(
            text     => $snippet,
            previous => Fake::Component->new,
        );
        ok $component->is_header, 'Header components should be headers';
        is $component->location,  'SOME PLACE',
          'Our location should be correct';
        is $component->time, '(LATER)', '... as should the time';
    };
    subtest 'Header with time, no parentheses' => sub {
        my $snippet = <<'END';
EXT. SOME PLACE -LATER
END
        my $component = Fountain::Parser::Body::Component->create(
            text     => $snippet,
            previous => Fake::Component->new,
        );
        ok $component->is_header, 'Header components should be headers';
        is $component->location,  'SOME PLACE',
          'Our location should be correct';
        is $component->time, 'LATER', '... as should the time';
    };
}

sub test_dialogue ( $test, $ ) {
    subtest 'Basic character cue' => sub {
        my $cue = <<'END';
MARY
Had a little lamb
END
        my $component = Fountain::Parser::Body::Component->create(
            text     => $cue,
            previous => Fake::Component->new,
        );

        ok $component->is_dialogue, 'Dialogue elements should be dialogues';
        is $component->character,   'MARY',
          'And we should have the correct character name';
        ok !$component->parenthetical, '... and we have no parenthetical';
        ok !$component->extended, '... or extended attributes to the name';
        is $component->dialogue, 'Had a little lamb',
          '... and the dialogue should be correct';
    };

    subtest 'Character cue with () text after name' => sub {
        my $cue = <<'END';
MARY (O.S.)
Had a little lamb
END
        my $component = Fountain::Parser::Body::Component->create(
            text     => $cue,
            previous => Fake::Component->new,
        );

        ok $component->is_dialogue, 'Dialogue elements should be dialogues';
        is $component->character,   'MARY',
          'And we should have the correct character name';
        ok !$component->parenthetical, '... and we have no parenthetical';
        is $component->extended, '(O.S.)',
          '... or extended attributes to the name';
        is $component->dialogue, 'Had a little lamb',
          '... and the dialogue should be correct';
    };

    subtest 'Character cue with () text after name' => sub {
        my $cue = <<'END';
MARY (O.S.)
(annoyed)
Support planned parenthood.
END
        my $component = Fountain::Parser::Body::Component->create(
            text     => $cue,
            previous => Fake::Component->new,
        );

        ok $component->is_dialogue, 'Dialogue elements should be dialogues';
        is $component->character,   'MARY',
          'And we should have the correct character name';
        is $component->parenthetical, '(annoyed)',
          '... and we have the correct parenthetical';
        is $component->extended, '(O.S.)',
          '... or extended attributes to the name';
        is $component->dialogue, 'Support planned parenthood.',
          '... and the dialogue should be correct';
    };

    subtest 'Not a character cue' => sub {
        my $not_cue = "A short, scaly demon, with batlike wings, TITIVILLUS";

        my $component = Fountain::Parser::Body::Component->create(
            text     => $not_cue,
            previous => Fake::Component->new( is_header => 1 ),
        );

        ok !$component->is_dialogue,
          'Text starting with an upper case character is not necessarily a dialog';
    };
}

sub test_cut ( $test, $ ) {
    my @good = (
        'CUT TO:',
        'SMASH CUT TO:',
        'FADE TO:',
    );
    my @bad = (
        'CUTTO:',
        'CUT TO',
        'SMASH CUT TO',
        'FADE TO',
        'cut to:',
        'smash cut to:',
        'fade to:',
    );
    foreach my $good (@good) {
        my $component = Fountain::Parser::Body::Component->create(
            text     => $good,
            previous => Fake::Component->new,
        );

        ok $component->is_cut,
          'Components ending in " TO:" are automatically cuts';
        like $component->to_string, qr/^\s+.* TO:$/,
          '... and should be right-justified';
    }
    foreach my $bad (@bad) {
        my $component = Fountain::Parser::Body::Component->create(
            text     => $bad,
            previous => Fake::Component->new,
        );

        ok !$component->is_cut,
          'Components not ending in " TO:" are not cuts';
    }
}

__PACKAGE__->meta->make_immutable;

1;
