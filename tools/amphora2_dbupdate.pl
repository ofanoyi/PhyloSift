#!/usr/bin/env perl

use warnings;
use strict;

use FindBin qw($Bin); use lib "$Bin/lib";
use Getopt::Long;
use Amphora2::Amphora2;
use Carp;
use Amphora2::Utilities qw(debug);
use Amphora2::UpdateDB;

die "Usage: amphora2_dbupdate.pl <data repository path>" unless @ARGV==1;

my $repository = $ARGV[0];
my $ebi_repository = $repository."/ebi";
my $ncbi_draft_repository = $repository."/ncbi_draft";
my $ncbi_finished_repository = $repository."/ncbi_finished";
my $local_repository = $repository."/local";
my $result_repository = $repository."/processed";
my $marker_dir = $repository."/markers";

my $newObject = new Amphora2::Amphora2();
$newObject->readAmphora2Config();
Amphora2::Utilities::dataChecks($newObject);

Amphora2::UpdateDB::get_ebi_genomes($ebi_repository);
Amphora2::UpdateDB::get_ncbi_draft_genomes($ncbi_draft_repository);
Amphora2::UpdateDB::get_ncbi_finished_genomes($ncbi_finished_repository);

my @new_genomes=();
Amphora2::UpdateDB::find_new_genomes($ncbi_finished_repository, $result_repository, \@new_genomes);
Amphora2::UpdateDB::find_new_genomes($ncbi_draft_repository, $result_repository, \@new_genomes);
Amphora2::UpdateDB::find_new_genomes($ebi_repository, $result_repository, \@new_genomes);
Amphora2::UpdateDB::find_new_genomes($local_repository, $result_repository, \@new_genomes);
Amphora2::UpdateDB::qsub_updates($result_repository, \@new_genomes);


Amphora2::UpdateDB::collate_markers($result_repository, $marker_dir);
Amphora2::UpdateDB::assign_seqids($result_repository, $marker_dir);
Amphora2::UpdateDB::build_marker_trees_fasttree($marker_dir);
Amphora2::UpdateDB::reconcile_with_ncbi($newObject, $result_repository, $marker_dir);
Amphora2::UpdateDB::package_markers($marker_dir);
