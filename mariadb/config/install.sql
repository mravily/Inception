FLUSH PRIVILEGES;
-- Change root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';

-- Delete Anonymous user
DELETE FROM mysql.user WHERE User='';

-- Disable root connection from outside
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Delete test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Change the password of "mysql" user
ALTER USER 'mysql'@'localhost' IDENTIFIED BY '$DB_MYSQL_PASS';

-- Create User for manage database from Docker Network
CREATE USER IF NOT EXISTS '$DB_ADMIN'@'$DOCKER_NET.%' IDENTIFIED BY '$DB_ADMIN_PASS';

-- Grant remote access with admin user
GRANT ALL PRIVILEGES ON *.* to '$DB_ADMIN'@'$DOCKER_NET.%' IDENTIFIED BY '$DB_ADMIN_PASS' WITH GRANT OPTION;

-- Appy changes
FLUSH PRIVILEGES;