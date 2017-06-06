# openshift-home-lab
Sample script to build a KVM environment for OpenShift 3.5 in my homelab

[I](mailto:mnozell@redhat.com) (irc: [MarcNo](mailto:marc@nozell.com)
needed to setup a local OpenShift environment for experimentation on a
local desktop with 32GB memory. These config files work for me to do a
simple install of OCP 3.5.

If you want to do the same, here are some scripts and configuration
files to help get you going.

This is a bit rough and requires some editing of files.  Please send
patches/PR.

Thanks to mmagnani and ruchika for kickstarting the initial work.

## What do you get

* Four RHEL7.3 VMs running in KVM
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
* rhel-guest-image-7.3-35.x86_64.qcow2 (from http://downloads.redhat.com)

## editing scripts

User specific information could/should be abstracted out to files
instead of editing files.  Send patches/PRs.

### edit Vagrantfile

* Edit the VM hostnames, IP addresses and default gateway.  Four VMs
  are created, choose your own names/addresses

  * `jump.nozell.com` - jumpstation (where you run the OCP installer from)
  * `master0.nozell.com` - first and only master node 
  * `node0.nozell.com`, `node1.nozell.com` - compute nodes

* Update your DNS server. Google hosts my DNS records, so I don't need
to hack `/etc/resolv.conf`. But you will need to update your DNS A
records to point to the local addresses so it looks like this.  eg:

        $ nslookup jump.nozell.com
        Server:		8.8.8.8
        Address:	8.8.8.8#53
        
        Non-authoritative answer:
        Name:	jump.nozell.com
        Address: 192.168.88.99

Also setup wildcard DNS entry for *.ocp.nozell.com, *.apps.nozell.com
to point to the master0.


### edit prep.yml

* Use your own Red Hat subscription username/password

      shell: sudo subscription-manager register --username XXX --password 'XXX' --force 

## Run

   1-create.sh -- Create qemu files for OS, container storage, OS config
   2-build.sh -- Install VMs and attach disks
   3-keys.sh -- push ssh keys around
   4-prep.sh -- update the VMs with required packages, etc
   5-cluster.sh -- copy files to jump VMs and remind the next steps

## Post configuration

### Install OpenShift 

        $ ssh root@jump.nozell.com # password is redhat
	
        # ssh-keygen

	# bash ./3-keys.sh
	
        # ansible-playbook -i hosts.ocp /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml

## TODO

* move sensitive values to external file
* abstract out domain/hostname/mac addresses
* fix warning messages from ansible (replace sudo with become/become_user/become_method, service module, etc)