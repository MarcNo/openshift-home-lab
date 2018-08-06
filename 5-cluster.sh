#!/bin/bash

source ./env.sh

echo "copied sample configuration hosts.ocp, hosts and 3-keys.sh to the jumpstation"
scp hosts.ocp root@jump.$DOMAIN:~/
scp hosts root@jump.$DOMAIN:~/
scp 3-keys.sh root@jump.$DOMAIN:~/
echo "Do this:"
echo "            $ ssh root@xjump.$DOMAIN"
echo "            jump# ssh-keygen"
echo "            jump# bash ./3-keys.sh"
echo "            jump# ansible-playbook -i hosts.ocp /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml"
echo "            jump# ansible-playbook -i hosts.ocp /usr/share/ansible/openshift-ansible/playbooks/deploy-cluster.yml"
echo "		  jump# ssh root@master0.gwiki.org \"htpasswd -b /etc/origin/master/htpasswd marc SekretPassword\""
echo "		  jump# oadm policy add-role-to-user system:registry marc (optional)"
exit
####
# Below are random notes
####

https://access.redhat.com/documentation/en-us/openshift_container_platform/3.5/html/installation_and_configuration/installing-a-cluster#what-s-next-2

Once the cluster is created, 

ssh root@master0.$DOMAIN and do:

   htpasswd -b /etc/origin/master/htpasswd marc SekretPassword
   oadm policy add-role-to-user system:registry marc


https://access.redhat.com/documentation/en-us/openshift_container_platform/3.5/html/installation_and_configuration/setting-up-the-registry#install-config-registry-overview

for non production use (may not have to do)

$ sudo chown 1001:root <path>
$ oadm registry --service-account=registry \
    --config=/etc/origin/master/admin.kubeconfig \
    --images='registry.access.redhat.com/openshift3/ose-${component}:${version}' \
    --mount-host=<path>

https://access.redhat.com/documentation/en-us/openshift_container_platform/3.5/html/installation_and_configuration/setting-up-a-router#install-config-router-overview

oadm policy add-cluster-role-to-user \
    cluster-reader \
    system:serviceaccount:default:router

oadm router <router_name> --replicas=<number> --service-account=router

https://master0.$DOMAIN:8443/
