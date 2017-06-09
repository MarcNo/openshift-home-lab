#!/bin/bash

domain="nozell.com"
workspace="/home/marc/ocp"
isos="/home/marc/ISOs"
vms="$workspace/VMs"

for i in `cat hosts`;
do 

    echo "########################################################################"

    baseimage="$vms/$i-base.qcow2"
    image="$vms/$i.qcow2"
    xmlfile="$vms/$i.xml"
    dockerdisk="$vms/$i-docker.qcow2"

    virsh shutdown $i
    virsh undefine $i
    rm $baseimage $image $dockerdisk $xmlfile

done

virsh list --all

exit
