#!/bin/bash

source ./env.sh

# Could use virt-install ... --extra-args="ip=[ip]::[gateway]:[netmask]:[hostname]:[interface]:[autoconf]"
# eg: 
# ip=192.168.88.123::192.168.88.1:255.255.255.0:test.example.com:eth0:none"

for i in `cat hosts`;
do 

    echo "########################################################################"
    echo "[$i start]"

    baseimage="$VMS/$i-base.qcow2"
    image="$VMS/$i.qcow2"
    dockerdisk="$VMS/$i-docker.qcow2"

    echo "[dry-run install $i w/ mac ${MACADDRESS[$i]}"

    virt-install --ram 16384 --vcpus 4 --os-variant rhel7 --disk path=$image,device=disk,bus=virtio,format=qcow2 \
        --noautoconsole --vnc --name $i --dry-run --cpu Skylake-Client,+vmx --network bridge=${BRIDGE},mac=${MACADDRESS[$i]} \
    	--print-xml > $VMS/$i.xml
# You may also need to change the CPU depending on the hypervisor's CPU
#    	--noautoconsole --vnc --name $i --dry-run --cpu Skylake-Client,+vmx --network bridge=${BRIDGE},mac=${MACADDRESS[$i]} \

    echo "[define $i]"
    virsh define --file $VMS/$i.xml
    echo "[attach disk to $i, $dockerdisk]"
    virsh attach-disk $i --source $dockerdisk --target vdb --persistent

    echo "[$i done]"

done

exit


echo "########################################################################"

virsh list --all

