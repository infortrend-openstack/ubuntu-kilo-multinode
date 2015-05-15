#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

############################################
echo "Please enter [controller-node] external network interface"
echo "ex: eth0"
read EXT_NET_INTF_NAME

echo "Please enter [controller-node] external network IP"
echo "ex: 172.27.117.102"
read EXT_NET_ADDRESS

echo "Please enter [controller-node] external network netmask"
echo "ex: 255.255.240.0"
read EXT_NET_NETMASK

echo "Please enter [controller-node] external network gateway"
echo "ex: 172.27.127.254"
read EXT_NET_GATEWAY

############################################
echo "Please enter [controller-node] management network interface"
echo "ex: eth1"
read MGNT_NET_INTF_NAME

echo "Please enter [controller-node] management network IP"
echo "ex: 20.20.20.2"
read MGNT_NET_ADDRESS

echo "Please enter [controller-node] management network netmask"
echo "ex: 255.255.255.0"
read MGNT_NET_NETMASK

############################################
echo "Please enter [network-node] management network IP"
echo "ex: 20.20.20.1"
read NET_MGMT_ADDR

echo "Please enter [compute-node] management network IP"
echo "ex: 20.20.20.3"
read COM_MGMT_ADDR

CTL_MGMT_ADDR=$MGNT_NET_ADDRESS

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

EOF

ifdown $EXT_NET_INTF_NAME && ifup $EXT_NET_INTF_NAME
ifdown $MGNT_NET_INTF_NAME && ifup $MGNT_NET_INTF_NAME
