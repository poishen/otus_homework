#!/bin/bash

GIT_REPO="https://github.com/poishen/otus_homework.git"
CLONE_DIR="/var/local/repo/"
read -p "Введите ip адрес mysql master " MASTER_HOST
MASTER_USER="replica"             # Репликационный пользователь на master
MASTER_PASSWORD="123456Aa"     # Пароль для репликационного пользователя



echo "Созданиие директорий"
sudo mkdir /var/local/repo


echo "Обновление пакетов"
sudo apt update && sudo apt upgrade -y

# Установка Apache2 и Nginx

echo "Установка необходимых пакетов"
sudo apt install -y mysql-server


echo "Скачивание репозитория" 

sudo git clone --branch master "$GIT_REPO" "$CLONE_DIR"


echo "Копирование конфигов mysql"
sudo cp /var/local/repo/mysql_slave/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf


echo "Подключаюсь к мастер-серверу $MASTER_HOST..."
sudo mysql -e "
STOP SLAVE;
CHANGE MASTER TO 
  MASTER_HOST='$MASTER_HOST',
  MASTER_USER='$MASTER_USER',
  MASTER_PASSWORD='$MASTER_PASSWORD',
  MASTER_AUTO_POSITION=1
GET_SOURCE_PUBLIC_KEY = 1;
START REPLICA;
"
