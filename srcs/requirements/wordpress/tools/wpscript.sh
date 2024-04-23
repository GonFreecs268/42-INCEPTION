#!/bin/bash

# Wait for 10 seconds to ensure everything is ready
sleep 10

# Check if wp-config.php file exists
if [ -f "/var/www/html/wp-config.php" ]; then
    echo "WordPress is already set up!"
else
    echo "Setting up WordPress"
    sleep 10

    # Create WordPress configuration file
    ./wp-cli.phar config create --allow-root \
                               --dbname=$SQL_DATABASE \
                               --dbuser=$SQL_USER \
                               --dbpass=$SQL_PASSWORD \
                               --dbhost=$SQL_HOST \
                               --path='/var/www/html'

    # Set appropriate permissions for wp-config.php file
    chmod 777 /var/www/html/wp-config.php
    chown -R root:root /var/www/html

    # Install WordPress
    ./wp-cli.phar core install --allow-root \
                               --url=$DOMAIN_NAME \
                               --title="$TITLE" \
                               --admin_user=$WP_ADMIN_USER \
                               --admin_password=$WP_PASSWORD \
                               --admin_email=$WP_ADMIN_MAIL \
                               --path='/var/www/html'

    # Create an additional user
    ./wp-cli.phar user create $WP_SECOND_USER $WP_SECOND_USER_MAIL \
                             --allow-root \
                             --role=author \
                             --user_pass=$WP_SECOND_USER_PW \
                             --path='/var/www/html'

    echo "WordPress is running!"
fi

# Start PHP-FPM
exec /usr/sbin/php-fpm7.4 -F -R
