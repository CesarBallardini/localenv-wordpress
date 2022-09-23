#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

export HOST_IP_ADDRESS=${1:-192.168.56.10}
export WP_DOMAIN=${2:-wpdev.virtual.ballardini.com.ar}
export HOSTNAME=${3:-wpdev}

sudo dpkg --configure -a
sudo apt-get install -f ${APT_OPTIONS}

sudo apt-get install pwgen ${APT_OPTIONS}
sudo apt-get install net-tools ${APT_OPTIONS}


# da un error con Docker pues a /etc/hosts lo trata diferentemente
# http://blog.jonathanargentiero.com/docker-sed-cannot-rename-etcsedl8ysxl-device-or-resource-busy/

REGEXP_HOST_IP_ADDRESS=$(echo ${HOST_IP_ADDRESS} | sed -e 's/\./\\\./g')
sed -e "s/^${REGEXP_HOST_IP_ADDRESS}.*/${HOST_IP_ADDRESS} ${WP_DOMAIN} ${HOSTNAME}/" < /etc/hosts > ~/etc-hosts.new
sudo cp -f ~/etc-hosts.new /etc/hosts

