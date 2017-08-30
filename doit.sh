#!/bin/bash
##Adresses
web1='web1.domain.com'
web2='web2.domain.com'
nfsserver='nfsserver.domain.com'
sql1='sql1.domain.com'
sql2='sql2.domain.com'

## Certificate files
web1_pem=root.$web1.pem
web2_pem=root.$web2.pem
nfsserver_pem=root.$nfsserver.pem
sql1_pem=root.$sql1.pem
sql2_pem=root.$sql2.pem


## Remote execution aliases

exe_w1 () {
ssh -i /home/puppet/files/aws_pem/$web1_pem $web1 $1
}

exe_w2 () {
ssh -i /home/puppet/files/aws_pem/$web2_pem $web2 $1
}

exe_n1 () {
ssh -i /home/puppet/files/aws_pem/$nfsserver1_pem $nfsserver $1
}

exe_s1 () {
ssh -i /home/puppet/files/aws_pem/$sql1_pem $sql1 $1
}

exe_s2 () {
ssh -i /home/puppet/files/aws_pem/$sql2_pem $sql2 $1
}


exe_hosts=("exe_w1" "exe_w2" "exe_n1" "exe_s1" "exe_s2")

## Remote copy aliases : Usage example cp_w1 /etc/hosts /etc/hosts

cp_w1 () {
scp -i /home/puppet/files/aws_pem/$web1_pem $1 $web1:$2
}

cp_w2 () {
scp -i /home/puppet/files/aws_pem/$web2_pem $1 $web2:$2
}

cp_n1 () {
scp -i /home/puppet/files/aws_pem/$nfsserver1_pem $1 $nfsserver:$2
}

cp_s1 () {
scp -i /home/puppet/files/aws_pem/$sql1_pem $1 $sql1:$2
}

cp_s2 () {
scp -i /home/puppet/files/aws_pem/$sql2_pem $1 $sql2:$2
}

cp_hosts=("cp_w1" "cp_w2" "cp_n1" "cp_s1" "cp_s2")




#Clone source files from Github repo 
git clone https://github.com/bgonev/neo.git
yum -y install ntp

## Install and configure ntp
/usr/bin -rf cp ./neo/files/files/allservers/ntp/ntp.conf /etc/ntp.conf
ntpdate pool.ntp.org
systemctl restart ntpd
systemctl enable ntpd

## Set hostname
hostnamectl set-hostname puppet.domain.com

## Disable SELinux and Firewall
echo 0 > /selinux/enforce
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
systemctl disable firewalld
systemctl stop firewalld

## install AWS CLI
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
~/.local/bin/pip install awscli --upgrade --user
/bin/cp -rf ~/.local/bin/* /usr/bin

## Install Puppet
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install puppetserver
sed -i 's/2g/1g/g' /etc/sysconfig/puppetserver /etc/sysconfig/puppetserver
systemctl start puppetserver
systemctl enable puppetserver


## Copy files to appropriate destinations
/usr/bin/cp -rf ./manifests /etc/puppetlabs/code/environments/production/
/usr/bin/cp -rf ./modules /etc/puppetlabs/code/environments/production/
/usr/bin/cp -rf ./environment.conf /etc/puppetlabs/code/environments/production/
systemctl restart puppetserver


## Create and configure AWS resources
#mkdir -p /home/puppet/aws_pem/
#
#Aws..
#Aws...
#Aws..


## Configure aws VPN
#Aws

## Configure Puppet VPN
#openvpn
#ipsec

## create hosts file for vpn network
echo dasdasdas >> \etc\hosts
scp \etc\hosts to_all_aws_machines

## configure hostnames to all aws machines
exe_w1 "hostnamectl set-hostname $web1"
exe_w2 "hostnamectl set-hostname $web2"
exe_n1 "hostnamectl set-hostname $nfsserver"
exe_s1 "hostnamectl set-hostname $sql1"
exe_s2 "hostnamectl set-hostname $sql2"


## Common commands for all hosts - Disable FW and SELinux

for host in "${exe_hosts[@]}"
do
$host "setenforce 0"
$host "sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config"
$host "systemctl disable firewalld"
$host "systemctl stop firewalld"
$host "rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm"
$host "yum -y install puppet-agent"
$host "/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true"

done

## Common copy for all hosts - /etc/hosts

for host in "${cp_hosts[@]}"
do
$host "/etc/hosts" "/etc/hosts"
done

## Sign all cerificates on Puppet Master
/opt/puppetlabs/bin/puppet cert sign --all


## Pull configs MUST IN THIS order
echo " *** Please Stand-By - Configuration is applying on each node - 10 minuter per node *** "
echo " *** GO dring a cofee, smoke a cigarete, or wach an epizode of GOT ;-) ***"
exe_n1 "/opt/puppetlabs/bin/puppet agent --test"
sleep 600
exe_s1 "/opt/puppetlabs/bin/puppet agent --test"
sleep 600
exe_s2 "/opt/puppetlabs/bin/puppet agent --test"
sleep 600
### execute replication configuration
exe_s1 "/tmp/master.sh"
sleep 30
exe_s2 "/tmp/slave.sh"
exe_w1 "/opt/puppetlabs/bin/puppet agent --test"
sleep 600
exe_w2 "/opt/puppetlabs/bin/puppet agent --test"
exe_w1 "/tmp/insert.sh"


