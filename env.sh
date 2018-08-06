# See README.md
export DOMAIN="gwiki.org"
declare -A MACADDRESS=( \
        ["jump."$DOMAIN]="52:54:00:42:B4:AD" \
     ["master0."$DOMAIN]="52:54:00:2C:C2:A0" \
     ["master1."$DOMAIN]="52:54:00:AC:C6:E1" \
     ["master2."$DOMAIN]="52:54:00:DE:6B:C4" \
       ["node0."$DOMAIN]="52:54:00:96:FF:84"   \
       ["node1."$DOMAIN]="52:54:00:4A:22:9B"   \
       ["node2."$DOMAIN]="52:54:00:4A:22:9C"   \
       ["node3."$DOMAIN]="52:54:00:4A:22:9D"   \
       ["xjump."$DOMAIN]="64:54:00:42:B4:00" \
    ["xmaster0."$DOMAIN]="64:54:00:42:B4:01" \
      ["xnode0."$DOMAIN]="64:54:00:42:B4:02" \
      ["xnode1."$DOMAIN]="64:54:00:42:B4:03" \
      ["xnode2."$DOMAIN]="64:54:00:42:B4:04" \
      ["xnode3."$DOMAIN]="64:54:00:42:B4:05" \
      ["xnode4."$DOMAIN]="64:54:00:42:B4:06" \
      ["xnode5."$DOMAIN]="64:54:00:42:B4:07" \
      ["xnode6."$DOMAIN]="64:54:00:42:B4:08" \
      ["xnode7."$DOMAIN]="64:54:00:42:B4:09" \
      ["xnode8."$DOMAIN]="64:54:00:42:B4:10" \
      ["xnode9."$DOMAIN]="64:54:00:42:B4:11" \
)
export OCPDOMAIN="nozell.com"
export WORKSPACE="$HOME/ocp"
export VMS="$WORKSPACE/VMs"
export ISOS="$HOME/ISOs"
export RHEL_IMAGE="$ISOS/rhel-server-7.5-update-1-x86_64-kvm.qcow2"
export BRIDGE="LondonBridge" # or virbr0 depending on your needs
#export BRIDGE="virbr0"
export VMRAM_JUMP=8192
export VMRAM_OCP=24576
export VMROOTDISK=120G
export VMDOCKERDISK=10G
export VMGLUSTERFSDISK=10G
