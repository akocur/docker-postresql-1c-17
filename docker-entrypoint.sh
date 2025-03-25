#!/bin/bash
set -e

# Функция для инициализации базы данных
init_db() {
    if [ ! -s "$PGDATA/PG_VERSION" ]; then
        echo "Initializing PostgreSQL database..."
        /opt/pgpro/1c-17/bin/initdb -D "$PGDATA"

        # Настройка конфигурации
        echo "listen_addresses = '*'" >> "$PGDATA/postgresql.conf"
        echo "max_connections = 100" >> "$PGDATA/postgresql.conf"
        echo "shared_buffers = 128MB" >> "$PGDATA/postgresql.conf"
        echo "dynamic_shared_memory_type = posix" >> "$PGDATA/postgresql.conf"
        echo "max_locks_per_transaction = 256" >> "$PGDATA/postgresql.conf"
        echo "host all all all md5" >> "$PGDATA/pg_hba.conf"
    fi
}

# Если первый аргумент - init, инициализируем базу данных
if [ "$1" = 'init' ]; then
    init_db
    exit 0
fi

# Если первый аргумент - bash или sh, выполняем его напрямую
if [ "$1" = 'bash' ] || [ "$1" = 'sh' ]; then
    exec "$@"
fi

# Если первый аргумент начинается с тире, предполагаем, что пользователь хочет запустить postgres
if [ "${1:0:1}" = '-' ]; then
    set -- /opt/pgpro/1c-17/bin/postgres "$@"
fi

# Если первый аргумент содержит слэш, предполагаем, что пользователь хочет запустить свою программу
if [ "${1:0:1}" = '/' ]; then
    exec "$@"
fi

# Проверяем, инициализирована ли база данных
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    init_db
fi

# Иначе предполагаем, что пользователь хочет запустить команду postgres
exec /opt/pgpro/1c-17/bin/postgres "$@"
