#!/bin/bash

domain="nozell.com"
workspace="/home/marc/ocp"
isos="/home/marc/ISOs"
vms="$workspace/VMs"

for i in jump master0 node0 node1;
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
