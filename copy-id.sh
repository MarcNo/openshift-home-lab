#!/bin/bash

source ./env.sh

for i in `cat hosts`;
do 
	ssh-copy-id $i
done

