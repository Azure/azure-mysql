echo "Running the PHP Sample App deployment scripts"
echo "Downloading composer files."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

echo "Copying files from /home/site/repository/* to /home/site/wwwroot"
cp -r /home/site/repository/* /home/site/wwwroot
cp /home/site/repository/.env.example.azure /home/site/wwwroot/.env
cp /home/site/repository/htaccess /home/site/wwwroot/.htaccess

echo "Installing composer"
curl -s https://getcomposer.org/installer | php
