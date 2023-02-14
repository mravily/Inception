-- Create database for wordpress
CREATE DATABASE IF NOT EXISTS $DB_NAME;

-- Create user for manage wordpress database
CREATE USER IF NOT EXISTS '$DB_USER'@'$DOCKER_NET.%' IDENTIFIED BY '$DB_PASS';

-- Grant user to manage db
GRANT ALL ON $DB_NAME.* to '$DB_USER'@'$DOCKER_NET.%' IDENTIFIED BY '$DB_PASS';

-- Apply changes
FLUSH PRIVILEGES;
