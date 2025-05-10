#!/bin/bash
//// Complete setup ubuntu instaces launch docker then download postgresql and create db and create table and backup store data \\\\

sudo su
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
docker pull ubuntu
docker images
docker run -it --name chirag ubuntu /bin/bash
apt-get update -y
apt install postgresql postgresql-contrib -y
// Choose Geographic area and time Zone
service postgresql start
service postgresql status
su - postgresql
psql
\l
create database db;
\c db
create table ram(id int primary key not null,name text not null, age int not null);
\d or \dt
insert into ram values(1,'chirag',28),(2,'raja',26),(3,'govind',24),(4,'kishan',23);
select * from ram;
\q
pwd
mkdir rama
pg-dump -v -d db -U postgres -p 5432 -Fc -f /var/lib/postgresql/rama/file.sql
cd rama
ls
cd
exit
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
drop table ram;

