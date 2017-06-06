#!/bin/bash

for i in jump master0 node0 node1;
do 
	virsh shutdown $i
done

