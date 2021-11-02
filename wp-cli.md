# Cómo usar `wp-cli` para administrar su sitio Wordpress


## Gestión de los plugins

```bash
source /vagrant/provision/vars.sh

# lista los plugins
sudo -u www-data wp --path=${WP_PATH}/public plugin list

# actualiza un plugin en particular
sudo -u www-data wp --path=${WP_PATH}/public plugin update akismet

#actualiza todos los plugins
sudo -u www-data wp --path=${WP_PATH}/public plugin update --all


wp --path=${WP_PATH}/public plugin search seo

#Success: Showing 10 of 1010 plugins.
#+-------------------------------------------------------------------------------------------------+---------------------+--------+
#| name                                                                                            | slug                | rating |
#+-------------------------------------------------------------------------------------------------+---------------------+--------+
#| Yoast SEO                                                                                       | wordpress-seo       | 96     |
#| All in One SEO – Best WordPress SEO Plugin – Easily Improve SEO Rankings &amp; Increase Traffic | all-in-one-seo-pack | 92     |
#| Rank Math SEO – Best SEO Plugin For WordPress To Increase Your SEO Traffic                      | seo-by-rank-math    | 98     |
#| The SEO Framework                                                                               | autodescription     | 98     |
#| SEOPress, on-site SEO                                                                           | wp-seopress         | 98     |
#| W3 Total Cache                                                                                  | w3-total-cache      | 88     |
#| Redirection                                                                                     | redirection         | 86     |
#| LiteSpeed Cache                                                                                 | litespeed-cache     | 96     |
#| WooCommerce                                                                                     | woocommerce         | 90     |
#| Internal Link Juicer: SEO Auto Linker for WordPress                                             | internal-links      | 94     |
#+-------------------------------------------------------------------------------------------------+---------------------+--------+

# continuar viendo la lista con:
wp --path=${WP_PATH}/public plugin search seo --page=2

```

## Gestión de `wp-cli`

```bash

source /vagrant/provision/vars.sh

# info sobre la instalación de wp-cli
wp --path=${WP_PATH}/public cli info


sudo -u www-data wp --path=${WP_PATH}/public cli version
# WP-CLI 2.5.0 al 2021-11-02

# verifica si hay alguna actualización
sudo -u www-data wp --path=${WP_PATH}/public cli check-update
 
# actualiza a la última versión
sudo wp --path=${WP_PATH}/public cli update
 
# limpia la cache interna
wp --path=${WP_PATH}/public cli cache clear
```

## Gestion de usuarios

```bash

source /vagrant/provision/vars.sh

wp --path=${WP_PATH}/public user list

#+----+------------+--------------+-------------+---------------------+---------------+
#| ID | user_login | display_name | user_email  | user_registered     | roles         |
#+----+------------+--------------+-------------+---------------------+---------------+
#| 1  | admin      | admin        | no@spam.org | 2021-11-02 13:23:39 | administrator |
#+----+------------+--------------+-------------+---------------------+---------------+


wp --path=${WP_PATH}/public role list

#+---------------+---------------+
#| name          | role          |
#+---------------+---------------+
#| Administrator | administrator |
#| Editor        | editor        |
#| Author        | author        |
#| Contributor   | contributor   |
#| Subscriber    | subscriber    |
#+---------------+---------------+

# alta
wp --path=${WP_PATH}/public user create bob bob@example.com --display_name=Robertito --role=author --user_pass=bobp4ass

# modificación
wp --path=${WP_PATH}/public user update --skip-email 2 --display_name="Rob Ertito" --user_pass=otrapass 



wp --path=${WP_PATH}/public user get 2 --field=login

# bob



wp --path=${WP_PATH}/public user get 2 

#+-----------------+---------------------+
#| Field           | Value               |
#+-----------------+---------------------+
#| ID              | 2                   |
#| user_login      | bob                 |
#| user_email      | bob@example.com     |
#| user_registered | 2021-11-02 14:37:07 |
#| display_name    | Rob Ertito          |
#| roles           | author              |
#+-----------------+---------------------+

# genera datos del usuario en otros formatos:
wp --path=${WP_PATH}/public user get bob --format=json > bob.json

# verifica si anda una password para un dado usuario: 0 OK / 1 NO ES LA PASSWORD
wp --path=${WP_PATH}/public user check-password bob otrapass ; echo $?
wp --path=${WP_PATH}/public user check-password bob OTRAPASS ; echo $?

# Delete user 123 and reassign posts to user 567
wp --path=${WP_PATH}/public user delete 123 --reassign=567

```

## Gestión de Themes

```bash

source /vagrant/provision/vars.sh

wp --path=${WP_PATH}/public theme list

#+-----------------+----------+--------+---------+
#| name            | status   | update | version |
#+-----------------+----------+--------+---------+
#| twentynineteen  | inactive | none   | 2.1     |
#| twentytwenty    | inactive | none   | 1.8     |
#| twentytwentyone | active   | none   | 1.4     |
#+-----------------+----------+--------+---------+


wp --path=${WP_PATH}/public theme  update --all


```

## Gestión de Posts

```bash

source /vagrant/provision/vars.sh

wp --path=${WP_PATH}/public post list

#+----+--------------+-------------+---------------------+-------------+
#| ID | post_title   | post_name   | post_date           | post_status |
#+----+--------------+-------------+---------------------+-------------+
#| 1  | Hello world! | hello-world | 2021-11-02 13:23:39 | publish     |
#+----+--------------+-------------+---------------------+-------------+


```

## Gestión de la base de datos


```bash

source /vagrant/provision/vars.sh


wp --path=${WP_PATH}/public db query "SELECT user_login,ID FROM wp_users;"


wp --path=${WP_PATH}/public db optimize

#wordpress.wp_commentmeta
#note     : Table does not support optimize, doing recreate + analyze instead
#status   : OK
#wordpress.wp_comments
#note     : Table does not support optimize, doing recreate + analyze instead
#error    : Invalid default value for 'comment_date'
#status   : Operation failed
#wordpress.wp_links
#note     : Table does not support optimize, doing recreate + analyze instead
#error    : Invalid default value for 'link_updated'
#status   : Operation failed
wordpress.wp_options
#note     : Table does not support optimize, doing recreate + analyze instead
#status   : OK
#wordpress.wp_postmeta
#note     : Table does not support optimize, doing recreate + analyze instead
#status   : OK
#wordpress.wp_posts
#note     : Table does not support optimize, doing recreate + analyze instead
#error    : Invalid default value for 'post_date'
#status   : Operation failed
#wordpress.wp_term_relationships
#note     : Table does not support optimize, doing recreate + analyze instead
#status   : OK
#wordpress.wp_term_taxonomy
#note     : Table does not support optimize, doing recreate + analyze instead
#status   : OK
#wordpress.wp_termmeta
#note     : Table does not support optimize, doing recreate + analyze instead
#status   : OK
#wordpress.wp_terms
#note     : Table does not support optimize, doing recreate + analyze instead
#status   : OK
#wordpress.wp_usermeta
#note     : Table does not support optimize, doing recreate + analyze instead
#status   : OK
#wordpress.wp_users
#note     : Table does not support optimize, doing recreate + analyze instead
#error    : Invalid default value for 'user_registered'
#status   : Operation failed
#Success: Database optimized.


wp --path=${WP_PATH}/public db repair

#wordpress.wp_commentmeta
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_comments
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_links
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_options
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_postmeta
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_posts
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_term_relationships
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_term_taxonomy
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_termmeta
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_terms
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_usermeta
#note     : The storage engine for the table doesn't support repair
#wordpress.wp_users
#note     : The storage engine for the table doesn't support repair
#Success: Database repaired.



```



# Referencias

* https://developer.wordpress.org/cli/commands/ 
* https://www.digitalocean.com/community/tutorials/how-to-use-wp-cli-v2-to-manage-your-wordpress-site-from-the-command-line
* https://www.codeinwp.com/blog/wp-cli/


