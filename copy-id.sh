#!/bin/bash

domain="nozell.com"

for i in jump master0 node0 node1;
do 
	ssh-copy-id $i.$domain
done

