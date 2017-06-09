#!/bin/bash

for i in `cat hosts`;
do 
	virsh shutdown $i
done

