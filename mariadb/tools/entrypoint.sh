export DOCKER_NET=$(awk 'END{print $1}' /etc/hosts | awk -F  '.' '{ print $1"."$2"."$3;}')

# First install mariadb
mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

# Launch mariaDB deamon in background with a config file
eval "echo \"$(cat /tmp/install.sql)\"" | /usr/bin/mysqld --user=mysql --bootstrap --skip-networking=0

# Launch server
exec /usr/bin/mysqld_safe --datadir=/var/lib/mysql/