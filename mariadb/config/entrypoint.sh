# db_root_password="${1}"
db_root_password="test"


mysql_install_db

# Start the mysql service
/etc/init.d/mysql start

# Securising the mariadb installation
# mariadb -u root << _EOF_
#   UPDATE mysql.user SET Password=PASSWORD('${db_root_password}') WHERE User='root';
#   DELETE FROM mysql.user WHERE User='';
#   DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
#   DROP DATABASE IF EXISTS test;
#   DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
#   FLUSH PRIVILEGES;
# _EOF_

# mariadb -u root --execute="UPDATE mysql.user SET Password=PASSWORD('${db_root_password}') WHERE User='root';"
# mariadb -u root --execute="DELETE FROM mysql.user WHERE User='';"
# mariadb -u root --execute="DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
# mariadb -u root --execute="DROP DATABASE IF EXISTS test;"
# mariadb -u root --execute="DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
# mariadb -u root --execute="FLUSH PRIVILEGES;"


# Create database will used by wordpress service
mariadb -u root --execute="CREATE DATABASE IF NOT EXISTS wp_db;"
# Creation d'un nouvelle utilisateur pour la gestion de la DB Wordpress.
mariadb -u root --execute="CREATE USER 'root'@'%' IDENTIFIED BY 'toor'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
mariadb -u root --execute="USE wp_db;"
mariadb -u root --execute="FLUSH PRIVILEGES;"

/etc/init.d/mysql stop

mariadb -u root wp_db < data.sql

cd '/usr' ; /usr/bin/mysqld_safe --datadir='/var/lib/mysql'
