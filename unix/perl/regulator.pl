#!/usr/bin/env perl

# os: bsd
# version: 1.0
# purpose:  reads ./regulator.db file for [user]:[allowed_procs] data and reports on process usage
#           if [user] exceeds [allowed_procs], the extra processes can be killed leaving the first [allowed_procs] spawned online
#           if [allowed_procs] is 0, the crontab for the user is also cleared
#           supports --log mode, to log only, if offending user is found, no action is taken
#
# requires: awk
#           procstat
#           tail
#           sort
#           populate ./regulator.db with [user]:[allowed_procs]

if ($ARGV[0] eq "--help" or $ARGV[0] eq "-h") {
	die("USAGE: $0 [--log | --help]\n--log\t\tRun in log mode, if offenders are found no action will be taken. A timestamp is also recorded\n");
}

my $db = "regulator.db";

my $tmp = "/tmp/.tmp.$$";
my $stamp = "";
system("ps aux|sort -k1 > $tmp");

my $match = "\$1 !~ /root|admin|USER|smmsp/ && \$11 !~ /-sh|-csh|-tcsh|-bash|sshd:/";
my $u = `awk '$match {print \$1}' $tmp`;
my $p = `awk 'BEGIN{OFS=\":\"} $match {print \$1,\$2}' $tmp | sort -nk2 -t\":\"`;

my @users = split(/\n/,$u);
my @pids = split(/\n/,$p);
my (@w, @kill);
my $lst = {};
my $plst = {};
my ($out, $offenders, $x, $read);
my $log = FALSE;

if ($ARGV[0] eq "--log" or $ARGV[0] eq "-l") {
        ($s,$m,$h,$mday,$mon,$year) = localtime(time);
        $stamp = sprintf("%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$h,$m,$s)." - ";
        $log = TRUE;
}

for $x (@pids) {
	@w = split(/:/,$x,3);
	$plst->{$w[0]} = ($plst->{$w[0]} ? $plst->{$w[0]}.", " : "").($w[1]);
}

for $x (@users) {
	$lst->{$x}++;
}

while (my ($k,$v) = each(%$lst)) {
	$allowed = `awk -F\":\" '\$1 == \"$k\" {print \$2;}' $db`;

	$out = `awk -F\":\" '\$1 == \"$k\" {
			if ($v > \$2) {
				printf(\"Warning: %s has $v procs running, allowed: %s\",\$1,\$2);
			}

		}' $db`;
	if ($out) {
	        @w = split(/ /,$out);
		print $stamp.$out." - pids: " .$plst->{$w[1]}. "\n";
		$offenders++;
		if (!$stamp) {
			@kill = split(/\, /,$plst->{$w[1]});
			for $proc (@kill) {
				print "   ".$proc." -> ".
					`procstat -b $proc|tail -1|awk '{print \$3}'|tr -d '\n'`
					." ".
					`procstat -c $proc|tail -1|awk '{\$1=\"\";\$2=\"\";\$3=\"\";print}'|tr -d '\n'`
					."\n";
			}
			splice(@kill,0,$w[7]);
			print "Would you like to kill the following extra procs: ".join(", ",@kill)."? [no] ";
			my $read = <STDIN>;
			chomp $read;
			if ($read eq "yes") {
				my $kcount = kill 9, @kill;
				print "KILL: $kcount procs owned by $w[1] were terminated\n";
				if (int($allowed) == 0) { system("crontab -ru $w[1]"); }
			}
			else {
				print "No action taken against $w[1]\n";
			}
		}
	}
}

if (!$offenders && !$stamp) {
	print "There are no offenders.\n";
}
elsif ($offenders && $stamp) {
	# notify admin?
}
system("rm -rf $tmp");
