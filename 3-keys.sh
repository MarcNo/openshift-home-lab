#!/bin/bash

source ./env.sh

for i in `cat hosts|grep -v \\\\[`;
do 
	ssh-copy-id root@$i
done

