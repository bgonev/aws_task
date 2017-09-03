#!/bin/bash
sudo gluster peer probe nfsserver2
sleep 10
sudo gluster volume create br0 webshare 2 nfsserver1:/share/webshare nfsserver2:/share/webshare
sudo gluster volume start webshare
sudo yes | gluster volume set br0 nfs.disable off
