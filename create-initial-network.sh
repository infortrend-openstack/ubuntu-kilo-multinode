#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

FLOATING_IP_START=172.27.120.200
FLOATING_IP_END=172.27.120.250
FLOATING_IP_CIDR=172.27.112.0/20
DNS_SERVER=192.168.99.16

echo "Enter Floating IP CIDR:(ex:172.27.112.0/20): "
read FLOATING_IP_CIDR
if [[ "$FLOATING_IP_CIDR" == "" ]]; then
    echo "Need to set floating IP CIDR!"
    exit 0
fi

echo "Enter Floating IP start:(ex:172.27.120.200): "
read FLOATING_IP_START
if [[ "$FLOATING_IP_START" == "" ]]; then
    echo "Need to set floating IP start!"
    exit 0
fi

echo "Enter Floating IP End:  (ex:172.27.120.250): "
read FLOATING_IP_END
if [[ "$FLOATING_IP_END" == "" ]]; then
    echo "Need to set floating IP end!"
    exit 0
fi

echo "Enter Floating IP Gateway:  (ex:172.27.127.254): "
read FLOATING_IP_GATEWAY
if [[ "$FLOATING_IP_GATEWAY" == "" ]]; then
    echo "Need to set floating IP gateway!"
    exit 0
fi

echo "Enter DNS:  (ex:192.168.99.16): "
read DNS_SERVER
if [[ "$DNS_SERVER" == "" ]]; then
    echo "Need to set DNS server!"
    exit 0
fi

echo "Start Create Virtual Network!"
sleep 3

source /root/admin-openrc
 
neutron net-create ext-net --router:external --provider:physical_network external --provider:network_type flat
neutron subnet-create ext-net $FLOATING_IP_CIDR --name ext-subnet --allocation-pool start=$FLOATING_IP_START,end=$FLOATING_IP_END --disable-dhcp --gateway $FLOATING_IP_GATEWAY --dns-nameserver $DNS_SERVER
neutron net-create private-net
neutron subnet-create private-net 100.100.100.0/24 --name private-subnet --gateway 100.100.100.1 --dns-nameserver $DNS_SERVER
neutron router-create admin-router
neutron router-interface-add admin-router private-subnet
neutron router-gateway-set admin-router ext-net

echo "wait 10 seconds to ping router!"
sleep 10

ping -c 4 $FLOATING_IP_START

echo "Please check network in dashboard is correct!"
