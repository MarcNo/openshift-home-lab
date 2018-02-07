#!/bin/bash

for i in `cat hosts|grep -v \\\\[`;
do 
	virsh start $i
	sleep 5
done

