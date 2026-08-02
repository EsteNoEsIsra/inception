FROM alpine@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce

WORKDIR /appAdminer
ARG PHP_VERSION

RUN 	apk update && \
		apk add --no-cache curl \
		php${PHP_VERSION} \
		php${PHP_VERSION}-fpm \
		php${PHP_VERSION}-mysqli \
		php${PHP_VERSION}-pdo_pgsql \
		php${PHP_VERSION}-json \
		php${PHP_VERSION}-session 

COPY /conf/www.conf /etc/php${PHP_VERSION}/php-fpm.d/www.conf
COPY --chmod=744 /conf/init.sh /appAdminer/init.sh

ENTRYPOINT ["/appAdminer/init.sh"]
#EXPOSE ${ADMINER_PORT}
CMD ["php"]
