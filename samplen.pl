#!/usr/bin/perl -sw
# When N is an integer, sample N lines from a file in constant memory,
# using reservoir sampling, as originally proposed by Knuth.
# If N is a percentage, sample N% of lines.
# Operates on either STDIN or a file, if given as second arg.

use POSIX qw(ceil floor);

$IN = 'STDIN' if (@ARGV == 1);
open($IN, '<'.$ARGV[1]) if (@ARGV == 2);
die "Usage:  perl samplen.pl <lines or %> <?file>\n" if (!defined($IN));

$N = $ARGV[0];
@sample = ();

# percentage
$P = $1/100 if ($N =~ /(.*)\%$/);
while (<$IN>) {
    ## if percent
    if ($P) {
	print if (rand() < $P);
    } elsif ($. <= $N) {
	$sample[$.-1] = $_;
    } elsif (($. > $N) && (rand() < $N/$.)) {
	$replace = int(rand(@sample));
	$sample[$replace] = $_;
    }
}
print foreach (@sample);
close($IN);
