#!/bin/bash
sudo apt-get upgrade -y
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo chmod 777 /var/www
sudo chmod 777 /var/www/html/index.html
echo "Hello World CHIRAG RATHI  OM from $(hostname -f)" > /var/www/html/index.html

//aws mai vertical scale up easy process hai:-
1 stop ec2 instances
2 select ec2 instance click action and Choose "Instance Settings" -> "Change Instance Type".
3 choose instance type and save
4 select ec2 instance and again start then proper working Ec2 instance. 


#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

# Adjust permissions
sudo chmod 755 /var/www
sudo chmod 644 /var/www/html

# Get the CPU utilization and hostname
CPU_UTILIZATION=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
HOSTNAME=$(hostname -f)

# Create the index.html with the required format
echo "<html>
<head><title>Welcome</title></head>
<body>
<h1><b>Hello CHIRAG RATHI </b></h1>
<p><b>Hostname:</b> $HOSTNAME</p>
<p><b>CPU Utilization:</b> ${CPU_UTILIZATION}%</p>
</body>
</html>" | sudo tee /var/www/html/index.html


USer Data for path:-
#!/bin/bash
apt-get update
apt-get install nginx -y
sudo mkdir -p /var/www/html/test 
sudo chmod 777 /var/www/html/test/
sudo echo "<html>
<head><title>Welcome</title></head>
<body>
<h1><b>Hello CHIRAG RATHI </b></h1>
<p><b>Hostname:</b> $(hostname)</p>
</body>
</html>" >/var/www/html/test/index.html
sudo chmod 777 /var/www/html/test/index.html

sudo apt-get install stress
stress -c 5

ps aux | grep stress
sudo kill -9 <pid>