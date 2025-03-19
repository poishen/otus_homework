#!/bin/bash

DB_NAME="MYBASE"


read -p "Введите новый URL (например, http://new-ip-or-domain): " NEW_URL

# Проверка, что URL не пустой
if [ -z "$NEW_URL" ]; then
    echo "Ошибка: URL не был введен."
    exit 1
fi


sudo mysql -e "
use MYBASE;
UPDATE wp_options SET option_value = '$NEW_URL' WHERE option_name = 'siteurl';
UPDATE wp_options SET option_value = '$NEW_URL' WHERE option_name = 'home';
"

echo "успех"
