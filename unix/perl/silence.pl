#!/usr/bin/env perl

# os: unix
# version: 1.0
# purpose:  kills all processes belonging to <user> as long as <user> is not 'root'
#
# requires: awk
#           kill

my $wait = 10;
my $user = $ARGV[0];
die ("USAGE: $0 <user (!root)>\n") if (!$user || $user eq "root");

print "Killing ${user}'s procs (ETA $wait seconds)...\n";
for (my $x = $wait; $x > 0; $x--) { sleep 1; print "$x\n"; }
print "Last chance to CTRL+C...\n";
sleep 5;
print "OK.. going down!\n";
sleep 2;
system("kill -9 `ps -U $user | awk '\$1 !~ /PID/ {printf(\"%s \",\$1);}'`");
