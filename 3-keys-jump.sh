#!/bin/bash

source ./env.sh

for i in `cat hosts.jump|grep -v \\\\[`;
do 
	ssh-copy-id root@$i
done

