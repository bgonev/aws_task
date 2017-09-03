#!/bin/bash
gluster peer probe nfsserver2
gluster volume create br0 webshare 2 nfsserver1:/share/webshare nfsserver2:/share/webshare
gluster volume start webshare
yes | gluster volume set br0 nfs.disable off
