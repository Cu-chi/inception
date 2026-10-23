#!/bin/sh
set -e

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# init if database isn't created yet
if [ ! -d "/var/lib/mysql/mysql" ]; then
    DB_PASSWORD=$(cat /run/secrets/SQL_PASSWORD)
    DB_ROOT_PASSWORD=$(cat /run/secrets/SQL_ROOT_PASSWORD)
    
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null

    # bootstrap mode starts without network
    mariadbd --user=mysql --bootstrap <<EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
EOF

fi

exec mariadbd --user=mysql
