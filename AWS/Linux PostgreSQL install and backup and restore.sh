#!/bin/bash

ec2-user
sudo tee /etc/yum.repos.d/pgdg.repo<<EOF
>[pgdg13]
>name=PostgreSQL 13 for RHEL/CentOS 7 - x86_64
>baseurl=https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-7-x86_64
>enabled=1
>gpgcheck=0
>EOF
sudo yum update -y
sudo yum install postgresql13 postgresql13-server -y
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb -y
sudo systemctl start postgresql-13
sudo systemctl enable postgresql-13
sudo systemctl status postgresql-13
sudo passwd postgres
su - postgres
psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"     //This is very usefull line to change password
psql
\l
CREATE DATABASE db;
\l
\c db
CREATE TABLE ram(id INT PRIMARY KEY NOT NULL,name text NOT NULL);
INSERT INTO ram VALUES(11,'chi');
SELECT * FROM ram;
\q
pwd
ls
mkdir folder
pg_dump -v -d ratyu -U postgres -p 5432 -Fc -f /var/lib/pgsql/rara/file.sql
pg_restore -d postgres -U postgres /var/lib/pgsql/rara/file.sql
psql -h 127.0.0.1 -d dbName -U postgres -W -f filePath (if file is text format using psql and other situation using pg_restore)
DROP DATABASE realmeds; (using Capital latter and ending ; is important)



/////////// LOGGING IN POSTGRESQL \\\\\\\\\\\

sudo -i -u postgres   //this line logging postgresql
psql //full logging
\l  // list of database
\dt // Show all Tables


///////////////////////////////////////////////////////////////////

