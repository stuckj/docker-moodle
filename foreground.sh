#!/bin/bash

echo "placeholder" > /var/moodledata/placeholder
chown -R www-data:www-data /var/moodledata
chmod 777 /var/moodledata

read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -TERM -$pgrp; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT

#start up cron
/usr/sbin/cron

# Disable apache SSL if we're behind an SSL proxy
if [ ${BEHIND_SSL_PROXY} -eq 1 ]; then
    a2dismod ssl && a2dissite default-ssl 
    if [ ! -f /etc/apache2/conf-enabled/apache-proxy-servername.conf ]; then
        ln -sf ../conf-available/apache-proxy-servername.conf /etc/apache2/conf-enabled/apache-proxy-servername.conf
    fi
fi

source /etc/apache2/envvars
tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND
