#!/bin/bash
echo "slave stop;" | mysql -uroot -pchangeme
sudo mkdir -p /mnt/tmp
sudo mount nfsserver1:/webshare/tmp /mnt/tmp
logfile=`cat /mnt/tmp/position.log | awk '{print $1 }'`
logpos=`cat /mnt/tmp/position.log | awk '{print $2}'`
#echo $logfile
#echo $logpos
mysqldump -u root -pchangeme --opt test < /mnt/tmp/test.sql
echo "change master to master_host='sql1',master_user='slave_user',master_password='changeme',master_log_file='$logfile',master_log_pos=$logpos;" | mysql -uroot -pchangeme
echo "start slave;" | mysql -uroot -pchangeme
sudo umount /mnt/tmp

