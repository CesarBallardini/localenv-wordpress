# Cómo respaldar y restaurar un sitio Wordpress


## Crear el respaldo


Hay que respaldar la base de datos y los archivos del sitio


```bash

source /vagrant/provision/vars.sh

sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode status

mkdir -p /vagrant/tmp/
sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode activate
wp --path=${WP_PATH}/public db export /vagrant/tmp/backup.sql
tar --directory=${WP_PATH} -czf /vagrant/tmp//backup.tgz public
sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode deactivate

sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode status
```


# Restaurar desde el respaldo


```bash

source /vagrant/provision/vars.sh

sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode status

# guardo info sitio dev para pisar lo que viene del backup
cp  ${WP_PATH}/public/wp-config.php /vagrant/tmp/
# cp el .htaccess si existe en el sitio dev

sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode activate

# elimino completamente el contenido actualmente existente en VM de destino
wp --path=${WP_PATH}/public db clean
sudo rm -rf ${WP_PATH}/public

# restaura archivos
sudo tar --directory=${WP_PATH} -xzf /vagrant/tmp//backup.tgz public
sudo cp  /vagrant/tmp/wp-config.php ${WP_PATH}/public/wp-config.php

# restaura base de datos
wp --path=${WP_PATH}/public db import /vagrant/tmp/backup.sql

# usa nombre del sitio dev, no del sitio prod
#WP_ORIG_DOMAIN="wpdev.virtual.ballardini.com.ar"
#WP_DEST_DOMAIN="wptest.virtual.ballardini.com.ar"
#
WP_ORIG_DOMAIN="wptest.virtual.ballardini.com.ar"
WP_DEST_DOMAIN="wpdev.virtual.ballardini.com.ar"

#wp --path=${WP_PATH}/public option set blogname  ${WP_DEST_DOMAIN}
wp --path=${WP_PATH}/public option update home "http://${WP_DEST_DOMAIN}"
wp --path=${WP_PATH}/public option update siteurl "http://${WP_DEST_DOMAIN}"


wp --path=${WP_PATH}/public search-replace "${WP_ORIG_DOMAIN}" "${WP_DEST_DOMAIN}" --all-tables --network --allow-root
wp --path=${WP_PATH}/public search-replace --url="${WP_ORIG_DOMAIN}" "${WP_ORIG_DOMAIN}" "${WP_DEST_DOMAIN}" 'wp_*options' wp_blogs
#wp --path=${WP_PATH}/public search-replace "http://${WP_DEST_DOMAIN}" "https://${WP_DEST_DOMAIN}" --all-tables --network
#wp --path=${WP_PATH}/public search-replace "http:\/\/${WP_DEST_DOMAIN}" "https:\/\/${WP_DEST_DOMAIN}" --all-tables --network

wp --path=${WP_PATH}/public cli cache clear
wp --path=${WP_PATH}/public cache flush

# desactiva emails en el sitio dev: los usuarios son los mismos que en producción, no queremos llenarlos de emails de dev
sudo -u www-data wp --path=${WP_PATH}/public plugin install disable-emails --activate

sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode deactivate

sudo -u www-data wp --path=${WP_PATH}/public maintenance-mode status


```



# Referencias

* https://servebolt.com/help/article/making-backups-of-your-wordpress-site/
* https://kinsta.com/es/blog/wordpress-modo-de-mantenimiento/
* https://www.rochen.com/2017/08/29/backup-and-restore-wordpress-files-folders-and-content-with-wp-cli/
