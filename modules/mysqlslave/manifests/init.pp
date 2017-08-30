class mysql::mysqlslave {
	class { 'mysql::server':
	root_password    => 'changeme',
	override_options => {
	  'mysqld' => {
		'bind_address'                   => '0.0.0.0',
		'server-id'                      => '2',
		'binlog-format'                  => 'mixed',
		'log-bin'                        => 'mysql-bin',
		'datadir'                        => '/var/lib/mysql',
		'innodb_flush_log_at_trx_commit' => '1',
		'sync_binlog'                    => '1',
		'binlog-do-db'                   => ['test'],
	  },
	}
}

mysql::db { 'test':
	ensure   => 'present',
	user     => 'test',
	password => 'changeme',
	host     => '%',
	grant    => ['all'],
  }

}
