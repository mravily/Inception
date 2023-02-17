FROM alpine:3.17

EXPOSE 9000

# Install dependencies for php-fpm and mariadb client
RUN set -eux ; \
	apk update ; \
	apk upgrade ; \
	apk add --update --no-cache curl php81 \
		php81-fpm \
		php81-mysqli \
		php81-mbstring \
		php81-phar \
		mariadb-client \
		fcgi \
	rm -rf /var/lib/apt/lists/*

# Download and config wp-cli binary
RUN set -eux ; \
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar ; \
	chmod +x wp-cli.phar ; \
	mv wp-cli.phar /usr/local/bin/wp 

# Create user for php
RUN set -eux ; \
	adduser -u 82 -D -S -G www-data www-data ; \	
	chown -R www-data:www-data /etc/php81 /var/log/php81

COPY tools/entrypoint.sh /

USER www-data

WORKDIR ${DIR_WP}

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]