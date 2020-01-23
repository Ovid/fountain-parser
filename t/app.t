#!/usr/bin/env perl

use Test::Class::Moose::Load 't/tests';
use Test::Class::Moose::Runner;
use Fountain::Boilerplate;
my @test_classes = map { path_to_package($_) } @ARGV;
Test::Class::Moose::Runner->new( test_classes => \@test_classes )->runtests;

sub path_to_package ($path) {
    $path =~ s/.*?(?=TestsFor)//;
    $path =~ s/\.pm$//;
    $path =~ s{/}{::}g;
    return $path;
}

