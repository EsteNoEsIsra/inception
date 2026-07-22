FROM alpine@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce

WORKDIR /appWordpress

ARG PHP_VERSION=84
ARG WPRESS_PORT=9000

RUN apk update && \
		apk add --no-cache \
		curl \
		php${PHP_VERSION} \
		php${PHP_VERSION}-fpm \
		php${PHP_VERSION}-mysqli \
		php${PHP_VERSION}-redis \
		php${PHP_VERSION}-ctype \
		php${PHP_VERSION}-phar \
		php${PHP_VERSION}-mbstring \
		php${PHP_VERSION}-xml      \
		php${PHP_VERSION}-dom  \
		php${PHP_VERSION}-xmlreader \
		php${PHP_VERSION}-curl \
		php${PHP_VERSION}-cli \
		php${PHP_VERSION}-zlib 

#COPY /config/www.conf /etc/php${PHP_VERSION}/php-fpm.d/www.conf
COPY /conf/www.conf /appWordpress/www.conf

COPY --chmod=755 /conf/init.sh /appWordpress/init.sh


#ENTRYPOINT ["./init.sh"]
EXPOSE ${WPRESS_PORT}
CMD ["php-fpm"]
