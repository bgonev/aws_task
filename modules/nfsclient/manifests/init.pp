class nfsclient {

exec { 'yum-update':
  command => '/usr/bin/yum -y update',
  timeout => 0,
}


package { "portmap":
	require => Exec['yum-update'],
        ensure => installed,
    }

package { "nfs-utils":
        require => Exec['yum-update'],
	ensure => installed,
    }

}
