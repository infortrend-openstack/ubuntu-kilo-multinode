#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

############################################
echo "Please enter [compute-node] external network interface"
echo "ex: eth0"
read EXT_NET_INTF_NAME

echo "Please enter [compute-node] external network IP"
echo "ex: 172.27.117.103"
read EXT_NET_ADDRESS

echo "Please enter [compute-node] external network netmask"
echo "ex: 255.255.240.0"
read EXT_NET_NETMASK

echo "Please enter [compute-node] external network gateway"
echo "ex: 172.27.127.254"
read EXT_NET_GATEWAY

############################################
echo "Please enter [compute-node] management network interface"
echo "ex: eth1"
read MGNT_NET_INTF_NAME

echo "Please enter [compute-node] management network IP"
echo "ex: 20.20.20.3"
read MGNT_NET_ADDRESS

echo "Please enter [compute-node] management network netmask"
echo "ex: 255.255.255.0"
read MGNT_NET_NETMASK

############################################
echo "Please enter [compute-node] VM data network interface"
echo "ex: eth2"
read VM_NET_INTF_NAME

echo "Please enter [compute-node] VM data network IP"
echo "ex: 30.30.30.3"
read VM_NET_ADDRESS

echo "Please enter [compute-node] VM data network netmask"
echo "ex: 255.255.255.0"
read VM_NET_NETMASK

############################################
echo "Please enter [network-node] management network IP"
echo "ex: 20.20.20.1"
read NET_MGMT_ADDR

echo "Please enter [controller-node] management network IP"
echo "ex: 20.20.20.2"
read CTL_MGMT_ADDR

COM_MGMT_ADDR=$MGNT_NET_ADDRESS

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
