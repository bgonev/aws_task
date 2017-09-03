#!/bin/bash
##Adresses
web1='web1.domain.com'
web2='web2.domain.com'
nfsserver1='nfsserver1.domain.com'
nfsserver2='nfsserver2.domain.com'
sql1='sql1.domain.com'
sql2='sql2.domain.com'

## Certificate files
web1_pem=web1.pem
web2_pem=web2.pem
nfsserver1_pem=nfsserver1.pem
nfsserver2_pem=nfsserver2.pem
sql1_pem=sql1.pem
sql2_pem=sql2.pem


echo " *****************************************************************************************"
echo " ***                                                                                  ****"
echo " ***                OK - We are on AWS - Let's deploy and configure the services !    ****"
echo " ***                                                                                  ****"
echo " *****************************************************************************************"
echo ""

cd ~/tmp/from_git/
chmod 400 ../to_aws/keys/*

## Remote execution aliases

exe_w1 () {
ssh -i ../to_aws/keys/$web1_pem -o StrictHostKeyChecking=no centos@$web1 $1
}
exe_w2 () {
ssh -i ../to_aws/keys/$web2_pem -o StrictHostKeyChecking=no centos@$web2 $1
}
exe_n1 () {
ssh -i ../to_aws/keys/$nfsserver1_pem -o StrictHostKeyChecking=no centos@$nfsserver1 $1
}
exe_n2 () {
ssh -i ../to_aws/keys/$nfsserver2_pem -o StrictHostKeyChecking=no centos@$nfsserver2 $1
}
exe_s1 () {
ssh -i ../to_aws/keys/$sql1_pem -o StrictHostKeyChecking=no centos@$sql1 $1
}
exe_s2 () {
ssh -i ../to_aws/keys/$sql2_pem -o StrictHostKeyChecking=no centos@$sql2 $1
}

exe_hosts=("exe_w1" "exe_w2" "exe_s1" "exe_s2" "exe_n1" "exe_n2")

## Remote execution aliases as root

exer_w1 () {
ssh -i ../to_aws/keys/$web1_pem -o StrictHostKeyChecking=no root@$web1 $1
}
exer_w2 () {
ssh -i ../to_aws/keys/$web2_pem -o StrictHostKeyChecking=no root@$web2 $1
}
exer_n1 () {
ssh -i ../to_aws/keys/$nfsserver1_pem -o StrictHostKeyChecking=no root@$nfsserver1 $1
}
exer_n2 () {
ssh -i ../to_aws/keys/$nfsserver2_pem -o StrictHostKeyChecking=no root@$nfsserver2 $1
}
exer_s1 () {
ssh -i ../to_aws/keys/$sql1_pem -o StrictHostKeyChecking=no root@$sql1 $1
}
exer_s2 () {
ssh -i ../to_aws/keys/$sql2_pem -o StrictHostKeyChecking=no root@$sql2 $1
}




exer_hosts=("exer_w1" "exer_w2" "exer_n1" "exer_n2" "exer_s1" "exer_s2")

## Remote copy aliases : Usage example cp_w1 /etc/hosts /etc/hosts

cp_w1 () {
scp -i ../to_aws/keys/$web1_pem $1 centos@$web1:$2
}
cp_w2 () {
scp -i ../to_aws/keys/$web2_pem $1 centos@$web2:$2
}
cp_n1 () {
scp -i ../to_aws/keys/$nfsserver1_pem $1 centos@$nfsserver1:$2
}
cp_n2 () {
scp -i ../to_aws/keys/$nfsserver2_pem $1 centos@$nfsserver2:$2
}
cp_s1 () {
scp -i ../to_aws/keys/$sql1_pem $1 centos@$sql1:$2
}
cp_s2 () {
scp -i ../to_aws/keys/$sql2_pem $1 centos@$sql2:$2
}

cp_hosts=("cp_w1" "cp_w2" "cp_n1" "cp_n2" "cp_s1" "cp_s2")



## Remote copy aliases AS ROOT : Usage example cp_w1 /etc/hosts /etc/hosts

cpr_w1 () {
scp -i ../to_aws/keys/$web1_pem $1 root@$web1:$2
}
cpr_w2 () {
scp -i ../to_aws/keys/$web2_pem $1 root@$web2:$2
}
cpr_n1 () {
scp -i ../to_aws/keys/$nfsserver1_pem $1 root@$nfsserver1:$2
}
cpr_n2 () {
scp -i ../to_aws/keys/$nfsserver2_pem $1 root@$nfsserver2:$2
}
cpr_s1 () {
scp -i ../to_aws/keys/$sql1_pem $1 root@$sql1:$2
}
cpr_s2 () {
scp -i ../to_aws/keys/$sql2_pem $1 root@$sql2:$2
}

cpr_hosts=("cpr_w1" "cpr_w2" "cpr_n1" "cpr_n2" "cpr_s1" "cpr_s2")

## Install dig
sudo yum -y install bind-utils

## Install ntp
sudo yum -y install ntp
sudo /usr/sbin/ntpdate pool.ntp.org
sudo systemctl restart ntpd
sudo systemctl enable ntpd

## Set hostname
#hostnamectl set-hostname puppet.domain.com

## Disable SELinux and Firewall
sudo setenforce 0
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
sudo systemctl disable firewalld
sudo systemctl stop firewalld

## Install Puppet
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppetserver
#sudo sed -i 's/2g/512m/g' /etc/sysconfig/puppetserver /etc/sysconfig/puppetserver
sudo sed -i 's/-XX\:MaxPermSize\=256m//g' /etc/sysconfig/puppetserver /etc/sysconfig/puppetserver 

sudo systemctl enable puppetserver

## Copy files to appropriate destinations
sudo /usr/bin/cp -rf ./manifests /etc/puppetlabs/code/environments/production/
sudo /usr/bin/cp -rf ./modules /etc/puppetlabs/code/environments/production/
sudo /usr/bin/cp -rf ./environment.conf /etc/puppetlabs/code/environments/production/
sudo systemctl stop puppetserver
sudo systemctl start puppetserver

## It is t2.micro, too lesss RAM so we must wait for puppetserver service to be started

while [ "$status" != "active" ]
do
echo "Waiting for puppet server to be ACTIVE"
status=`sudo systemctl status puppetserver | grep Active: | awk '{print $2}'`
sleep 5
done
echo "OK - We got status: Active - let's continue.."


## Temporary enable root trough ssh

for host in "${exe_hosts[@]}"
do
$host "sudo -i cp -rf /root/.ssh/authorized_keys /root/.ssh/authorized_keys_orig"
$host "sudo -i cp -rf ~/.ssh/authorized_keys /root/.ssh/authorized_keys"

done


## Common copy for all hosts - /etc/hosts

echo "Distribute /etc/hosts to all hosts..."
for host in "${cpr_hosts[@]}"
do
$host "/etc/hosts" "/etc/hosts"
done


## configure hostnames to all aws machines
echo "Setting hostnames on servers..."
exer_w1 "echo 'preserve_hostname: true' >> /etc/cloud/cloud.cfg"
exer_w1 "hostnamectl set-hostname $web1"
exer_w2 "echo 'preserve_hostname: true' >> /etc/cloud/cloud.cfg"
exer_w2 "hostnamectl set-hostname $web2"
exer_n1 "echo 'preserve_hostname: true' >> /etc/cloud/cloud.cfg"
exer_n1 "hostnamectl set-hostname $nfsserver1"
exer_n2 "echo 'preserve_hostname: true' >> /etc/cloud/cloud.cfg"
exer_n2 "hostnamectl set-hostname $nfsserver2"
exer_s1 "echo 'preserve_hostname: true' >> /etc/cloud/cloud.cfg"
exer_s1 "hostnamectl set-hostname $sql1"
exer_s2 "echo 'preserve_hostname: true' >> /etc/cloud/cloud.cfg"
exer_s2 "hostnamectl set-hostname $sql2"

## Disable root trough ssh

for host in "${exe_hosts[@]}"
do
$host "sudo -i cp -rf /root/.ssh/authorized_keys_orig /root/.ssh/authorized_keys"

done


## Common commands for all hosts - Disable FW and SELinux

for host in "${exe_hosts[@]}"
do
$host "sudo  setenforce 0"
$host "sudo  sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config"
$host "sudo  systemctl disable firewalld"
$host "sudo  systemctl stop firewalld"
$host "sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm"
$host "sudo  yum -y install puppet-agent"
$host "sudo  systemctl restart puppet"
$host "sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true"

done


## Sign all cerificates on Puppet Master

sudo /opt/puppetlabs/bin/puppet cert sign --all


## Pull configs MUST IN THIS order
echo " *****************************************************************************************"
echo " *   Please Stand-By - Configuration is applying on each node - cca 4 minuter per node   *"
echo " *   GO dring a cofee, smoke a cigarete, or wach an episode of GoT ;-)                   *"
echo " *****************************************************************************************"
echo ""
echo "Configuring Node1 for NFS server part..."
cp_n1 "./files/mount_disk.sh" "~/"
cp_n1 "./files/post_gluster.sh" "~/"
cp_n2 "./files/mount_disk.sh" "~/"
exe_n1 "sudo ~/mount_disk.sh"
exe_n2 "sudo ~/mount_disk.sh"
exe_n1 "sudo ~/post_gluster.sh"
exe_n1 "sudo /opt/puppetlabs/bin/puppet agent --test"
sleep 120
echo "Configuring Node2 for NFS server part..."
exe_n2 "sudo /opt/puppetlabs/bin/puppet agent --test"
sleep 120
sleep 10
echo "Configuring Master for SQL server part..."
exe_s1 "sudo /opt/puppetlabs/bin/puppet agent --test"
sleep 120
echo "Configuring Slave for SQL server part..."
exe_s2 "sudo /opt/puppetlabs/bin/puppet agent --test"
sleep 120
### execute replication configuration
exe_s1 "/tmp/master.sh"
sleep 30
exe_s2 "/tmp/slave.sh"
sleep 120
echo "Configuring Node1 for Web server part..."
exe_w1 "sudo /opt/puppetlabs/bin/puppet agent --test"
sleep 120
echo "Configuring Node2 for Web server part..."
exe_w2 "sudo /opt/puppetlabs/bin/puppet agent --test"
exe_w1 "/tmp/insert.sh"
echo "*****End.******"

