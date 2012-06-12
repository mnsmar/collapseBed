#!/usr/bin/env perl
use warnings;
use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);

my $help;
GetOptions(
        'h'          => \$help,
) or usage();
usage() if $help;

my %scores;
while (my $line = <>) {
	chomp $line;
	if ($line =~ /^(track|browser)/) {
		print "$line\n";
	}
	else {
		my @fields = split(/\t/,$line);
		
		# get the score and name and remove them from fields
		my ($score,$name) = splice(@fields, 3, 2);
		if (!looks_like_number($score)) {
			$score = 1;
		}
		
		# discard empty fields at the end
		while (!defined $fields[-1]) {
			pop @fields;
		}
		
		my $identifier = join("\t",@fields);
		$scores{$identifier} += $score;
	}
}

foreach my $identifier (keys %scores) {
	my @fields = split(/\t/,$identifier);
	my $final_score = $scores{$identifier};
	
	# put the score and name back into fields (use score as name)
	my ($score,$name) = splice(@fields, 3, 0, ($final_score,$final_score));
	
	print join("\t",@fields)."\n";
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
