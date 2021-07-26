#!/bin/bash

# VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php/7.4/apache2/php.ini

# if [[ ! -d $VOLUME_HOME/mysql ]]; then
#     echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
#     echo "=> Installing MySQL ..."
#     mysql_install_db > /dev/null 2>&1
#     echo "=> Done!"

#     echo "=> Installing playSMS ..."
#     /install.sh
#     echo "=> Done!"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT -e status > /dev/null 2>&1
USERCANLOGIN=$?
if [[ $USERCANLOGIN != 0 ]]; then
    echo "Database user cannot login. Assuiming we need to create the database and user."
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT -e status > /dev/null 2>&1
    ROOTCANLOGIN=$?
    if [[ $ROOTCANLOGIN != 0 ]]; then
        echo "Cannot login to database as root. Did you remember to specify the MYSQL_ROOT_PASSWORD environment variable?"
        exit 1
    fi
    /create_db.sh
    touch /tmp/.db_user_created
else
    touch /tmp/.db_user_created
fi
echo "=> Installing playSMS ..."
/install.sh
echo "=> Done!"
echo "=> Exec supervisord"
exec supervisord -n
