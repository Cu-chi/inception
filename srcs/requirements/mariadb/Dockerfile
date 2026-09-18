FROM alpine:3.23.5

RUN apk add --no-cache mariadb mariadb-client

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
