package TestsFor::Fountain::Regexes;

use utf8::all;
use Test::Class::Moose;
use Moose;
use namespace::autoclean;

use Fountain::Boilerplate;
use Fountain::Regexes ':all';

sub test_class_name ( $test, $ ) {
    my @scene_headers = (
        [   "INT. BLOOM FRONT HALL",
            'standard INT. header',
            {
                scene_heading_int_ext  => 'INT',
                scene_heading_location => 'BLOOM FRONT HALL',
            }
        ],
        [   "EXT. BLOOM FRONT HALL",
            'standard EXT. header',
            {
                scene_heading_int_ext  => 'EXT',
                scene_heading_location => 'BLOOM FRONT HALL',
            }
        ],
        [   "EXT. BLOOM FRONT HALL - NIGHT",
            'standard EXT. header with time',
            {
                scene_heading_int_ext  => 'EXT',
                scene_heading_location => 'BLOOM FRONT HALL',
                scene_heading_time     => 'NIGHT',
            }
        ],
        [   "EXT. BLOOM FRONT HALL - NIGHT (later)",
            'standard EXT. header with time',
            {
                scene_heading_int_ext       => 'EXT',
                scene_heading_location      => 'BLOOM FRONT HALL',
                scene_heading_time          => 'NIGHT',
                scene_heading_time_extended => '(later)',
            }
        ],
    );
    foreach my $example (@scene_headers) {
        my ( $header, $description, $matches ) = $example->@*;
        ok( $header =~ $SCENE_HEADER_PATTERN, $description );
        if ($matches) {
            while ( my ( $match, $value ) = each $matches->%* ) {
                is $+{$match}, $value, "... and '$match' should be '$value'";
            }
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;
