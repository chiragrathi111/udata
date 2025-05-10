Loopback API created full work flow:-

1. create a new model :-

						which location to create a new model give actual path
						* /home/chirag/realmeds/realmeds/network/api/common/models
						* lb model 
							Model Name - enter name
							DB merge - enter
							Persisted Model - Model
							enter enter enter and created one js file and another json file

							see the JSON file looking wise

							{
							  "name": "Person",
 							  "base": "Model",
  							  "idInjection": true,
  							  "options": {
    							"validateUpsert": true
  									},
 							 "properties": {},
 							 "validations": [],
 							 "relations": {},
  								"acls": [],
  								"methods": {}
								}

2. Added method your js file like add,get,update (below example code)

	'use strict';

const escapeJson = require('escape-json-node/lib/escape-json'); 
const chaincode = require('../../lib/validate-user');
const loopback = require('loopback');
const ds = loopback.createDataSource('memory'); 

module.exports = function(Person) {   //Medel name (Person)

    let definePersonFormat = function(){
        let PersonModel = {
            'personId' : String,
            'name' : String
        };
        ds.define('person',PersonModel);  //'person' using remoteMethod type
    };
    definePersonFormat();

    Person.addPersonData = async function(data){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addPersondata', //this is main chaincode method if you enter diff you are face node_moduler error 144:33 and 255:10
            data.personId,
            data.name
            );
            return JSON.parse(result.toString()) ;
    }

    Person.getPersonData = async function(personId){
        const contract = await chaincode.validateUser('user3')

        var result = await contract.evaluateTransaction('queryState',personId);  //this 'queryState' is also chaincode method
        return JSON.parse(result.toString());
    }

    Person.updatePersonData = async function(data){
        try{
        const contract = await chaincode.validateUser('user3')
        
        var personId = data.personId;
        data = escapeJson(JSON.stringify(data));

        var responce = await contract.submitTransaction(
            'updatePersonData', //this is main chaincode method if you enter diff you are face node_moduler error 144:33 and 255:10
            personId,
            data
        );

        return JSON.parse(responce.toString());

    }catch(error){
        throw error;
    } }

    Person.remoteMethod('updatePersonData', {
        accepts: [
            { arg: 'data', type: 'person', http: { source: 'body' } }
        ],
        returns: { type: 'object', root: true },
        http: {verb: 'put'}
    });

    Person.remoteMethod('getPersonData',{
        accepts: [{arg: 'personId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Person.remoteMethod('addPersonData', {
        accepts: [
            { arg: 'data', type: 'person', http: { source: 'body' } }
        ],
        returns: { type: 'person', root: true }
    });
};

-------------------------------------------------------------------------------------------------------------------------------------
go to chaincode folder and create a new class

* /home/chirag/realmeds/realmeds/network/chaincode/lib
* create a new js file if your multiple file then you create a folder and added all js file


const state = require('./utils/state');  //if you are create file in folder then you use ('..//utils/state')
module.exports = {
   
    async addPerson(ctx,personId,name){
        try{
            if(personId.length === 0 ){
                console.log(".....................................................................................");
                console.log("personId should be there");
                console.log("==============================================");
                throw "personId must not be empty";
            }
    
            try {
                await state.keyMustNotExist(ctx, personId);
            
            } catch (error) {
                console.log(personId)
                throw personId + " Person is already registered"
            }
    
            if(name.length === 0 ){
                console.log(".....................................................................................");
                console.log("Person Name should be there");
                console.log("==============================================");
                throw "Person Name must not be empty";
            }
    
            const addPersonData = {
                personId,
                name,
                docType: "person"
            }
            await ctx.stub.putState(personId,Buffer.from(JSON.stringify(addPersonData)));
            return {
                status: true,
                data: personId + " Person Data added Successfully"
            }
    }catch(error){
        return{
            status: false,
            data: error
        }
    }
    },

    async updatePersonData(ctx,personId,children){
        try{
            children = JSON.parse(children);
    
            if(personId.length === 0 ){
                throw "personId must not be empty";
            } 
            try{
               var personUserData = await state.keyMustExist(ctx,personId);

            }catch(error){
                throw 'invalid PersonId ' +personId;
            }
            if(children.name){
                personUserData.name = children.name;
            }

            await ctx.stub.putState(personId, Buffer.from(JSON.stringify(personUserData)));

            return{
                status : true,
                data :  personId +" updated successfully"
            }
        }catch(error){
            return{
                status: false,
                data: error
            }
        }
    }
}

if you added record in loopback and show false means your code mistake this js file 
---------------------------------------------------------------------------------------------------
First create js file then create obj and call method

const person = require('./person');

async addPersondata(ctx,id,name){
        let responce = await person.addPerson(ctx,id,name);
        return responce
    }

    async updatePersonData(ctx,id,children){
        let responce = await person.updatePersonData(ctx,id,children);
        return responce
    }

Most Impoertant point if you added any word in js file or realmeds file then every time upgrade version and run upgrade scripts
If you are not run upgrade scripts then your changes not apply in real time project

First upgrade script then every time enter node .


path 

upgrade chaincode path:-
* /home/chirag/realmeds/realmeds/scripts/network/
	First update version in upgrade.sh file then run scripts
* ./upgrade.sh	

this task is done then api enter node .
* /home/chirag/realmeds/realmeds/network/api/
* node .

and check login in loopback

http://localhost:3000/explorer/



 
