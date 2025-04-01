FROM debian:12

# Установка необходимых пакетов
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    ca-certificates \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Настройка локалей
RUN sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=ru_RU.UTF-8
ENV LC_ALL=ru_RU.UTF-8

# Добавление репозитория PostgreSQL для 1С
WORKDIR /tmp
RUN wget https://repo.postgrespro.ru/1c/1c-17/keys/pgpro-repo-add.sh && \
    chmod +x pgpro-repo-add.sh && \
    ./pgpro-repo-add.sh && \
    rm pgpro-repo-add.sh

# Установка PostgreSQL для 1С
RUN apt-get update && \
    apt-get install -y postgrespro-1c-17 && \
    rm -rf /var/lib/apt/lists/*

# Копирование скриптов инициализации
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Переключение на пользователя postgres
USER postgres

RUN /opt/pgpro/1c-17/bin/pg_ctl -D /var/lib/pgpro/1c-17/data -o "-c listen_addresses=''" -w start && \
    /opt/pgpro/1c-17/bin/psql --command "ALTER USER postgres WITH PASSWORD 'password';" && \
    /opt/pgpro/1c-17/bin/pg_ctl -D /var/lib/pgpro/1c-17/data -m fast -w stop

# Открытие порта PostgreSQL
EXPOSE 5432

# Установка точки входа
ENTRYPOINT ["docker-entrypoint.sh"]

# Запуск PostgreSQL при старте контейнера
CMD ["/opt/pgpro/1c-17/bin/postgres", "-D", "/var/lib/pgpro/1c-17/data"]
