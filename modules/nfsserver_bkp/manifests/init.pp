class nfsserver {

exec { 'yum-update':
  command => '/usr/bin/yum -y update',
  timeout => 1800,
}

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

package { "nfs-utils":
        require => Exec['yum-update'],
	ensure => installed,
    }

service { "rpcbind":
        ensure => running,
        enable => true,
        require => [
            Package["nfs-utils"],
        ],
    }

service { "nfs-idmap":
        ensure => running,
        enable => true,
        require => [
            Package["nfs-utils"],
        ],
    }


    service { "nfs-lock":
        ensure => running,
        enable => true,
        require => [
            Package["nfs-utils"],
        ],
    }

    service { "nfs-server":
        ensure => running,
        enable => true,
        require => Service["nfs-lock"],
    }

file { '/webshare':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }

file { '/webshare/tmp':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }


file { 'certs':
    path    => '/webshare/certs',
    ensure  => 'directory',
    owner => 'nginx',
    group => 'nginx',
  }

file { 'logs':
    path    => '/webshare/logs',
    ensure  => 'directory',
    owner => 'nginx',
    group => 'nginx',
  }

file { 'www.domain.com':
    path    => '/webshare/www.domain.com',
    ensure  => 'directory',
    owner => 'nginx',
    group => 'nginx',
  }


file { "/etc/exports":
        notify => Service['nfs-server'],
	path => '/etc/exports',
        ensure => present,
        owner => root,
        group => root,
        source => 'puppet:///modules/nfsserver/exports'
}

}
