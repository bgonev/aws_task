class nginx {

group { 'nginx':
    ensure => 'present',
    gid => '503',
}

user { 'nginx':
    ensure => 'present',
    gid => '503',
    comment => 'nginx user',
    home => '/home/nginx',
    managehome => true
  }



package { 'nginx':
  require => Exec['yum-update'],
  ensure => installed,
}


service { 'nginx':
  ensure => running,
}

}
