* docker ps

* docker exec -it <container_id> bash/sh 

* psql -U postgres -d <db_name>

* psql -U postgres

* \l (list of db_name)

* \c <db_name> (change db)


* psql -U postgres -d realmeds -f backup.sql  (terminal running specific sql file)

# Run the sql file on the container :-

* docker ps

* docker cp database.sql postgres-db:/tmp/database.sql

* docker exec -it postgres-db psql -U postgres -d realmeds -f /tmp/database.sql