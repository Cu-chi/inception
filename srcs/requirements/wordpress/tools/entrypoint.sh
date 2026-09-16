#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/SQL_PASSWORD)
WP_ADMIN_PASSWORD=$(cat /run/secrets/WP_ADMIN_PASSWORD)
WP_PASSWORD=$(cat /run/secrets/WP_PASSWORD)

echo "Waiting MariaDB"
until mariadb -h mariadb -u "${SQL_USER}" -p"${DB_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 1
done
echo "MariaDB ready"

if [ ! -f "wp-config.php" ]; then
    wp config create \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        "${WP_USER}" "${WP_EMAIL}" \
        --role=author \
        --user_pass="${WP_PASSWORD}" \
        --allow-root
fi

exec php-fpm84 -F
