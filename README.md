# ubuntu-kilo-multinode
Document for ubuntu multinode setup

This documents are based on 

http://docs.openstack.org/kilo/install-guide/install/apt/content/

http://docs.openstack.org/kilo/install-guide/install/apt/openstack-install-guide-apt-draft.pdf

Controller Node
===============
Prepare script repository:

	sudo su

	apt-get install -y git 

	git clone https://github.com/infortrend-openstack/ubuntu-kilo-multinode.git 

	cd ubuntu-kilo-multinode/


Check your network topology is right(see [topology](http://tinyurl.com/ldzgx28)), 

Use `ip addr` or `ifconfig` to check your network interface name

Execute setup IP script, it will ask your IP, enter the Mgmt net, Ext net, VM net related to 3 nodes

	bash set-controller-node-ip.sh

Recheck ip is correct (ifconfig, /etc/hosts, /etc/network/interfaces)

Update cloudarchive package, this script will reboot after installed:

	bash update-cloudarchive-kilo.sh | tee log-update-cloudarchive-controller

Go on install Controller node (RabbitMQ, DB, Keystone, ...):

	bash install-controller-node.sh | tee log-install-controller-node


Network Node
============

prepare script repository:

	sudo su

	apt-get install -y git 

	git clone https://github.com/infortrend-openstack/ubuntu-kilo-multinode.git 

	cd ubuntu-kilo-multinode/

Check your network topology is right(see [topology](http://tinyurl.com/ldzgx28)),

Use `ip addr` or `ifconfig` to check your network interface name

Execute setup IP script, it will ask your IP, enter the Mgmt net, Ext net, VM net related to 3 nodes

	bash set-network-node-ip.sh

Recheck ip is correct (ifconfig, /etc/hosts, /etc/network/interfaces)

Update cloudarchive package, this script will reboot after installed:

	bash update-cloudarchive-kilo.sh | tee log-update-cloudarchive-network

Go on install Network node (Neutron ...):

	bash install-network-node.sh | tee log-install-network-node


Compute Node
============
Prepare script repository:

	sudo su

	apt-get install -y git 

	git clone https://github.com/infortrend-openstack/ubuntu-kilo-multinode.git 

	cd ubuntu-kilo-multinode/

Check your network topology is right(see [topology](http://tinyurl.com/ldzgx28)),

Use `ip addr` or `ifconfig` to check your network interface name

Execute setup IP script, it will ask your IP, enter the Mgmt net, Ext net, VM net related to 3 nodes

	bash set-compute-node-ip.sh

Recheck ip is correct (ifconfig, /etc/hosts, /etc/network/interfaces)

Update cloudarchive package, this script will reboot after installed:

	bash update-cloudarchive-kilo.sh | tee log-update-cloudarchive-compute

Go on install Compute node (Nova, Neutron ...):

	bash install-compute-node.sh | tee log-install-compute-node


Next
====

After set up 3 node completely, reboot the 3 nodes

        reboot

Finally, create networking on controller node, or you can create by yourself :)

        bash create-initial-network.sh

You can launch VM instance now, have fun!

