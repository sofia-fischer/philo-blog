
# delete files
echo $HETZNER_SSH_PASSWORD | sudo -kS rm -rf /var/www/html/philoblog/public/

# copy files to /var/www/
echo $HETZNER_SSH_PASSWORD | sudo -kS cp -r ~/dev/philoblog/* /var/www/html/philoblog/

# fix permissions from sudo copy
echo $HETZNER_SSH_PASSWORD | sudo -kS chown -R www-data:www-data /var/www/html/philoblog/
