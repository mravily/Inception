# MariaDb Container

The Docker `Database Service` runs on `MariaDB Server` which a fork from `MySQL` and is 100% compatible with previous versions of MySQL

## Environement Variables

```bash
PATH_CFG="/path/to/mariadb/config" 		#./mariadb/config
DB_ROOT_PASS=
DB_MYSQL_PASS=
DB_ADMIN=
DB_ADMIN_PASS=
```

## Docker compose

Still in the first time, it is important to define the name of the service

```yaml
database:
```

### Image Build

In this part we will write the path to the Dockerfile, and the argument used until the image build

```yaml
container_name: mariadb
build:
	context: ./mariadb
	dockerfile: Dockerfile
```

### Service Container Config

Next, we will declare some additional configurations for the service to work properly

Let's tell him the way to find the .env file

```yaml
env_file:
	- .env
```

Then let's define the volumes, which will be used for the persistence of the data in case of crash, but also to transmit the configuration files of our MariaDB server

```yaml
volumes:
	- ${PATH_DATA}/database:/var/lib/mysql #data persistence
	- ${PATH_CFG}/my.cnf:/etc/my.cnf
	- ${PATH_CFG}/mariadb-server.cnf:/etc/my.cnf.d/mariadb-server.cnf
	- ${PATH_CFG}/install.sql:/tmp/install.sql
```

Before starting the other services, we need to verify that the connection to our database server is working by pinging

```yaml
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "--silent"]
```

If the service stops, Docker compose can restart it for us. In any case, we want the service to be restarted

```yaml
restart: always
```

and finally the name of the network that docker creates for the LEMP environment

```yaml
networks:
	- internal
````

## Dockerfile

First expose the port used for communication with the database server

```Dockerfile
EXPOSE 3306
```

Now let's install the MariabDB and disable the ability to install other dependencies

```Dockerfile
RUN set -eax ; \
	apk update ; \
	apk upgrade ; \
	apk add --update --no-cache mariadb \
	mariadb-common \
	mariadb-client \
    rm -rf /var/lib/apt/lists/*
```

Let's create two directories for mysql deamon and client, then we will change the property of these and other directories, so that they can be used without problems during execution

```Dockerfile
RUN set -eax ; \
	mkdir -p /run/mysqld /tmp/mysql ;\
	chown -R mysql:mysql /etc/mysql /run/mysqld /var/lib/mysql \
    /usr/lib/mariadb /tmp/mysql /usr/bin/ /etc/my.cnf
````

Copy the entrypoint config script inside the container

```Dockerfile
COPY tools/entrypoint.sh /
```

Change Docker container main user

```Dockerfile
USER mysql
```

Lauch the config script and start the `MariaDB Deamon`

```Dockerfile
ENTRYPOINT [ "/bin/sh", "entrypoint.sh" ]
````

## Ressources

[Beginner's Guide MariaDB](https://www.fosslinux.com/category/mariadb)

[Automating `mysql_secure_installation`](https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/)

[Official MariaDB Docs](https://mariadb.com/kb/en/documentation/)

[MySQL Tutorial](https://www.mysqltutorial.org/)

