# Inception

This project aims to deepen the knowledge using Docker with the implementation of a [LEMP](https://www.geeksforgeeks.org/what-is-lemp-stack/), orchestrated by Docker Compose.

All the images used are on an Alpine Linux base for optimization purposes.

```Dockerfile
FROM alpine:3.17
```

## Environement Variables

An example of `.env` is provided, the less explicit variables will be explained to help launch the project, the use of [secret](https://docs.docker.com/engine/swarm/secrets/) is privileged, we will not use it in this Docker environment

The default domain name used during development is the following, if you use another domain name with this project on your machine, you will have to make other changes to the project to make it work properly

```Dockerfile
DOMAIN_NAME="mravily.42.fr"
```

## Start the project

To launch the project, you have to fill in the env_example file, if you want to launch it in its default configuration, you can use the paths in comments, you will only have to indicate a path where the data of your machines will be stored, the user name and the password... 

You will find advanced explanations in the respective README of the services. 
- [MariaDB Readme](https://github.com/mravily/Inception/blob/fix-bug-image/mariadb/README.md)
- [Wordpress Readme](https://github.com/mravily/Inception/blob/fix-bug-image/wordpress/README.md)
- [Nginx Readme](https://github.com/mravily/Inception/blob/fix-bug-image/nginx/README.md)

You must also add to the `/etc/hosts` file of your machine the following mention for `DNS redirection`
```shell
127.0.0.1       mravily.42.fr
```

Once the env_example file is completed, rename it to .env, then launch 
```shell
make
```

When running make, you will be asked if you generate SSL certificates

```shell
[ SSL ] Do you need generate SSL certificates ? (y/n)
```

In both cases, don't forget to indicate the path where to find them in the `.env file`
```shell
PATH_DATA="/path/where/data/will/be/stored"		# ./data
```

Be patient while the services are launched in turn
```shell
[ OK ] Ready to use 🍻
```

### Disclaimer
Ce projet est à but pédagogique, il ne peut pas être utilisé en production.

### Ressources 

[Best practices for building containers](https://cloud.google.com/architecture/best-practices-for-building-containers#remove_unnecessary_tools)

[Top 20 Dockerfile best practices](https://sysdig.com/blog/dockerfile-best-practices/)

[Docker Docs](https://docs.docker.com/desktop/)

[Use set -ex in RUN command of Dockerfile](https://gitlab.com/gitlab-org/gitlab/-/issues/221030)

