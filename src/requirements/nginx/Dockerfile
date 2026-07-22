FROM alpine:3.23

RUN apk update && \
		apk add --no-cache nginx openssl 

RUN		mkdir -p /run/nginx

COPY nginx nginx.conf /etc/nginx/nginx.conf
#		 index.html /usr/share/nginx/html/index.html


EXPOSE 80 443

CMD ["nginx"]


# openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt



#Crea un Dockerfile con FROM debian: / alpine.
#Instala únicamente nginx y comprueba que el contenedor arranca.
#Instala openssl y genera un certificado autofirmado.
#Escribe tu propio nginx.conf y entiende cada directiva (listen, server_name, ssl_certificate, ssl_protocols, location, etc.).
#Finalmente, conecta NGINX con el contenedor de WordPress mediante FastCGI.
