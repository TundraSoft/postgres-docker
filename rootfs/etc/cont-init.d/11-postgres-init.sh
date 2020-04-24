#!/usr/bin/with-contenv sh
# Set Variables
if [ ! -f /data/postgresql.conf ]; then
  authMethod=md5
  POSTGRES_USER=${POSTGRES_USER:-"postgres"}
  POSTGRES_DATABASE=${POSTGRES_DATABASE:-"postgres"}
  if [ -z "$POSTGRES_PASSWORD" ]; then
    # Set root password
    echo "[w] Password is not set for user $POSTGRES_USER"
    echo "[i] If you want to set it yourself, then set the ENV variable POSTGRES_PASSWORD"
    POSTGRES_PASSWORD=`pwgen 16 1`
    echo "[i] Password for user $POSTGRES_USER set as: $POSTGRES_PASSWORD"
    # Set auth mode to trust as password is not set
  fi
  # Initialize
  # exec s6-setuidgid postgres initdb
  s6-setuidgid postgres initdb
  echo "[i] Done initializing postgres"
  sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" ${PGDATA}/postgresql.conf
  if [ "$POSTGRES_DATABASE" != 'postgres' ]; then
    createSql="CREATE DATABASE $POSTGRES_DATABASE;"
    echo $createSql | s6-setuidgid postgres postgres --single -jE
    echo
  fi
  if [ "$POSTGRES_USER" != 'postgres' ]; then
    echo "[i] Creating user $POSTGRES_UDER with password: $POSTGRES_PASSWORD"
    userSql="CREATE USER $POSTGRES_USER WITH SUPERUSER PASSWORD '$POSTGRES_PASSWORD';"
  else
    echo "[i] Updating password for user $POSTGRES_USER: $POSTGRES_PASSWORD"
    userSql="ALTER USER $POSTGRES_USER WITH SUPERUSER PASSWORD '$POSTGRES_PASSWORD';"
  fi
  # Alter/Create user
  echo $userSql | s6-setuidgid postgres postgres --single -jE
  echo "[i] Updated user records."
  echo "[i] Starting postgres to run setup scripts."
  s6-setuidgid postgres pg_ctl -D ${PGDATA} \
    -o "-c listen_addresses=''" \
    -w start
  echo
  
  for initFile in /init.d/*; do
      case "$initFile" in
          *.sh)  echo "$0: running $initFile"; . "$initFile" ;;
          *.sql) echo "$0: running $initFile"; psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DATABASE" < "$initFile" && echo ;;
          *)     echo "$0: ignoring $initFile" ;;
      esac
      echo
  done
  # Stopping postgres
  s6-setuidgid postgres pg_ctl -D ${PGDATA} -m fast -w stop
  # Setting listen all permissions
  { echo; echo "host all all 0.0.0.0/0 $authMethod"; } >> ${PGDATA}/pg_hba.conf
  echo "[i] Done configuring postgres and importing data"
fi
