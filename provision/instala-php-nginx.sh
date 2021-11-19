#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

export WP_DOMAIN=${1:-wpdev.virtual.ballardini.com.ar}
export WP_ADMIN_USERNAME=${2:-admin}
export WP_ADMIN_PASSWORD=${3:-admin}
export WP_ADMIN_EMAIL=${4:-no@spam.org}

source /vagrant/provision/vars.sh

instala_paquetes() {

  sudo apt-get remove --purge libapache2-mod-php apache2 apache2-data apache2-utils ${APT_OPTIONS}
  sudo apt-get install nginx php php-mysql php-curl php-gd php-fpm apache2- ${APT_OPTIONS}
  sudo apt-get install letsencrypt ${APT_OPTIONS}
}


configura_nginx_no_ssl() {

  sudo mkdir -p $WP_PATH/public $WP_PATH/logs

  sudo tee /etc/nginx/sites-available/$WP_DOMAIN <<EOF
server {
  listen 80;
  server_name $WP_DOMAIN www.$WP_DOMAIN;

  root $WP_PATH/public;
  index index.php;

  access_log /var/log/nginx/${DOMAIN}-access.log;
  error_log  /var/log/nginx/${DOMAIN}-error.log;

  location / {
    try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ \.php\$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
  }
}
EOF

  [ -L /etc/nginx/sites-enabled/$WP_DOMAIN ] || sudo ln -s /etc/nginx/sites-available/$WP_DOMAIN /etc/nginx/sites-enabled/$WP_DOMAIN
  [ -L /etc/nginx/sites-enabled/${WP_DOMAIN}-selfsigned  ] && sudo rm -f /etc/nginx/sites-enabled/${WP_DOMAIN}-selfsigned
  [ -L /etc/nginx/sites-enabled/${WP_DOMAIN}-letsencrypt ] && sudo rm -f /etc/nginx/sites-enabled/${WP_DOMAIN}-letsencript

  sudo systemctl restart nginx
  sudo systemctl status nginx.service
}


configura_nginx_ssl_selfsigned() {

  sudo apt-get install openssl ${APT_OPTIONS}


  # Country Name (2 letter code) [AU]:AR
  # State or Province Name (full name) [Some-State]:Santa Fe
  # Locality Name (eg, city) []:Santa Fe
  # Organization Name (eg, company) [Internet Widgits Pty Ltd]:Gnandu Systems
  # Organizational Unit Name (eg, section) []:Sysadmin Services
  # Common Name (e.g. server FQDN or YOUR name) []:wpdev.virtual.ballardini.com.ar
  # Email Address []:sysadmin@wpdev.virtual.ballardini.com.ar

  if [ ! -f /etc/ssl/private/${WP_DOMAIN}-selfsigned.key ]
  then
      echo -e "AR\nSanta Fe\nSanta Fe\nGnandu Systems\nSysadmin Services\n${WP_DOMAIN}\nsysadmin@${WP_DOMAIN}" \
           | sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	                  -keyout /etc/ssl/private/${WP_DOMAIN}-selfsigned.key \
			  -out /etc/ssl/certs/${WP_DOMAIN}-selfsigned.crt
  fi

  # create a strong Diffie-Hellman (DH) group, which is used in negotiating Perfect Forward Secrecy with clients
  # tarda en el orden de 55 minutos en ejecutarse, solo usar para sitios en produccion
  # FIXME: usar algun generador de entropia como en https://www.cyberciti.biz/open-source/debian-ubuntu-centos-linux-setup-additional-entropy-for-server-using-aveged-rng-tools-utils/
  #[ -f /etc/nginx/dhparam.pem ] || sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096

  # tarda menos pero es menos seguro, ver: https://security.stackexchange.com/a/95184
  [ -f /etc/nginx/dhparam.pem ] || sudo openssl dhparam -dsaparam -out /etc/nginx/dhparam.pem 4096

  # verificamos el certificado:
  sudo openssl x509 -text -noout -in /etc/ssl/certs/nginx-selfsigned.crt


  sudo tee /etc/nginx/snippets/${WP_DOMAIN}-selfsigned.conf <<EOF
ssl_certificate     /etc/ssl/certs/${WP_DOMAIN}-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/${WP_DOMAIN}-selfsigned.key;
ssl_dhparam         /etc/nginx/dhparam.pem;
EOF

  sudo tee  /etc/nginx/snippets/ssl-params-strict.conf <<EOF
ssl_protocols TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers EECDH+AESGCM:EDH+AESGCM;
ssl_ecdh_curve secp384r1;
ssl_session_timeout  10m;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable strict transport security for now. You can uncomment the following
# line if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";

EOF


  sudo tee  /etc/nginx/snippets/ssl-params-relaxed.conf <<EOF
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
ssl_prefer_server_ciphers on;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.4.4 8.8.8.8 valid=300s;
resolver_timeout 10s;

add_header Strict-Transport-Security max-age=15552000;

EOF



  sudo tee /etc/nginx/sites-available/${WP_DOMAIN}-selfsigned <<EOF

server {
  listen 80;
  server_name $WP_DOMAIN www.$WP_DOMAIN;
  return 301 https://\$server_name\$request_uri;
}

server {
  listen 443 ssl http2;
  #listen [::]:443 ssl;

  include snippets/${WP_DOMAIN}-selfsigned.conf;
  include snippets/ssl-params-strict.conf;
  #include snippets/ssl-params-relaxed.conf

  server_name $WP_DOMAIN www.$WP_DOMAIN;

  root $WP_PATH/public;
  index index.php;

  access_log /var/log/nginx/${DOMAIN}-access.log;
  error_log  /var/log/nginx/${DOMAIN}-error.log;

  location / {
    try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ \.php\$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
  }
}
EOF

  [ -L /etc/nginx/sites-enabled/${WP_DOMAIN}-selfsigned ] || sudo ln -s /etc/nginx/sites-available/${WP_DOMAIN}-selfsigned /etc/nginx/sites-enabled/${WP_DOMAIN}-selfsigned
  [ -L /etc/nginx/sites-enabled/${WP_DOMAIN} ] && sudo rm -f /etc/nginx/sites-enabled/${WP_DOMAIN}
  [ -L /etc/nginx/sites-enabled/${WP_DOMAIN}-letsencrypt ] && sudo rm -f /etc/nginx/sites-enabled/${WP_DOMAIN}-letsencript

  sudo systemctl restart nginx
  sudo systemctl status nginx.service
}



configura_nginx_ssl_letsencrypt() {

  sudo tee /etc/nginx/sites-available/$WP_DOMAIN <<EOF
server {
  listen 80;
  server_name $WP_DOMAIN www.$WP_DOMAIN;
  return 301 https://\$server_name\$request_uri;
}

server {
  listen 443 ssl http2;
  server_name $WP_DOMAIN www.$WP_DOMAIN;

  root $WP_PATH/public;
  index index.php;

  access_log /var/log/nginx/${DOMAIN}-access.log;
  error_log  /var/log/nginx/${DOMAIN}-error.log;

  ssl_certificate           /etc/letsencrypt/live/$WP_DOMAIN/fullchain.pem;
  ssl_certificate_key       /etc/letsencrypt/live/$WP_DOMAIN/privkey.pem;
  ssl_trusted_certificate   /etc/letsencrypt/live/$WP_DOMAIN/chain.pem;
  ssl_dhparam               /etc/letsencrypt/live/$WP_DOMAIN/dhparam.pem;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
  ssl_prefer_server_ciphers on;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 8.8.4.4 8.8.8.8 valid=300s;
  resolver_timeout 10s;

  add_header Strict-Transport-Security max-age=15552000;

  location / {
    try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ \.php\$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
  }
}
EOF

  [ -L /etc/nginx/sites-enabled/$WP_DOMAIN ] || sudo ln -s /etc/nginx/sites-available/$WP_DOMAIN /etc/nginx/sites-enabled/$WP_DOMAIN

  sudo systemctl restart nginx
  sudo systemctl status nginx.service
}


crea_certificado_letsencrypt() {
  sudo mkdir -p $WP_PATH
  sudo letsencrypt certonly -n --agree-tos --webroot -w $WP_PATH -d $WP_DOMAIN -d www.$WP_DOMAIN -d m.$WP_DOMAIN -m $WP_ADMIN_EMAIL
  sudo openssl dhparam -out /etc/letsencrypt/live/$WP_DOMAIN/dhparam.pem 2048

  # TODO: Make sure that the certificates never expire by periodically renewing them.

}


asegura_certificado_no_se_vence() {

  sudo tee /etc/cron.daily/letsencrypt <<EOF
letsencrypt renew --agree-tos && systemctl restart nginx
EOF

  sudo chmod +x /etc/cron.daily/letsencrypt
}


instala_no_ssl() {
  instala_paquetes
  configura_nginx_no_ssl
  sudo service php7.4-fpm restart
}


instala_ssl_selfsigned() {
  instala_paquetes
  configura_nginx_ssl_selfsigned
  sudo service php7.4-fpm restart
}


instala_ssl_letsencrypt() {
  instala_paquetes
  #configura_nginx_ssl_letsencrypt
  #asegura_certificado_no_se_vence
  sudo service php7.4-fpm restart
}

##
# main
#

#instala_no_ssl
instala_ssl_selfsigned
#instala_ssl_letsencrypt


