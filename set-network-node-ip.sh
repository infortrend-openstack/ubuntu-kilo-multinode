#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

############################################
echo "Please enter [network-node] external network interface"
echo "ex: eth0"
read EXT_NET_INTF_NAME
echo "EXT_NET_INTF_NAME=$EXT_NET_INTF_NAME" >> networkrc

echo "Please enter [network-node] external network IP"
echo "ex: 172.27.117.101"
read EXT_NET_ADDRESS
echo "EXT_NET_ADDRESS=$EXT_NET_ADDRESS" >> networkrc

echo "Please enter [network-node] external network netmask"
echo "ex: 255.255.240.0"
read EXT_NET_NETMASK
echo "EXT_NET_NETMASK=$EXT_NET_NETMASK" >> networkrc

echo "Please enter [network-node] external network gateway"
echo "ex: 172.27.127.254"
read EXT_NET_GATEWAY
echo "EXT_NET_GATEWAY=$EXT_NET_GATEWAY" >> networkrc

############################################
echo "Please enter [network-node] management network interface"
echo "ex: eth1"
read MGNT_NET_INTF_NAME
echo "MGNT_NET_INTF_NAME=$MGNT_NET_INTF_NAME" >> networkrc

echo "Please enter [network-node] management network IP"
echo "ex: 20.20.20.1"
read MGNT_NET_ADDRESS
echo "MGNT_NET_ADDRESS=$MGNT_NET_ADDRESS" >> networkrc

echo "Please enter [network-node] management network netmask"
echo "ex: 255.255.255.0"
read MGNT_NET_NETMASK
echo "MGNT_NET_NETMASK=$MGNT_NET_NETMASK" >> networkrc

############################################
echo "Please enter [network-node] VM data network interface"
echo "ex: eth2"
read VM_NET_INTF_NAME
echo "VM_NET_INTF_NAME=$VM_NET_INTF_NAME" >> networkrc

echo "Please enter [network-node] VM data network IP"
echo "ex: 30.30.30.1"
read VM_NET_ADDRESS
echo "VM_NET_ADDRESS=$VM_NET_ADDRESS" >> networkrc

echo "Please enter [network-node] VM data network netmask"
echo "ex: 255.255.255.0"
read VM_NET_NETMASK
echo "VM_NET_NETMASK=$VM_NET_NETMASK" >> networkrc

############################################
echo "Please enter [controller-node] management network IP"
echo "ex: 20.20.20.2"
read CTL_MGMT_ADDR
echo "CTL_MGMT_ADDR=$CTL_MGMT_ADDR" >> networkrc

echo "Please enter [compute-node] management network IP"
echo "ex: 20.20.20.3"
read COM_MGMT_ADDR
echo "COM_MGMT_ADDR=$COM_MGMT_ADDR" >> networkrc

NET_MGMT_ADDR=$MGNT_NET_ADDRESS
echo "NET_MGMT_ADDR=$NET_MGMT_ADDR" >> networkrc

cp /etc/hosts /etc/hosts~
sed -i "s/127.0.1.1/#127.0.1.1/g" /etc/hosts
echo "$NET_MGMT_ADDR      network" >> /etc/hosts
echo "$CTL_MGMT_ADDR      controller" >> /etc/hosts
echo "$COM_MGMT_ADDR      compute" >> /etc/hosts

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
