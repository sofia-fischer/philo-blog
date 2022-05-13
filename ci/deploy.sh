
# delete files
echo $HETZNER_SSH_PASSWORD | sudo -kS rm -rf /var/www/html/philo-blog

# copy files to /var/www/
echo $HETZNER_SSH_PASSWORD | sudo -kS cp -r "$GITHUB_WORKSPACE/public" /var/www/html/philo-blog/

# fix permissions from sudo copy
echo $HETZNER_SSH_PASSWORD | sudo -kS chown -R www-data:www-data /var/www/html/philo-blog
