#!/usr/bin/env perl

# os: linux
# version: 1.0
# purpose: adds a specified IP to a specified chain with a DROP target
# requires: iptables (+chain $chain)
#           awk

# chain to use for blacklist, ex: INPUT/FORWARD/spammers
my $chain = "blacklist";


my $list = `iptables -L $chain -n --line-numbers | awk '\$5 != "source" && \$5 != "" {print \$5}'`;

die($list) if ($ARGV[0] eq "-l" || $ARGV[0] eq "list");

die("USAGE: ./blacklist.pl [ip | -l]") if ($ARGV[0] !~ /^[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+$/ || !$ARGV[0]);

my $ip = $ARGV[0];

my @bl = split /\n/,$list;

die ("$ip is already blacklisted\n") if (grep($_ eq $ip,@bl));

`iptables -A $chain -s $ip -p tcp -j DROP`;
