/////////// If your syatem shut down \\\\\\\\\\\\
cd ~/Realmeds/realmeds/network/setup
docker-compose -f docker-compose.yml up -d ca.realmeds.io orderer.realmeds.io peer0.org1.realmeds.io couchdb cli
//below method not always time apply if not working then apply below method.
cd ../../script/network
//starting go to upgrade.sh file and change version in increment
./upgrade.sh
///if you are not update your chaincode version and not run script and direct run nodemon you are show only latest version of chaincode not show aal version chaincode.


---------------------------------------------------------------------------------------------------------------------------------------------------------

/////////////////// Starting Setup \\\\\\\\\\\\\\\\\\\\\\\\

If system starting setup step by step do work

1.realmeds cd script/network 
  ./stopFabric.sh
  docker volume ls
  docker volume prune
  startFabric.sh


2.realmeds/network/api
  nodemon or node .

3.Realmeds-Selfcare
  cd ~/realmeds-Selfcare/apiserver/server
  node create-table.js
  node create-state.js
  node create-csc.js
  node create-users.js

  this four step done,then create two new terminal

  Realmeds-Selfcare/allInOne
  -- nodemon //node . (ka use bhi karke wahi kam kar sakte hai jo nodemon karta hai)
  nvm version
  nvm use 14
  ng serve (This command is running port 4200 if you are running in ec2 ins. then using ng-build)
  (Local mai port 4200 ka use kiya jata hai isi mai login kiya jata hai)

  Realmeds-Selfcare/apiserver
  nodemon   or node .

  //isse jo link milega use copy karke browser mai open kar lete hai
  //Issme login ke liye admin Id And Password requird hota hai (port 3100 ka use Ec2 mai kiya jata hai)
  id :-admin@realmeds.io 
  pass:- re@lmeds

4.Realmeds-Selfcare/apiServer/server this terminal also come

	line no. 90 uncomment and run (await realmeds.insert(dappUser))
	* node create-couchDb-view.js
	go to browser and create Organizations:-
	Manage Organization +add org.
	GCP = 9 digit(Unique)

	line no. 92 uncomment and run (await realmeds.insert(organization))
	* node create-couchDb-view.js
	go to browser and create location:-
	Manage Location -> all brand choose a org. +add location
	GLN = GCP/4digit random no.
	Put the real latitude and longitude

	line no. 91 uncomment and run (await realmeds.insert(location))
	* node create-couchDb-view.js
	go to browser and create medicine:-	
	GLN = 0GCP 4 digit random no.

	line no. 93 uncomment and run (await realmeds.insert(product))
	* node create-couchDb-view.js
	go to browser and create user:-
	Manage User + add user
	fill the details
    and one logout nad login

	line no. 89 uncomment and run (await realmeds.insert(batch))
	* node create-couchDb-view.js    
	another user login page and Create a Label
	Manage lable -> create  
	Batch no. bt-1(kuch bhi)
	target country,batch quantity and other datils fill 
	and go Manage Batch and seen your Batch details

//Sare 89,90,91,92 and 93 uncomment karke direct run bhi posible hai no any issue

// This is complete setup starting thoda confusion but after time very easy

#### if port no. is already exist show error use this command:-

lsof -i
kill -9 PS no.



======================================================================================================================================================	

////// Instance Stop and Start after setting \\\\\\\\\\\\\\

1. Ec2 instance stop
2. Ec2 instance start
3. docker ps (not show any Container)
4. cd realmeds/network/setup/
5. docker-compose -f docker-compose.yml up -d ca.realmeds.io orderer.realmeds.io peer0.org1.realmeds.io couchdb cli
6. cd ../../script/network/
7. vi upgrade.sh (version increment and save file)
8. ./upgrade.sh
9. cd ../../network/api/
10. forever start server/server.js
11. cd ~/realmeds-selfcare/apiserver/
12. forever start server/server.js
13. cd ../microsite/
14. forever start dist/microsite/server/main.js
15. forever logs (Check all logs)
16. ip:3001 browser working or not 
17. df -h
18. sudo mount volume path directory path

Work is final done

======================================================================================================================================================
Docker logs check in chaincode:-
docker ps (show all running Container First container is latest version chaincode and copy container id)
docker logs -f <container id>
and show logs








