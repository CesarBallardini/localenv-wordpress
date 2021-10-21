# README - Wordpress local dev environment

Para atender un cliente con Wordpress es necesario tener un entorno de desarrollo y uno de _staging_.

En este repositorio se crean dichos entornos de manera desatendida.  La VM se crea mediante Virtualbox, gestionado desde Vagrant
y el aprovisionamiento se realiza con _scripts_ de _shell_ que residen en el directorio `provision/`.

# Requisitos

* Vagrant (verificado con 2.2.18)

* Plugins para Vagrant:

  * vagrant-cachier (1.2.1)
  * vagrant-disksize (0.1.3)
  * vagrant-hostmanager (1.8.9)
  * vagrant-mutate (1.2.0)
  * vagrant-proxyconf (2.0.10)
  * vagrant-rekey-ssh (0.1.9)
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

* levante la VM

```bash
cd localenv-wordpress/
time vagrant up
```

Esto va a crear una VM con Ubuntu 20.04 llamada `wpdev` con dirección IP 192.168.56.1 en la red _host only_ de Virtualbox, lo cual permite accederla 
desde la pc o notebook que aloja el Virtualbox.

Cuando la VM levanta, muestra las URLs y credenciales necesarias para el acceso de lectura del blog y para el _login_ con la cuenta privilegiada de administración.

En la VM se dispone de la herramienta WP-CLI bajo el nombre `wp`.


# Referencias

* WP CLI: herramienta de administración de tipo CLI para Wordpress.
  * https://wp-cli.org/es/
  * https://developer.wordpress.org/cli/commands/

* https://peteris.rocks/blog/unattended-installation-of-wordpress-on-ubuntu-server/ los _scripts_ están basados en este material.

