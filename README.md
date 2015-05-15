# ubuntu-kilo-multinode
Document for ubuntu multinode setup

This documents are based on 

http://docs.openstack.org/kilo/install-guide/install/apt/content/

http://docs.openstack.org/kilo/install-guide/install/apt/openstack-install-guide-apt-draft.pdf

Controller Node
===============
Prepare script repository::

  sudo su

  apt-get install -y git 

  git clone https://github.com/infortrend-openstack/ubuntu-kilo-multinode.git 

  cd ubuntu-kilo-multinode/


Check set-controller-node-ip.sh is correct::

  bash set-controller-node-ip.sh

Recheck ip is correct (ifconfig, /etc/hosts, /etc/network/interfaces)

Update cloudarchive package, this script will reboot after installed::

  bash update-cloudarchive-kilo.sh | tee log-update-cloudarchive-controller

go on install Controller node (RabbitMQ, DB, Keystone, ...)::

  bash install-controller-node.sh | tee log-install-controller-node

after set up 3 node completely, create networking::

  bash create-initial-network.sh


Network Node
============

prepare script repository::

  sudo su

  apt-get install -y git 

  git clone https://github.com/infortrend-openstack/ubuntu-kilo-multinode.git 

  cd ubuntu-kilo-multinode/

Check set-network-node-ip.sh is correct::

  bash set-network-node-ip.sh

Recheck ip is correct (ifconfig, /etc/hosts, /etc/network/interfaces)

update cloudarchive package, this script will reboot after installed::

  bash update-cloudarchive-kilo.sh | tee log-update-cloudarchive-network

go on install Network node (Neutron ...)::

  bash install-network-node.sh | tee log-install-network-node



Compute Node
============
prepare script repository::

  sudo su

  apt-get install -y git 

  git clone https://github.com/infortrend-openstack/ubuntu-kilo-multinode.git 

  cd ubuntu-kilo-multinode/

Check set-compute-node-ip.sh is correct::

  bash set-compute-node-ip.sh

Recheck ip is correct (ifconfig, /etc/hosts, /etc/network/interfaces)

Update cloudarchive package, this script will reboot after installed::

  bash update-cloudarchive-kilo.sh | tee log-update-cloudarchive-compute

go on install Compute node (Nova, Neutron ...)::

  bash install-compute-node.sh | tee log-install-compute-node

