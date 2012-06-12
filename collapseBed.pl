#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

my $help;
GetOptions(
        'h'          => \$help,
) or usage();
usage() if $help;

my %counts;
while (my $line = <>) {
	chomp $line;
	if ($line !~ /^chr/) {
		print "$line\n";
		next;
	}
	my ($chr, $start, $stop, $name, $score, $strand) = split(/\t/,$line);
	$counts{"$chr|$start|$stop|$strand"}++;
}

foreach my $name (keys %counts) {
	my ($chr, $start, $stop, $strand) = split(/\|/,$name);
	print "$chr\t$start\t$stop\t$counts{$name}\t$counts{$name}\t$strand\n"; 
}

###########################################
# Subroutines used
###########################################
sub usage {
	print "\nUsage: $0 [options] <bed_file>\n\n".
	      "Options:\n".
	      "        -h             print help\n\n";
	exit;
}
