#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl

BEGIN { unshift (@INC, "../", "./"); } 

use strict;
use File::Basename;
use Array;
use Periodogram;

chomp ( $ENV{PWD} = `pwd` );		#	because $ENV{PWD} is $ISDC_OPUS/pipeline_lib when running in Perl

print "\n###############################################################################\n";
print "#######\n";
print "#######     RUNNING THE PeriodAnalysis UNIT TEST \n";
print "#######\n";
print "###############################################################################\n\n\n";

print "#\n#\tCleaning up from previous runs.\n#\n";
foreach ( "test_data","out","outref" ) {
	next unless ( -e $_ );
	print "#\t\tRemoving $_\n";
	system ( "chmod -R +w $_" );
	system ( "rm -rf $_" );
}
print "#\n";

#-------------------------------------------------------------------------------------

my $OS = `uname`;
chomp $OS;
my $osdir = ( $OS =~ /SunOS/i ) ? "sparc_solaris" : "linux";
my ( $retval, @result );

print "Setting up lots of environment variables for OS=$OS.\n";

my @TEST_DATA_TGZ = ( "test_data.tar.gz" );

my @OUTREF_TGZ = ( "outref.tar.gz" );

foreach ( @TEST_DATA_TGZ ) {
	print "#######     Searching for $_\n";
	if ( -e "$_" ) {
		print "#######     Gunzipping $_\n";
		system ( "gunzip -c $_ | tar xf -" );
	} else {
		print "#######     WARNING: $_ not found!\n";
	}
}


foreach ( @OUTREF_TGZ ) {
	print "#######     Searching for outref $_\n";
	if ( -e "$_" ) {
		print "#######     Gunzipping $_\n";
		system ( "gunzip -c $_ | tar xf -" );
	} else {
		print "#######     WARNING: $_ not found!\n";
	}
}



system ( "mkdir -p out" );


open OUT, "> out/VERSION";
print OUT Periodogram->VERSION;
close OUT;

print "Opening test_data/Sin.iii\n";
my $data = Periodogram->new('test_data/Sin.iii');
open OUT, "> out/Sin.iii";
foreach ( $data->data() ) { print OUT "$_->[0], $_->[1]\n"; }
close OUT;

open OUT, "> out/Sin.Variance";
print OUT $data->TotalYVariance()."\n";
close OUT;

print "Setting period to 6.28\n";
$data->period(6.28);
print "Converting to Phase\n";
$data->TimeToPhase();
open OUT, "> out/Sin.phase1.6.28";
foreach ( $data->data() ) { print OUT "$_->[0], $_->[1]\n"; }
close OUT;

print "Doubling\n";
$data->DoublePhase();
open OUT, "> out/Sin.phase2.6.28";
foreach ( $data->data() ) { print OUT "$_->[0], $_->[1]\n"; }
close OUT;

print "Opening test_data/Sin.iii\n";
my $data = Periodogram->new('test_data/Sin.iii');

open OUT, "> out/Sin.pdm";
my $total = $data->TotalYVariance();
print "Computing PDM from 1-12, step 0.01\n";
for ( my $x=1; $x<=12; $x+=0.01 ){
	my $clone = Periodogram->clone($data);
	$clone->period($x);
	$clone->TimeToPhase();
	$clone->DoublePhase();
	my $overall = $clone->OverallVariance(5,2);
	my $y = $overall/$total;
	print OUT "$x, $y\n";
}
close OUT;

open OUT, "> out/Sin.sl";
print "Computing SL from 1-12, step 0.01\n";
for ( my $x=1; $x<=12; $x+=0.01 ){
	my $clone = Periodogram->clone($data);
	$clone->period($x);
	$clone->TimeToPhase();
	my $y = $clone->StringLength();
	print OUT "$x, $y\n";
}
close OUT;



#my $clone = Periodogram->clone($data);
#$clone->show();
#
#$data->file('test.iii');
#$data->readdata();
#$data->show();
#
#print "\n\n\n";
#
#$clone->show();
#
#print "\n\n\n";

#print $data->show();

#
#print "\n\n\n";


#my $newdata = new Periodogram($ARGV[0]);
#
#$newdata->show();

