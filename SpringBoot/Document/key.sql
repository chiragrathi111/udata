ORM - Object Reletional Mapping

JPA - JAva Persistence API
(This is only use Reletional Database not a noSQL Database)

MongoDb using Dependency:-
<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-mongodb</artifactId>
			<version>3.5.4</version>
</dependency>	

Query Methos DSL
Criteria API
(This two way know you every think on Database)

=======================================================================
application.properties (Inside Resource)
this file using database create a Reletion

spring.data.mongodb.host=localhost
spring.data.mongodb.port=27017
spring.data.mongodb.database=journaldb
#spring.data.mongodb.username=chirag
#spring.data.mongodb.password=chirag