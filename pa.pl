#!/usr/bin/perl -s

#use Array;
use Periodogram;

#	requires "1243, 1234" with NO SPACE BEFORE COMMA AND 1 SPACE AFTER!
#	gnuplot> plot 'test' using 1:2 

#	./pa.pl -x1=1 -x2=10 -dx=.1 Sin.iii

my $data = Periodogram->new($ARGV[0]);
foreach ( $data->data() ) { print "$_->[0], $_->[1]\n"; }

