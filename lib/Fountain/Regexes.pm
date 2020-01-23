package Fountain::Regexes;
use strict;
use warnings;
use base 'Exporter';

our @EXPORT_OK = qw(
  $SCENE_HEADER_PATTERN
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

our $SCENE_HEADER_PATTERN = qr{
    ^
    (?<scene_heading_int_ext>INT|EXT)\.
    \s+
    (?<scene_heading_location>[^-\\n]+)
    (?:
        \s+
        -
        \s+
        (?<scene_heading_time>.*?)
        (?:
            \s+
            (?<scene_heading_time_extended>\([^\)]+\))
            \s*
        )?
    )?
$}x;

our $CHARACTER_CUE_PATTERN = qr{
    ^
    \s+
    (?<character_cue_character>[[:upper:][:space:]]+)
    (?:
        \s+
        (?<character_cue_parenthetical>\([^\)]+\))
        \s*
    )?
$}x;

1;
__END__
our $ACTION_PATTERN             = qr%([^<>]*?)(\\n{2}|\\n<)%;
our $MULTI_LINE_ACTION_PATTERN  = qr%\n{2}(([^a-z\\n:]+?[\\.\\?,\\s!\\*_]*?)\n{2}){1,2}%;
our $CHARACTER_CUE_PATTERN      = qr%(?<=\\n)([ \\t]*[^<>a-z\\s\\/\\n][^<>a-z:!\\?\\n]*[^<>a-z\\(!\\?:,\\n\\.][ \\t]?)\\n{1}(?!\\n)%;
our $DIALOGUE_PATTERN           = qr%(<(Character|Parenthetical)>[^<>\\n]+<\\/(Character|Parenthetical)>)([^<>]*?)(?=\\n{2}|\\n{1}<Parenthetical>)%;
our $PARENTHETICAL_PATTERN      = qr%(\\([^<>]*?\\)[\\s]?)\n%;
our $TRANSITION_PATTERN         = qr%\\n([\\*_]*([^<>\\na-z]*TO:|FADE TO BLACK\\.|FADE OUT\\.|CUT TO BLACK\\.)[\\*_]*)\\n%;
our $FORCED_TRANSITION_PATTERN  = qr%\\n((&gt;|>)\\s*[^<>\\n]+)\\n%;     # need to look for &gt; pattern because we run this regex against marked up content
our $FALSE_TRANSITION_PATTERN  = qr%\\n((&gt;|>)\\s*[^<>\\n]+(&lt;\\s*))\\n%;     # need to look for &gt; pattern because we run this regex against marked up content
our $PAGE_BREAK_PATTERN         = qr%(?<=\\n)(\\s*[\\=\\-\\_]{3,8}\\s*)\\n{1}%;
our $CLEANUP_PATTERN            = qr%<Action>\\s*<\\/Action>%;
our $FIRST_LINE_ACTION_PATTERN  = qr%^\\n\\n([^<>\\n#]*?)\\n%;
our $SCENE_NUMBER_PATTERN       = qr%(\\#([0-9A-Za-z\\.\\)-]+)\\#)%;
our $SECTION_HEADER_PATTERN     = qr%((#+)(\\s*[^\\n]*))\\n?%;

#pragma mark - Templates

our $SCENE_HEADER_TEMPLATE      = qr%\n<Scene Heading>$1</Scene Heading>%;
our $ACTION_TEMPLATE            = qr%<Action>$1</Action>$2%;
our $MULTI_LINE_ACTION_TEMPLATE = qr%\n<Action>$2</Action>%;
our $CHARACTER_CUE_TEMPLATE     = qr%<Character>$1</Character>%;
our $DIALOGUE_TEMPLATE          = qr%$1<Dialogue>$4</Dialogue>%;
our $PARENTHETICAL_TEMPLATE     = qr%<Parenthetical>$1</Parenthetical>%;
our $TRANSITION_TEMPLATE        = qr%\n<Transition>$1</Transition>%;
our $FORCED_TRANSITION_TEMPLATE = qr%\n<Transition>$1</Transition>%;
our $FALSE_TRANSITION_TEMPLATE  = qr%\n<Action>$1</Action>%;
our $PAGE_BREAK_TEMPLATE        = qr%\n<Page Break></Page Break>\n%;
our $CLEANUP_TEMPLATE           = qr"";
our $FIRST_LINE_ACTION_TEMPLATE = qr%<Action>$1</Action>\n%;
our $SECTION_HEADER_TEMPLATE    = qr%<Section Heading>$1</Section Heading>%;

#pragma mark - Block Comments

our $BLOCK_COMMENT_PATTERN      = qr%\\n\\/\\*([^<>]+?)\\*\\/\\n%;
our $BRACKET_COMMENT_PATTERN    = qr% \\n \\[{2} ( [^<>]+? ) \\]{2} \\n%x;
our $SYNOPSIS_PATTERN           = qr%\\n={1}([^<>=][^<>]+?)\\n%;     # we need to make sure we don't catch ==== as a synopsis

our $BLOCK_COMMENT_TEMPLATE     = qr%\n<Boneyard>$1</Boneyard>\n%;
our $BRACKET_COMMENT_TEMPLATE   = qr%\n<Comment>$1</Comment>\n%;
our $SYNOPSIS_TEMPLATE          = qr%\n<Synopsis>$1</Synopsis>\n%;

our $NEWLINE_REPLACEMENT        = qr%@@@@@%;
our $NEWLINE_RESTORE            = qr%\n%;


#pragma mark - Title Page

our $TITLE_PAGE_PATTERN             = qr%^([^\\n]+:(([ \\t]*|\\n)[^\\n]+\\n)+)+\\n%;
our $INLINE_DIRECTIVE_PATTERN       = qr%^([\\w\\s&]+):\\s*([^\\s][\\w&,\\.\\?!:\\(\\)\\/\\s-©\\*\\_]+)$%;
our $MULTI_LINE_DIRECTIVE_PATTERN   = qr%^([\\w\\s&]+):\\s*$%;
our $MULTI_LINE_DATA_PATTERN        = qr%^([ ]{2,8}|\\t)([^<>]+)$%;


#pragma mark - Misc

our $DUAL_DIALOGUE_PATTERN          = qr%\\^\\s*$%;
our $CENTERED_TEXT_PATTERN          = qr%^>[^<>\\n]+<%;


#------------------------------------------------------------------------------
# The following regexes aren't used by the code here, but may be useful for you

#pragma mark - Styling for FDX

our $BOLD_ITALIC_UNDERLINE_PATTERN  = qr%(_\\*{3}|\\*{3}_)([^<>]+)(_\\*{3}|\\*{3}_)%;
our $BOLD_ITALIC_PATTERN            = qr%(\\*{3})([^<>]+)(\\*{3})%;
our $BOLD_UNDERLINE_PATTERN         = qr%(_\\*{2}|\\*{2}_)([^<>]+)(_\\*{2}|\\*{2}_)%;
our $ITALIC_UNDERLINE_PATTERN       = qr%(_\\*{1}|\\*{1}_)([^<>]+)(_\\*{1}|\\*{1}_)%;
our $BOLD_PATTERN                   = qr%(\\*{2})([^<>]+)(\\*{2})%;
our $ITALIC_PATTERN                 = qr%(?<!\\\\)(\\*{1})([^<>]+)(\\*{1})%;
our $UNDERLINE_PATTERN              = qr%(_)([^<>_]+)(_)%;

#pragma mark - Styling templates

our $BOLD_ITALIC_UNDERLINE_TEMPLATE = qr%Bold+Italic+Underline%;
our $BOLD_ITALIC_TEMPLATE           = qr%Bold+Italic%;
our $BOLD_UNDERLINE_TEMPLATE        = qr%Bold+Underline%;
our $ITALIC_UNDERLINE_TEMPLATE      = qr%Italic+Underline%;
our $BOLD_TEMPLATE                  = qr%Bold%;
our $ITALIC_TEMPLATE                = qr%Italic%;
our $UNDERLINE_TEMPLATE             = qr%Underline%;
