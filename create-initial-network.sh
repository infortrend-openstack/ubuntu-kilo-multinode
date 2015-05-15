#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

FLOATING_IP_START=172.27.120.200
FLOATING_IP_END=172.27.120.250

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


echo "Start Create Virtual Network!"
sleep 3

source /root/admin-openrc.sh
 
neutron net-create ext-net --router:external --provider:physical_network external --provider:network_type flat
neutron subnet-create ext-net 172.27.112.0/20 --name ext-subnet --allocation-pool start=$FLOATING_IP_START,end=$FLOATING_IP_END --disable-dhcp --gateway 172.27.127.254 --dns-nameserver 8.8.8.8
neutron net-create private-net
neutron subnet-create private-net 10.10.10.0/24 --name private-subnet --gateway 10.10.10.1 --dns-nameserver 8.8.8.8
neutron router-create admin-router
neutron router-interface-add admin-router private-subnet
neutron router-gateway-set admin-router ext-net
ping -c 4 $FLOATING_IP_START

echo "Please check network in dashboard is correct!"