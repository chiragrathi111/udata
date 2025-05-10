Realmeds Block chain added access key and secret key:-

Realmeds side:-
cd realmeds/network/api

 modify access key and secret key



after mofidy 
  cd /realmeds-selfcare/apiserver
  forever stop server/server.js
  forever start server/server.js

Realmeds Selfcare side:-
cd /realmeds-selfcare/apiserver


2 side update access key and secret key:-
 1 cd environment
 sudo nano environment.js

//aws configuration
    //******************************

    modify and update


  2 cd server
  sudo nano datasources.json
  modify access key and secret key.

after mofidy 
  cd /realmeds-selfcare/apiserver
  forever stop server/server.js
  forever start server/server.js
