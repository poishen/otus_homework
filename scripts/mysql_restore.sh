#!/bin/bash

GIT_REPO="https://github.com/poishen/otus_homework.git"
CLONE_DIR="/var/local/repo_mysql"
DB_NAME="MYBASE"
DB_USER="user"
DB_PASS="123456Aa"
read -p "введите ip адрес мастера" MASTER_IP
echo "Созданиие директорий"
sudo mkdir /var/local/repo_mysql

echo "Обновление пакетов"
sudo apt update && sudo apt upgrade -y

# Установка Apache2 и Nginx

echo "Установка необходимых пакетов"
sudo apt install -y mysql-server

echo "Скачивание репозитория" 

sudo git clone --branch master "$GIT_REPO" "$CLONE_DIR"


read -p "Выберите опцию (1 мастер или 2 слейв):" choice

if [ "$choice" = "1" ]; then
  echo "1 — выполняется восстановление мастера"

echo "Копирование конфигов mysql_master"
sudo cp $CLONE_DIR/mysql/mysqld_master.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

elif [ "$choice" = "2" ]; then
  echo "2 — выполняется восстановление слейва"
  sudo cp $CLONE_DIR/mysql_slave/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
else
  echo "Неверный выбор"
fi

echo "Восстановление базы данных"
sudo mysql < $CLONE_DIR/backups/backup_mysql.sql

sudo systemctl restart mysql.service

read -p "Выберите опцию (1 мастер или 2 слейв):" choice

if [ "$choice" = "1" ]; then
  echo "1 - выполняется конфигурация репликации на мастере"
  sudo mysql -e "
ALTER USER 'replica'@'%' IDENTIFIED WITH 'caching_sha2_password' BY '123456Aa';
SET @@GLOBAL.read_only = ON;
"

elif [ "$choice" = "2" ]; then
  echo "2 -  - выполняется конфигурация репликации на слейве"
  sudo mysql -e "
SET @@GLOBAL.read_only = ON;
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='$MASTER_IP',
  SOURCE_USER='replica',
  SOURCE_PASSWORD='123456Aa',
  SOURCE_AUTO_POSITION=1,
GET_MASTER_PUBLIC_KEY = 1;


"

else
  echo "Неверный выбор"
fi
