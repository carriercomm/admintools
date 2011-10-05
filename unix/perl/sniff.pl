#!/usr/bin/env perl

# os: bsd
# version: 1.0
# purpose:  follows a user's shell session by using either proccess id or username
#
# requires: Switch lib
#           truss


use Switch;

my $i = 0;
my ($pid, $tee, $logfile);

for my $a (@ARGV) {
	$i++;
	switch ($a) {
		case "-s" {
			my $u = $ARGV[$i];
			chomp $u;
			if ($u =~ /[a-zA-Z0-9]+/) {
				$pid = `ps -U $u 2>/dev/null|awk '\$5 ~ /^-sh/ {print \$1}'`;
				$pid || die("No such user $u or no shell pid active.\n");
				$pid = (split(/\n/,$pid))[0];
				chomp $pid;
			}
		}
                case "-p" { $pid = $ARGV[$i]; chomp $pid; }
		case "-l" { $logfile = "$ARGV[$i]"; chomp $logfile; }
	}
}

$pid || die("USAGE: $0 [-s user] [-p pid]\n");

if ($logfile) {
	$tee = "-o $logfile";
	print "Writing to logfile $logfile\n";

}
print "Following $pid...\n";
system("truss $tee -fa -p $pid");
