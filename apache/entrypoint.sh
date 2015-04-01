#!/bin/bash
set -e

# ====|==== HTTP  ====|==== #

if [ -z ${SERVERNAME} ]; then
    SERVERNAME="localhost"
fi

if [ -z ${SERVERALIAS} ]; then
    SERVERALIAS="localhost"
fi

if [ -z ${DOCROOT} ]; then
    DOCROOT="/var/www/html"
fi

if [ -z ${APPNAME} ]; then
    APPNAME="000-default"
fi

if [ -z ${CHARSET} ]; then
    CHARSET="UTF-8"
fi

APACHECONF="/etc/apache2/sites-available/$APPNAME.conf"

if [ -f "$APACHECONF" ]; then
    rm $APACHECONF
fi

cat > "$APACHECONF" <<-EOCONF
    <VirtualHost *:80>
        ServerName ${SERVERNAME}
        ServerAlias ${SERVERALIAS}
        AddDefaultCharset ${CHARSET}
        DocumentRoot '${DOCROOT}'
         <Directory '${DOCROOT}'>
            Options Indexes FollowSymLinks MultiViews
            AllowOverride All
        </Directory>
        ErrorLog '/var/log/apache2/${APPNAME}_error.log'
        ServerSignature Off
        CustomLog '/var/log/apache2/${APPNAME}_access.log' combined
        ScriptAlias /cgi-bin/ '/usr/lib/cgi-bin'
    </VirtualHost>
EOCONF

# ====|==== HTTPS  ====|==== #

if [ -z ${SERVERNAMESSL} ]; then
    SERVERNAMESSL="localhost"
fi

if [ -z ${DOCROOTSSL} ]; then
    DOCROOTSSL="/var/www/html"
fi

APACHECONFSSL="/etc/apache2/sites-available/$APPNAME-ssl.conf"

if [ -f "$APACHECONFSSL" ]; then
    rm $APACHECONFSSL
fi

cat > "$APACHECONFSSL" <<-EOCONF
    <IfModule mod_ssl.c>
        <VirtualHost *:443>

            ServerName ${SERVERNAMESSL}

            DocumentRoot '${DOCROOTSSL}'

            ErrorLog ${APACHE_LOG_DIR}/${APPNAME}_error-ssl.log
            CustomLog ${APACHE_LOG_DIR}/${APPNAME}_access-ssl.log combined

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


/usr/sbin/a2ensite "$APPNAME" && /usr/sbin/a2ensite "$APPNAME-ssl"  && service apache2 stop

exec "$@"