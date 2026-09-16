#!/bin/sh
set -e

# Préparation des répertoires d'exécution et de données avec les bons droits
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

DB_PASSWORD=$(cat /run/secrets/SQL_PASSWORD)
DB_ROOT_PASSWORD=$(cat /run/secrets/SQL_ROOT_PASSWORD)

# Initialisation uniquement si la base n'a jamais été créée
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null

    # Démarrage temporaire en arrière-plan sans ouvrir le réseau externe
    mariadbd-safe --skip-networking &
    pid="$!"

    # Attente active que MariaDB réponde sur la socket locale
    until mariadb-admin ping --silent; do
        sleep 1
    done

    # Création de la base, des comptes et sécurisation du root
    mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # Arrêt propre du serveur temporaire et attente de fin du processus
    mariadb-admin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

# Démarrage final au premier plan (PID 1 du conteneur)
exec mariadbd-safe
