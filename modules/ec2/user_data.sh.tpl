#!/bin/bash
set -euo pipefail
exec > /var/log/zabbix-install.log 2>&1

export DEBIAN_FRONTEND=noninteractive

# ── System update ──────────────────────────────────────────────────────────────
apt-get update -y
apt-get upgrade -y

# ── PostgreSQL ─────────────────────────────────────────────────────────────────
apt-get install -y postgresql postgresql-contrib

systemctl enable postgresql
systemctl start postgresql

sudo -u postgres psql -c "CREATE USER ${db_user} WITH PASSWORD '${db_password}';"
sudo -u postgres psql -c "CREATE DATABASE ${db_name} OWNER ${db_user} ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8' TEMPLATE template0;"

# ── Zabbix 7.x LTS ────────────────────────────────────────────────────────────
wget -q https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest+ubuntu22.04_all.deb
apt-get update -y

apt-get install -y \
  zabbix-server-pgsql \
  zabbix-frontend-php \
  zabbix-nginx-conf \
  zabbix-sql-scripts \
  zabbix-agent2

# ── Import initial schema ──────────────────────────────────────────────────────
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz \
  | sudo -u postgres psql -d ${db_name}

sudo -u postgres psql -d ${db_name} -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${db_user};"
sudo -u postgres psql -d ${db_name} -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${db_user};"

# ── Zabbix server config ───────────────────────────────────────────────────────
sed -i "s/^# DBPassword=.*/DBPassword=${db_password}/" /etc/zabbix/zabbix_server.conf
sed -i "s/^DBName=.*/DBName=${db_name}/" /etc/zabbix/zabbix_server.conf
sed -i "s/^DBUser=.*/DBUser=${db_user}/" /etc/zabbix/zabbix_server.conf

# ── Nginx config ───────────────────────────────────────────────────────────────
# Uncomment listen and server_name in Zabbix nginx conf
sed -i 's/#        listen          80;/        listen          80;/' /etc/zabbix/nginx.conf
sed -i 's/#        server_name     example.com;/        server_name     _;/' /etc/zabbix/nginx.conf

# ── Zabbix agent2 (monitors the server itself) ─────────────────────────────────
sed -i "s/^Server=.*/Server=127.0.0.1/" /etc/zabbix/zabbix_agent2.conf
sed -i "s/^ServerActive=.*/ServerActive=127.0.0.1/" /etc/zabbix/zabbix_agent2.conf
sed -i "s/^Hostname=.*/Hostname=Zabbix server/" /etc/zabbix/zabbix_agent2.conf

# ── Enable and start services ──────────────────────────────────────────────────
systemctl enable zabbix-server zabbix-agent2 nginx php8.1-fpm
systemctl restart zabbix-server zabbix-agent2 nginx php8.1-fpm

echo "Zabbix installation complete at $(date)" >> /var/log/zabbix-install.log
