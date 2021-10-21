# README - Wordpress local dev environment

Para atender un cliente con Wordpress es necesario tener un entorno de desarrollo y uno de _staging_.

En este repositorio se crean dichos entornos de manera desatendida.  La VM se crea mediante Virtualbox, gestionado desde Vagrant
y el aprovisionamiento se realiza con _scripts_ de _shell_ que residen en el directorio `provision/`.

# Requisitos

* Vagrant (verificado con 2.2.18)

* Plugins para Vagrant:

  * vagrant-cachier (1.2.1) (caché de paquetes DEB, etc.)
  * vagrant-hostmanager (1.8.9) (para modificar automáticamente el `/etc/hosts` en VM y _host_)
  * vagrant-proxyconf (2.0.10) (si debe salir a internet a través de un _proxy_ corporativo)
  * vagrant-reload (0.0.1)
  * vagrant-share (2.0.0)
  * vagrant-vbguest (0.30.0)

* Virtualbox (verificado con 6.1.28r147628)

# Cómo usar este repositorio

* Asegúrese de instalar los requisitos

* clone el repo

```bash
git clone https://github.com/CesarBallardini/localenv-wordpress
```

Configure si desea otros valores diferentes a los provistos.  Puede dejar todo sin modificar y el sistema será completamente funcional.

* `Vagrantfile` (estas variables identifican el dominio y las credenciales de la cuenta Wordpress con privilegios administrativos)

```ruby
HOSTNAME = "wpdev"
HOST_IP_ADDRESS="192.168.56.10"

WP_DOMAIN = "wpdev.virtual.ballardini.com.ar"
WP_ADMIN_USERNAME="admin"
WP_ADMIN_PASSWORD="admin"
WP_ADMIN_EMAIL="no@spam.org"
```

* `provision/vars.sh` (no debería ser necesario cambiar nada aquí para una VM de desarrollo o staging)

```bash
export WP_PATH="/var/www/wordpress"

export WP_DB_NAME="wordpress"
export WP_DB_USERNAME="wordpress"

export WP_DB_PASSWORD="wordpress"
#export WP_DB_PASSWORD="$(pwgen -1 -s 64)"

export MYSQL_ROOT_PASSWORD="root"
#export MYSQL_ROOT_PASSWORD="$(pwgen -1 -s 64)"

PHP_VERSION=7.4
```

Es muy importante que la versión de PHP instalada en la VM (mayor.minor) se indique en la variable `PHP_VERSION`. 
En el caso de Ubuntu 20.04 LTS se corresponde con la 7.4.

* `/etc/hosts` indique la asociación entre la dirección IP y el nombre de la VM, y el fqdn de la misma.  Si tiene instalado el plugin `vagrant-hostmanager`, esta tarea se hace automáticamente.

```text
192.168.56.10	wpdev
192.168.56.10	wpdev.virtual.ballardini.com.ar
```

* levante la VM

```bash
cd localenv-wordpress/
time vagrant up
```

Esto va a crear una VM con Ubuntu 20.04 llamada `wpdev` con dirección IP 192.168.56.1 en la red _host only_ de Virtualbox, lo cual permite accederla 
desde la pc o notebook que aloja el Virtualbox.

Cuando la VM levanta, muestra las URLs y credenciales necesarias para el acceso de lectura del blog y para el _login_ con la cuenta privilegiada de administración.
Si usa los valores provistos aquí, las URL serán:

* http://wpdev.virtual.ballardini.com.ar/ lectura del blog
* http://wpdev.virtual.ballardini.com.ar/wp-login.php acceso con credenciales `admin / admin` para la cuenta privilegiada de administración Wordpress.

En la VM se dispone de la herramienta WP-CLI bajo el nombre `wp`.

Como siempre en el caso de Vagrant, se puede ingresar mediante SSH con el mandato:

```bash
vagrant ssh
```

Para detener la VM:

```bash
vagrant halt
```

y para destruirla por completo:

```bash
vagrant destroy -f
```


# Referencias

* WP CLI: herramienta de administración de tipo CLI para Wordpress.
  * https://wp-cli.org/es/
  * https://developer.wordpress.org/cli/commands/

* https://peteris.rocks/blog/unattended-installation-of-wordpress-on-ubuntu-server/ los _scripts_ están basados en este material.

