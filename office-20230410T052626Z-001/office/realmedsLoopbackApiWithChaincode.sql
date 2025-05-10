//Add data (POST method):-

cd realmeds/network/chaincode/lib/test.js create file

const state =  require('./utils/state');
const constants = require('./utils/constants');

module.exports = {

    async addData(ctx, id, name, company, city) {
    	const data = {
    		name,
    		company,
    		city,
    		docType:"testUser"
    	}
      await ctx.stub.putState(id,Buffer.from(JSON.stringify(data)));

      return {
       status: true, 
       data: id + " added successfully" };
    },
 }

 realmeds.js file mai add :-
 const Itemi = require('./item')  //create obj

 create add method:-

 	async addTestUser(ctx,id,name,comapny,city){
 	     let response = await Itemi.addData(ctx,id,name,comapny,city);
 	     return response
 	 }

 cd realmeds/network/api/comman/model/test.js (API file)	
 
 'use strict';

const chaincode = require('../../lib/validate-user');	
const loopback = require('loopback');
const ds = loopback.createDataSource('memory');

module.exports = function(Item) {

    let defineDappUserFormat = function() {
        let newUserModel = {
                'id' : String,
                'name' : String ,
                'company' : String ,
                'city' : String
            };
        ds.define('newDapp', newUserModel);
      };
      defineDappUserFormat() ;


    Item.addData =  async function (data){
        const contract = await chaincode.validateUser('user3');
        let result = await contract.submitTransaction(
            'addTestUser',
            data.id,
            data.name,
            data.company,
            data.city
        );
        return result;
    } 

        Item.remoteMethod('addData', {
        accepts: [
            { arg: 'data', type: 'newDapp', http: { source: 'body' } }
        ],
        returns: { type: 'object', root: true }
    });

 }       

==================================================================================================================================================================
GET data :-

data jab get karte hai to chaincode ke lib file mai nahi karna padta chaincode

realmeds.js

    async queryState(ctx, id) {
        try {
            var result = await state.keyMustExist(ctx, id);
            return result;
        } catch (error) {
            return "not found";
        }
    }

    cd realmeds/network/api/comman/model/test.js (API file)	

        Item.getData = async function(userId){
        const contract = await chaincode.validateUser('user3');

        var userResult = await contract.evaluateTransaction('queryState',userId);
        userResult = JSON.parse(userResult.toString());
        return userResult;
    }

        Item.remoteMethod('getData', {
        accepts: [{ arg: 'userId', type: 'string' }],
        returns: { type: 'object', root: true },
        http: {verb: 'get'}, //this line ka use ui mai name add karne ke liye hota hai like get name

    });
===============================================================================================================================================================
UPDATE data:-
cd realmeds/network/chaincode/lib/test.js file

    async updateData(ctx,id,name,company,city){
        try{
            var userId = await state.keyMustExist(ctx,id);
        }catch(error){
            throw 'invalid userId' +id;
        }
        const userDetails = {
            name,
            company,
            city,
            docType : "testUser"
        }
        await ctx.stub.putState(id,Buffer.from(JSON.stringify(userDetails)));
        return {
            status: true,
            data: id + "updated Successfully"
        }
    }

    realmeds.js :-

        async updateUserData(ctx,id,name,comapny,city){
        let response = await Itemi.updateData(ctx,id,name,comapny,city);
        return response
    }

    cd realmeds/network/api/comman/model/test.js (API file)	

        Item.updateDataa = async function(updatadata){
        const contract = await chaincode.validateUser('user3');
        let updateResult = await contract.submitTransaction(
            'updateUserData',
            updatadata.id,
            updatadata.name,updatadata.company,updatadata.city
        );

        const updateBuffer = updateResult.toString(); //Buffer data to convert String method
        console.log('updateResult:', updateBuffer);
        
        return updateResult
    }

        Item.remoteMethod('updateDataa', {
        accepts: [
            { arg: 'data', type: 'newDapp', http: { source: 'body' } }
        ],
        returns: { type: 'object', root: true },
        http: {verb: 'put'} //this methid is use show UI in put name
    });


        