If Realmeds any changes and Deploy :-

	If Blockchain any changes:-
	* First push the changes
	* Second login our terminal 
	* pull the data
	* go to realmeds
	* cd ../../script/network/
	* vi upgrade.sh (version increment and save file)
	* ./upgrade.sh
	* If changes realmeds then realmeds forever stop and start another way realmeds-selfcare then forever stop and start realmeds-selfcare
	* forever stop server/server.js	
	* forever start server/server.js

==========================================================================================================================================


	If only API changes:-
	* First push the changes
	* Second login our terminal 
	* pull the data
	* If changes realmeds then realmeds forever stop and start another way realmeds-selfcare then forever stop and start realmeds-selfcare
	* forever stop server/server.js	
	* forever start server/server.js