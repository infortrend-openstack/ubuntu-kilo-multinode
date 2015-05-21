#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

PASSWORD=111111
CONFIG_DIR=compute

echo "Start to Install Nova"
sleep 3
apt-get install -y nova-compute sysfsutils
mv /etc/nova/nova.conf /etc/nova/nova.conf~
cp $CONFIG_DIR/nova/nova.conf /etc/nova
sed -i "s/111111/$PASSWORD/g" /etc/nova/nova.conf
service nova-compute restart
sleep 3
rm -f /var/lib/nova/nova.sqlite
	

echo "Start to Install Neutron"
sleep 3
cp /etc/sysctl.conf /etc/sysctl.conf~
echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
sysctl -p
apt-get install -y neutron-plugin-ml2 neutron-plugin-openvswitch-agent
mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf~
cp $CONFIG_DIR/neutron/neutron.conf /etc/neutron
mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
cp $CONFIG_DIR/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2
service openvswitch-switch restart
sleep 3
service nova-compute restart
sleep 3
service neutron-plugin-openvswitch-agent restart
sleep 3


echo "Start to Install Cinder"
sleep 3
apt-get install -y cinder-volume python-mysqldb
mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf~
cp $CONFIG_DIR/cinder/cinder.conf /etc/cinder
service tgt restart
service cinder-volume restart
rm -f /var/lib/cinder/cinder.sqlite

echo "Start to Install infortrend related packages"
sleep 3
add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install -y oracle-java7-installer  
wget https://github.com/infortrend-openstack/eonstor-ds-cinder-driver/releases/download/v1.0.0-dvt-0.4.0/raidcmd_ESDS10.jar
mkdir -p /opt/bin/Infortrend/
mv raidcmd_ESDS10.jar /opt/bin/Infortrend
apt-get install -y multipath-tools

exit 0
