#!/usr/bin/env perl

# os: bsd
# version: 1.0
# purpose: scans and displays users history lines containing 'suspicious' commands
# requires: cat
#           hostname
#           cut
#           modify @ignore and @uignore as required


# commands to consider as 'safe'
my @ignore = qw|
    passwd
    cp
    rmdir
    grep
    mkdir
    mv
    ./bnc
    ./ezbounce
    ee
    vim
    pwd
    cd
    ls
    ./eggdrop
    ./psybnc
    tar
    ./znc
    ./znc-config
    exit
    chown
    chgrp
    crontab
    uptime
    kill
    killall
    get
    ps
    top
    irssi
    BitchX
    epic
    make
    chmod
    pico
    nano
    vi
    ./configure
    vhosts
    rm
    uname
|;

# users to consider as safe
my @uignore = qw/
    root
    admin
/;

my $only = "";

if ($ARGV[0]) { $only = $ARGV[0]; }
my $raw = `cat /etc/passwd|awk -F":" '\$6 ~ /home/{print \$1" "\$6"/";}'`;
my @tmp = split(/\n/,$raw);

my %data;
my @u = ();

my @histlines = ();
my @histlines_raw = ();
my $server = `hostname | cut -d. -f1`; chomp $server;
my ($template, $lines);
my $limit = 3000;

if ($only) { $data{$only} = "/home/$only/"; }
else {
	foreach (@tmp) {
       	 	@u = split(/ /,$_);
       	 	my ($name, $file) = ($u[0],$u[1]);
       		$data{$name} = $file if !grep(/$name/,@uignore);
	}
}
while (my ($user,$hist) = each(%data)) {
	$template = "  [$user\@$server ~]\$ ";
        $raw = `tail -q -n $limit $hist.history $hist.bash_history $hist.sh_history 2>/dev/null`;
        @histlines = split(/\n/,$raw);

        # strip out common history lines
        @histlines = grep(!/^#/,@histlines);

	if (@histlines+0 < 1) { print "! $user has no history.\n\n"; next; }

        for my $ig (@ignore) {
                @histlines = grep {!/^\Q$ig\E$/ and !/^\Q$ig\E\s/} @histlines;
        }

        $lines = $template.join("\n$template",@histlines);
        print "$user history lines of interest: \n$lines\n\n";
}
