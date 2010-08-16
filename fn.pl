#!/usr/bin/perl -w

use strict;
use CGI qw(:standard);
use Periodogram;

my $fn = param ( "fn" );
my $x1 = param ( "min" ) || 4;
my $x2 = param ( "max" ) || 9;
my $dx = param ( "step" ) || 0.1;


print header;   #       Content-Type: text/html; charset=ISO-8859-1

print start_html( 
	-title      => "Period Analysis 4.0", 
	-script     => [ 	{ -src => "js/wz_jsgraphics.js" },
							{ -src => "js/graph.js" }, ],
	-style      => { src => "css/jsgraph.css" },
	);

print "\n";

print *$fn,"\<br/>n";
print $fn,"<br/>\n";
print ref($fn),"<br/>\n";
print ref($x1),"<br/>\n";

while ( <$fn> ) {
	print $_;
}


print end_html;

