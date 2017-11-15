#!/bin/bash

source ./env.sh

if [ ! -d $VMS ]
then
    echo "Creating $VMS"
    mkdir -p $VMS
fi

for i in `cat hosts`;
do 

    echo "########################################################################"
    echo "[$i start]"

    baseimage="$VMS/$i-base.qcow2"
    image="$VMS/$i.qcow2"
    dockerdisk="$VMS/$i-docker.qcow2"

    echo "[Creating a $VMROOTDISK disk for root, $image]"
    qemu-img create -f qcow2 $baseimage $VMROOTDISK
    virt-resize --expand /dev/sda1 $RHEL_IMAGE $baseimage

    qemu-img create -f qcow2 -b $baseimage $image

    echo "[Creating a $VMDOCKERDISK disk for docker, $dockerdisk]"
    qemu-img create -f raw $dockerdisk $VMDOCKERDISK

    echo "[Customizing $i system]"
    virt-customize -a $image --run-command 'yum remove cloud-init* -y'
    virt-customize -a $image --root-password password:redhat
    virt-customize -a $image --hostname "$i"
    echo "[$i done]"

done

exit
