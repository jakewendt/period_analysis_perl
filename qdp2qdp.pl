#!/usr/bin/perl -w

#	qdp column names
#	center dT count_soft error_soft count_hard error_hard detsig radius revolution pointing subpointing pointingtype 


use strict;
use File::Basename;
#	$ENV{COMMONLOGFILE} = "+";
$ENV{COMMONLOGFILE} =~ s/^\+//;

#	die "No file given as first argument" unless $ARGV[0];

#my $source_data = "/isdc/integration/isdc_int/sw/dev/prod/opus/pipeline_lib/misc/qla_history/SOURCES";
#my $source_data = "/home/scientist/IQLA/SOURCES";
my $source_data = "/isdc/pvphase/IQLA/SOURCES";
die "$source_data unavailable." unless ( -r $source_data ); 


foreach my $instr ( qw/jemx/ ) {
	my %source;

	print "\n######################################################################\n\n";
	print "Processing $instr\n\n";

	my $source_name = "";
	my $source_id   = "";
	chomp ( my $date = `date` );
	my $source_cmt  = "Computed maximum from qdp files on $date";
	foreach my $source_dir ( glob "$source_data/*" ) {
		print "\n$source_dir\n";
		unless ( -d $source_dir ) {
			print "$source_dir is not a dir.  Skipping.\n";
			next;
		}
		$source_name  = &basename ( $source_dir );
#		$source_name =~ s/_/ /g;
		print "Processing source : $source_name \n";

		my @qdp_files = glob "$source_dir/*$instr*qdp";
		unless ( @qdp_files ) {
			print "No qdp files found for $source_name and $instr.  Skipping.\n";
			next;
		}
		print "Extracting data from all found qdp files.\n";
#		my $max_bin1 = 0;
#		my $max_bin2 = 0;
		`mkdir $instr`;
		open OUT, "> $instr/$source_name.qdp";
		foreach my $qdp_file ( @qdp_files ) {
			print "Reading $qdp_file\n";
			open QDP, "< $qdp_file";
			while (<QDP>) {
#				#	The important lines are of similar format to ...
#				#  2390.561301884880 0.0125578776098791    18.2054    1.1155    10.0588    0.7230   29.266   2.40  ! 0459 0042 001 0/ );
#				#	column 3 and column 5 are the fluxes
				next unless ( /^\s+\S+\s+\S+\s+(\S+)\s+\S+\s+(\S+)/ );
				print OUT $_;
#				$max_bin1 = $1 if ( $1 > $max_bin1 );
#				$max_bin2 = $2 if ( $2 > $max_bin2 );
			}
			close QDP;
		}
		close OUT;
#		print "$source_name : $instr : Max1 $max_bin1 : Max2 $max_bin2 \n";
#		$source{"$source_id"}{"name"} = $source_name;
#		$source{"$source_id"}{"max1"} = ( $max_bin1 > $hsh{$instr}{'max_bin1'} ) ? $hsh{$instr}{'max_bin1'} : $max_bin1;
#		$source{"$source_id"}{"max2"} = ( $max_bin2 > $hsh{$instr}{'max_bin2'} ) ? $hsh{$instr}{'max_bin2'} : $max_bin2;
#		$source{"$source_id"}{"cmt"}  = $source_cmt;
	}
#	open OUTPUT, "> $instr.maximums";
#	foreach my $id ( sort { $source{"$a"}{"name"} cmp $source{"$b"}{"name"} } keys ( %source ) ) {
#		printf OUTPUT "%20s %20s %15s %15s   %50s\n", $id, $source{"$id"}{"name"}, $source{"$id"}{"max1"}, $source{"$id"}{"max2"}, $source{"$id"}{"cmt"}; 
#	}
#	close OUTPUT;
}


exit;

######################################################################

sub DoOrDie {
	my ( $command ) = @_;
	my @result = `$command`;
	die ( "$command failed with $?" ) if ( $? );
	return @result;
}

