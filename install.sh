#!/bin/bash
sudo apt-get update
sudo apt-get install apache2 -y
sudo apt-get install php7.0 php7.0-mysql libapache2-mod-php7.0 php7.0-cli php7.0-cgi php7.0-gd -y
sudo systemctl enable apache2
sudo systemctl start apache2
cd /home/ubuntu/
sudo wget   https://wordpress.org/latest.tar.gz
sudo tar -zxvf latest.tar.gz
sudo cp -rf /home/ubuntu/wordpress/* /var/www/html/
sudo rm -rf /var/www/html/index.html
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo mv  /var/www/html/wp-config-sample.php  /var/www/html/wp-config.php
sudo sed -i -e 's/database_name_here/WordpressDB/g' /var/www/html/wp-config.php
sudo sed -i -e 's/username_here/wordpress/g' /var/www/html/wp-config.php
sudo sed -i -e 's/password_here/wordpress/g' /var/www/html/wp-config.php
sudo sed -i -e 's/localhost/wordpress-db.czbb5xu9f8dt.us-west-1.rds.amazonaws.com:3306/g' /var/www/html/wp-config.php
sudo systemctl restart apache2


