#!/bin/bash

# Настройки базы данных
DB_USER="root"
read -p "введите пароль от mysql root" DB_PASSWORD
BACKUP_DIR="/home/user/db_backup"
BINLOG_INFO_FILE="$BACKUP_DIR/binlog_info.txt" 

# Создаем директорию для бэкапов, если она не существует
mkdir -p "$BACKUP_DIR"

# Получаем список баз данных
DATABASES=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;" | awk 'NR>1' | grep -Ev "^(information_schema|performance_schema|mysql|sys)$")

# Проверяем, удалось ли получить список баз данных
if [ -z "$DATABASES" ]; then
  echo "Ошибка: Не удалось получить список баз данных."
  exit 1
fi

# Получаем позицию бинлога
mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW MASTER STATUS;" > "$BINLOG_INFO_FILE"

# Проверяем, удалось ли получить информацию о бинлоге
if [ $? -ne 0 ]; then
  echo "Ошибка: Не удалось получить информацию о бинлоге."
  exit 1
fi

echo "Информация о бинлоге сохранена в $BINLOG_INFO_FILE"

# Проходим по каждой базе данных
for DB_NAME in $DATABASES; do
  echo "Бэкап базы данных: $DB_NAME"

  # Создаем директорию для базы данных
  DB_BACKUP_DIR="$BACKUP_DIR/$DB_NAME"
  mkdir -p "$DB_BACKUP_DIR"

  # Получаем список таблиц для текущей базы данных
  TABLES=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW TABLES IN $DB_NAME;" | awk 'NR>1')

  # Проверяем, удалось ли получить список таблиц
  if [ -z "$TABLES" ]; then
    echo "Ошибка: Не удалось получить список таблиц для базы данных '$DB_NAME'."
    continue
  fi

  # Делаем бэкап каждой таблицы
  for TABLE in $TABLES; do
    echo "  Бэкапим таблицу: $TABLE"
    mysqldump --master-data=2 -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" "$TABLE" > "$DB_BACKUP_DIR/$TABLE.sql"
    if [ $? -eq 0 ]; then
      echo "  Таблица $TABLE успешно забэкаплена."
    else
      echo "  Ошибка при бэкапе таблицы $TABLE."
    fi
  done

  # Бэкапим всю базу данных целиком
  echo "  Бэкапим всю базу данных целиком: $DB_NAME"
  mysqldump --master-data=2 -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$DB_BACKUP_DIR/$DB_NAME.sql"
  if [ $? -eq 0 ]; then
    echo "  База данных $DB_NAME успешно забэкаплена."
  else
    echo "  Ошибка при бэкапе базы данных $DB_NAME."
  fi

done

done

echo "Бэкап всех баз данных завершен."
