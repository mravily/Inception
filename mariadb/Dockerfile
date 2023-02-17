FROM debian:buster

EXPOSE 3306

RUN set -eax ; \
	apt update ; \
	apt -y upgrade ; \
	apt -y install mariadb-server; \
	rm -rf /var/lib/apt/lists/*

COPY config/my.cnf /etc/mysql/

COPY config/entrypoint.sh /

ENTRYPOINT [ "/bin/sh", "entrypoint.sh" ]
