#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

NET_MGMT_ADDR=20.20.20.1
CTL_MGMT_ADDR=20.20.20.2
COM_MGMT_ADDR=20.20.20.3

EXT_NET_INTF_NAME=eth0
EXT_NET_ADDRESS=172.27.117.101
EXT_NET_NETMASK=255.255.240.0
EXT_NET_GATEWAY=172.27.127.254

MGNT_NET_INTF_NAME=eth1
MGNT_NET_ADDRESS=20.20.20.1
MGNT_NET_NETMASK=255.255.255.0

VM_NET_INTF_NAME=eth2
VM_NET_ADDRESS=30.30.30.1
VM_NET_NETMASK=255.255.255.0

cp /etc/hosts /etc/hosts~
sed -i "s/127.0.1.1/#127.0.1.1/g" /etc/hosts
echo "$NET_MGMT_ADDR      network" >> /etc/hosts
echo "$CTL_MGMT_ADDR      network" >> /etc/hosts
echo "$COM_MGMT_ADDR      network" >> /etc/hosts

cp /etc/network/interfaces /etc/network/interfaces~
cat << EOF > /etc/network/interfaces
# The loopback network interface
auto lo
iface lo inet loopback

## External net 
auto $EXT_NET_INTF_NAME
iface $EXT_NET_INTF_NAME inet static
address $EXT_NET_ADDRESS
netmask $EXT_NET_NETMASK
gateway $EXT_NET_GATEWAY
dns-nameservers 8.8.8.8

## Management net
auto $MGNT_NET_INTF_NAME
iface $MGNT_NET_INTF_NAME inet static
address $MGNT_NET_ADDRESS
netmask $MGNT_NET_NETMASK

## VM Data net 
auto $VM_NET_INTF_NAME
iface $VM_NET_INTF_NAME inet static
address $VM_NET_ADDRESS
netmask $VM_NET_NETMASK

EOF

ifdown $EXT_NET_INTF_NAME && ifup $EXT_NET_INTF_NAME
ifdown $MGNT_NET_INTF_NAME && ifup $MGNT_NET_INTF_NAME
ifdown $VM_NET_INTF_NAME && ifup $VM_NET_INTF_NAME
