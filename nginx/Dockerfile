FROM alpine:3.17

EXPOSE 443

# Install nginx and open ssl deps 
RUN set -eux ; \
	apk update ; \
	apk upgrade ; \
	apk add --update --no-cache nginx openssl ; \
	rm -f /var/cache/apk/* 

# Generate SSL and Dhparam Certificates
RUN set -eux ; \
	mkdir /etc/nginx/certs ; \
	openssl req -x509 -newkey rsa:2048 -days 365 -nodes \
		-keyout /etc/nginx/certs/key.pem \
		-out /etc/nginx/certs/cert.pem \
		-subj '/ST=France/L=Paris/O=42/CN=web-server' ; \
	openssl dhparam -out /etc/nginx/certs/dhparam.pem 2048

# Change owner nginx directory
RUN set -eux ; \
	chown -R nginx:nginx \
		/etc/nginx/ \
		/run/nginx \
		/var/run/nginx

# Add server config for wordpress
# COPY config/wordpress.conf /etc/nginx/http.d

# Define running container user
USER nginx

ENTRYPOINT ["nginx", "-g", "daemon off;"]