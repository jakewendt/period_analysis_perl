#!/usr/bin/perl -s

#use Array;
use Periodogram;

#	requires "1243, 1234" with NO SPACE BEFORE COMMA AND 1 SPACE AFTER!
#	gnuplot> plot 'test' using 1:2 

#	./pa.pl -x1=1 -x2=10 -dx=.1 Sin.iii

my $data = Periodogram->new($ARGV[0]);
my $total = $data->TotalYVariance();
$x1 ||= 4;
$x2 ||= 9;
$dx ||= 0.1;

for ( my $x=$x1; $x<=$x2; $x+=$dx ){
	my $clone = Periodogram->clone($data);
	$clone->period($x);
	$clone->TimeToPhase();
	$clone->DoublePhase();
	my $overall = $clone->OverallVariance(5,2);
	my $y = $overall/$total;
	print "$x, $y\n";
}
