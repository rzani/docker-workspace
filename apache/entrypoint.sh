#!/bin/bash
set -e

# ====|==== HTTP  ====|==== #

if [ -z ${SERVER_NAME} ]; then
    SERVER_NAME="localhost"
fi

if [ -z ${SERVER_ALIAS} ]; then
    SERVER_ALIAS="localhost"
fi

if [ -z ${DOC_ROOT} ]; then
    DOC_ROOT="/var/www/html"
fi

if [ -z ${APP_NAME} ]; then
    APP_NAME="000-default"
fi

if [ -z ${CHARSET} ]; then
    CHARSET="UTF-8"
fi

# Internal duplicate confs resolution
APACHE_CONF="/etc/apache2/sites-available/$APP_NAME.conf"
if [ -f "$APACHE_CONF" ]; then
    rm $APACHE_CONF
fi

cat > "$APACHE_CONF" <<-EOCONF
    <VirtualHost *:80>
        ServerName ${SERVER_NAME}
        ServerAlias ${SERVER_ALIAS}
        AddDefaultCharset ${CHARSET}
        DocumentRoot '${DOC_ROOT}'
         <Directory '${DOC_ROOT}'>
            Options Indexes FollowSymLinks MultiViews
            AllowOverride All
        </Directory>
        ErrorLog '/var/log/apache2/${APP_NAME}_error.log'
        ServerSignature Off
        CustomLog '/var/log/apache2/${APP_NAME}_access.log' combined
        ScriptAlias /cgi-bin/ '/usr/lib/cgi-bin'
    </VirtualHost>
EOCONF

# ====|==== HTTPS  ====|==== #

if [ -z ${SERVER_NAME_SSL} ]; then
    SERVER_NAME_SSL="localhost"
fi

if [ -z ${DOC_ROOT_SSL} ]; then
    DOC_ROOT_SSL="/var/www/html"
fi

APACHE_CONF_SSL="/etc/apache2/sites-available/$APP_NAME-ssl.conf"

if [ -f "$APACHE_CONF_SSL" ]; then
    rm $APACHE_CONF_SSL
fi

cat > "$APACHE_CONF_SSL" <<-EOCONF
    <IfModule mod_ssl.c>
        <VirtualHost *:443>

            ServerName ${SERVER_NAME_SSL}

            DocumentRoot '${DOC_ROOT_SSL}'

            ErrorLog ${APACHE_LOG_DIR}/${APP_NAME}_error-ssl.log
            CustomLog ${APACHE_LOG_DIR}/${APP_NAME}_access-ssl.log combined

            SSLEngine on

            SSLCertificateFile  /etc/ssl/certs/ssl-cert-snakeoil.pem
            SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

            <FilesMatch "\.(cgi|shtml|phtml|php)$">
                    SSLOptions +StdEnvVars
            </FilesMatch>
            <Directory /usr/lib/cgi-bin>
                    SSLOptions +StdEnvVars
            </Directory>

            BrowserMatch "MSIE [2-6]" \
                    nokeepalive ssl-unclean-shutdown \
                    downgrade-1.0 force-response-1.0
            # MSIE 7 and newer should be able to use keepalive
            BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

        </VirtualHost>
    </IfModule>
EOCONF


/usr/sbin/a2ensite "$APP_NAME" && /usr/sbin/a2ensite "$APP_NAME-ssl"  && service apache2 stop

exec "$@"