#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

PASSWORD=111111
CONFIG_DIR=network

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
service openvswitch-switch restart
sleep 3
ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex eth0
ethtool -K eth0 gro off
service neutron-plugin-openvswitch-agent restart
sleep 3
service neutron-l3-agent restart
sleep 3
service neutron-dhcp-agent restart
sleep 3
service neutron-metadata-agent restart
sleep 3

	
	