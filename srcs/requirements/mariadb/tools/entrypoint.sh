#!/bin/sh
set -e

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

DB_PASSWORD=$(cat /run/secrets/SQL_PASSWORD)
DB_ROOT_PASSWORD=$(cat /run/secrets/SQL_ROOT_PASSWORD)

# init if database isn't created yet
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null

    # temp start without networking
    mariadbd-safe --skip-networking &
    pid="$!"

    # wait for MariaDB
    until mariadb-admin ping --silent; do
        sleep 1
    done

    # creation of db, users and secure root
    mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # stop temp process
    mariadb-admin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

exec mariadbd-safe
