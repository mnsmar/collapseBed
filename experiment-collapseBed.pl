#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use XML::Simple;

use lib '/home/mns/lib/perl/class/v5.0';
use MyBio::NGS::Experiment;

# Read command options
my $help;
my $time = time;
GetOptions(
        'h'            => \$help,
) or usage();
usage() if $help;

my $params_file = shift;
my $ifilename = shift;

# Die if arguments not correct
unless ((defined $params_file) and (defined $ifilename)) {
	usage();
}

my $experiment = MyBio::NGS::Experiment->new({XML => $params_file});
my $experiment_folder = $experiment->get_path();

my @sub_experiment_names = $experiment->get_subexperiment_names();
foreach my $sub_experiment_name (@sub_experiment_names) {
	my @samples = $experiment->get_samples_for_subexperiment($sub_experiment_name);
	foreach my $sample (@samples) {
		my $sample_name = $sample->{'name'};
		my $sample_type = $sample->{'type'};
		my $sample_species_id = $sample->{'bwa'}->{'species'};
		my $sample_folder = $sample->{'relative_path'};
		
		warn "Working for $sample_name\n";
		
		my $ifile = $experiment_folder.'/'.$sample_folder."/tracks/$ifilename";
		my $ofile = $experiment_folder.'/'.$sample_folder."/tracks/$ifilename";
		$ofile =~ s/\.bed(\.gz)*$/.collapse.bed/;
		if ($ofile eq $ifile) {
			die "Input file and output file are the same. $ofile eq $ifile\n";
		}
		
		if ($ifile =~ /\.gz$/) {
			warn "Running \"zcat $ifile | collapseBed.pl | sort -k1,1 -k2,2n > $ofile\"\n";
			system "zcat $ifile | collapseBed.pl | sort -k1,1 -k2,2n > $ofile";
		}
		else {
			warn "Running \"cat $ifile | collapseBed.pl | sort -k1,1 -k2,2n > $ofile\"\n";
			system "cat $ifile | collapseBed.pl | sort -k1,1 -k2,2n > $ofile";
		}
	}
}


my $ifile_pool = $experiment_folder."/tracks/$ifilename";
my $ofile_pool = $experiment_folder."/tracks/$ifilename";
if (-e $ifile_pool) {
	warn "Working for pool of samples\n";
	$ofile_pool =~ s/\.bed(\.gz)*$/.collapse.bed/;
	if ($ofile_pool eq $ifile_pool) {
		die "What the f...! Input file and output file are the same. $ofile_pool eq $ifile_pool\n";
	}
	
	if ($ifile_pool =~ /\.gz$/) {
		warn "Running \"zcat $ifile_pool | collapseBed.pl | sort -k1,1 -k2,2n > $ofile_pool\"\n";
		system "zcat $ifile_pool | collapseBed.pl | sort -k1,1 -k2,2n > $ofile_pool";
	}
	else {
		warn "Running \"cat $ifile_pool | collapseBed.pl | sort -k1,1 -k2,2n > $ofile_pool\"\n";
		system "cat $ifile_pool | collapseBed.pl | sort -k1,1 -k2,2n > $ofile_pool";
	}

}

warn "time elapsed = ".(time-$time)."sec\n";

###########################################
# Subroutines used
###########################################
sub usage {
	print "\nUsage:   $0 <options> experiment_params_file bed_input_filename\n\n".
	      "Options:\n".
	      "        -h             print this help\n\n";
	exit;
}