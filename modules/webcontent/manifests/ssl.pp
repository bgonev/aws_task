class webcontent::ssl {

exec {'create_cert_1':
command => '/usr/bin/openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /webshare/certs/nginx-selfsigned.key -out /webshare/certs/nginx-selfsigned.crt -subj "/CN=domain.com"',
unless => '/usr/bin/test -f /webshare/certs/nginx-selfsigned.key',
}

exec {'create_cert_2':
command => '/usr/bin/openssl dhparam -out /webshare/certs/dhparam.pem 2048',
unless => '/usr/bin/test -f /webshare/certs/dhparam.pem',
}

}
