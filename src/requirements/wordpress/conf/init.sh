#!/bin/sh

set -e

conneciting_db()
{
	mariadb=$1
	port=$2
	while ! nc -z -v -w20 $mariadb $port; do 
		echo "Waiting response from $mariadb"
		sleep 2 
	done
	echo "$mariadb Ready"
}

add_group()
{
	group=$1
	user=$2
	dir=$3
	if ! getent group "$group" ; then
		addgroup -S $group;
	fi 
	if ! getent passwd "$user" ; then
		adduser -S -D -H -s /sbin/nologin -g $group $user;
	fi
	chown -R $user:$group $dir
}

client_wp_download()
{
	$volume=$1
	echo "location"
	pwd
	echo "location end"
	
	if [ ! -f usr/local/bin/wp ]; then
	echo "Installing wp-cli"
	curl -L -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	chmod 744 wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp
	else
		echo "wp-cli Instaled!"
	fi
}

configure_php()
{
	echo "config doing"
}



# tar -z-x-f  --strip-component = extrae aqui          
wp_download()
{	
	vol=$1	

	if [ ! -f $vol/index.php ] ; then
		echo "downloading wordpress "
		cd $vol && curl -L -O https://wordpress.org/wordpress-latest.tar.gz
		tar -xzf wordpress-latest.tar.gz --strip-components=1 && \
		rm wordpress-latest.tar.gz
	fi 	
	echo "Wordpress downloaded"
}


inti_wordpress()
{
		volume=/var/www/html
		conneciting_db "mariadb" "${MARIA_DB_PORT}"
		add_group "www-data" "www-data" "$volume"
		wp_download "$volume"
		client_wp_download "$volume"
		#redis_dowlload
		configure_php "${PHP_VER}"
		configure_wp  "${PHP_VER}" "$volume"
}




if [ "$1" -eq "php" ] ; then
	echo  "entro al sh"	
	init_wordpress
else 
	echo "no entro"
	exec "$@"
fi
