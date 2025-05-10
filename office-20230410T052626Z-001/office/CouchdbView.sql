View:-
		Realmeds mai view ka use searching time save karne ke liye use kiya jata hai.
		Ex. - hamare pass 1000 email hai but hamare dappUser ke only 10 hai usme bhi only one email is admin email to email ke login time existing user check 
			  karne ke liye sare 1000 email se check karne mai time consuming jyada hoga jisse server mai wait time lega is problem ko solve karne ke liye hi 
			  hum view ka use karte hai issme condition provide kar diya jata hai jisse wo dappuser ke 10 email mai hi admin ko check karega and result 
			  provide karega .

1. Realmeds-selfcare/apiServer/server/
   create-couchDb-views.js file mai data put karte hai

   Ex. 
    const dappUser_email = function (doc) { //doc is a parameter of a function
    	if(doc.docType === 'dappUser'  && doc.type === 'admin') 
    	emit(doc.email, doc); 
    	}

		const dappUser = {   //this object name call createView(){}
		    _id: '_design/dappUser',//show Degign Document folder
		    views: {    //inside folder
		      "email": {  //inside folder
		        map: dappUser_email.toString()
		      }
		    }
	  	}	

	  	async function createView(){
      try {
        await realmeds.insert(dappUser);
    } catch (error) {
          console.log("error", error);
      }
  }		  


----------------------------------------------------------------------------------------------------------------------------------

2. Realmeds/network/api/comman/model/
   dappUser.js file ko open karte hai (jis file ka view banana hai use hi open karke usme code put karte hai)

   const nano = require('nano')(environment.couchDbViewUrl); //ye line concanicate karta hai ki kisme jana hai 
   const realmeds = nano.db.use('channel_realmeds'); //couchdb mai channel_realmeds ka folder hoga usi mai show hota hai


//generelly login mai check karne ke liye use hota hai 

   Dappuser.login = async function (data) {
        var response = {}

        try {
            const contract = await chaincode.validateUser('user3');

            const params = {
                key: data.emailId,
                limit: 1
            }
        
            var dappUser = await realmeds.view('dappUser', 'email', params)   //This is main line
            
            if(dappUser.length === 0){
                throw new Error ("Email not Found");
            }

            dappUser = dappUser.rows[0];

    --         if(sha256(data.password) === dappUser.value.password){
                
    --             response.dappId = dappUser.id;
    --             response.login = true;
    --             response.type = dappUser.value.type;
    --             response.name = dappUser.value.userName;
                
    --             if(dappUser.value.type === constants.userType.BRANDOWNER){

    --                 var organisationData =  await contract.evaluateTransaction('queryState', dappUser.value.gcp);
    --                 organisationData = JSON.parse(organisationData.toString());

    --                 response["gcp"] = dappUser.value.gcp;
    --                 response["hasGlobalPresence"] = organisationData.globalPresence.hasGlobalPresence;
    --                 if(organisationData.globalPresence.hasGlobalPresence === false){
    --                     response["presenceInCountry"] = organisationData.globalPresence.presenceInCountry;
    --                 }
    --                 response["options"] = organisationData.options;
    --             }

    --             return response;
    --         }else{
    --             throw new Error ("password not correct");
    --         }
    --     } catch (error) {
    --         throw error.message
    --     }

    -- };

  	This two method and show your view in couchdb.
    ----------------------------------------------------------------------------------------------------------------------

    if multiple view create karnna hai to-

    const location_list = function(doc) { if (doc.docType === 'location') { emit([doc.gcp, doc._id], {'_id': doc._id}); } }
const location_lookup = function(doc) { if (doc.docType === 'location') { emit(doc._id, {'_id': doc._id}); } }

const location = {
    _id: '_design/location',
    views: {
      "list": {
        map: location_list.toString()
      },
      "lookup": {
        map: location_lookup.toString()
      }
    }
  }

  then also channel_realmeds

  ------------------------------------------------------------------------------------------------------------------------

const products_details = function (doc) { if(doc.docType === 'product') emit([doc.gcp, doc.name], { '_id': doc._id }); }
const products_list = function (doc) { if(doc.docType === 'product') emit([doc.gcp, doc.gln, doc._id], { '_id': doc._id }); }
const products_lookup = function(doc) { if (doc.docType === 'product') { emit(doc._id, {'_id': doc._id}); } }
const products = {
    _id: '_design/products',
    views: {
      "details": {
        map: products_details.toString()
      },
      "list":{
        map: products_list.toString()
      },
      "lookup":{
        map: products_lookup.toString()
      }
    }
  }  

  then also call.

