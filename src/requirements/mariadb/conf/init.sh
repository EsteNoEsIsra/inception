#!/bin/bash


set -e
$MYSQL_DIR =/var/lib/mysql
$MYSQL_PORT =3306
$db_root_password=root  # eliminar .  lo dejo test  (se hace en los secrets)
$MYSQL_DATABASE=mydatabase
$MYSQL_USER=mysql
$MYSQL_ROOT=root


conf_mariadb_file()
{
	echo "Creating conf file "
	cat << EOF > /etc/mysql/my.cnf
	[mysqld]
	user=mysql
	datadir=${MYSQL_DIR}
	port=${MYSQL_PORT}
	bind-address=0.0.0.0
	socket=/run/mysqld/mysqld.sock
EOF
}	




init_database()
{
	echo "Creating Database"
	if [ -d "${MYSQL_DIR}/mysql" ] ; then 
		echo "Database exists"
	else 
		echo "Database initialized "
		mariadb-install_db --user=mysql --datadir=${MYSQL_DIR}
		mysqld --datadir=${MYSQL_DIR} & 
		
		while ! mysqladmin ping --silent; do
					echo "Waiting for database"
				sleep 1
		done
		create_database_file

			mysql -u root -p"$db_root_password" < ${MYSQL_DIR}/init-db.sql 
			mysqladmin shutdown -u root -p"$db_root_password"
	fi
	
		echo "Database Created!"
}

create_database_file()
{
	db_password_file=/run/secrets/db_password
	db_root_password_file=/run/secrets/db_root_password


if [ -f $db_password_file ] && [ -f $db_root_password_file ]; then

#	db_password=$(cat $db_password_file)
#	db_root_password=$(cat $db_root_password_file)
	db_password=$db_root_password
	db_root_password=$db_root_password


cat << EOF > ${MYSQL_DIR}/init-db.sql
	CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

	CREATE USER IF NOT EXISTS "${MYSQL_ROOT}"@"%" IDENTIFIED BY "$db_root_password";
	ALTER USER 'root'@'localhost' IDENTIFIED BY "$db_root_password";
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO "${MYSQL_ROOT}"@"%" WITH GRANT OPTION;

	CREATE USER IF NOT EXISTS "${MYSQL_USER}"@"localhost" IDENTIFIED BY "$db_password";
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO "${MYSQL_USER}"@"localhost";
	CREATE USER IF NOT EXISTS "${MYSQL_USER}"@"%" IDENTIFIED BY "$db_password";
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO "${MYSQL_USER}"@"%";

	FLUSH PRIVILEGES;
EOF

	else

		echo "error init.sh: "
		echo "$db_password_file or $db_root_password_file not found..."
		exit 
	fi

}


init_mariadb()
{
	conf_mariadb_file
	init_database
	exec gosu mysql "$@"
}



if [ "$1" == "mysqld" ] ; then
	init_mariadb "$@"
else	
	echo "adios"
	exec "$@"	
fi 
