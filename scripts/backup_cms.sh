#!/bin/bash
DATE=$(date +%F)

sudo mkdir /var/backups/$DATE

tar -czf "/var/backups/$DATE/wp_files_$DATE.tar.gz" /var/www/html/wordpress
