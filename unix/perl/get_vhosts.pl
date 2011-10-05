#!/usr/bin/env perl

# os: bsd
# version: 1.0
# purpose: returns all interface IP{v4,v6} addresses and associated PTR records
# requires: awk
#           host


#ifconfig | awk '$1 ~ /inet[0-9]*/ && $2 !~ /fe80::1%lo0|::1|127.0.0.1/ {print $2};' | xargs -n 1 host | awk '$5 ~ /.*[.]$/ {print $5}'
my @v4 = `ifconfig | awk '\$1 ~ /inet\$/ && \$2 !~ /fe80::1%lo0|::1|127.0.0.1/ {print \$2};'`;
my @v6 = `ifconfig | awk '\$1 ~ /inet6\$/ && \$2 !~ /fe80::1%lo0|::1|127.0.0.1/ {print \$2};'`;

chomp @v4; chomp @v6;

print <<HEADER;
We are always adding vhosts! Check back soon!
HEADER

print "\nIPv4 Vhosts\n-----------\n\n";
for $x (@v4) {
	my $host = `host -t ptr -W 1 $x|awk '\$5 ~ /.*[.]\$/ {print \$5;}'`;
	chomp $host;
	print $x." -> ". ($host ? $host : "Available! - Choose your custom vhost today!"). "\n";# if $host;
}

print "\nIPv6 Vhosts\n-----------\n\n";
for $x (@v6) {
        my $host = `host -t ptr -W 1 $x|awk '\$5 ~ /.*[.]\$/ {print \$5;}'`;
        chomp $host;
        print $x." -> ". ($host ? $host : "Available! - Choose your custom vhost today!"). "\n" if $host;
}

print <<FOOTER;
FOOTER
