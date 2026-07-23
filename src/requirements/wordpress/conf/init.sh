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
	volume=$1
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
#mirar detalladament esto que hay una manera mejor de hacerlo
configure_wp()
{
		php_version=$1
		volume=$2
	
WP="php$php_version -d memory_limit=256M /usr/local/bin/wp --path=$volume"	
	echo $WP
	user_password_file=/run/secrets/db_password	
	admin_password_file=/run/secrets/db_root_password
	
	if ! $WP core is-installed; then
	echo "Creating Worpress tables"
	$WP core install --path=$volume     						\
		--url="${DOMAIN_NAME}" 									\
		--title="${WP_TITLE}"  									\
		--admin_user="${WP_DB_ADMIN}"  							\
		--admin_password="$(cat $admin_password_file)" 			\
		--admin_email="${WP_DB_ADMIN}@dev.com"					\
		--skip-email											\
		--allow-root
	fi 
	if ! $WP user get ${WP_DB_USER} --field=ID --quiet; then
		echo "Creating ${WP_DB_USER} user"
		$WP user create --path=$volume								\
		"${WP_DB_USER}" "${WP_DB_USER}@dev.com" 				\
		--role=author 											\
		--user_pass="$(cat $user_password_file)" 				\
		--allow-root
	fi
	echo "Worpdress Configured!"


}


configure_php()
{
	volume_path=$1

	echo "config doing"
	if [ -f /appWordpress/wp-config.php ]; then
		mv /appWordpress/wp-config.php $volume_path/
	fi
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
		configure_php "${PHP_VER}" "$volume"
#		configure_wp  "${PHP_VER}" "$volume"
		exec php-fpm${PHP_VER} -F
}




if [ "$1" = "php" ] ; then
	echo  "entro al sh"	
	init_wordpress
else 
	echo "no entro"
	exec "$@"
fi
