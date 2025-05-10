Database Backup:-
pg_dump -U adempiere -W idempiere5 > /home/chirag/datas.dmp(-w Without password and -W With Password)

Database Restore:-
psql -U adempiere -d idempiere6 < /home/chirag/austrak_C.dmp (This code is also setup in Austrak)

Why are use psql and pg_restore
(If you created an SQL-format dump, all you can use is psql .
 If you created a custom-format ( pg_dump -Fc ) or directory-format ( pg_dump -Fd ) dump, you can and must use pg_restore )

scp -i "pemFile/democ.pem" ubuntu@13.235.255.17:/home/ubuntu/datavinayNew.dmp /home/chirag/

pg_dump -U adempiere -W vinayERP > /root/vinaydatas.dmp