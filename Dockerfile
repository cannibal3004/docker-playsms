FROM ubuntu:latest
ADD README.md /README.md

# debs
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install supervisor git apache2 libapache2-mod-php php php-cli php-mysql php-gd php-imap php-curl php-xml php-mbstring php-zip unzip p7zip mariadb-client

# ssh
# ADD start-sshd.sh /start-sshd.sh
# ADD supervisord-sshd.conf /etc/supervisor/conf.d/supervisord-sshd.conf
# RUN mkdir /var/run/sshd
# RUN echo 'root:changemeplease' | chpasswd
#RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# ENV NOTVISIBLE "in users profile"
# RUN echo "export VISIBLE=now" >> /etc/profile

# apache2
ADD start-apache2.sh /start-apache2.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN a2enmod rewrite
RUN rm -rf /var/www/html/*

# mysql
#ADD start-mysqld.sh /start-mysqld.sh
#ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD create_db.sh /create_db.sh
#ADD my.cnf /etc/mysql/conf.d/my.cnf
#RUN rm -rf /var/lib/mysql/*

# playsms
ADD start-playsmsd.sh /start-playsmsd.sh
ADD supervisord-playsmsd.conf /etc/supervisor/conf.d/supervisord-playsmsd.conf
RUN rm -rf /app && mkdir /app && git clone --branch 1.4.2 --depth=1 https://github.com/playsms/playsms.git /app
ADD install.conf /app/install.conf
ADD install.sh /install.sh

# php
ENV PHP_UPLOAD_MAX_FILESIZE 8M
ENV PHP_POST_MAX_SIZE 8M
ENV MYSQL_ROOT_PASSWORD password
ENV MYSQL_HOST mariadb
ENV MYSQL_PORT 3306
ENV MYSQL_DATABSE playsms
ENV MYSQL_USERNAME playsms
ENV MYSQL_PASSWORD password

# finalize scripts
ADD run.sh /run.sh
RUN chmod +x /*.sh

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80
CMD ["/run.sh"]
