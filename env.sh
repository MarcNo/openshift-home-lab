export DOMAIN="gwiki.org"
export WORKSPACE="$HOME/ocp"
export VMS="$WORKSPACE/VMs"
export ISOS="$HOME/ISOs"
export RHEL_IMAGE="$ISOS/rhel-guest-image-7.3-35.x86_64.qcow2"
declare -A macaddress=( \
    ["jump."$DOMAIN]="52:54:00:42:B4:AD" \
    ["master0."$DOMAIN]="52:54:00:2C:C2:A0" \
    ["master1."$DOMAIN]="52:54:00:AC:C6:E1" \
    ["master2."$DOMAIN]="52:54:00:DE:6B:C4" \
    ["node0."$DOMAIN]="52:54:00:96:FF:84"   \
    ["node1."$DOMAIN]="52:54:00:4A:22:9A"   \
)
