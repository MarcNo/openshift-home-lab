#!/bin/bash

domain="nozell.com"
workspace="/home/marc/ocp"
isos="/home/marc/ISOs"
vms="$workspace/VMs"

rhel_image="$isos/rhel-guest-image-7.3-35.x86_64.qcow2"

if [ ! -d $vms ]
then
    echo "Creating $vms"
    mkdir -p $vms
fi

for i in `cat hosts`;
do 

    echo "########################################################################"
    echo "[$i start]"

    baseimage="$vms/$i-base.qcow2"
    image="$vms/$i.qcow2"
    dockerdisk="$vms/$i-docker.qcow2"

    echo "[Creating a 60G disk for root, $image]"
    qemu-img create -f qcow2 $baseimage 60G
    virt-resize --expand /dev/sda1 $rhel_image $baseimage
    qemu-img create -f qcow2 -b $baseimage $image

    echo "[Creating a 10G disk for docker, $dockerdisk]"
    qemu-img create -f raw $dockerdisk 10G

    echo "[Customizing $i system]"
    virt-customize -a $image --run-command 'yum remove cloud-init* -y'
    virt-customize -a $image --root-password password:redhat
    virt-customize -a $image --hostname "$i.$domain"
    echo "[$i done]"

done

exit
