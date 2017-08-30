class phpfpm {

exec { 'download-epel-repo':
  command => '/usr/bin/wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm',
  unless => '/usr/bin/test -f /etc/yum.repos.d/epel.repo',
}

exec { 'download-remi-repo':
  command => '/usr/bin/wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm',
  unless => '/usr/bin/test -f /etc/yum.repos.d/remi.repo',
}

exec { 'install-repos':
  command => '/usr/bin/rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm',
  unless => '/usr/bin/test -f /etc/yum.repos.d/remi.repo',
}

exec { 'enable-remis-repo':
  command => '/usr/bin/yum-config-manager --enable remi-php70',
  unless => '/usr/bin/test -f /etc/yum.repos.d/remi.repo',
}

exec { 'yum-update1':
  command => '/usr/bin/yum -y update',
  timeout => 1800,
}

package { 'php-fpm':
  require => Exec['yum-update1'],
  ensure => installed,
}

package { 'php-mysql':
  require => Exec['yum-update1'],
  ensure => installed,
}

service { 'php-fpm':
  ensure => running,
}
}
