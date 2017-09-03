#!/bin/bash
sudo yum -y install centos-release-gluster
sudo yum -y install glusterfs-server
sudo systemctl start glusterd
sudo systemctl enable glusterd

sudo /sbin/parted -a optimal /dev/xvdf mklabel gpt
sudo /sbin/parted -a optimal /dev/xvdf mkpart primary 0% 100%
sudo /sbin/mkfs.ext4 /dev/xvdf1
sudo /bin/mkdir /share
sudo /bin/mount /dev/xvdf1 /share
sudo /bin/mkdir /share/webshare
