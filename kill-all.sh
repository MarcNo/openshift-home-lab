#!/bin/bash

source ./env.sh

for i in `cat hosts|grep -v \\\\[`;
do 

    echo "########################################################################"

    baseimage="$VMS/$i-base.qcow2"
    image="$VMS/$i.qcow2"
    xmlfile="$VMS/$i.xml"
    dockerdisk="$VMS/$i-docker.qcow2"

    virsh shutdown $i
    virsh undefine $i
    rm $baseimage $image $dockerdisk $xmlfile

done

virsh list --all

exit
