FROM alpine:3.17

EXPOSE 9000

RUN adduser -u 82 -D -S -G www-data www-data

RUN apk update && \
	apk upgrade && \
	apk add php81 php81-mysqli php81-fpm php81-curl php81-dom \
	php81-exif php81-fileinfo php81-mbstring \
	php81-openssl php81-zip  php81-opcache php81-gd php81-intl \
	php81-cgi 

RUN mkdir -p /usr/share/webapps/

RUN wget -O /usr/share/webapps/latest.tar.gz http://wordpress.org/latest.tar.gz

# Copy the .conf in the html directory
COPY config/www.conf /etc/php81/php-fpm.d/

WORKDIR /usr/share/webapps/

RUN tar -xzvf latest.tar.gz && \
	rm latest.tar.gz

RUN chown -R www-data:www-data /usr/share/webapps/wordpress && \
	chmod -R o-rwx /usr/share/webapps/wordpress

WORKDIR /usr/share/webapps/wordpress

#Launch PHP FPM in foreground and ignore deamonize from conf file (-F)
CMD ["/usr/sbin/php-fpm81", "-F"]