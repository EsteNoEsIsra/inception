#FROM debian:bookworm
FROM debian@sha256:129588494497601baa5dbca1df687c835ff166ec4dd3bf307be684f34da07ab5

WORKDIR /appMariadb


RUN set -eux; \
	apt update && \
	apt-get install -y gosu; \
	gosu nobody true

RUN apt update && \
		apt install -y --no-install-recommends \
		-o Dir::Cache::pkgcache="" -o Dir::Cache::srcpkgcache="" \
		mariadb-server && \
		apt-get clean && \
		rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN mkdir -p /run/mysqld /var/lib/mysql && \
					chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY --chmod=755 init.sh ./init.sh 

VOLUME /var/lib/mysql


ENTRYPOINT ["conf/init.sh"]
EXPOSE 3306

# Cambiamos al usuario mysql antes de ejecutar el comando final para evitar el root // cambiar luego para el entry point
#USER mysql


CMD	["mysqld"]

