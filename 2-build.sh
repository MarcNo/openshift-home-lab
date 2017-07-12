#!/bin/bash

source ./env.sh

declare -A macaddress=( \
    ["jump.gwiki.org"]="52:54:00:42:B4:AD" \
    ["master0.gwiki.org"]="52:54:00:2C:C2:A0" \
    ["master1.gwiki.org"]="52:54:00:AC:C6:E1" \
    ["master2.gwiki.org"]="52:54:00:DE:6B:C4" \
    ["node0.gwiki.org"]="52:54:00:96:FF:84"   \
    ["node1.gwiki.org"]="52:54:00:4A:22:9A"   \
)

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

    echo "[dry-run install $i w/ mac ${macaddress[$i]}"

    virt-install --ram 8192  --vcpus 4 --os-variant rhel7 --disk path=$image,device=disk,bus=virtio,format=qcow2 \
    	--noautoconsole --vnc --name $i --dry-run --cpu Skylake-Client,+vmx --network bridge=virbr0,mac=${macaddress[$i]} \
    	--print-xml > $VMS/$i.xml
#    	--noautoconsole --vnc --name $i --dry-run --cpu Skylake-Client,+vmx --network bridge=br1,mac=${macaddress[$i]} \
    echo "[define $i]"
    virsh define --file $VMS/$i.xml
    echo "[attach disk to $i, $dockerdisk]"
    virsh attach-disk $i --source $dockerdisk --target vdb --persistent

    echo "[$i done]"

done

exit


echo "########################################################################"

virsh list --all

