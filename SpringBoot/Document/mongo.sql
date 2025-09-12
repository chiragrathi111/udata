* sudo systemctl status mongod
* sudo systemctl start mongod
* sudo systemctl status mongod
* sudo systemctl enable mongod
* sudo journalctl -u mongod
* sudo netstat -plnt | grep 27017
* mongosh
* history | tail -10 (last 10 command see)


Mongo Install:-
* sudo apt update && sudo apt upgrade -y

* sudo apt install -y gnupg curl

* curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

* echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

* sudo apt update

* sudo apt install -y mongodb-org

* sudo systemctl start mongod

* sudo systemctl enable mongod
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* mongosh (this command go to mongo db)

* show dbs (This command showing all dbs)

* use school (if you have not school db,so automatic create and switch the db)

* show collections (collections jest table,Showing all table)

* db.students.insertOne({"name":"chirag","age":"30"}) (This command create a new collections(table)
  and added new record)

* db.students.find().pretty() (This commend show all records)

* db.students.deleteOne({"name":"chirag"})

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Terminal through created manually collection:-
* mongosh
* use dbs
* db.createCollection("config_journal_app")
* db.config_journal_app.insertOne({
  key: "theme",
  value: "dark"
})


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
userName - chiragrathi111
password - ywvldDcMJLO569Dn

