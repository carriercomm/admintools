#!/usr/bin/env bash

# os: unix
# version: 1.0
# purpose: create's an ssh tunnel and periodically checks the state, respawning when needed
# requires: grep
#           awk
#           ssh (+rsa keypair between localhost and rhost)

privkey="/root/.ssh/id_rsa"
recheck=10
lport=8080
rport=3306
rhost="master"
ruser="root"


while [ true ]; do
	sshpid=`ps aux|grep "$lport:localhost:$rport"|grep -v grep|awk '{print \$2}'`;
	#echo -n "Checking for ssh tunnel... "
	if [ ! $sshpid ]; then
		#echo -n "not found, creating..."
		#date
		ssh -nN2g -i $privkey -L $lport:localhost:$rport $ruser@$rhost sleep 5&
		sshpid=$!
		if [ $? ]; then
			:
			#echo "success! (pid: $sshpid)"
		else
			kill -9 $sshpid > /dev/null 2>&1 # cleanup
			#echo "failed! will try again in ${recheck}s"
		fi
	else
		:
		#echo "found (pid: $sshpid)... sleeping"
	fi
	sleep $recheck
done;
