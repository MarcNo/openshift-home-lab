#!/bin/bash

domain="nozell.com"

for i in `cat hosts`;
do 
	ssh-copy-id $i
done

