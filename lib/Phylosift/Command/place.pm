package Phylosift::Command::place;
use Phylosift::Command::all;
use Phylosift -command;
use Phylosift::Settings;
use Phylosift::Phylosift;
use Carp;
use Phylosift::Utilities qw(debug);

sub description {
	return "phylosift place - place aligned reads onto a reference phylogeny";
}

sub abstract {
	return "place aligned reads onto a reference phylogeny";
}

sub usage_desc { "place %o <sequence file> [pair sequence file]" }

sub place_opts {
	my %opts = (
		coverage => [ "coverage=s",   "Provides a contig/scaffold coverage file for estimating relative abundance"],
		bayes    => [ "bayes",        "Compute posterior probabilities during phylogenetic placement. Required for Bayesian hypothesis testing"],
	);
	return %opts;
}

sub options {
	my %opts = place_opts();	
	%opts = (Phylosift::Command::all::all_opts(), %opts);
	return values(%opts);
}

sub validate {
	my ($self, $opt, $args) = @_;
	$self->usage_error("phylosift place requires exactly one or two file name arguments to run") unless @$args == 1 || @$args == 2;
}

sub execute {
	my ($self, $opt, $args) = @_;
	Phylosift::Command::all::load_opt(opt=>$opt);
	$Phylosift::Settings::keep_search = 1;
	Phylosift::Command::sanity_check();

	my $ps = new Phylosift::Phylosift();
	$ps = $ps->initialize( mode => "placer", file_1 => @$args[0], file_2 => @$args[1]);
	$ps->{"ARGV"} = \@ARGV;
	$ps->run( force=>$Phylosift::Settings::force, custom=>$Phylosift::Settings::custom, cont=>$Phylosift::Settings::continue );
}

1;