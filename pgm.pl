#!/usr/bin/perl -w

use strict;
use CGI qw(:standard);
use Periodogram;

my $fn = param ( "fn" );
my $x1 = ( param ( "min" ) > 0 ) ? param("min") : 4;
my $x2 = ( param ( "max" ) > 0 ) ? param("max") : 9;
my $dx = ( param ( "step" )> 0 ) ? param("step") : 0.1;
my $dp = length($dx)-index($dx,".")-1; # decimal places

print header;   #       Content-Type: text/html; charset=ISO-8859-1

print start_html( 
	-title      => "Period Analysis 4.0", 
	-script     => [ 	{ -src => "js/wz_jsgraphics.js" },
							{ -src => "js/graph.js" }, ],
	-style      => { src => "css/jsgraph.css" },
	);

print "\n";

print "<div id='container'><div id='table'> <div id='cell'> <div id='wrapper'><div id='content'>\n";


print "<div id='graphCanvas1' style='background-color: white; margin: auto; width: 700px; height: 400px; position: relative;'>\n";
print "	<script type='text/javascript'>\n";
print "		var g1 = new graph();\n";
print "		g1.width = 700;\n";
print "		g1.height = 400;\n";
print "		g1.Lines  = 1;\n";
print "		g1.Marks = 0;\n";

my $data = Periodogram->new($fn);
my $total = $data->TotalYVariance();
my $min = 9999;
my $minp = 0;
for ( my $x=$x1; $x<=$x2; $x+=$dx ){
	$x = sprintf( "%.${dp}f", $x );
	my $clone = Periodogram->clone($data);
	$clone->period($x);
	$clone->TimeToPhase();
	$clone->DoublePhase();
	my $overall = $clone->OverallVariance(5,2);
	my $y = $overall/$total;
	if ( $y < $min ) {
		$min = $y;
		$minp = $x;
	}
	print "g1.add($x, $y);\n";
}

print "		g1.render('graphCanvas1', 'PDM Periodogram');\n";
print "	</script>\n";
print "</div>\n";	#	graphCanvas1

print "<br /> <br />\n";

print "<div id='graphCanvas2' style='background-color: white; margin: auto; width: 700px; height: 400px; position: relative;'>\n";
print "	<script type='text/javascript'>\n";
print "		var g2 = new graph();\n";
print "		g2.width = 700;\n";
print "		g2.height = 400;\n";
print "		g2.Lines  = 0;\n";
print "		g2.Marks = 1;\n";

my $clone = Periodogram->clone($data);
$clone->period($minp);
$clone->TimeToPhase();
foreach my $p ( $clone->data() ) {
	print "g2.add($p->[0], $p->[1]);\n";
}

print "		g2.render('graphCanvas2', 'Phase Diagram ($minp)');\n";
print "	</script>\n";
print "</div>\n";	#	graphCanvas2

print "</div>\n";	#	content
print "</div>\n";	#	wrapper
print "</div>\n";	#	cell
print "</div>\n";	#	table
print "</div>\n";	#	container

print end_html;

