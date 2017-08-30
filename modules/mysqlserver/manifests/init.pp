class mysqlserver {

exec { 'mysql-repo':
  command => '/usr/bin/wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm'
}

exec { 'install-mysql-repo':
  command => '/usr/bin/rpm -ivh mysql-community-release-el7-5.noarch.rpm'
}


exec { 'yum-update':
  command => '/usr/bin/yum -y update',
  timeout => 1800,
}


package { 'mysql-server':
  require => Exec['yum-update'],
  ensure => installed,
}

service { 'mysql':
  ensure => running,
}


file { 'secure-it.sh':
    path    => '/tmp/secure-it.sh',
    ensure  => file,
    require => Package['mysql-server'],
    source  => "puppet:///modules/mysqlserver/secure-it.sh",
    owner => 'root',
    group => 'root',
    mode  => '0755',
    notify => Exec['run_script'],
  }


exec { 'run_script':
  command => '/tmp/secure-it.sh',
  refreshonly => true
  }
}
