#!/bin/bash

# if [[ $# -eq 0 ]]; then
# 	echo "Usage: $0 <db_name>"
# 	exit 1
# fi

#/usr/bin/mysqld_safe >/dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service connection."
    sleep 5
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "status" > /dev/null 2>&1
    RET=$?
done

echo "=> Creating database $MYSQL_DATABASE"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT  -e "CREATE DATABASE $MYSQL_DATABASE;" > /dev/null 2>&1

echo "=> Creating database user $MYSQL_USERNAME"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT  -e "CREATE USER $MYSQL_USERNAME IDENTIFIED BY '$MYSQL_PASSWORD';" > /dev/null 2>&1

echo "=> Flushing privileges."
mysql -uroot -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT  -e "FLUSH PRIVILEGES;" > /dev/null 2>&1

echo "=> Creating base database tables."
mysql -uroot -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT playsms < /app/db/playsms.sql

echo "=> Granting user privileges to database."
mysql -uroot -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT  -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* to '$MYSQL_USERNAME'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"

echo "=> Flushing privileges one more time, just to be sure."
mysql -uroot -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT  -e "FLUSH PRIVILEGES;" > /dev/null 2>&1

echo "=> Done!"
