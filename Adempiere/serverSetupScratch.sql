1. ssh login with vnc viewver
2. sudo su (login super user)
3. cd warePro 
4. Copy idempiere-server folder to your destination
5. Rename the idempiere-server folder name
6. sh console-server.sh(if throw error getvar.sh)
7. cd utils
8. getVar.sh and setVar.sh both script file provide permission execution and script run also
9. file path changes
	cd idempiere-server/utils/
	open a file myEnvironment.sh and change path
	IDEMPIERE_HOME="/home/ubuntu/WareProDemo/wms/idempiere-server"
	ADEMPIERE_DB_URL = last changes 5432/demo (erp changes demo)
	ADEMPIERE_DB_NAME = "demo"(db_name also changes )
	ADEMPIERE_WEB_PORT = "9090"
	ADEMPIERE_SSL_PORT = "9091"

Check log screen in server:-
*cd /opt/idempiere-server/log/
*ls
*cat <last file name>