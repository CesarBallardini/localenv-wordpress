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

  if [ -z "${WORDPRESS_VERSION}" -o "${WORDPRESS_VERSION}" = "latest" ]
  then
    WORDPRESS_FILENAME=latest.tar.gz
  else
    WORDPRESS_FILENAME="wordpress-${WORDPRESS_VERSION}.tar.gz"
  fi
  WORDPRESS_URL="https://wordpress.org/${WORDPRESS_FILENAME}"

  sudo rm -rf $WP_PATH/public/ # !!!
  sudo mkdir -p $WP_PATH/public/
  sudo chown -R $USER $WP_PATH/public/
  cd $WP_PATH/public/

  # https://wordpress.org/download/releases/
  [ -f "${WORDPRESS_FILENAME}" ] || wget "${WORDPRESS_URL}"
  tar xf "${WORDPRESS_FILENAME}" --strip-components=1
  #rm -f "${WORDPRESS_FILENAME}"

  [ -f wp-config.php ] || cp wp-config-sample.php wp-config.php
  sed -i s/database_name_here/$WP_DB_NAME/ wp-config.php
  sed -i s/username_here/$WP_DB_USERNAME/ wp-config.php
  sed -i s/password_here/$WP_DB_PASSWORD/ wp-config.php
  echo "define('FS_METHOD', 'direct');" >> wp-config.php

  sudo chown -R www-data:www-data $WP_PATH/public/
}


configura_instalacion_ssl() {

  curl "https://$WP_DOMAIN/wp-admin/install.php?step=2" \
    --insecure \
    --noproxy "${WP_DOMAIN}" \
    --data-urlencode "weblog_title=$WP_DOMAIN"\
    --data-urlencode "user_name=$WP_ADMIN_USERNAME" \
    --data-urlencode "admin_email=$WP_ADMIN_EMAIL" \
    --data-urlencode "admin_password=$WP_ADMIN_PASSWORD" \
    --data-urlencode "admin_password2=$WP_ADMIN_PASSWORD" \
    --data-urlencode "pw_weak=1"
}


configura_instalacion_no_ssl() {

  curl "http://$WP_DOMAIN/wp-admin/install.php?step=2" \
    --noproxy "${WP_DOMAIN}" \
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

  HOME_WEB_USER=$(getent passwd www-data | cut -d\: -f6)
  sudo mkdir -p "${HOME_WEB_USER}/.wp-cli/cache/"
  sudo chown -R www-data:www-data  "${HOME_WEB_USER}/.wp-cli/"

}


wp_version() {
  sudo -u www-data wp --path=${WP_PATH}/public core version
}


activa_modo_mantenimiento() {
  sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode activate
  sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode status
}

desactiva_modo_mantenimiento() {
  sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode deactivate
  sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode status
}


configura_timezone() {
  sudo -u www-data wp --path=${WP_PATH}/public option update timezone_string "America/Argentina/Buenos_Aires"
  sudo -u www-data wp --path=${WP_PATH}/public option get timezone_string
}


instala_plugin_woocooomerce() {
  # WooCommerce https://wordpress.org/plugins/woocommerce/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install --version=5.5.4 --activate woocommerce

  # Change Price Title for WooCommerce https://wordpress.org/plugins/change-wc-price-title/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install --version=1.9 --activate change-wc-price-title

  # YITH WooCommerce Badge Management -desactivado https://wordpress.org/plugins/yith-woocommerce-badges-management/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install yith-woocommerce-badges-management
  
  # OneClick Chat to Order https://wordpress.org/plugins/oneclick-whatsapp-order/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install --version=1.0.4.1 --activate oneclick-whatsapp-order

}


instala_un_plugin() {
  nombre=$1
  version=$2
  activacion=$3
  shift ; shift ; shift
  extras=$*

  sudo -u www-data wp --path=${WP_PATH}/public plugin install --version=${version} ${activacion} ${nombre} ${extras}

}


instala_plugins_activados() {

  ##
  # Plugins Comerciales para revisar:
  #
  # Avada Builder, Avada Core https://avada.theme-fusion.com/
  # Slider Revolution https://www.sliderrevolution.com/
  # WP All Import https://www.wpallimport.com/


  # Contact Form 7 https://wordpress.org/plugins/contact-form-7/
  instala_un_plugin  contact-form-7   5.4.2   --activate

  # Flamingo https://es.wordpress.org/plugins/flamingo/
  instala_un_plugin  flamingo   2.2.1  --activate

  # Enable Media Replace https://wordpress.org/plugins/enable-media-replace/
  instala_un_plugin enable-media-replace 3.5.0  --activate

  # Limit Login Attempts Reloaded https://wordpress.org/plugins/limit-login-attempts-reloaded/
  instala_un_plugin limit-login-attempts-reloaded 2.22.1  --activate

  # WP Super Cache https://es.wordpress.org/plugins/wp-super-cache/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install --version=1.7.4 --activate wp-super-cache

  # Yoast Duplicate Post https://wordpress.org/plugins/duplicate-post/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install --version=4.1.2 --activate duplicate-post

  # Yoast SEO https://es.wordpress.org/plugins/wordpress-seo/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install --version=16.7 --activate wordpress-seo

  # Honeypot Anti-Spam https://wordpress.org/plugins/honeypot-antispam/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install --activate honeypot-antispam

  # WP Mail SMTP https://wordpress.org/plugins/wp-mail-smtp/
  #sudo -u www-data wp --path=${WP_PATH}/public plugin install --version=3.5.2 --activate wp-mail-smtp
  #wpdev: WordPress database error Table 'wordpress.wp_wpmailsmtp_tasks_meta' doesn't exist for query SHOW FULL COLUMNS FROM `wp_wpmailsmtp_tasks_meta` made by include('phar:///usr/local/bin/wp/php/boot-phar.php'), include('phar:///usr/local/bin/wp/vendor/wp-cli/wp-cli/php/wp-cli.php'), WP_CLI\bootstrap, WP_CLI\Bootstrap\LaunchRunner->process, WP_CLI\Runner->start, WP_CLI\Runner->load_wordpress, require('wp-settings.php'), do_action('init'), WP_Hook->do_action, WP_Hook->apply_filters, WPMailSMTP\Core->get_tasks, WPMailSMTP\Tasks\Tasks->init, WPMailSMTP\Tasks\Reports\SummaryEmailTask->init, WPMailSMTP\Tasks\Task->register, WPMailSMTP\Tasks\Meta->add, WPMailSMTP\Tasks\Meta->add_to_db
  # https://wordpress.org/support/topic/database-error-table-wp_wpmailsmtp_tasks_meta-doesnt-exist/
  # https://wordpress.org/support/topic/wpmailsmtp_tasks_meta-doesnt-exist/
  # parece que la instalacion del pugin necesita crear tablas en la base de datos

  #instala_plugin_woocooomerce  # FIXME

  # Wordfence Security https://wordpress.org/plugins/wordfence/
  #sudo -u www-data wp --path=${WP_PATH}/public plugin install --version=7.6.2 --activate wordfence
  # FIXME:
  #     wpdev: PHP Warning:  fopen(/var/www/wordpress/public/wp-content/wflogs/rules.php): failed to open stream: No such file or directory in /var/www/wordpress/public/wp-content/plugins/wordfence/vendor/wordfence/wf-waf/src/lib/waf.php on line 332
  #  wpdev: Warning: fopen(/var/www/wordpress/public/wp-content/wflogs/rules.php): failed to open stream: No such file or directory in /var/www/wordpress/public/wp-content/plugins/wordfence/vendor/wordfence/wf-waf/src/lib/waf.php on line 332
  #  wpdev: PHP Warning:  include(/var/www/wordpress/public/wp-content/wflogs/rules.php): failed to open stream: No such file or directory in /var/www/wordpress/public/wp-content/plugins/wordfence/vendor/wordfence/wf-waf/src/lib/waf.php on line 335
  #  wpdev: Warning: include(/var/www/wordpress/public/wp-content/wflogs/rules.php): failed to open stream: No such file or directory in /var/www/wordpress/public/wp-content/plugins/wordfence/vendor/wordfence/wf-waf/src/lib/waf.php on line 335
  #  wpdev: PHP Warning:  include(): Failed opening '/var/www/wordpress/public/wp-content/wflogs/rules.php' for inclusion (include_path='.:/usr/share/php') in /var/www/wordpress/public/wp-content/plugins/wordfence/vendor/wordfence/wf-waf/src/lib/waf.php on line 335
  #  wpdev: Warning: include(): Failed opening '/var/www/wordpress/public/wp-content/wflogs/rules.php' for inclusion (include_path='.:/usr/share/php') in /var/www/wordpress/public/wp-content/plugins/wordfence/vendor/wordfence/wf-waf/src/lib/waf.php on line 335

}




instala_plugins_desactivados() {

  # Duplicator -desactivado https://wordpress.org/plugins/duplicator/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install duplicator

  # File Manager Advanced -desactivado https://wordpress.org/plugins/file-manager-advanced/
  sudo -u www-data wp --path=${WP_PATH}/public plugin install file-manager-advanced

}


elimina_plugins_predeterminados() {
  sudo -u www-data wp --path=${WP_PATH}/public plugin delete hello akismet
}


lista_plugins_instalados() {
  sudo -u www-data wp --path=${WP_PATH}/public plugin list
}


genera_contenido_dummy()
{
  sudo -u www-data wp --path=${WP_PATH}/public user generate --count=5 --role=subscriber
  sudo -u www-data wp --path=${WP_PATH}/public post generate --count=3 --post_content <<< $(curl -s -N http://loripsum.net/api/2 )
}


desactiva_actualizacion_automatica_wordpress() {
  sudo -u www-data wp --path=${WP_PATH}/public config set WP_AUTO_UPDATE_CORE false
  # Opciones: true, 'false', 'beta', 'rc', 'development', 'branch-development', 'minor'

  sudo -u www-data wp --path=${WP_PATH}/public cache flush
  # TODO: https://github.com/wearerequired/wp-cli-clear-opcache
  sudo service "php${PHP_VERSION}-fpm" reload
}


desactiva_actualizacion_automatica_plugins() {
  sudo -u www-data wp --path=${WP_PATH}/public plugin auto-updates disable \
	  $(sudo -u www-data wp --path=${WP_PATH}/public plugin list --field=name --status=active,inactive) 
}


main() {

instala_wordpress
instala_wp_cli

#configura_instalacion_no_ssl
configura_instalacion_ssl

desactiva_actualizacion_automatica_wordpress
sudo service nginx restart

activa_modo_mantenimiento
lista_plugins_instalados
configura_timezone

# TODO: crear un array de PLUGINS_ACTIVADOS y uno de PLUGINS_DESACTIVADOS y poner nombre y version del plugin en cada entrada del array
#        mudar el array a provision/vars.sh y aquí recorrer el array para hacer cada instalacion de plugin
instala_plugins_activados
instala_plugins_desactivados
desactiva_actualizacion_automatica_plugins
elimina_plugins_predeterminados
lista_plugins_instalados

genera_contenido_dummy

desactiva_modo_mantenimiento
wp_version
}

##
# https://peteris.rocks/blog/unattended-installation-of-wordpress-on-ubuntu-server/
main

# EOF
