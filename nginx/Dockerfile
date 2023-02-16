FROM alpine:3.17

EXPOSE 443

ARG DOMAIN_NAME

# Install nginx and open ssl deps 
RUN set -eux ; \
	apk update ; \
	apk upgrade ; \
	apk add --update --no-cache nginx ; \
	rm -f /var/cache/apk/* 

# Change owner nginx directory
RUN set -eux ; \
	chown -R nginx:nginx \
		/etc/nginx/ \
		/run/nginx \
		/var/run/nginx \
		/var/www

RUN sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" /etc/nginx/http.d/wordpress.conf

# Define non-root user
USER nginx

ENTRYPOINT ["nginx", "-g", "daemon off;"]