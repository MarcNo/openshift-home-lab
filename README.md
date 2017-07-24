# openshift-home-lab
Sample script to build a KVM environment for OpenShift 3.5 in my homelab

[I](mailto:mnozell@redhat.com) (irc: [MarcNo](mailto:marc@nozell.com))
needed to setup a local OpenShift environment for experimentation on a
local desktop with 32GB memory. These config files work for me to do a
simple install of OCP 3.5.

If you want to do the same, here are some scripts and configuration
files to help get you going.

This is still a bit rough and requires some editing of files.  Please
send patches/PR.

Thanks to mmagnani and ruchika for kickstarting the initial work.

## What do you get

* Three RHEL7.3 VMs running in KVM
* Registered and appropriate subscriptions attached 
* required RPMs installed, including atomic-openshift-installer
* docker installed and storage configured
* ready to install the OpenShift cluster from the jump VM.

## Requirements

* Access to DNS server.  I'm using a personal domain hosted on
  domains.google.com.
* Access to DHCP server. I'm using my home MikroTik router and tie
  specific IP addresses to known mac addresses. ie: VMs always get the
  same IP address from DHCP.
* RHEL 7 KVM hypervisor host
* `rhel-guest-image-7.3-35.x86_64.qcow2` (from https://access.redhat.com/downloads/)

## editing scripts

You should only have to edit one configuration file, env.sh

### edit various files

* Edit `env.sh` for your environment:
  - VM_LIST - the names of the VMs to create (3 by default, add more
    if needed)
  - DOMAIN - the domain name to use for the hosts (ie: gwiki.org)
  - MACADDRESS - MAC addresses for your VMs (be unique)
  - OCPDOMAIN - the domain name for the cluster (ie: ocp.nozell.com,
    *.apps.nozell.com)  
  - WORKSPACE, VMS - where VMs, etc are stored
  - ISOS - where your ISOs can be found
  - RHEL_IMAGE - your rhel-guest-image-7.3-35.x86_64.qcow2 is

* Update your DNS server. Google hosts my DNS records, so I don't need
  to hack `/etc/resolv.conf`. But you will need to update your DNS A
  records to point to the local addresses so it looks like this.  eg:

        $ nslookup jump.$DOMAIN
        Server:		8.8.8.8
        Address:	8.8.8.8#53
        
        Non-authoritative answer:
        Name:	jump.$DOMAIN
        Address: 192.168.88.99

Also setup wildcard DNS entry for *.ocp.$OCPDOMAIN, *.apps.$OCPDOMAIN to
point to the master0.$OCPDOMAIN

* Update your DHCP server

Tie those specific IP addresses defined in DNS to known mac
addresses. ie: VMs always get the same IP address from DHCP.

### edit prep-os-for-ocp.yml

* Use your own Red Hat subscription username/password

      shell: sudo subscription-manager register --username XXX --password 'XXX' --force 

## Run on your hypervisor

*   `1-create.sh` -- Create qemu files for OS, container storage, OS config
*   `2-build.sh` -- Install VMs and attach disks
*   `start-all.sh` -- boot them up
*   `3-keys.sh` -- push ssh keys around
*   `4-prep.sh` -- update the VMs with required packages, etc
*   `5-cluster.sh` -- copy files to jump VMs and remind the next steps

## Post configuration

### Install OpenShift 

* hypervisor# ssh root@jump.nozell.com # password is redhat
* jump#       ssh-keygen
* jump#       bash ./3-keys.sh
* jump#       ansible-playbook -i hosts.ocp /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml

* Once the cluster is created, ssh root@master0 and create a non-admin user:
  # touch /etc/origin/master/htpasswd
  # htpasswd /etc/origin/master/htpasswd someuser

## TODO

* move sensitive values in prep-os-for-ocp.yml to external file
* fix warning messages from ansible (replace sudo with become/become_user/become_method, service module, etc)
