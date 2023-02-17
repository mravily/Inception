FROM alpine:3.17

EXPOSE 80 443

RUN apk update && \
	apk upgrade && \
	apk add openssl curl ca-certificates

RUN curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub

RUN mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/

RUN apk add nginx

RUN mkdir /etc/nginx/certs && \
	openssl req \
		-x509 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/certs/key.pem \
		-out /etc/nginx/certs/cert.pem \
		-days 365 \
		-nodes \
		 -subj '/ST=France/L=Paris/O=42/CN=webserver'

RUN openssl dhparam -out /etc/nginx/certs/dhparam.pem 2048

COPY config/default.conf /etc/nginx/http.d/default.conf
COPY config/wordpress.conf /etc/nginx/http.d/wordpress.conf

RUN mkdir -p /data/www

ENTRYPOINT ["nginx", "-g", "daemon off;"]