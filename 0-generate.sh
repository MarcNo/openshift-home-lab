#!/bin/bash

source ./env.sh

echo "generating hosts and hosts.ocp based on env.sh configuration"

rm -v hosts

for i in $VM_LIST
do
    echo "$i.$DOMAIN" >> hosts
done

replace_tokens() {
  eval "echo \"$(cat $1)\""
}

replace_tokens ./hosts.ocp.template > ./hosts.ocp.template

