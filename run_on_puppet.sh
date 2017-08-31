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
ssh -i ../to_aws/keys/$nfsserver2_pem -o StrictHostKeyChecking=no centos@$nfsserver1 $1
}

exe_s1 () {
ssh -i ../to_aws/keys/$sql1_pem -o StrictHostKeyChecking=no centos@$sql1 $1
}

exe_s2 () {
ssh -i ../to_aws/keys/$sql2_pem -o StrictHostKeyChecking=no centos@$sql2 $1
}


exe_hosts=("exe_w1" "exe_w2" "exe_n1" "exe_n2" "exe_s1" "exe_s2")

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
sudo sed -i 's/2g/512m/g' /etc/sysconfig/puppetserver /etc/sysconfig/puppetserver
sudo sed -i 's/-XX\:MaxPermSize\=256m//g' /etc/sysconfig/puppetserver /etc/sysconfig/puppetserver 

sudo systemctl start puppetserver
sudo systemctl enable puppetserver


## Copy files to appropriate destinations
sudo /usr/bin/cp -rf ./manifests /etc/puppetlabs/code/environments/production/
sudo /usr/bin/cp -rf ./modules /etc/puppetlabs/code/environments/production/
sudo /usr/bin/cp -rf ./environment.conf /etc/puppetlabs/code/environments/production/
sudo systemctl restart puppetserver

## Temporary enable root trough ssh

for host in "${exe_hosts[@]}"
do
$host "sudo -i cp -rf /root/.ssh/authorized_keys /root/.ssh/authorized_keys_orig"
$host "sudo -i cp -rf ~/.ssh/authorized_keys /root/.ssh/authorized_keys"

done

## Common copy for all hosts - /etc/hosts

for host in "${cpr_hosts[@]}"
do
$host "/etc/hosts" "/etc/hosts"
done

## Disable root trough ssh

for host in "${exe_hosts[@]}"
do
$host "sudo -i cp -rf /root/.ssh/authorized_keys_orig /root/.ssh/authorized_keys"

done


## configure hostnames to all aws machines
echo "Setting hostnamemes on servers..."
exe_w1 "sudo -i hostnamectl set-hostname $web1"
exe_w2 "sudo -i hostnamectl set-hostname $web2"
exe_n1 "sudo -i hostnamectl set-hostname $nfsserver1"
exe_n2 "sudo -i hostnamectl set-hostname $nfsserver2"
exe_s1 "sudo -i hostnamectl set-hostname $sql1"
exe_s2 "sudo -i hostnamectl set-hostname $sql2"


## Common commands for all hosts - Disable FW and SELinux

for host in "${exe_hosts[@]}"
do
echo "Start of $host.... - DEBUG"
$host "sudo  setenforce 0"
$host "sudo  sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config"
$host "sudo  systemctl disable firewalld"
$host "sudo  systemctl stop firewalld"
$host "sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm"
$host "sudo  yum -y install puppet-agent"
$host "sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true"

done


## Sign all cerificates on Puppet Master
sudo /opt/puppetlabs/bin/puppet cert sign --all


## Pull configs MUST IN THIS order
echo " *** Please Stand-By - Configuration is applying on each node - 10 minuter per node *** "
echo " *** GO dring a cofee, smoke a cigarete, or wach an epizode of GOT ;-) ***"
exe_n1 "/opt/puppetlabs/bin/puppet agent --test"
sleep 300
exe_s1 "/opt/puppetlabs/bin/puppet agent --test"
sleep 300
exe_s2 "/opt/puppetlabs/bin/puppet agent --test"
sleep 300
### execute replication configuration
exe_s1 "/tmp/master.sh"
sleep 30
exe_s2 "/tmp/slave.sh"
exe_w1 "/opt/puppetlabs/bin/puppet agent --test"
sleep 300
exe_w2 "/opt/puppetlabs/bin/puppet agent --test"
exe_w1 "/tmp/insert.sh"


