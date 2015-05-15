#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

PASSWORD=111111
AUTH_TOKEN=7d26b49dd57e0d9ba420
CONFIG_DIR=controller

echo "Start to Install Database"
sleep 3
apt-get install -y mariadb-server python-mysqldb
cp /etc/mysql/my.cnf /etc/mysql/my.cnf~
sed -i 's/127.0.0.1/20.20.20.2/g' /etc/mysql/my.cnf
sed -i "/bind-address/a\default-storage-engine = innodb\n\
innodb_file_per_table\n\
collation-server = utf8_general_ci\n\
init-connect = 'SET NAMES utf8'\n\
character-set-server = utf8" /etc/mysql/my.cnf
service mysql restart
sleep 3
mysql_secure_installation 


echo "Start to Install RabbitMQ"
sleep 3
curl -O https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
apt-key add rabbitmq-signing-key-public.asc
echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list
apt-get update
apt-get install -y rabbitmq-server
rabbitmqctl add_user openstack $PASSWORD	
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

echo "Start to Install Keystone"
sleep 3
cat << EOF | mysql -uroot -p$PASSWORD
#
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$PASSWORD';
#
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$PASSWORD';
#
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$PASSWORD';
#
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$PASSWORD';
#
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$PASSWORD';
EOF

echo "manual" > /etc/init/keystone.override
apt-get install -y keystone python-openstackclient apache2 libapache2-mod-wsgi memcached python-memcache 
mv /etc/keystone/keystone.conf /etc/keystone/keystone.conf~
cp $CONFIG_DIR/keystone/keystone.conf /etc/keystone/
sed -i "s/111111/$PASSWORD/g" /etc/keystone/keystone.conf
su -s /bin/sh -c "keystone-manage db_sync" keystone
mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf~
cp $CONFIG_DIR/apache2/apache2.conf /etc/apache2/
cp $CONFIG_DIR/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-available/
rm /etc/apache2/sites-enabled/000-default.conf
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
mkdir -p /var/www/cgi-bin/keystone
curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin
chown -R keystone:keystone /var/www/cgi-bin/keystone
chmod 755 /var/www/cgi-bin/keystone/*
service apache2 restart
sleep 3
rm -f /var/lib/keystone/keystone.db
export OS_TOKEN=$AUTH_TOKEN
export OS_URL=http://controller:35357/v2.0
openstack service create --type identity --description "OpenStack Identity" keystone
openstack endpoint create --publicurl http://controller:5000/v2.0 --internalurl http://controller:5000/v2.0 --adminurl http://controller:35357/v2.0 --region RegionOne identity
openstack project create --description "Admin Project" admin
openstack user create --password $PASSWORD admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --description "Service Project" service
openstack project create --description "Demo Project" demo
openstack user create --password $PASSWORD demo
openstack role create _member_
openstack role add --project demo --user demo _member_
mv /etc/keystone/keystone-paste.ini /etc/keystone/keystone-paste.ini~
cp $CONFIG_DIR/keystone/keystone-paste.ini /etc/keystone/
unset OS_TOKEN OS_URL
cat << EOF > /root/admin-openrc.sh
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$PASSWORD
export OS_AUTH_URL=http://controller:35357/v3
EOF
cat << EOF > /root/demo-openrc.sh
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=demo
export OS_TENANT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$PASSWORD
export OS_AUTH_URL=http://controller:5000/v3
EOF
source /root/admin-openrc.sh
openstack token issue


echo "Start to Install Glance"
sleep 3
openstack user create --password $PASSWORD glance
openstack role add --project service --user glance admin
openstack service create --type image --description "OpenStack Image service" glance
openstack endpoint create --publicurl http://controller:9292 --internalurl http://controller:9292 --adminurl http://controller:9292 --region RegionOne image
apt-get install -y glance python-glanceclient
mv /etc/glance/glance-api.conf /etc/glance/glance-api.conf~
cp $CONFIG_DIR/glance/glance-api.conf /etc/glance
sed -i "s/111111/$PASSWORD/g" /etc/glance/glance-api.conf
mv /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf~
cp $CONFIG_DIR/glance/glance-registry.conf /etc/glance
sed -i "s/111111/$PASSWORD/g" /etc/glance/glance-registry.conf
su -s /bin/sh -c "glance-manage db_sync" glance
service glance-registry restart
sleep 3
service glance-api restart
sleep 3
rm -f /var/lib/glance/glance.sqlite
echo "export OS_IMAGE_API_VERSION=2" | tee -a /root/admin-openrc.sh /root/demo-openrc.sh
source /root/admin-openrc.sh
mkdir /tmp/images
wget -P /tmp/images http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img 
glance image-create --name "cirros-0.3.3-x86_64" --file /tmp/images/cirros-0.3.3-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility public --progress
glance image-list
rm -r /tmp/images


echo "Start to Install Nova"
sleep 3
openstack user create --password $PASSWORD nova
openstack role add --project service --user nova admin
openstack service create --type compute --description "OpenStack Compute" nova 
openstack endpoint create --publicurl http://controller:8774/v2/%\(tenant_id\)s --internalurl http://controller:8774/v2/%\(tenant_id\)s --adminurl http://controller:8774/v2/%\(tenant_id\)s --region RegionOne compute
apt-get install -y nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient
mv /etc/nova/nova.conf /etc/nova/nova.conf~
cp $CONFIG_DIR/nova/nova.conf /etc/nova
sed -i "s/111111/$PASSWORD/g" /etc/nova/nova.conf
su -s /bin/sh -c "nova-manage db sync" nova
service nova-api restart
sleep 3
service nova-cert restart
sleep 3
service nova-consoleauth restart
sleep 3
service nova-scheduler restart
sleep 3
service nova-conductor restart
sleep 3
service nova-novncproxy restart
sleep 3
rm -f /var/lib/nova/nova.sqlite
nova service-list
nova endpoints
nova image-list

echo "Start to Install Neutron"
sleep 3
openstack user create --password $PASSWORD neutron
openstack role add --project service --user neutron admin
openstack service create --type network --description "OpenStack Networking" neutron
openstack endpoint create --publicurl http://controller:9696 --adminurl http://controller:9696 --internalurl http://controller:9696 --region RegionOne network
apt-get install -y neutron-server neutron-plugin-ml2 python-neutronclient
mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf~
cp $CONFIG_DIR/neutron/neutron.conf /etc/neutron/
sed -i "s/111111/$PASSWORD/g" /etc/neutron/neutron.conf
mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini~
cp $CONFIG_DIR/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
service nova-api restart
sleep 3
service neutron-server restart
sleep 3 
neutron ext-list

echo "Start to Install DashBoard"
sleep 3
apt-get install -y openstack-dashboard
apt-get remove -y openstack-dashboard-ubuntu-theme
mv /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py~
cp $CONFIG_DIR/openstack-dashboard/local_settings.py /etc/openstack-dashboard
service apache2 reload
sleep 3

echo "Dashboard: http://controller/horizon"
echo "user admin or demo to test"

exit 0	
