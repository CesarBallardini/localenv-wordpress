#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

export WP_DOMAIN=${1:-wpdev.virtual.ballardini.com.ar}
export WP_ADMIN_USERNAME=${2:-admin}
export WP_ADMIN_PASSWORD=${3:-admin}
export WP_ADMIN_EMAIL=${4:-no@spam.org}


source /vagrant/provision/vars.sh


instala_wordpress() {

  sudo rm -rf $WP_PATH/public/ # !!!
  sudo mkdir -p $WP_PATH/public/
  sudo chown -R $USER $WP_PATH/public/
  cd $WP_PATH/public/

  [ -f latest.tar.gz ] || wget https://wordpress.org/latest.tar.gz
  tar xf latest.tar.gz --strip-components=1
  #rm latest.tar.gz

  [ -f wp-config.php ] || cp wp-config-sample.php wp-config.php
  sed -i s/database_name_here/$WP_DB_NAME/ wp-config.php
  sed -i s/username_here/$WP_DB_USERNAME/ wp-config.php
  sed -i s/password_here/$WP_DB_PASSWORD/ wp-config.php
  echo "define('FS_METHOD', 'direct');" >> wp-config.php

  sudo chown -R www-data:www-data $WP_PATH/public/
}


configura_instalacion() {

  curl "http://$WP_DOMAIN/wp-admin/install.php?step=2" \
    --data-urlencode "weblog_title=$WP_DOMAIN"\
    --data-urlencode "user_name=$WP_ADMIN_USERNAME" \
    --data-urlencode "admin_email=$WP_ADMIN_EMAIL" \
    --data-urlencode "admin_password=$WP_ADMIN_PASSWORD" \
    --data-urlencode "admin_password2=$WP_ADMIN_PASSWORD" \
    --data-urlencode "pw_weak=1"
}


# https://make.wordpress.org/cli/handbook/guides/installing/
instala_wp_cli() {
  cd /tmp
  curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  sudo mv wp-cli.phar /usr/local/bin/wp

  wp --info

  wget https://github.com/wp-cli/wp-cli/raw/master/utils/wp-completion.bash

  sudo mkdir /usr/local/etc/bash_completion.d/
  sudo mv wp-completion.bash /usr/local/etc/bash_completion.d/

  echo "source /usr/local/etc/bash_completion.d/wp-completion.bash" | tee --append ~/.bash_profile

  source ~/.bash_profile

  WP_CLI_DIR=$(dirname $(echo $WP_PATH )/.wp-cli)
  sudo mkdir -p $WP_CLI_DIR/cache/
  sudo chown -R www-data:www-data $WP_CLI_DIR

}


## main
# https://peteris.rocks/blog/unattended-installation-of-wordpress-on-ubuntu-server/

instala_wordpress
configura_instalacion
instala_wp_cli
