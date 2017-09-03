#!/bin/bash
/sbin/parted -a optimal /dev/xvdf mklabel gpt
/sbin/parted -a optimal /dev/xvdf mkpart primary 0% 100%
/sbin/mkfs.ext4 /dev/xvdf1
/bin/mkdir /share
/bin/mount /dev/xvdf1 /share
/bin/mkdir /share/webshare

