FROM debian:buster

EXPOSE 3306

RUN set -eax ; \
	apt update ; \
	apt -y upgrade ; \
	apt -y install mariadb-server mariadb-client ; \
	rm -rf /var/lib/apt/lists/*

# COPY config/my.cnf /etc/

COPY	config/entrypoint.sh			/

ENTRYPOINT [ "/bin/sh", "entrypoint.sh" ]