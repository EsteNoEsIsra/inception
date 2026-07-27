FROM alpine@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce

WORKDIR  /App_nginx

RUN apk update && \
		apk add --no-cache nginx openssl gettext 


RUN		mkdir -p /run/nginx

COPY --chmod=644 /conf/nginx.conf /App_nginx/nginx.cnf.template
COPY --chmod=774 /conf/init.sh /App_nginx/init.sh

ENTRYPOINT ["/App_nginx/init.sh"]

EXPOSE ${NGINX_PORT}

CMD ["nginx", "-g", "daemon off;"]


# openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt



#Crea un Dockerfile con FROM debian: / alpine.
#Instala únicamente nginx y comprueba que el contenedor arranca.
#Instala openssl y genera un certificado autofirmado.
#Escribe tu propio nginx.conf y entiende cada directiva (listen, server_name, ssl_certificate, ssl_protocols, location, etc.).
#Finalmente, conecta NGINX con el contenedor de WordPress mediante FastCGI.
