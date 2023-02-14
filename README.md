# Inception

Ce projet a pour but d’approfondir les connaissances en utilisant  Docker avec mise en place d'un [LEMP](https://www.geeksforgeeks.org/what-is-lemp-stack/), orchestrer par Docker Compose.

Toutes les images utilisés sont sur une base Alpine Linux dans un soucis de d'optimisation.

```Dockerfile
FROM alpine:3.17
```

## Environement Variables

Une exemple de `.env` est mis à disposition, les variables les moins explicites seront expliqués pour aider au lancement du projet, l'utilisation de [secret](https://docs.docker.com/engine/swarm/secrets/) est à priviligié, nous n'en utiliserons pas dans cette environement Docker

Le nom de domaine utilisé par défault lors du dévelopement est le suivant, si vous venez à utiliser un autre nom de domaine avec ce projets sur votre machine, il faudra apporter d'autre changement au projets pour qu'il fonctionne correctement

```Dockerfile
DOMAIN_NAME="mravily.42.fr"
```

```Dockerfile
PHP_DB="/path/to/db/configs/for/wp"
```

Indique le chemin vers un dossier contenant 2 fichiers
 - `db.sql` (Contient les instructions pour créer la DB utilisé par WP et l'user la managant)
 - `wordpress.sql` (La DB du site utilisé lors du dévellopement)

### Disclaimer
Ce projet est à but pédagogique, il ne peut pas être utilisé en production.

### Ressources 
[Configure TLS on NGINX](https://hackernoon.com/how-properly-configure-nginx-server-for-tls-sg1d3udt)

[Custom MariaDB Docker Image](https://mariadb.com/kb/en/creating-a-custom-docker-image/)

[Install MariaDB on Linux](https://www.fosslinux.com/47885/install-mariadb-linux-windows.htm)

[MySQL Tutorial](https://www.mysqltutorial.org/)

[Automating mariadb secure installation](https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/)

[PHP fastCGI Nginx Exemple](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/)

[Httpoxy vulnerabily](https://httpoxy.org/)

[WP-CLI Documentation](https://wp-cli.org)
