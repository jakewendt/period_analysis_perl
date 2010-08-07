
package Periodogram;

use Carp;
use Array;

$AUTOLOAD;
$Periodogram::VERSION = "1.1";

#	variables declared outside of the functions are available for change
#	by any instantiated object of the class. (class data)
#	(ie. $count can be read and modified by any Periodogram object)
#	my $count = 0;


#	http://perldoc.perl.org/perltoot.html

#	An automatic set and get routine for each field
#	is created by AUTOLOAD as needed.
#	Great place to put defaults as well.
my %fields = (
	name        => 'test',
	period      => 6.28,
	file        => undef,
);


sub DESTROY { }

sub AUTOLOAD {	#	from http://perldoc.perl.org/perltoot.html
	my $self = shift;
	my $type = ref($self)
		or croak "$self is not an object";
	my $name = $AUTOLOAD;
	$name =~ s/.*://;   # strip fully-qualified portion
	unless (exists $self->{_permitted}->{$name} ) {
		croak "Can't access `$name' field in class $type";
	}
	if (@_) { $self->{$name} = shift; }
	return $self->{$name};
}

sub new {
	my $class = shift;
#	if class ISA something else
#	my $self  = $class->SUPER::new();
	my $self  = {
		_permitted => \%fields,
		%fields,
		file => shift,
		points => [],
	};
	bless ($self, $class);
	$self->readdata() if $self->{file};
	return $self;
}

sub clone {
	my $class = shift;
	my $source = shift;
	my $self  = {
		file => "",
		points => [],
		_permitted => \%fields,
		%fields,
	};
	bless ($self, $class);
	foreach my $k ( keys ( %$self ) ) {
		if ( ref($source->{$k}) eq "ARRAY" ) {
#
#	This is a very specific situation.  An array of array references which can't be copied.
#	This above if could just be "$k eq 'points'" as it is the only place it is used.
#
			foreach my $p ( @{$source->{$k}} ) {
				push @{$self->{$k}}, [$p->[0],$p->[1]];
			}
		} else {
			$self->{$k} = $source->{$k};
		}
	}
	return $self;
}

############################ STANDARD ################################

sub data { return ( @{shift->{points}} ) ; }

sub readdata {
	my $self = shift;
	@{$self->{points}} = ();
	open FILE, "$self->{file}";
	while (<FILE>) {
		next unless /\s*(\d+)\s*,\s*([\-\d\.]+)\s*/;
		push @{$self->{points}}, [$1,$2];
	}
	close FILE;
	@{$self->{points}} = sort { $a->[0] <=> $b->[0] } @{$self->{points}};
}

sub doublepoints {
	my $self = shift;
	my $num = $#{$self->{points}};
	for ( my $i=0; $i<=$num; $i++ ) {
		push @{$self->{points}}, [${$self->{points}}[$i]->[0],${$self->{points}}[$i]->[1]];
	}
}

sub DoublePhase {
	my $self = shift;
	my $num = $#{$self->{points}};
	for ( my $i=0; $i<=$num; $i++ ) {
		push @{$self->{points}}, [1+${$self->{points}}[$i]->[0],${$self->{points}}[$i]->[1]];
	}
}

sub TimeToPhase {
	my $self = shift;
	if ($self->{period}) {
		my $cycles;
		foreach  ( @{$self->{points}} ) {
			$cycles = $_->[0] / $self->{period};
			$_->[0] = abs($cycles - int($cycles));
		}
		@{$self->{points}} = sort { $a->[0] <=> $b->[0] } @{$self->{points}};
	}
}

sub show {
	foreach ( @{shift->{points}} ) {
		print "$_->[0], $_->[1]\n";
	}
}

sub TotalYVariance {
	return Array::TrueVariance(map { $_->[1] } @{shift->{points}});
}

sub OverallVariance {
	my $self = shift;
	my ( $TotalBins, $TotalCovers ) = @_;
	# For Fixed Bin Width
	# Requires SortXAscending and DoublePhase first to properly function

	my $ActualCount = scalar(@{$self->{points}}) / 2;	#	due to DoublePhase
	my $TempSum = 0;
	foreach my $Cover ( 1 .. $TotalCovers ) {
		my $BinStart = ($Cover - 1) / ($TotalBins * $TotalCovers);
		my $element = 0;
#		print "Points: ",scalar(@{$self->{points}}),"\n";
#		print "Cover: $Cover\n";
		while ( ( $element <= scalar(@{$self->{points}}) )
			&& ( ${$self->{points}}[$element]->[0] < $BinStart ) ) {
			$element++;
		}	#	skip 
		foreach my $Bin ( 1 .. $TotalBins ) {
#			print "Bin:   $Bin\n";
#			print "BinStart: $BinStart\n";
			my $BinEnd = (($Bin * $TotalCovers) + $Cover - 1) / ($TotalBins * $TotalCovers);
#			print "BinEnd: $BinEnd\n";
			my @a = ();

			while ( ( $element <= scalar(@{$self->{points}}) )
				&& ( ${$self->{points}}[$element]->[0] >= $BinStart )
				&& ( ${$self->{points}}[$element]->[0] <  $BinEnd ) ) {
				push @a, ${$self->{points}}[$element];
#				print "${$self->{points}}[$element]->[0]\n";
				$element++;
			}
#			print "BinCount: ",scalar(@a),"\n";
			if ( scalar(@a) > 1 ) {			
				my $BinVariance = Array::TrueVariance(map { $_->[1] } @a );
#				print "TrueVariance: $BinVariance\n"; 
				$TempSum += ($BinVariance * $#a);
			}
			$BinStart = $BinEnd;
		}	#	Bin
	}	#	Cover
	return ($TempSum / (($TotalCovers * $ActualCount) - ($TotalCovers * $TotalBins)));
}

sub StringLength {
	my $self = shift;

	my $sl = 0;
#	print scalar(@{$self->{points}}),"\n";
	for ( my $i=0; $i< scalar(@{$self->{points}})-1 ; $i++ ) {
#		print "$i : ",scalar(@{$self->{points}})," : $sl\n";
		$sl += abs( ${$self->{points}}[$i+1]->[1] - ${$self->{points}}[$i]->[1] );
#		$sl += ( (${$self->{points}}[$i+1]->[0] - ${$self->{points}}[$i]->[0])**2 
#				 + (${$self->{points}}[$i+1]->[1] - ${$self->{points}}[$i]->[1])**2 )**0.5;
	}
	$sl += abs( ${$self->{points}}[0]->[1] - ${$self->{points}}[$#{$self->{points}}]->[1] );
#	$sl += ( (${$self->{points}}[0]->[0] - ${$self->{points}}[$#{$self->{points}}]->[0] + 1)**2 
#			 + (${$self->{points}}[0]->[1] - ${$self->{points}}[$#{$self->{points}}]->[1])**2 )**0.5;
}

sub OverallVariance_B {
	my $self = shift;
	my $BinCount = $_[0];
#		For Fixed Bin Count
#		Requires SortXAscending and DoublePhase first to properly function
#		Perhaps add "offset"
	my $ActualCount = scalar(@{$self->{points}}) / 2;	#	due to DoublePhase
	my $TempSum = 0;
	my $TotalPoints = 0;
#	print "BinCount: $BinCount\n";
	for ( my $i=0; $i<$ActualCount; $i+=$BinCount ) {
#		print "i: $i\n";
		my @a = ();
		foreach ( 0 .. $BinCount-1 ) {
#			print "_: $_ : ${${$self->{points}}[$i+$_]}[0]\n";
			push @a, ${$self->{points}}[$i+$_];
		}
		my $BinVariance = Array::TrueVariance(map { $_->[1] } @a );
#		print "TrueVariance: $BinVariance\n"; 
		$TempSum += ($BinVariance * $#a);
#		print "TempSum: $TempSum\n";
		$TotalPoints += $BinCount;
#		print "TotalPoints: $TotalPoints\n";
	}
#	print "TotalPoints: $TotalPoints\n";
#	print "BinCount**2: ",$BinCount**2,"\n";
	return abs($TempSum / (($TotalPoints) - ($BinCount**2)));
}

return 1;

__END__





'   --------------------------------------------------------------------------------
'       Fourier Transform Method

Public Function DFT_Z(ByVal Period As Double) As Double
    Dim A As Double
    Dim SinSum As Double
    Dim CosSum As Double
    Dim Omega As Double
    Dim SqrSum As Double
    Dim C As Double

    Omega = (1 / Period) * 2 * 3.14159265
    CosSum = 0#
    SinSum = 0#

    Me.Data.GoFirst
    Do
        A = Omega * Me.Data.XValue '(wt)
        SinSum = SinSum + Me.Data.YValue * Sin(A)
        CosSum = CosSum + Me.Data.YValue * Cos(A)
        SqrSum = SqrSum + Me.Data.YValue ^ 2
    Loop While Me.Data.GoNext
    C = (Me.Data.Count - 1) / (Me.Data.Count * SqrSum)
    DFT_Z = (CosSum ^ 2 + SinSum ^ 2) * C
End Function



