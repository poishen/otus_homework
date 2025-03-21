
#!/bin/bash

GIT_REPO="https://github.com/poishen/otus_homework.git"
CLONE_DIR="/var/local/repo/"
DB_NAME="MYBASE"
DB_USER="user"
DB_PASS="123456Aa"


echo "Созданиие директорий"
sudo mkdir /var/local/repo


echo "Обновление пакетов"
sudo apt update && sudo apt upgrade -y

# Установка Apache2 и Nginx

echo "Установка необходимых пакетов"
sudo apt install -y apache2 nginx mysql-server php php-mysql libapache2-mod-php php-cli php-cgi php-gd unzip

echo "Добавление в автозагрузку"
sudo systemctl enable --now apache2 mysql nginx

echo "Скачивание репозитория" 

sudo git clone --branch master "$GIT_REPO" "$CLONE_DIR"

echo "Настройка конфигов"
echo "Копирование конфигов apache2."
sudo cp /var/local/repo/apache2/apache2.conf /etc/apache2/apache2.conf
echo "Копирование конфигов apache2.."
sudo cp /var/local/repo/apache2/wordpress.conf /etc/apache2/sites-available/wordpress.conf
echo "Копирование конфигов apache2..."
sudo cp /var/local/repo/apache2/wordpress2.conf /etc/apache2/sites-available/wordpress2.conf
sudo  a2dissite 000-default.conf
sudo a2ensite wordpress*
sudo cp /var/local/repo/apache2/ports.conf /etc/apache2/ports.conf
sudo systemctl restart apache2
echo "Копирование конфигов nginx"
sudo cp /var/local/repo/nginx/default /etc/nginx/sites-available/default

sudo cp /var/local/repo/nginx/nginx.conf /etc/nginx/nginx.conf
echo "Копирование конфигов mysql"
sudo cp /var/local/repo/mysql/mysqld_master.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
echo "Копирование crontab"
sudo cp /var/local/repo/cron/crontab /etc/crontab
echo "Восстановление базы данных"
sudo mysql < /var/local/repo/backups/backup_mysql.sql
echo "Востановление файлов  cms"
sudo mkdir /var/www/html
sudo mkdir /var/www/html/wordpress
sudo tar -xzf /var/local/repo/backups/wp_backup.tar.gz -C /var/local/repo/backups/
sudo cp -r /var/local/repo/backups/var/www/html/wordpress/* /var/www/html/wordpress/
echo "Настройка прав для папок сайта"
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

sudo systemctl restart --now apache2 mysql nginx
echo "Все готово, не забудь внести изменения в файл hosts для подключения mysql-slave"
 
