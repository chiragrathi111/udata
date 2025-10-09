Install required software:

 * sudo apt update && sudo apt upgrade -y
 * sudo apt install openjdk-17-jdk maven mysql-server nginx git -y

 * java -version
 * mvn -v
 * mysql --version


Setup MySQL Database:-
 * sudo mysql -u root -p
 * CREATE DATABASE pipra_intranet;
 * CREATE USER 'pipra_intranet'@'%' IDENTIFIED BY 'mypassword';
 * GRANT ALL PRIVILEGES ON myappdb.* TO 'pipra_intranet'@'%';
 * FLUSH PRIVILEGES;

application.yml:-
spring.datasource.url=jdbc:mysql://localhost:3306/myappdb?useSSL=false&serverTimezone=UTC
spring.datasource.username=myappuser
spring.datasource.password=mypassword
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

 * mvn clean package -DskipTests
 * scp target/myapp-0.0.1-SNAPSHOT.jar user@server-ip:/home/user/
 * java -jar myapp-0.0.1-SNAPSHOT.jar
 * pm2 start "java -jar myapp-0.0.1-SNAPSHOT.jar" --name backend



cd frontend
npm install
npm run build
sudo cp -R ~/Pipra_Internet/pipra-intranet/frontend/dist/* /var/www/pi.pipra.solutions/
scp -r build/* user@server-ip:/var/www/html/


sudo apt install nginx -y
sudo nano /etc/nginx/sites-available/myapp



sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx


sudo mysql
use mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Pipra@123';
FLUSH PRIVILEGES;


<<<<<<< HEAD

cd ~/Pipra_Internet/pipra-intranet/backend/
mvn clean package -DskipTests
pm2 start "java -jar intranet-backend-1.0.0.jar" --name backend

cd ../frontend
npm install
npm run build
sudo cp -R ~/Pipra_Internet/pipra-intranet/frontend/dist/* /var/www/pi.pipra.solutions/

<<<<<<< HEAD



>>>>>>> 56bcaeb8b096ec9f140e9651aa02e35cdde49697

cd ~/Pipra_Internet/pipra-intranet/backend/
mvn clean package -DskipTests
pm2 start "java -jar intranet-backend-1.0.0.jar" --name backend

cd ../frontend
npm install
npm run build
sudo cp -R ~/Pipra_Internet/pipra-intranet/frontend/dist/* /var/www/pi.pipra.solutions/
