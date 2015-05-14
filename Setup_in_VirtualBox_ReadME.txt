* VM launch failed because of Libvirt CPU affinity error in ubuntu 
	=> workaround: 
		modify /nova/virt/libvirt/driver.py 
		-MIN_LIBVIRT_NUMA_VERSION = (1, 2, 7)
		+MIN_LIBVIRT_NUMA_VERSION = (1, 2, 99)
	ref: https://bugs.launchpad.net/ubuntu/+source/nova/+bug/1439280
	ref: http://libvirt.org/git/?p=libvirt.git;a=commitdiff;h=a103bb105c0c189c3973311ff1826972b5bc6ad6;hp=98780c6be69f290c2a4956dd7747d3000908c7cd

* VM launch success but encounter "This kernel requires an x86-64 CPU, but only detected an i686 CPU..."
	=> because VM in virtualbox can only run 32-bit OS, change image to 32-bit OS
	ex: 
		wget -P /tmp/images http://download.cirros-cloud.net/0.3.0/cirros-0.3.0-i386-disk.img
		mkdir /tmp/images
		glance image-create --name "cirros-0.3.0-i386" --file /tmp/images/cirros-0.3.0-i386-disk.img --disk-format qcow2 --container-format bare --visibility public --progress
	
