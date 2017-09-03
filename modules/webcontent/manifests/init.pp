class webcontent {
  file { 'sites-available':
    path    => '/etc/nginx/sites-available',
    ensure  => 'directory',
    owner => 'root',
    group => 'root',
  }

file { 'sites-enabled':
    path    => '/etc/nginx/sites-enabled',
    ensure  => 'directory',
    owner => 'root',
    group => 'root',
  }

file { 'www.domain.com.conf':
    path    => '/etc/nginx/sites-available/www.domain.com.conf',
    ensure  => file,
#    require => file['/etc/nginx/sites-available'],
    source  => "puppet:///modules/webcontent/www.domain.com.conf"
  }
file { 'ssl.conf':
    path    => '/etc/nginx/sites-available/ssl.conf',
    ensure  => file,
 #   require => file['/etc/nginx/sites-available'],
    source  => "puppet:///modules/webcontent/ssl.conf"
  }

file { 'nginx.conf':
    path    => '/etc/nginx/nginx.conf',
    ensure  => file,
    source  => "puppet:///modules/webcontent/nginx.conf"
  }

exec {'available-http':
#   require => file['www.domain.com.conf'],
    command => '/usr/bin/ln -s /etc/nginx/sites-available/www.domain.com.conf /etc/nginx/sites-enabled/www.domain.com.conf',
    unless => '/usr/bin/test -f /etc/nginx/sites-available/www.domain.com.conf',
}

exec {'available-ssl':
#    require => file['ssl.conf'],
    command => '/usr/bin/ln -s /etc/nginx/sites-available/ssl.conf /etc/nginx/sites-enabled/ssl.conf',
    unless => '/usr/bin/test -f /etc/nginx/sites-available/ssl.conf'
}

file { 'webshare':
    path    => '/webshare',
    ensure  => 'directory',
    owner => 'root',
    group => 'root',
  }


if $hostname == 'web1.domain.com'  {
mount { "/webshare":
        device  => "nfsserver1:/webshare",
        fstype  => "nfs",
        ensure  => "mounted",
        options => "rw,nolock",
        atboot  => "true",
    }
} else {
mount { "/webshare":
        device  => "nfsserver2:/webshare",
        fstype  => "nfs",
        ensure  => "mounted",
        options => "rw,nolock",
        atboot  => "true",
    }
}


file { 'index.php':
    path    => '/webshare/www.domain.com/index.php',
    ensure  => 'file',
    owner => 'nginx',
    group => 'nginx',
    source => 'puppet:///modules/webcontent/index.php',
  }
file { 'me_and_max.jpg':
    path    => '/webshare/www.domain.com/me_and_max.jpg',
    ensure  => 'file',
    owner => 'nginx',
    group => 'nginx',
    source => 'puppet:///modules/webcontent/me_and_max.jpg',
  }
file { 'insert.sh':
    path    => '/tmp/insert.sh',
    ensure  => 'file',
    owner => 'root',
    group => 'root',
    mode => '0755',
    source => 'puppet:///modules/webcontent/insert.sh',
  }

file { '/etc/nginx/sites-enabled/www.domain.com.conf':
  ensure => link,
  target => '/etc/nginx/sites-available/www.domain.com.conf',
}

file { '/etc/nginx/sites-enabled/ssl.conf':
  ensure => link,
  target => '/etc/nginx/sites-available/ssl.conf',
}

exec {'restart':
command => '/sbin/service nginx restart'
}

}
