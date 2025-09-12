We are wroking on different envirnment such as dev and prod
so we setup 4 way:-
1. application.properties/application.yml
 this vase file we set active path
 Example:- application-dev.yml,application-prod.yml
   so i added base application.yml file
   spring:
  	profiles:
      active: dev

2. We modify Edit Configurationso their accroding we setup envirnment value
	like spring.profiles.active=dev
	and run whole application

3. If jar not created so we enter the code with maven
   mvn clean package -D spring.profiles.active=dev

4. We have jar file so directly run that command
   java -jar .\<jar-name> --spring.profiles.active=dev    	

