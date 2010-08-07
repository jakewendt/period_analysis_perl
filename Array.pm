
package Array;

use Carp;

$Array::VERSION = "1.0";

sub Count {
	return scalar(@_);
}

sub Average {
	if (@_) {
		my $sum = 0;
		foreach ( @_ ) { $sum += $_; }
		return ( $sum / scalar(@_) );
	} else {
		return;
	}
}

sub TrueVariance {
	if (@_) {
		my $sum = 0;
		my $ave = Array::Average(@_);
		foreach ( @_ ) { $sum += (($_-$ave)**2); }
		return ( $sum / $#_ );
	} else {
		return;
	}
}


