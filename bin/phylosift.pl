#!/usr/bin/env perl
use warnings;
use strict;
use FindBin qw($Bin);
#use lib "$Bin/../lib";
BEGIN { push(@INC, "$Bin/../lib") }
use Phylosift;
Phylosift->run();

exit 0;