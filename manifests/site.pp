node default { }

node web1.domain.com {
include wget
include ntp
include nfsclient
include nginx
include phpfpm
include webcontent
include webcontent::ssl
include mysqlclient
}

node web2.domain.com {
include wget
include ntp
include nfsclient
include nginx
include phpfpm
include webcontent
include mysqlclient
}

node nfsserver1.domain.com {
include wget
include ntp
include nfsserver
}


node nfsserver2.domain.com {
include wget
include ntp
include nfsserver
}

node sql1.domain.com {
include wget
include ntp
include nfsclient
include mysql::mysqlmaster
include mysql::copyscripts
}

node sql2.domain.com {
include wget
include ntp
include nfsclient
include mysql::mysqlslave
include mysql::copyscripts
}
