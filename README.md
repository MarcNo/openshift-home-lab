# openshift-home-lab
Sample script to build a KVM environment for OpenShift 3.11 in my homelab

[I](mailto:mdunnett@redhat.com) (irc: [mdunnett](mailto:mdunnett@charter.net))
needed to setup a local OpenShift environment for experimentation on a
local desktop with 32GB memory. These config files work for me to do a
simple install of OpenShift.

If you want to do the same, here are some scripts and configuration
files to help get you going.

This is still a bit rough and requires some editing of files.  Please
send patches/PR.

Thanks to mmagnani, ruchika, and MarcNo for kickstarting the initial work.

## What do you get

* Three RHEL7.5 VMs running in KVM (1 master, 1 node, 1 jump). You can add
  more as desired as part of the initial installation, or after you get 
  things up and running. The more VMs you turn on, the more memory you will
  need. I have more than one server serving some of my nodes (more on that 
  below). 
* Registered and appropriate subscriptions attached 
* required RPMs installed, including atomic-openshift-installer
* docker installed and storage configured
* ready to install the OpenShift cluster from the jump VM.

## Requirements

* Access to DNS server.  I'm using two personal domains hosted on
  godaddy.com.
* Access to DHCP server. I'm using my home tp-link router and tie
  specific IP addresses to known mac addresses. ie: VMs always get the
  same IP address from DHCP.
* RHEL 7 KVM hypervisor host
* `rhel-server-7.5-x86_64-kvm.qcow2` (from https://access.redhat.com/downloads/)
* 1 NIC on your hypervisor. (You can optionally use two).

If you are looking at this the first time, and wondering what you need to know to
get up and running, this is the place to read. 

## edit hosts file 

There are several host files in this repo. The first one you want to look at is 
hosts. After the [ocp] line, make sure the next two lines are your FQDN's for 
your master and your node.

```bash
[ocp]
master0.domain.com
node0.domain.com
```

### edit various files

When you look at the env.sh file, you'l lnotice that the MAC addresses 
are already set up for your VMs. You need to take those MACs and add them
to your router (in my case) to pin IP addresses to those MACs.

* Edit `env.sh` for your environment:
  - DOMAIN - the domain name to use for the hosts (ie: pokitoach.com)
  - MACADDRESS - MAC addresses for your VMs (be unique)
  - OCPDOMAIN - the domain name for the cluster (ie: ocp.hupiper.com,
    *.apps.hupiper.com)  
  - WORKSPACE, VMS - where VMs, etc are stored
  - ISOS - where your ISOs can be found
  - RHEL_IMAGE - your rhel-server-7.5-x86_64-kvm.qcow2 image 
  - BRIDGE - which bridge to use.  See Network Notes below

* Update your DNS server. godaddy hosts my DNS records, so I don't need
  to hack `/etc/resolv.conf`. But you will need to update your DNS A
  records to point to the local addresses so it looks like this.  eg:

        $ nslookup jump.$DOMAIN
        Server:		8.8.8.8
        Address:	8.8.8.8#53
        
        Non-authoritative answer:
        Name:	jump.$DOMAIN
        Address: 192.168.88.99

Also setup wildcard DNS entry for *.ocp.$OCPDOMAIN, *.apps.$OCPDOMAIN to
point to the master0.$DOMAIN

* Update your DHCP server

Tie those specific IP addresses defined in DNS to known mac
addresses. ie: VMs always get the same IP address from DHCP.

### Network Notes

  Getting the network setup properly is a trick. You can use the
  default virb0 bridge that KVM automatically sets up, but that will
  only allow the VMs be connected to from the hypervisor or other VMs
  on the same host.

  If you want to be able to connect to the individual VMs from any system,
  you can add a second NIC in the form of an inexpensive USB 3 NIC
  (enp0s20f0u1)

  Here are the NetworkManager CLI commands to create another bridge
  (br0) and have enp0s20f0u1 bound (aka slaved) to it.

  `nmcli con add type bridge ifname br0` 

  `nmcli con show` # some will be yellow

  `nmcli -f bridge con show bridge-br0` # just take a look

  `nmcli con add type bridge-slave ifname enp0s20f0u1 master br0`

  `ifup br0`

  `nmcli con show`  # all green
  
  Then edit /etc/qemu-kvm/bridge.conf to add:

  `allow br0`
  
  Optional just finishing up libvirt config

  `virsh net-list --all`

  If you don't see a `default` network entry from the previous
  command, do this:
  
  `virsh net-define /usr/share/libvirt/networks/default.xml`

  `virsh net-start default`

  `virsh net-autostart default`

### generate SSH key pair

* Use ssh-keygen to create a new key pair. This key will be added to the VMs.

  `ssh-keygen -f /home/<USER>/.ssh/id_rsa -t rsa -N ''`

  Then copy the public key to the ocp directory - 
 
  `cp ~/.ssh/id_rsa.pub to ~/ocp/vm_id_rsa.pub`


### edit variables.yml

* You need to set the openshift_subscription_pool for your own Red Hat account.
  Use this command will find your pool id:

  `subscription-manager list --all --available --matches "*openshift*"`

  Make variable.yml look something like this:

  `openshift_subscription_pool: 8a85f9833e1404a9013e3cddf95a0599`

### create ansible-vault vault.yml

* Create a vault to store your own Red Hat subscription
  username/password in variables. (ie: what you use on the Red Hat
  portal)

  **Delete the vault.yml file cloned in this repo first**

  `ansible-vault create vault.yml` - this command will open
  a vi session with a file called vault.yml. 

  add these two lines to this file:

  `vault_rhn_username: my-rhn-support-username`

  `vault_rhn_password: secretpassword-for-rhn`

  Take a look at the resulting file and it should not have the
  variables in cleartext.
  
## Run on your hypervisor

~~*   `0-generate.sh` -- Create hosts and hosts.ocp based on your env.sh settings~~
*   `1-create.sh` -- Create qemu files for OS, container storage, OS config
*   `2-build.sh` -- Install VMs and attach disks
*   `start-all.sh` -- boot them up
*   `3-keys.sh` -- push ssh keys around
*   `4-prep.sh` -- update the VMs with required packages, etc
*   `5-cluster.sh` -- copy files to jump VMs and remind the next steps

## Post configuration

### Install OpenShift 

* `hypervisor# ssh root@jump.pokitoach.com # password is redhat`
* `jump#       ssh-keygen`
* `jump#       bash ./3-keys.sh`
* `jump#       ansible-playbook -i hosts.ocp /usr/share/ansible/openshift-ansible/playbooks/deploy-cluster.yml`

* Once the cluster is created, ssh root@master0 and create a non-admin user:

  `# touch /etc/origin/master/htpasswd`

  `# htpasswd /etc/origin/master/htpasswd someuser`

### Start using OpenShift

The easiest way to get started is to point a browser to
https://ocp.$OCPDOMAIN:8443/ (in my example,
https://ocp.hupiper.com:8443)

