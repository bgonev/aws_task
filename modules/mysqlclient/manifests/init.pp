class mysqlclient {

exec { 'mysql-repo':
  command => '/usr/bin/wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm',
  unless => '/usr/bin/test -f /etc/yum.repos.d/mysql-community.repo',
}

exec { 'install-mysql-repo':
  command => '/usr/bin/rpm -ivh mysql-community-release-el7-5.noarch.rpm',
unless => '/usr/bin/test -f /etc/yum.repos.d/mysql-community.repo',
}


exec { 'yum-update2':
  command => '/usr/bin/yum -y update',
  timeout => 1800,
}


package { 'mysql':
  ensure => installed,
}
}
