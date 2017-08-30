class mysql::copyscripts {


file { 'master.sh':
    path    => '/tmp/master.sh',
    ensure  => file,
    source  => "puppet:///modules/mysql/master.sh",
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }

file { 'slave.sh':
    path    => '/tmp/slave.sh',
    ensure  => file,
    source  => "puppet:///modules/mysql/slave.sh",
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }

}
