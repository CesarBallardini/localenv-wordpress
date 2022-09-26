export WP_PATH="/var/www/wordpress"

export WP_DB_NAME="wordpress"
export WP_DB_USERNAME="wordpress"

export WP_DB_PASSWORD="wordpress"
#export WP_DB_PASSWORD="$(pwgen -1 -s 64)"

export MYSQL_ROOT_PASSWORD="root"
#export MYSQL_ROOT_PASSWORD="$(pwgen -1 -s 64)"

# https://www.php.net/supported-versions.php 
# Branch Initial Release Active Support Until Security Support Until
# 7.4    28 Nov 2019     28 Nov 2021          28 Nov 2022
# 8.0    26 Nov 2020     26 Nov 2022          26 Nov 2023
# 8.1    25 Nov 2021     25 Nov 2023          25 Nov 2024

PHP_VERSION=7.4
PHP_VERSION=8.0
PHP_VERSION=8.1


# https://wordpress.org/download/releases/
WORDPRESS_VERSION=6.0.2
WORDPRESS_VERSION=latest


##
# ultimas versiones (2022-09-22)
#PHP_VERSION=8.1
#WORDPRESS_VERSION=latest


##
# versiones viejas:
PHP_VERSION=7.4
WORDPRESS_VERSION=5.7.7

##
# versiones especialmente solicitadas
PHP_VERSION=8.0
WORDPRESS_VERSION=5.9.4
