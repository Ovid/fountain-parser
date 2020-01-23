package Fountain::Util::String;

use Fountain::Boilerplate;
use String::Util 'trim';
use base 'Exporter';
our @EXPORT_OK = qw(
  trimsplit
  num_lines
);

sub trimsplit ( $separator, $text, $num_parts = 0 ) {
    if ($num_parts) {
        return map { trim($_) } split $separator => $text, $num_parts;
    }
    else {
        return map { trim($_) } split $separator => $text;
    }
}

sub num_lines ($text) {
    chomp($text);
    return 1 + ( $text =~ tr/\n// );
}

1;
