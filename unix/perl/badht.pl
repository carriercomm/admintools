#!/usr/bin/env perl

# os: linux
# version: 1.0
# purpose:  scans an Apache access log file for malicious requests and blocks the IP responsible
#
# requires: iptables (+chain @arg1, else uses 'bad_traffic' by default)
#           grep
#           cut

use strict;
use warnings;
use POSIX qw(strftime);

die("Usage: $0 </var/log/httpd/access_log> [iptables_chain]") if !$ARGV[0];
my $log = $ARGV[0];

my $chain = ($ARGV[1] ? $ARGV[1] : "bad_traffic");

my @bad = `grep w00tw00t $log|cut -f1 -d" "|sort -u`;
my @ablk = `/sbin/iptables -S $chain|grep DROP|awk '{print \$4}'|cut -d"/" -f1`;

foreach my $ip (@bad) {
    if (!grep $_ eq $ip, @ablk) {
        chomp $ip;
        `/sbin/iptables -A $chain -s $ip -j DROP`;
        print strftime("%b %d %T",localtime(time))." badht: blocked bad HTTP traffic from: $ip\n";
    }
}
