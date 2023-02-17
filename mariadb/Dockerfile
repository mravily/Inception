FROM alpine:3.17

EXPOSE 3306

# Install MariaDB dependencies 
RUN set -eax ; \
	apk update ; \
	apk upgrade ; \
	apk add --update --no-cache mariadb \
	mariadb-common \
	mariadb-client \
    rm -rf /var/lib/apt/lists/*

# Create folders and change rights for mysql user
RUN set -eax ; \
	mkdir -p /run/mysqld /tmp/mysql ;\
	chown -R mysql:mysql /etc/mysql /run/mysqld /var/lib/mysql \
    /usr/lib/mariadb /tmp/mysql /usr/bin/ /etc/my.cnf

# Copy config file
COPY tools/entrypoint.sh /

# Change main user
USER mysql

ENTRYPOINT [ "/bin/sh", "entrypoint.sh" ]