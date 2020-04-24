# TundraSoft - SAMBA Docker

PostgreSQL is a powerful, open source object-relational database system with over 30 years of active development that has earned it a strong reputation for reliability, feature robustness, and performance.

# Usage

You can run the docker image by

## docker run

```
docker run \
 --name=postgres \
 -p 5432:5432 \
 -e TZ=Europe/London \
 -e POSTGRES_PASSWORD= \
 -e POSTGRES_USER= \
 -e POSTGRES_DATABASE= \
 -v <volume name>:/data \
 -v <volume name>:/init.d \
 --restart unless-stopped \
 tundrasoft/postgres-docker:latest
```

## docker Create

```
docker run \
 --name=postgres \
 -p 5432:5432 \
 -e TZ=Europe/London \
 -e POSTGRES_PASSWORD= \
 -e POSTGRES_USER= \
 -e POSTGRES_DATABASE= \
 -v <volume name>:/data \
 -v <volume name>:/init.d \
 --restart unless-stopped \
 tundrasoft/postgres-docker:latest
```

## docker-compose

```
version: "3.2"
services:
  mariadb:
    image: tundrasoft/postgres-docker:latest
    ports:
      - 5432:5432
    environment:
      - TZ=Asia/Kolkata # Specify a timezone to use EG Europe/London
      - POSTGRES_USER=
      - POSTGRES_PASSWORD=
      - POSTGRES_DATABASE=
    volumes:
      - <volume name>:/data # Where postgres data resides
      - <volume name>:/init.d # Path where you can put the initialization files (supported are sql, sql.gz and bash files)
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
```

## Ports

5432 - The default port for postgresql

## Variables

### TZ

The timezone to use.

### POSTGRES_USER

A custom username to use to login to postgres. If left blank, it defaults to postgres user.
This is only created on the first execution

Default is postgres

### POSTGRES_PASSWORD

Password for the custom user created, if POSTGRES_USER is blank, then this password will be set for postgres user.
If a username is provided but no password, then a password is generated.
This is only created on the first execution

Default - randomly generated

### POSTGRES_DATABASE

The database to create by default during the first run
This is only created on the first execution

## Volumes

### Data - /data

The main data store volume for postgres. This contains actual data, transaction logs, error logs and config files.
Be very very careful editing these files

### init.d - /init.d

Place all files which needs to be executed during first deployment here. This will execute and files
with .sql, .sql.gz and .sh extensions
Useful if trying to migrate/load existing data to the database automagically
