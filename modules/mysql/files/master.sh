#!/bin/bash
echo "flush tables with read lock;" | mysql -uroot -pchangeme
sudo mkdir -p /mnt/tmp
sudo mount nfsserver:/webshare/tmp /mnt/tmp
echo "show master status;" | mysql -uroot -pchangeme -N > /mnt/tmp/position.log
mysqldump -u root -pchangeme --opt test > /mnt/tmp/test.sql
echo "unlock tables;" | mysql -uroot -pchangeme
sudo umount /mnt/tmp
