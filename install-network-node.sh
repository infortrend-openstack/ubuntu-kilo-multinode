#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

PASSWORD=111111
CONFIG_DIR=network

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


echo "Start to Install Neutron"
sleep 3
cp /etc/sysctl.conf /etc/sysctl.conf~
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
sysctl -p
apt-get install -y neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent
mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf~
cp $CONFIG_DIR/neutron/neutron.conf /etc/neutron
sed -i "s/111111/$PASSWORD/g" /etc/neutron/neutron.conf
mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini~
cp $CONFIG_DIR/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2
mv /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini~
cp $CONFIG_DIR/neutron/l3_agent.ini /etc/neutron
mv /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini~
cp $CONFIG_DIR/neutron/dhcp_agent.ini /etc/neutron
cp $CONFIG_DIR/neutron/dnsmasq-neutron.conf /etc/neutron
pkill dnsmasq
mv /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini~
cp $CONFIG_DIR/neutron/metadata_agent.ini /etc/neutron/
sed -i "s/111111/$PASSWORD/g" /etc/neutron/metadata_agent.ini

cp /etc/network/interfaces /etc/network/interfaces~~
cat << EOF > /etc/network/interfaces
# The loopback network interface
auto lo
iface lo inet loopback

## External net 
auto br-ex
iface br-ex inet static
address $EXT_NET_ADDRESS
netmask $EXT_NET_NETMASK
gateway $EXT_NET_GATEWAY
dns-nameservers 8.8.8.8

## External net 
auto $EXT_NET_INTF_NAME
iface $EXT_NET_INTF_NAME inet manual
   up ifconfig \$IFACE 0.0.0.0 up
   up ip link set \$IFACE promisc on
   down ip link set \$IFACE promisc off
   down ifconfig \$IFACE down

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

service openvswitch-switch restart
sleep 3
ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex $EXT_NET_INTF_NAME
ethtool -K $EXT_NET_INTF_NAME gro off

ifdown br-ex && ifup br-ex && ifdown $EXT_NET_INTF_NAME && ifup $EXT_NET_INTF_NAME

service neutron-plugin-openvswitch-agent restart
sleep 3
service neutron-l3-agent restart
sleep 3
service neutron-dhcp-agent restart
sleep 3
service neutron-metadata-agent restart
sleep 3

	
	
