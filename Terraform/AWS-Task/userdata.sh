#!/bin/bash
sudo apt-get upgrade -y
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo chmod 777 /var/www
sudo chmod 777 /var/www/html/index.html
echo "Hello CHIRAG RATHI from $(hostname -f)" > /var/www/html/index.html