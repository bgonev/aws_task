class ntp {

  package { 'ntp':
    ensure => installed,
  }
  file { '/etc/ntp.conf':
    path    => '/etc/ntp.conf',
    ensure  => file,
    require => Package['ntp'],
    source  => 'puppet:///modules/ntp/ntp.conf',
  }
  service { 'ntp':
    name      => ntpd,
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/ntp.conf'],
  }
}
