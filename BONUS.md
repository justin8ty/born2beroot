# Bonus: WordPress LLMP Stack

![alt text](<Screenshot 2024-07-23 220606.png>)

## Install PHP

```
sudo apt install php php-cgi php-mysql -y
```

Stop Apache2:

```
systemctl status apache2
sudo systemctl stop apache2
sudo systemctl disable apache2
```

## Install Lighttpd

```
sudo apt install lighttpd
sudo ufw allow 80
sudo ufw allow http

sudo systemctl start lighttpd
sudo systemctl enable lighttpd
sudo systemctl status lighttpd
```

Add port forwarding for 8080 to 80 in VM >> Settings >> Network >> Port Forwarding.

Test with host browser: http://localhost:8080

Activate Lighttpd FastCGI module:

```
sudo lighty-enable-mod fastcgi
sudo lighty-enable-mod fastcgi-php
sudo service lighttpd force-reload
```

### Test Lighttpd with PHP

```
nano /var/www/html/info.php
```

Append these lines to info.php:

```
<?php
phpinfo();
?>
```

Check logs:

```
sudo cat /var/log/lighttpd/error.log
sudo journalctl -u lighttpd
```

Test with host browser: http://localhost/info.php

## Install WordPress

```
sudo apt install curl wget tar -y
cd /tmp && wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
cp -R wordpress /var/www/html/
rm -rf latest.tar.gz wordpress/
```

Change permissions:

```
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

## Install MariaDB

```
sudo apt install mariadb-server -y
sudo mysql_secure_installation

Switch to unix_socket authentication [Y/n]: N
Change the root password? [Y/n]: N
Remove anonymous users? [Y/n]: Y
Disallow root login remotely? [Y/n]: Y
Remove test database and access to it? [Y/n]:  Y
Reload privilege tables now? [Y/n]:  Y
```

## Create Database

```
sudo mariadb
CREATE DATABASE wp_db;
CREATE USER 'jin-tan'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL ON wp_db.* TO 'jin-tan'@'localhost';
FLUSH PRIVILEGES;
exit
```

Output database:

```
mariadb -u jin-tan -p
SHOW DATABASES;
```

![alt text](<Screenshot 2024-07-23 213153.png>)

## Configure WordPress

```
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo nano wp-config.php
```

Edit database, user, password based on database.
```
define( 'DB_NAME', 'wp_db' );
define( 'DB_USER', 'jin-tan' );
define( 'DB_PASSWORD', 'admin123' );
```

Go to `http://localhost` and finish setup.

# Bonus: FTP

![alt text](<Screenshot 2024-07-23 225503.png>)

```
sudo apt install ftp vsftpd
sudo ufw allow 21
sudo nano /etc/vsftpd.conf
```

Edit these lines:

```
# Allow anonymous FTP? (Disabled by default)
anonymous_enable=NO

# Uncomment this to allow local users to log in.
local_enable=YES

# Enable write permissions for local users.
write_enable=YES

# Optional: Customize the welcome message
ftpd_banner=Welcome to blah FTP service.
```

## Create User

```
sudo systemctl restart vsftpd
sudo adduser ftpuser
sudo mkdir -p /home/ftpuser/ftp/upload
sudo chown -R ftpuser:ftpuser /home/ftpuser/ftp
sudo chmod -R 755 /home/ftpuser/ftp
sudo chmod 750 /home/ftpuser/ftp/upload
```

## Test Connection

```
ftp localhost
quit
echo "This is a test file" > testfile.txt
ftp localhost
put testfile.txt
ls
```

# Docs

**Bonus**

- https://www.digitalocean.com/community/tutorials/install-wordpress-on-ubuntu
- https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mariadb-php-lamp-stack-on-debian-10
- https://ubuntu.com/server/docs/how-to-install-and-configure-php
- https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lamp-on-debian-10
- https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-20-04