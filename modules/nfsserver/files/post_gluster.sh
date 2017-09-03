#!/bin/bash
/sbin/gluster peer probe nfsserver2
/sbin/gluster volume create webshare replica 2 nfsserver1:/share/webshare nfsserver2:/share/webshare
/sbin/gluster volume start webshare
yes | /sbin/gluster volume set webshare nfs.disable off
