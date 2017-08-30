#!/bin/bash
echo "create table mytable ( id MEDIUMINT NOT NULL AUTO_INCREMENT, firstname varchar (50) ,lastname varchar (50), PRIMARY KEY (id) );" | mysql -u test -pchangeme -h sql1 test
echo "insert into mytable (firstname,lastname) values ('Boris', 'Gonev');" | mysql -u test -pchangeme -h sql1 test
