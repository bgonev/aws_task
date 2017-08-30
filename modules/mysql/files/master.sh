#!/bin/bash
echo "flush tables with read lock;" | mysql -uroot -pchangeme
mkdir -p /mnt/tmp
mount nfsserver:/webshare/tmp /mnt/tmp
echo "show master status;" | mysql -uroot -pchangeme -N > /mnt/tmp/position.log
mysqldump -u root -pchangeme --opt test > /mnt/tmp/test.sql
echo "unlock tables;" | mysql -uroot -pchangeme
umount /mnt/tmp
