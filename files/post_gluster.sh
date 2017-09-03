#!/bin/bash
sudo gluster peer probe nfsserver2
sleep 10
sudo gluster volume create webshare replica 2 nfsserver1:/share/webshare nfsserver2:/share/webshare
sleep 30
sudo gluster volume start webshare
sleep 10
yes | sudo gluster volume set webshare nfs.disable off
