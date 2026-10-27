#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/SQL_PASSWORD)
WP_ADMIN_PASSWORD=$(cat /run/secrets/WP_ADMIN_PASSWORD)
WP_PASSWORD=$(cat /run/secrets/WP_PASSWORD)

tries=1
echo "Waiting MariaDB"
until mariadb -h mariadb -u "${SQL_USER}" -p"${DB_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "Connection (try number $tries)"
    tries=$((tries+1))
    if [ "$tries" -gt "10" ]; then
        echo "Failed to connect after 10 tries, exiting"
        exit 1
    fi
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
else
    echo "wp-config exists"
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
else
    echo "wordpress already installed"
fi

if ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1; then
    wp user create \
        "${WP_USER}" "${WP_EMAIL}" \
        --role=author \
        --user_pass="${WP_PASSWORD}" \
        --allow-root
else
    echo "user ${WP_USER} already exists"
fi

chown -R www-data:www-data /var/www/wordpress

exec php-fpm84 -F
