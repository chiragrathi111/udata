Docker Flow first added .dmp file in local and restore data new DB_name:-

Ctrl+Alt+T (Terminal Open)
docker cp /home/pipra/Downloads/ExpDat.dmp postgres:/
Ex postgres(Container name)

Login Postgres Container:-
docker exec -it postgres/<Container_id> bash
psql -U postgres (psql login then all table see)
\l 
\c db_name (change db_name)
Run your internal table query

If you added any database then you only Container login not db login
createdb  --template=template0 -E UNICODE -O adempiere -U adempiere db_name
psql -d db_name -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"
psql -U adempiere -d db_name < /ExpDat.dmp (any dmp file your use according)

Note:- If you want to use your existing database and restore a new database, it is possible. However, I observed that the data 
	   from existing tables does not get carried over, and new clients are also not included. While new tables are added to the database,
	   these tables are not accessible through the iDempiere web interface. This means that if you want all tables, columns, windows, tabs, 
	   fields, and menus to function properly, you will need to create everything manually. Otherwise, they will not be displayed. 
	   This is a limitation when using an existing database.

Second Flow:-
Using a New Database in PostgreSQL with iDempiere:-
If you want to achieve this, it is possible by following these steps:
1. First, stop the existing container using:
	docker stop <containerId>
2. Then remove the container using:
	docker rm <containerId>
3. After completing the above steps, run the iDempiere container with the new database.
	docker run -d name idempiere -p 8443:8443 network docker_idempiere_app-network -e DB_HOST=postgres -e DB_PORT=5432 -e DB_NAME=vinay2 -e DB_USER=adempiere -e DB_PASS=adempiere -e DB_ADMIN_PASS=postgres idempiereofficial/idempiere:10

docker run -d \
--name idempiere \
--network docker_idempiere_app-network \
-p 8443:8443 \
-e DB_HOST=postgres \
-e DB_PORT=5432 \
-e DB_NAME=vinay2 \
-e DB_USER=adempiere \
-e DB_PASS=adempiere \
-e DB_ADMIN_PASS=postgres \
idempiereofficial/idempiere:10


	Explain:-
	idempierevinay2 				= Container Name
	8443							= Idempiere port
	docker_idempiere_app-network 	= network
	postgres 						= DataBase Container Name
	5432 							= DataBase PORT
	vinay 							= New DB_NAME
	adempiere						= DataBase User 
	adempiere						= DataBase Password
	PostgreSQL						= DataBase Admin Password
	idempiereofficial/idempiere:10	= Idempiere Image

For windows:-

docker run -d --name idempiere --network docker_idempiere_app-network
-p 8443:8443 ^
-e DB_HOST=postgres ^
-e DB_PORT=5432 ^
-e DB_NAME=vinay2 ^
-e DB_USER=adempiere ^
-e DB_PASS=adempiere ^
-e DB_ADMIN_PASS=postgres ^
idempiereofficial/idempiere:10	