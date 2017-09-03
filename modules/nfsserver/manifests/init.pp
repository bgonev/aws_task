class nfsserver {

exec { 'yum-update':
  command => '/usr/bin/yum -y update',
  timeout => 1800,
}

file { "/tmp/mount_disk.sh":
        ensure => present,
        owner => root,
        group => root,
        mode => '0755',
        source => 'puppet:///modules/nfsserver/mount_disk.sh'
}


file { "/tmp/post_gluster.sh":
        ensure => present,
        owner => root,
        group => root,
        mode => '0755',
        source => 'puppet:///modules/nfsserver/post_gluster.sh'
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
#package { "nfs-utils":
#        require => Exec['yum-update'],
#       ensure => absent,
#    }

#package { "centos-release-gluster":
#        require => Exec['yum-update'],
#        ensure => present,
#    }

#package { "glusterfs-server":
#        require => Exec['yum-update'],
#        ensure => present,
#    }


#service { "glusterd":
#        ensure => running,
#        enable => true,
#    }


#service { "rpcbind":
#        ensure => running,
#        enable => true,
#        require => [
#            Package["nfs-utils"],
#        ],
#    }

#service { "nfs-idmap":
#        ensure => running,
#        enable => true,
#        require => [
#            Package["nfs-utils"],
#        ],
#    }


#    service { "nfs-lock":
#        ensure => running,
#        enable => true,
#        require => [
#            Package["nfs-utils"],
#        ],
#    }

#    service { "nfs-server":
#        ensure => running,
#        enable => true,
#        require => Service["nfs-lock"],
#    }
#file { '/share/webshare':
#    ensure => 'directory',
#    owner  => 'root',
#    group  => 'root',
#    mode   => '0777',
#  }

file { '/share/webshare/tmp':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }


file { 'certs':
    path    => '/share/webshare/certs',
    ensure  => 'directory',
    owner => 'nginx',
    group => 'nginx',
  }

file { 'logs':
    path    => '/share/webshare/logs',
    ensure  => 'directory',
    owner => 'nginx',
    group => 'nginx',
  }

file { 'www.domain.com':
    path    => '/share/webshare/www.domain.com',
    ensure  => 'directory',
    owner => 'nginx',
    group => 'nginx',
  }

file { "/etc/exports":
        #notify => Service['nfs-server'],
        path => '/etc/exports',
        ensure => present,
        owner => root,
        group => root,
        source => 'puppet:///modules/nfsserver/exports'
}

}

