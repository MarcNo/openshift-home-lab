# openshift-home-lab
Sample script to build a KVM environment for OpenShift 3.11 in my home lab.

I needed to setup a local OpenShift environment for experimentation on a
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
* 1 NIC

** If you are looking at this the first time, and wondering what you need to know to
get up and running, this is the place to start reading. **

These instructions assume you are installing a jump server VM in addition to
the master0 and node0 nodes. The install scripts for the jump server are
separate to allow you to skip the jump server if you choose to.

### 1. Clone or fork this git repo
```
$ git clone https://github.com/hupiper/openshift-home-lab.git
$ cd openshift-home-lab
```

### 2. Create working directories
```
mkdir ~/ocp/VMs
mkdir ~/ISOs
```

### 3. Edit hosts file

There are several host files in this repo. The first one you want to look at is
hosts. After the [ocp] line, make sure the next two lines are the FQDN's for
your master and your node.

```
[ocp]
master0.domain.com
node0.domain.com
```
Edit the hosts.jump file:
```
[jump]
jump.domain.com
```
### 4. Edit env.sh

When you look at the env.sh file, you'll notice that the MAC addresses are
already set up for your VMs. You need to take those MACs and add them to your
router (in my case) to pin IP addresses to those MACs. You'll also use those IP
addresses in DNS.

  - DOMAIN - the domain name to use for the hosts (ie: domain.com)
  - MACADDRESS - MAC addresses for your VMs (be unique)
  - OCPDOMAIN - the domain name for the cluster (ie: ocp.ocpdomain.com,
    \*.apps.ocpdomain.com\)  
  - WORKSPACE, VMS - where VMs, etc are stored
  - ISOS - where your ISOs can be found
  - RHEL_IMAGE - your rhel-server-7.5-x86_64-kvm.qcow2 image
  - BRIDGE - which bridge to use.  See Network Notes below

### 5. Add DNS A records for your domains
godaddy hosts my DNS records, so I don't need to hack `/etc/resolv.conf`. But
you will need to create/update your DNS A records to point to the local
addresses so it looks like this.  eg:

        $ nslookup jump.$DOMAIN
        Server:		8.8.8.8
        Address:	8.8.8.8#53

        Non-authoritative answer:
        Name:	jump.$DOMAIN
        Address: 192.168.88.99

Your A record for domain.com would be:
```
Host *           Points to *            TTL
jump             192.168.88.99          1 hour
```

Also setup wildcard DNS entry for ocp.$OCPDOMAIN, \*.apps.$OCPDOMAIN to
point to the master0.$DOMAIN IP address.

### 6. Update your DHCP server

Tie those specific IP addresses defined in DNS to known mac addresses. ie:
VMs always get the same IP address from DHCP.

### 7. Add required packages to your hosts
I'm assuming you are using RHEL 7.5 server as the host OS, but this also works
with Fedora 28/29 (use DNF instead of yum).

```
$ sudo yum install -y ansible
$ sudo yum install -y qemu-kvm libvirt libvirt-python libguestfs-tools virt-install
$ sudo systemctl enable libvirtd
$ sudo systemctl start libvirtd
```
You may also need to install libguestfs-xfs if it isn't installed as a dependency.

### 8. Create ssh keys
```
$ ssh-keygen -f /home/user/.ssh/id_rsa -t rsa -N ''
$ cp ~/.ssh/id_rsa.pub ~/ocp/vm_id_rsa.pub
```
### 9. Check CPU model in 2-build.sh script
1-create.sh creates the VMs for your nodes. 2-build.sh configures them to run
in your KVM environment. The virt-install command in this file has a --cpu
variable that is set to Skylake-client, which is the model of Intel CPU I am using
in my server. To see what model CPU you are using, use the virsh capabilities
command.
```
$ virsh capabilities
<capabilities>

  <host>
    <uuid>42d0404d-dd37-4be6-8703-336ddad75b67</uuid>
    <cpu>
      <arch>x86_64</arch>
      <model>IvyBridge-IBRS</model>
      <vendor>Intel</vendor>
```
You should see the model in the first several lines of XML that is generated from
that command. If it is not Skylake-client, you'll need to edit the command in
2-build.sh for the model you have, which for the example above is IvyBridge-IBRS.

### 10. Set up Linux Bridging

We are using Linux bridging to connect the physical NIC to the VMs in the
hypervisor. The bridge is called LondonBridge (it was that way when I forked -  
you can use br0 or something similar if you like, but you'll have to make sure
all of the scripts are using that name too). I'm assuming you are using the
Network Manager.

```
$ sudo nmcli con add type bridge con-name LondonBridge ifname LondonBridge
$ sudo nmcli con add type ethernet con-name UK-slave ifname enp0s25 master LondonBridge
$ sudo nmcli con modify LondonBridge bridge.stp no
$ sudo nmcli con up LondonBridge
$ sudo nmcli con up UK-slave
$ brctl show LondonBridge
$ nmcli con show # should be all green
$ ifconfig
```
Then edit /etc/qemu-kvm/bridge.conf and add the line:

`allow LondonBridge`

Optional:

`sudo virsh net-list --all`

If you don't see a `default` network entry from the previous command, do this:

```
$ sudo virsh net-define /usr/share/libvirt/networks/default.xml
$ sudo virsh net-start default
$ sudo virsh net-autostart default
```

### 11. Edit variables.yml

You need to set the openshift_subscription_pool for your own Red Hat account.
Use this command will find your pool id:

`subscription-manager list --all --available --matches "*openshift*"`

Make variable.yml look something like this:

`openshift_subscription_pool: 8a85f98c63842fef01647d9012060465`

### 12. Create ansible-vault vault.yml

Create a vault to store your own Red Hat subscription username/password
in variables. (ie: what you use on the Red Hat portal)

**Delete the vault.yml file cloned in this repo first**

  `ansible-vault create vault.yml` - this command will open
  a vi session with a file called vault.yml.

  add these two lines to this file:

  `vault_rhn_username: my-rhn-support-username`

  `vault_rhn_password: secretpassword-for-rhn`

  Take a look at the resulting file and it should not have the
  variables in cleartext.

### 14. (not superstitious, just careful) Edit hosts.ocp
Change `oreg_auth_user` to your Red Hat subscription name, and
`oreg_auth_password` to the Red Hat subscription password.

Change `openshift_master_default_subdomain` to the OCPDOMAIN you specified in
the env.sh file.

## Run on your hypervisor

*   `1-create.sh` -- Create qemu files for OS, container storage, OS config
*   `1-create-jump.sh` -- ditto for jump server
*   `2-build.sh` -- Install VMs and attach disks
*   `2-build-jump.sh` -- Install jump VM and attach disk
*   `start-all.sh` -- boot them up
*   `$ virsh start jump.domain.com`
*   `3-keys.sh` -- push ssh keys around
*   `4-prep.sh` -- update the VMs with required packages, etc
*   `4-prep-jump.sh` -- update the VMs with required packages, etc
*   `5-cluster.sh` -- copy files to jump VMs and remind the next steps

### Install OpenShift

* `hypervisor$ ssh root@jump.pokitoach.com # password is redhat`
* `jump#       ssh-keygen`
* `jump#       bash ./3-keys.sh`
* `jump#       ansible-playbook -i hosts.ocp /usr/share/ansible/openshift-ansible/playbooks/deploy-cluster.yml`

May need to scp ssh keys and/or ssh into the other nodes from the jump node to
make sure the known_hosts file is updated.

If you run into the WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! message,
use

`ssh-keygen -R node.domain.com`

for each host. Then you need to ssh into them again to add them to the known_hosts
file.

* Based on what we specified in the hosts.ocp file we are using the HTPasswdPasswordIdentityProvider type of RBAC in OpenShift. So we need to populate
the htpasswd file with users for our system.

  `# touch /etc/origin/master/htpasswd`

  `# htpasswd /etc/origin/master/htpasswd someuser`

### Start using OpenShift

The easiest way to get started is to point a browser to
https://ocp.$OCPDOMAIN:8443/.

Good luck!
