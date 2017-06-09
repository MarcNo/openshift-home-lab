#!/bin/bash

for i in `cat hosts`;
do 
	virsh start $i
done

