# NAME

Fountain::Parser - A parser for Fountain screenplay markup

# VERSION

version 0.001

# SYNOPSIS

    use Fountain::Parser;
    my $parser = Fountain::Parser->new(
        text => $fountain_text,
    );
    say $parser->to_string;    # screenplay in text format
    say $parser->report;       # screenplay statistics

# DESCRIPTION

Fountain is a Markdown inspired syntax for writing screenplays.  This module
provides parsing capabilities for the Fountain screenplay format.  It also
provides a text output for a quick scan, and statistics.

It should be assumed that there are no user-serviceable parts inside and the
`Fountain::Parser` module is the _only_ public interface.

# METHODS

## `new`

    my $parser = Fountain::Parser->new( text => $fountain_text );

Returns a `Fountain::Parser` instance.

## `to_string`

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

## `report`

        say $parser->report;

As of version .01, this prints:

- The names of the characters and number of dialogues
- A list of all places and the number of times they appear
- A **rough** estimate of the final page count

# SEE ALSO

- See [the Fountain website](https://fountain.io/) for syntax details.
- The [afterwriting](https://afterwriting.com/) web site can convert your Fountain to a PDF.
- [Afterwriting](https://github.com/ifrost/afterwriting-labs/blob/master/docs/clients.md) can also be installed locally.

# TODO

## Formatters

Currently we only have a simple text output. Later, we'll want custom formatters
to allow us output the format as MS Word or PDFs.

# AUTHOR

Curtis "Ovid" Poe <curtis.poe@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Curtis "Ovid" Poe.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
