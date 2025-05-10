Error postgresql :-

psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: Connection refused Is the server running locally and accepting connections on that socket?

Solve:-

go to directory

cd /etc/postgresql/14/main/
1.sudo nano pg_hba.conf

# Database administrative login by Unix domain socket
local   all             postgres                                md5

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     md5

# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            md5

host    replication     all             ::1/128                 md5


This code is fix if your code any changes please update you 


2.sudo nano postgresql.conf

listen_addresses = '*'          

save and restart postgresql

3.sudo service postgresql restart

and problem is solve