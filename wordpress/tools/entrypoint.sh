#!/bin/sh

export DOCKER_NET=$(awk 'END{print $1}' /etc/hosts | awk -F  '.' '{ print $1"."$2"."$3;}')

if ! wp core is-installed --path=$DIR_WP --quiet ; then

	# Interpret env vars in the file and send it to the database
	eval "echo \"$(cat /tmp/php/db.sql)\"" | mysql -u $DB_ADMIN -h $DB_HOST --password=$DB_ADMIN_PASS
	
	# Download WP Files
	wp core download --path=$DIR_WP

	# Create wp-config.php
	wp config create --path=$DIR_WP \
		--dbname=$DB_NAME \
		--dbuser=$DB_USER \
		--dbpass=$DB_PASS \
		--dbhost=$DB_HOST \
		--dbprefix=$DB_PREFIX \
		--dbcharset=$DB_CHAR \
		--dbcollate=$DB_COLL

	# Install Wordpress
	wp core install --path=$DIR_WP \
		--url=$URL_WS \
		--title=$TITLE_WS \
		--admin_user=$ADMIN_USER \
		--admin_password=$ADMIN_PASS \
		--admin_email=$ADMIN_EMAIL \
		--skip-email

	# Import Wordpress Database
	mysql -u "$DB_USER" -h $DB_HOST -p $DB_NAME --password="$DB_PASS" < /tmp/php/wordpress.sql
fi


# Install theme if not install
if ! wp theme is-installed twentytwenty --path=$DIR_WP ; then
	wp theme install --path=$DIR_WP twentytwenty --activate
fi

exec /usr/sbin/php-fpm81 -F
