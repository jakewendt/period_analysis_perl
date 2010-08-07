#!/usr/bin/perl -w

use strict;
use Array;

#my @a = ( 1,2,3,4,5 );
#my @a = ( );
my @a = ( 1 );

print @a, "\n";
print scalar(@a), "\n";
print $#a, "\n";

print "-------\n";

print Array::Count(@a), "\n";
print Array::Average(@a), "\n";
