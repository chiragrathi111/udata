1. Alter Table Column :-
	// ALTER TABLE adempiere.C_Orderline ADD COLUMN ExpiryDate DATE;

2. Delete Table Column :-
	// Alter Table adempiere.c_orderline drop column BatchNo;

3. Current Date Record Find:-
	// SELECT * FROM adempiere.m_storageonhand WHERE DATE(created) = CURRENT_DATE;

4. Date Format :-
	// SELECT TO_CHAR(dateordered, 'DD-MM-YYYY') AS date_only

5. Alter Postgres Password:-
	// sudo -i -u postgres
	// psql
	// ALTER USER postgres WITH PASSWORD 'postgres';	

6. If Postgres Password error :-
	// cd /etc/postgresql/14/main/
	// ls (pg_hba.conf,postgresql.conf)
	//  sudo nano pg_hba.conf (change hd5)
	// sudo nano postgresql.conf (localhost = * and remove #)	