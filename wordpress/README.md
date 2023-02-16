# Wordpress Container

This Docker container will run `PHP FPM` for offload our `Nginx` container from interpreting `Wordpress PHP files`

## Environement Variables
```bash
DOMAIN_NAME="your-domain" # mravily.42.fr
# Docker compose
PHP_CFG="/path/to/php/config/files"  #./wordpress/config/www.conf
PHP_DB="/path/to/db/configs/wp"		 #./wordpress/config/db

# Wordpress
DIR_WP="/path/inside/docker/where/install/wp" ## /var/www/inception
# wp-config.php
DB_USER=
DB_PASS=
DB_HOST="name_service_db" #database
DB_PREFIX="wp_"
DB_CHAR="utf8"
DB_COLL="" # Leave empty unless you know
# Install Website
URL_WS="https://$DOMAIN_NAME"
TITLE_WS=
ADMIN_USER=
ADMIN_PASS=
ADMIN_EMAIL=

# For Healthcheck php-fpm server
SCRIPT_NAME=/ping
SCRIPT_FILENAME=/ping
REQUEST_METHOD=GET
```

## Dockerfile
In First, we will expose the `port 9000` of the container that will be used for our service

```Dockerfile
EXPOSE 9000
```

We need to install `PHP` with somes packages and the `MariaDB Client` to easily communicate with our `Server Database`.

 - `php81` - bundles packages
 - `php81-fpm` - bundles for FastCGI communication
 - `php81-mbstring` - Used to properly handle UTF8 text. script
 - `php81-mysqli` - allows you to access the functionality provided by MySQL
 - `php81-phar` - (PHP Archive) for easy distribution and installation
 - `mariadb-client` - for communicate with database
 - `fcgi` - packages for comunicate with php-fpm server

```Dockerfile
RUN set -eux ; \
	apk update ; \
	apk upgrade ; \
	apk add --update --no-cache curl php81 \
		php81-fpm \
		php81-mysqli \
		php81-mbstring \
		php81-iconv \
		mariadb-client \
	rm -rf /var/lib/apt/lists/*
```

Let's download the `wp-cli` binary, that we allow us to manage `Wordpress` with command line, and give it necessary the rights to be executed

```Dockerfile
RUN set -eux ; \
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar ; \
	chmod +x wp-cli.phar ; \
	mv wp-cli.phar /usr/local/bin/wp 
```

For `security reason`, we will create a user with sufficient rights for php, to `avoid any root action during execution` 

```Dockerfile
RUN set -eux ; \
	adduser -u 82 -D -S -G www-data www-data ; \	
	chown -R www-data:www-data /etc/php81 /var/log/php81
```

Next we will copy our `entrypoint script`, that we contain all the steps to configure the service 

```Dockerfile
COPY tools/entrypoint.sh /
````

Tell `Docker Engine` to run our container as user `www-data`

```Dockerfile
USER www-data
```

Before running the `php fpm` process, we need to be in the right directory for it to find the `wordpress files` to interpret, you can also specify the directory path in the `php.ini` configuration file

```Dockerfile
WORKDIR ${DIR_WP}  ## /var/www/inception
```

And finally, we execute the `entrypoint script` while the container is running.

```Dockerfile
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
```

### Entrypoint Script

`ENTRYPOINT` is usually used to execute a configuration script, it can also be overloaded to execute an arbitrary command

```shell
docker run --entrypoint /bin/sh myservice
```

To allow dynamic configurations from the service, we need to get the first three values of the Docker network IP address

```bash
export DOCKER_NET=$(awk 'END{print $1}' /etc/hosts | awk -F  '.' '{ print $1"."$2"."$3;}')

$> echo DOCKER_NET 
192.168.48
```

It is possible that our service is interrupted for some reason, to avoid a double installation of Wordpress that would prevent the restart of the service, we will check if wp is installed, in this case we continue the installation steps

```bash
if [ ! wp core is-installed --path=$DIR_WP ] ; then
```

The following line is divided into two parts, first we will use `eval` to replace the `environment variable` in `db.sql`, then we will send the output to our `database server` with the `MariaDB client`

```bash
eval "echo \"$(cat /tmp/php/db.sql)\"" | mysql -u $DB_ADMIN -h $DB_HOST --password=$DB_ADMIN_PASS
```


To install and configure our Wordpress, we will perform some steps with wp-cli, starting by downloading it

```bash
wp core download --path=$DIR_WP   ## /var/www/inception
```


Next, we will create `wp-config.php`, it is used to make the connection between the website and the database server

```bash
wp config create --path=$DIR_WP \
	--dbname=$DB_NAME \
	--dbuser=$DB_USER \
	--dbpass=$DB_PASS \
	--dbhost=$DB_HOST \
	--dbprefix=$DB_PREFIX \
	--dbcharset=$DB_CHAR \
	--dbcollate=$DB_COLL
```

Let's install it

```bash
wp core install --path=$DIR_WP \
	--url=$URL_WS \
	--title=$TITLE_WS \
	--admin_user=$ADMIN_USER \
	--admin_password=$ADMIN_PASS \
	--admin_email=$ADMIN_EMAIL \
	--skip-email
```

And to finish with `Wordpress`, we will `install a theme`, free to choose any of the themes present in the `theme library`

```bash
wp theme install --path=$DIR_WP twentytwenty --activate
```

The second last line is optional, because it sends a `Wordpress database` already configured

```bash
mysql -u "$DB_USER" -h $DB_HOST -p $DB_NAME --password="$DB_PASS" < /tmp/php/wordpress.sql
```

Execute now our `php fpm` process with `-F` option for running in foreground

```bash
exec /usr/sbin/php-fpm81 -F
```


## db.sql

This file provides the necessary configuration to manage the Wordpress database

We will create the worpdress database 

```sql
CREATE DATABASE IF NOT EXISTS $DB_NAME;
```

Then we create a user to `access the database only from our Docker network`

```sql
CREATE USER IF NOT EXISTS '$DB_USER'@'$DOCKER_NET.%' IDENTIFIED BY '$DB_PASS';
```

Let's then authorize our user to manage the `Wordpress` database, still only from the `Docker network`

```sql
GRANT ALL ON $DB_NAME.* to '$DB_USER'@'$DOCKER_NET.%' IDENTIFIED BY '$DB_PASS';
```

Apply the changes to the `MariaDB Server`.

```sql
FLUSH PRIVILEGES;
```

## Ressources

[PHP Packages for Wordpress](https://make.wordpress.org/hosting/handbook/server-environment/)

[Configure Php Fpm for nginx](https://www.digitalocean.com/community/tutorials/php-fpm-nginx)

[WP-CLI Documentation](https://wp-cli.org/)

[Replace Env Var in SQL File](https://stackoverflow.com/questions/18725880/using-an-environment-variable-in-a-psql-script)

[Connect to PHP-FPM directly](https://easyengine.io/tutorials/php/directly-connect-php-fpm/)