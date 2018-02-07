#!/bin/bash

for i in `cat hosts|grep -v \\\\[`;
do 
	virsh shutdown $i
done

