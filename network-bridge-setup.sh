sudo nmcli con add type bridge con-name LondonBridge ifname LondonBridge
sudo nmcli con add type ethernet con-name UK-slave ifname enp6s0 master LondonBridge
sudo nmcli con modify LondonBridge bridge.stp no
sudo nmcli con up LondonBridge
sudo nmcli con up UK-slave
brctl show LondonBridge
