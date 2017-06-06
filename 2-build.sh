#!/bin/bash

workspace="/home/marc/ocp"
vms="$workspace/VMs"

declare -A macaddress=( \
    ["jump"]="52:54:00:42:B4:AD" \
    ["master0"]="52:54:00:2C:C2:A0" \
    ["node0"]="52:54:00:96:FF:84"   \
    ["node1"]="52:54:00:4A:22:9A"   \
)

# Could use virt-install ... --extra-args="ip=[ip]::[gateway]:[netmask]:[hostname]:[interface]:[autoconf]"
# eg: 
# ip=192.168.88.123::192.168.88.1:255.255.255.0:test.example.com:eth0:none"

for i in jump master0 node0 node1;
do 

    echo "########################################################################"
    echo "[$i start]"

    baseimage="$vms/$i-base.qcow2"
    image="$vms/$i.qcow2"
    dockerdisk="$vms/$i-docker.qcow2"

    echo "[dry-run install $i w/ mac ${macaddress[$i]}"

    virt-install --ram 12288  --vcpus 4 --os-variant rhel7 --disk path=$image,device=disk,bus=virtio,format=qcow2 \
    	--noautoconsole --vnc --name $i --dry-run --cpu Skylake-Client,+vmx --network bridge=br1,mac=${macaddress[$i]} \
    	--print-xml > $vms/$i.xml
    echo "[define $i]"
    virsh define --file $vms/$i.xml
    echo "[attach disk to $i, $dockerdisk]"
    virsh attach-disk $i --source $dockerdisk --target vdb --persistent

    echo "[$i done]"

done

exit


echo "########################################################################"

virsh list --all

