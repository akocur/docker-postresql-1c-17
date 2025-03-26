DockerFile для https://hub.docker.com/repository/docker/akocur/postgresql-1c-17/

# Инструкция по использованию Docker-контейнера PostgreSQL для 1С

## Данные о процессе и пользователе.
- Процесс запускается от имени postgres.
- Пароль пользователя postgres: password.

## Что такое точка входа (entrypoint)
Точка входа в Docker - это исполняемый файл, который запускается при старте контейнера. В этом образе это скрипт docker-entrypoint.sh, который обрабатывает аргументы командной строки и определяет, какую команду выполнить внутри контейнера.

## Как работает скрипт docker-entrypoint.sh
Скрипт обрабатывает аргументы следующим образом:

* Если первый аргумент начинается с тире (-), скрипт предполагает, что это параметры для PostgreSQL и добавляет путь к исполняемому файлу PostgreSQL перед аргументами.
* Если первый аргумент начинается со слэша (/), скрипт предполагает, что пользователь хочет запустить свою программу и выполняет команду как есть.
* В остальных случаях скрипт запускает PostgreSQL с переданными аргументами.

## Что можно передавать в точку входа
### 1. Параметры PostgreSQL
Вы можете передавать любые параметры командной строки PostgreSQL:

```
docker run -d --name postgresql-1c-17 akocur/postgresql-1c-17:latest -c "max_connections=200" -c "shared_buffers=256MB"

```
Здесь `-c "max_connections=200"` и `-c "shared_buffers=256MB"` - это параметры PostgreSQL.

### 2. Пути к исполняемым файлам
Вы можете запустить любую программу, указав полный путь:

```
docker run -it --name postgresql-1c-17 akocur/postgresql-1c-17:latest /bin/bash

```
### 3. Команды инициализации базы данных
```
docker run -it --name postgresql-1c-17 akocur/postgresql-1c-17:latest /opt/pgpro/1c-17/bin/initdb -D /path/to/data

```
## Инструкция по использованию контейнера PostgreSQL для 1С

### Запуск PostgreSQL с настройками по умолчанию
```
docker run -d --name postgresql-1c-17 -p 5432:5432 -v pg_data:/var/lib/pgpro/1c-17/data akocur/postgresql-1c-17:latest
```
### Запуск PostgreSQL с пользовательскими параметрами
```
docker run -d --name postgresql-1c-17 -p 5432:5432 -v pg_data:/var/lib/pgpro/1c-17/data akocur/postgresql-1c-17:latest -c "max_connections=200" -c "shared_buffers=256MB"

```
### Запуск bash внутри контейнера
```
docker run -it --name postgresql-1c-17 akocur/postgresql-1c-17:latest /bin/bash

```
### Выполнение команды внутри работающего контейнера
```
docker exec -it postgresql-1c-17 /bin/bash

```

### Остановка и удаление контейнера
```
docker stop postgresql-1c-17
docker rm postgresql-1c-17
```

## Сохранение и восстановление данных
Для сохранения данных используйте тома Docker:

```
docker run -d --name postgresql-1c-17 -p 5432:5432 -v pg_data:/var/lib/pgpro/1c-17/data akocur/postgresql-1c-17:latest

```
### Для резервного копирования:
```
docker exec -it postgresql-1c-17 bash -c "su - postgres -c \"/opt/pgpro/1c-17/bin/pg_dump db1c > /tmp/backup.sql\""
docker cp postgresql-1c-17:/tmp/backup.sql ./backup.sql
```

### Для восстановления:
```
docker cp ./backup.sql postgresql-1c-17:/tmp/backup.sql
docker exec -it postgresql-1c-17 bash -c "su - postgres -c \"psql db1c < /tmp/backup.sql\""
```

## Выход из контейнера
Чтобы выйти из запущенного контейнера, в котором вы находитесь в интерактивном режиме, используйте:

```
exit
```

или комбинацию клавиш `Ctrl + D`

Если вы хотите выйти из контейнера, но оставить его работающим в фоновом режиме, используйте комбинацию клавиш: `Ctrl + P`, затем `Ctrl + Q`
