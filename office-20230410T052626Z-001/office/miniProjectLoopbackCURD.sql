//loopback CRUD operation:-

chaincode/lib product.js

const state = require('../utils/state');
module.exports = {

    async addProduct(ctx,gtin,name,type,composition,gln,gcp){
        try{
            if(gtin.length === 0){
                throw "gtin must not be empty";
            }

            try{
                await state.keyMustNotExist(ctx,gtin);
            }catch(error){
            throw gtin + " gtin is already registered"
            }

            if(name.length === 0){
                throw "name must not be empty";
            }

            if(type.length === 0){
                throw "product type must not be empty";
            }

            if(composition.length === 0){
                throw "product composition must not be empty";
            }

            if(gln.length === 0){
                throw "gln must not be empty";
            }

            if(gcp.length === 0){
                throw "gcp must not be empty";
            }

            try{
                await state.keyMustExist(ctx,gcp)
                }catch(error){
                    throw gcp + " gcp is invalid"
                }

            try{
                await state.keyMustExist(ctx,gln)
                }catch(error){
                    throw gln + " gln is invalid"
                }    

            const addData = {
                gtin,
                name,
                type,
                composition,
                gln,
                gcp,
                docType: "pproduct"
            }
            await ctx.stub.putState(gtin,Buffer.from(JSON.stringify(addData)));
            return {
                status: true,
                data: gtin + "gtin added Successfully"
            }

        }catch(error){
            return {
                state: false,
                data: error
            }
        }
    },

    async updateProduct(ctx,gtin,children){
        try{
            children = JSON.parse(children);

            if(gtin.length === 0){
                throw "gtin must not be empty"
            }

            try{
                var proUserdata = await state.keyMustExist(ctx,gtin);
            }catch(error){
                throw "invalid gtin " + gtin;
            }

            if(children.name){
                proUserdata.name = children.name;
            }

            if(children.type){
                proUserdata.type = children.type;
            }

            if(children.composition){
                proUserdata.composition = children.composition;
            }

            if(children.gln){
                proUserdata.gln = children.gln;
            }

            if(children.gcp){
                proUserdata.gcp = children.gcp;
            }

            await ctx.stub.putState(gtin,Buffer.from(JSON.stringify(proUserdata)));
            return {
                status: true,
                data: gtin + "updated successfully"
            }
        }catch(error){
            return {
                status: false,
                data: error
            }
        }
    },

    async deleteProduct(ctx, gtin){
//This method is proper working
        try {
            
            var queryString = {};
            queryString.selector = {};
            queryString.selector.gtin = gtin;

            var totalKeyCntIterator = await state.query(ctx, queryString);
            var keys = await state.keyCount(totalKeyCntIterator);
            keys = JSON.parse(keys);
            if(keys.length === 0){
                throw  "Product: "+ gtin + " not found";  
            }

            var filterKeyList = []; 
            for (let index = 0; index < keys.length; index++) {
                const element = keys[index];
                filterKeyList.push(element.Key);
            }

            var queryString = {};
            queryString.selector = {};

            queryString.selector = { 
                gtin: {
                    "$in": filterKeyList
                },
                docType: "pproduct"
            };

            var iterator = await state.query(ctx, queryString);
            
            let keyList = await state.getAllResultsOfPagination(iterator);

            try {
                for (let index = 0; index < keyList.length; index++) {
                    const key = keyList[index];
                    await ctx.stub.deleteState(key);
                    
                }
            }catch (error) {
                throw error
            }

            try {
                for (let index = 0; index < filterKeyList.length; index++) {
                    const key = filterKeyList[index];
                await ctx.stub.deleteState(key);
                    
                }
            } catch (error) {
                throw error
            }

            await ctx.stub.deleteState(gtin);

            return {
                status:true,
                data: "Product linked with gtin: " + gtin + " deleted successfully"
            }

        } catch(error) {
            return{
                status : false,
                data : error
            }
        }  
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------------
location.js

const state = require('../utils/state');
module.exports = {

    async addLocation(ctx,gln,name,gcp){
        try{
            if(gln.length === 0){
                throw "gln must not be empty";
            }

            try{
                await state.keyMustNotExist(ctx,gln);
            }catch(error){
            throw gln + " gln is already registered"
            }

            if(name.length === 0){
                throw "name must not be empty";
            }

            if(gcp.length === 0){
                throw "gcp must not be empty";
            }

            try{
                await state.keyMustExist(ctx,gcp)
                }catch(error){
                    throw gcp + " gcp is invalid"
                }
                
            const addData = {
                gln,
                name,
                gcp,
                docType: "plocation"
            }
            await ctx.stub.putState(gln,Buffer.from(JSON.stringify(addData)));
            return {
                status: true,
                data: gln + "gln added Successfully"
            }

        }catch(error){
            return {
                state: false,
                data: error
            }
        }
    },

    async updateOrganisation(ctx,gln,children){
        try{
            children = JSON.parse(children);

            if(gln.length === 0){
                throw "gln must not be empty"
            }

            try{
                var locationUserdata = await state.keyMustExist(ctx,gln);
            }catch(error){
                throw "invalid gln " + gln;
            }

            if(children.name){
                locationUserdata.name = children.name;
            }

            if(children.gcp){
                locationUserdata.gcp = children.gcp;
            }

            await ctx.stub.putState(gln,Buffer.from(JSON.stringify(locationUserdata)));
            return {
                status: true,
                data: gln + "updated successfully"
            }
        }catch(error){
            return {
                status: false,
                data: error
            }
        }
    },

    async deleteLocation(ctx,gln){
        try{
            var queryString = {};
            queryString.selector = {};
            queryString.selector.gln = gln;

            var iterator = await state.query(ctx,queryString);
            var keys = await state.keyCount(iterator);
            keys = JSON.parse(keys);
            if(keys.length === 0){
                throw "Location : "+ gln +" not found";
            }
            var filterKeyList = [];
            for(let index = 0; index<keys.length; index++){
                const element = keys[index];
                filterKeyList.push(element.Key)
            }

            var queryString = {};
            queryString.selector = {};
            queryString.selector = {
                gln: {
                    "$in": filterKeyList
                },
                docType: "plocation"
            };
            var iterator = await state.query(ctx,queryString);
            let keyList = await state.getAllResultsOfPagination(iterator)

            try{
                for(let index = 0; index<keyList.length; index++){
                    const key = filterKeyList[index];
                    await ctx.stub.deleteState(key);
                }
            }catch(error){
                throw error
            }
            await ctx.stub.deleteState(gln);
            return{
                status: true,
                data: "Location linked with gln: " + gln + " deleted Successfully"
            }
        }catch(error){
            return {
                status: false,
                data: error
            }
        }
    }
}
----------------------------------------------------------------------------------------------------------------------------------------------------
org.js
const state = require('../utils/state');
module.exports = {

    async addOrganisation(ctx,gcp,name,address){
        try{
            if(gcp.length === 0){
                throw "gcp must not be empty";
            }
            if((gcp.length > 9) || (gcp.length < 9)){
                throw "gcp enter must 9 digit"
            }//Gcp only enter 9 digit otherwise throw error

            try{
                await state.keyMustNotExist(ctx,gcp);
            }catch(error){
            throw gcp + " gcp is already registered"
            }

            if(name.length === 0){
                throw "name must not be empty";
            }

            if(address.length === 0){
                throw "address must not be empty";
            }

            const addData = {
                gcp,
                name,
                address,
                docType: "porg"
            }
            await ctx.stub.putState(gcp,Buffer.from(JSON.stringify(addData)));
            return {
                status: true,
                data: gcp + "gcp added Successfully"
            }

        }catch(error){
            return {
                state: false,
                data: error
            }
        }
    },

    async updateOrganisation(ctx,gcp,children){
        try{
            children = JSON.parse(children);

            if(gcp.length === 0){
                throw "gcp must not be empty"
            }

            try{
                var orgUserdata = await state.keyMustExist(ctx,gcp);
            }catch(error){
                throw "invalid gcp " + gcp;
            }

            if(children.name){
                orgUserdata.name = children.name;
            }

            if(children.address){
                orgUserdata.address = children.address;
            }

            await ctx.stub.putState(gcp,Buffer.from(JSON.stringify(orgUserdata)));
            return {
                status: true,
                data: gcp + "updated successfully"
            }
        }catch(error){
            return {
                status: false,
                data: error
            }
        }
    },

    async deleteOrganisation(ctx,gcp){
        try{
            var queryString = {};
            queryString.selector = {};
            queryString.selector.gcp = gcp;  //selector ke baad jise remove karna hai use choose karte hai

            var iterator = await state.query(ctx,queryString);
            var keys = await state.keyCount(iterator);
            keys = JSON.parse(keys);
            if(keys.length === 0){
                throw "Organisation : "+ gcp + " not found";
            }

            var filterKeyList = [];
            for (let index = 0; index<keys.length; index++){
                const element = keys[index];
                filterKeyList.push(element.Key)
            }

            var queryString = {};
            queryString.selector = {};
            queryString.selector = {
                gcp: {
                    "$in": filterKeyList
                },
                docType: "porg"
            };

            var iterator = await state.query(ctx,queryString);
            let keyList = await state.getAllResultsOfPagination(iterator);

            try{
                for(let index = 0; index<keyList.length; index++){
                    const key = filterKeyList[index];
                    await ctx.stub.deleteState(key);
                }
            }catch(error){
                   throw error 
            }
            await ctx.stub.deleteState(gcp);
            return {
                state: true,
                data: "Organisation linked with gcp: " + gcp + " deleted Successfully"
            }
        }catch(error){
            return{
                status: false,
                data: error
            }
        }
    }
}
==================================================================================================================================
realmeds.js

 async addOrganisationData(ctx,gcp,name,address){
        return await porg.addOrganisation(ctx,gcp,name,address);
    }

    async addLocationData(ctx,gln,name,gcp){
        return await ploc.addLocation(ctx,gln,name,gcp)
    }

    async addProductData(ctx,gtin,name,type,composition,gln,gcp){
        return await ppro.addProduct(ctx,gtin,name,type,composition,gln,gcp)
    }

    async updateOrganisationData(ctx,gcp,children){
        return await porg.updateOrganisation(ctx,gcp,children)
    }

    async updateLocationData(ctx,gln,children){
        return await ploc.updateOrganisation(ctx,gln,children)
    }

    async updateProductData(ctx,gtin,children){
        return await ppro.updateProduct(ctx,gtin,children)
    }

    async deleteProducts(ctx, gtin){
        return await ppro.deleteProduct(ctx, gtin);
    }

    async deleteOrganisations(ctx, gcp){
        return await porg.deleteOrganisation(ctx, gcp);
    }

    async deleteLocations(ctx, gln){
        return await ploc.deleteLocation(ctx, gln);
    }

=================================================================================================================================================
api/commom/model/
org.js

'use strict';

const escapeJson = require('escape-json-node/lib/escape-json'); 
const chaincode = require('../../lib/validate-user');
const loopback = require('loopback');
const ds = loopback.createDataSource('memory'); 

module.exports = function(Porganisation) {

    let defineOrgFormat = function(){
        let orgModel = {
            'gcp': String,
            'name': String,
            'address': String
        };
        ds.define('org',orgModel);
    };
    defineOrgFormat();

    Porganisation.addOrgData = async function(data){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addOrganisationData',
            data.gcp,
            data.name,
            data.address
        );
        return JSON.parse(result.toString());
    }

    Porganisation.getOrgData = async function(gcp){
        const contract = await chaincode.validateUser('user3')
        var orgResult = await contract.evaluateTransaction('queryState',gcp)
        return JSON.parse(orgResult.toString());
    }

    Porganisation.updateOrgData = async function(data){
        try{
        const contract = await chaincode.validateUser('user3')
        var gcpId = data.gcp;
        data = escapeJson(JSON.stringify(data));
        var responce = await contract.submitTransaction(
            'updateOrganisationData',
            gcpId,
            data
        );
        return JSON.parse(responce.toString());
        }catch(error){
            throw error;
        }
    }

    Porganisation.deleteOrgData = async function(gcp){
        try{
        const contract = await chaincode.validateUser('user3')
        var result = await contract.submitTransaction(
            'deleteOrganisations',
            gcp
        );
        return JSON.parse(result.toString());
        }catch(error){
            throw error
        }
    }

    Porganisation.remoteMethod('deleteOrgData',{
        accepts: [
            {arg: 'gcp',type: 'string'}
        ],
        returns: {type: 'object', root: true},
        http: {verb: 'delete'},
    });

    Porganisation.remoteMethod('updateOrgData', {
        accepts: [
            { arg: 'data', type: 'org', http: { source: 'body' } }
        ],
        returns: { type: 'object', root: true },
        http: {verb: 'put'}
    });

    Porganisation.remoteMethod('getOrgData',{
        accepts: [{arg: 'gcp',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Porganisation.remoteMethod('addOrgData', {
        accepts: [
            { arg: 'data', type: 'org', http: { source: 'body' } }
        ],
        returns: { type: 'org', root: true }
    });
};
--------------------------------------------------------------------------------------------------------------------------------------
location.js
'use strict';

const escapeJson = require('escape-json-node/lib/escape-json'); 
const chaincode = require('../../lib/validate-user');
const loopback = require('loopback');
const ds = loopback.createDataSource('memory'); 

module.exports = function(Plocation) {

    let defineLocationFormat = function(){
        let locationModel = {
            'gln': String,
            'name': String,
            'gcp': String
        };
        ds.define('loc',locationModel);
    };
    defineLocationFormat();

    Plocation.addLocationData = async function(data){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addLocationData',
            data.gln,
            data.name,
            data.gcp
        );
        return JSON.parse(result.toString());
    }

    Plocation.getLocationData = async function(gln){
        const contract = await chaincode.validateUser('user3')
        var LocationResult = await contract.evaluateTransaction('queryState',gln)
        return JSON.parse(LocationResult.toString());
    }

    Plocation.updateLocationData = async function(data){
        try{
        const contract = await chaincode.validateUser('user3')
        var glnId = data.gln;
        data = escapeJson(JSON.stringify(data));
        var responce = await contract.submitTransaction(
            'updateLocationData',
            glnId,
            data
        );
        return JSON.parse(responce.toString());
        }catch(error){
            throw error;
        }
    }

    Plocation.deleteLocationData = async function(gln){
        try{
            const contract = await chaincode.validateUser('user3')
            var result = await contract.submitTransaction(
                'deleteLocations',
                gln
            );
            return JSON.parse(result.toString());

        }catch(error){
            throw error
        }
    }

    Plocation.remoteMethod('deleteLocationData',{
        accepts: [
            {arg: 'gln', type: 'string'}
        ],
        returns: {type: 'object', root: true},
        http: {verb: 'delete'},
    });

    Plocation.remoteMethod('updateLocationData', {
        accepts: [
            { arg: 'data', type: 'loc', http: { source: 'body' } }
        ],
        returns: { type: 'object', root: true },
        http: {verb: 'put'}
    });

    Plocation.remoteMethod('getLocationData',{
        accepts: [{arg: 'gln',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Plocation.remoteMethod('addLocationData', {
        accepts: [
            { arg: 'data', type: 'loc', http: { source: 'body' } }
        ],
        returns: { type: 'loc', root: true }
    });
};
-------------------------------------------------------------------------------------------------------------------------------------------
pro.js

'use strict';

const escapeJson = require('escape-json-node/lib/escape-json'); 
const chaincode = require('../../lib/validate-user');
const loopback = require('loopback');
const ds = loopback.createDataSource('memory'); 

module.exports = function(Pproduct) {

    let defineProFormat = function(){
        let proModel = {
            'gtin': String,
            'name': String,
            'type': String,
            'composition': String,
            'gln': String,
            'gcp': String
        };
        ds.define('pro',proModel);
    };
    defineProFormat();

    Pproduct.addProData = async function(data){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addProductData',
            data.gtin,
            data.name,
            data.type,
            data.composition,
            data.gln,
            data.gcp
        );
        return JSON.parse(result.toString());
    }

    Pproduct.getProData = async function(gtin){
        const contract = await chaincode.validateUser('user3')
        var proResult = await contract.evaluateTransaction('queryState',gtin)
        return JSON.parse(proResult.toString());
    }

    Pproduct.updateProData = async function(data){
        try{
        const contract = await chaincode.validateUser('user3')
        var gtinId = data.gtin;
        data = escapeJson(JSON.stringify(data));
        var responce = await contract.submitTransaction(
            'updateProductData',
            gtinId,
            data
        );
        return JSON.parse(responce.toString());
        }catch(error){
            throw error;
        }
    }

    Pproduct.getProductDataWithPagination = async function(data){
        const contract = await chaincode.validateUser('user3')
        let filterObject = {
            "docType": "pproduct"
        }
        filterObject = escapeJson(JSON.stringify(filterObject));

        if(data.bookmark === undefined){
            data.bookmark = "";
        }

        if(data.pageSize === undefined){
            data.pageSize = "5";
        }
        var result = await contract.evaluateTransaction(
            'filterDataWithPagination',
            filterObject,
            data.pageSize,
            data.bookmark
        );
        return JSON.parse(result.toString());
    }

    Pproduct.deleteProductData = async function(gtin){
        try{
            const contract = await chaincode.validateUser('user3');
            var result = await contract.submitTransaction(
                'deleteProducts',
                gtin
            );
            return JSON.parse(result.toString());

        }catch(error){
            throw error
        }//This method is working
    }

    Pproduct.remoteMethod('deleteProductData',{
        accepts: [
            {arg: 'gtin', type: 'string' }
        ],
        returns: {type: 'object', root: true},
        http: {verb: 'delete'},
    });//This method only value put and without inverted comma using.

    Pproduct.remoteMethod('getProductDataWithPagination',{
        accepts: [
            {arg: 'data',type: 'object'}
        ],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
        // get and post both method is working but get method using right way
    });

    Pproduct.remoteMethod('updateProData', {
        accepts: [
            { arg: 'data', type: 'pro', http: { source: 'body' } }
        ],
        returns: { type: 'object', root: true },
        http: {verb: 'put'}
    });

    Pproduct.remoteMethod('getProData',{
        accepts: [{arg: 'gtin',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Pproduct.remoteMethod('addProData', {
        accepts: [
            { arg: 'data', type: 'pro', http: { source: 'body' } }
        ],
        returns: { type: 'pro', root: true }
    });
};
=======================================================================================================================================================
chaincode/lib/practice
pbatch.js

const state =  require('../../lib/utils/state');
var moment = require('moment');
console.log(state);
module.exports = {

    async addBatch(ctx,batchId,gtin,serialNumStartIdx,mfgDate,expiryDate,quantity){
        try{

        if(batchId.length === 0){
            throw "Batch Id must not be empty";
        }

        try{
            await state.keyMustNotExist(ctx,batchId);
        }catch(error){
            throw batchId + " already registered";
        }

        quantity = parseInt(quantity);
        serialNumStartIdx = parseInt(serialNumStartIdx);
        
        if(quantity <= 0){
            throw "Invalid batch quantity : " + quantity;
        }

        if(serialNumStartIdx < 0){
            throw "Invalid starting serial number : " + serialNumStartIdx;
        }

        if(mfgDate.length != 0){
            mfgDate = new Date(mfgDate);
        }else{
            mfgDate = new Date();
        }

        if(expiryDate.length != 0){
            expiryDate = new Date(expiryDate);

            if(expiryDate < mfgDate){
                throw "Invalid expiry date : " + expiryDate;
            }
        }

        if(gtin.length === 0){
            throw "gtin must not be empty";
        }

        try{
            var product = await state.keyMustExist(ctx,gtin)
            }catch(error){
                throw gtin + " gtin is invalid"
            }

        // var units = product.attributes.units;//throw error 
        console.log("data is : " +product)
        try{
            await state.keyMustExist(ctx,product.gln);
        }catch(error){
            throw "Location " + product.gln + " is not found";
        }

        try{
            await state.keyMustExist(ctx,product.gcp);
        }catch(error){
            throw "GCP " + product.gcp + " is not found";
        }

        var productInstanceIdToken = batchId;
        var firstIndex = 0;
        var lastIndex = quantity;

        if(serialNumStartIdx != ''){
            firstIndex = serialNumStartIdx;
            lastIndex = serialNumStartIdx + quantity;
        }

        for(index = firstIndex; index < lastIndex; index++){
            var productInstanceId = productInstanceIdToken + "-" + index;

            const productInstance = {
                docType: "primary",
                batchId,
                isInvalid: false,
                gtin: gtin
            }
            await ctx.stub.putState(productInstanceId,Buffer.from(JSON.stringify(productInstance)));  
        }

        var batch = {
            docType: "pbatch",
            batchId,
            gtin,
            mfgDate: moment.utc(mfgDate).format(),
            expiryDate: moment.utc(expiryDate).format(),
            quantity,
            isRecalled: false,
            gcp: product.gcp,
            gln: product.gln

        }

        await ctx.stub.putState(batchId,Buffer.from(JSON.stringify(batch)));
        batch['status'] = true;


        return{
            status: true,
            batchId: batchId,
            gtin,
            mfgDate: moment.utc(mfgDate).format(),
            expiryDate: moment.utc(expiryDate).format(),
            gcp: product.gcp,
            gln: product.gln
        }
    }catch(error){
        return{
            status: false,
            data: error
        }
    }
    },

    async updateBatchData(ctx,batchId,children){
        try{
            children = JSON.parse(children);
            try{
                var batchData = await state.keyMustExist(ctx,batchId);
            }catch(error){
                throw batchId + " not found"
            }

            if(children.serialNumStartIdx){
                batchData.serialNumStartIdx = children.serialNumStartIdx;
            }

            if(children.mfgDate){
                batchData.mfgDate = children.mfgDate;
            }

            if(children.expiryDate){
                batchData.expiryDate = children.expiryDate;
            }

           await ctx.stub.putState(batchId,Buffer.from(JSON.stringify(batchData)));
           
           return{
            status : true,
            data: "Batch " + batchId + " Updated Successfully"
           }

        }catch(error){
            return{
                status: false,
                data: error
            }
        }
    },

    async deleteBatchData(ctx, batchId){
        try {
            
            var queryString = {};
            queryString.selector = {};
            queryString.selector.batchId = batchId;

            var totalKeyCntIterator = await state.query(ctx, queryString);
            var keys = await state.keyCount(totalKeyCntIterator);
            keys = JSON.parse(keys);
            if(keys.length === 0){
                throw  "Batch: "+ batchId + " not found";  
            }

            var filterKeyList = []; 
            for (let index = 0; index < keys.length; index++) {
                const element = keys[index];
                filterKeyList.push(element.Key);
            }

            var queryString = {};
            queryString.selector = {};

            queryString.selector = { 
                batchId: {
                    "$in": filterKeyList
                }
            };

            var iterator = await state.query(ctx, queryString);
            
            let keyList = await state.getAllResultsOfPagination(iterator);

            try {
                for (let index = 0; index < keyList.length; index++) {
                    const key = keyList[index];
                    await ctx.stub.deleteState(key);  
                }
            }catch (error) {
                throw error
            }

            try {
                for (let index = 0; index < filterKeyList.length; index++) {
                    const key = filterKeyList[index];
                await ctx.stub.deleteState(key);
                    
                }
            } catch (error) {
                throw error
            }

            await ctx.stub.deleteState(batchId);

            return {
                status:true,
                data: "Batch linked with batchId: " + batchId + " deleted successfully"
            }

        } catch(error) {
            return{
                status : false,
                data : error
            }
        }  //Proper working
    }

    // async cancelBatchData(ctx,batchId){
    //     try{
    //         try{
    //             var batchData = await state.keyMustExist(ctx,batchId);
    //         }catch(error){
    //             throw batchId + " not found"
    //         };

    //         batchData.cancelled = true;
    //         await ctx.stub.putState(batchId,Buffer.from(JSON.stringify(batchData)));

    //         return{
    //             status: true,
    //             data: "Batch "+ batchId + " cancelled Successfully"
    //         }
    //     }catch(error){
    //         return{
    //             status: false,
    //             data: error
    //         }
    //     }
    // }
}

----------------------------------------------------------------------------------------------------------------------------------------------

realmeds.js 

async addBatchData(ctx,batchId,gtin,serialNumStartIdx,mfgDate,expiryDate,quantity){
        return await pbatch.addBatch(ctx,batchId,gtin,serialNumStartIdx,mfgDate,expiryDate,quantity);
    }

    async updateBatchDatas(ctx,batchId,children){
        return await pbatch.updateBatchData(ctx,batchId,children)
    }

    // async cancelBatchDatas(ctx,batchId){
    //     return await pbatch.cancelBatchData(ctx,batchId)
    // }

    async deleteBatchDatas(ctx, batchId){
        return await pbatch.deleteBatchData(ctx, batchId);
    }

--------------------------------------------------------------------------------------------------------------------------------------------
api/comman/model/
pbatch.js 

'use strict';

const loopback = require('loopback');
const ds = loopback.createDataSource('memory');
const chaincode = require('../../lib/validate-user');
const escapeJson = require('escape-json-node/lib/escape-json');

module.exports = function(Pbatch) {

    let defineBatchFormat = function(){
        let batchFormat = {
            'batchId': String,
            'gtin': String,
            'serialNumStartIdx': String,
            'mfgDate': String,
            'expiryDate': String,
            'quantity': String
        };
        ds.define('batch',batchFormat);
    };
    defineBatchFormat();

    let defineBatchUpdateFormat = function(){
        let batchUpdateFormat = {
            'batchId': String,
            'serialNumStartIdx': String,
            'mfgDate': String,
            'expiryDate': String
        };
        ds.define('batcha',batchUpdateFormat);
    };
    defineBatchUpdateFormat();

Pbatch.addBatchdata = async function (data){
    try{
        const contract = await chaincode.validateUser('user3');
        var result = await contract.submitTransaction(
            'addBatchData',
            data.batchId,
            data.gtin,
            data.serialNumStartIdx,
            data.mfgDate,
            data.expiryDate,
            data.quantity
        );
        console.log(JSON.parse(result.toString()));
        return JSON.parse(result.toString());
    }catch(error){
        throw error
    }
}

Pbatch.getBatchdata = async function(batchId){
    const contract = await chaincode.validateUser('user3')
    var result = await contract.evaluateTransaction('queryState',batchId)
    return JSON.parse(result.toString());
}

Pbatch.updateBatchdata = async function(data){
    try{
        const contract = await chaincode.validateUser('user3')
        var batchIds = data.batchId;
        data = escapeJson(JSON.stringify(data))
        var responce = await contract.submitTransaction(
            'updateBatchDatas',
            batchIds,
            data
        ); //This method working but primary data are not changes 
        //Beacuse not use this method
        return JSON.parse(responce.toString());

    }catch(error){
          throw error;  
    }
}

Pbatch.deleteBatchData = async function(batchId){
    try{
        const contract = await chaincode.validateUser('user3')
        var result = await contract.submitTransaction(
            'deleteBatchDatas',
            batchId
        );
        return JSON.parse(result.toString());

    }catch(error){
        throw error;
    }
}

Pbatch.remoteMethod('deleteBatchData',{
    accepts: [
        {arg: 'batchId', type: 'string'}
    ],
    returns: {type: 'object', root: true},
    http: {verb: 'delete'},
});

// Pbatch.cancel =  async function (batchId){

//     try {
//         const contract = await chaincode.validateUser('user3');
//         var result = await contract.submitTransaction(
//             'cancelBatchDatas', 
//             batchId);
//         result = JSON.parse(result.toString());
//     } catch (error) {
//         throw error
//     }
// }

// Pbatch.remoteMethod('cancel', {
//     accepts: [
//         { arg: 'batchId', type: 'string', required: true }
//     ],
//     returns: { type: 'object', root: true }
// });

Pbatch.remoteMethod('addBatchdata',{
    accepts: [
        {arg: 'data', type: 'batch', http: {source: 'body'}}
    ],
    returns: {type: 'object', root: true}
});

Pbatch.remoteMethod('updateBatchdata', {
    accepts: [
        { arg: 'data', type: 'batcha', http: { source: 'body' } }
    ],
    returns: { type: 'object', root: true },
    http: {verb: 'put'}
});

Pbatch.remoteMethod('getBatchdata',{
    accepts: [{arg: 'batchId',type: 'string'}],
    returns: {type: 'object', root: true},
    http: {verb: 'get'},
});
};

==================================================================================================================================================================    
api/comman/model/pbatch.js

create label method to modify add data

'use strict';

const loopback = require('loopback');
const ds = loopback.createDataSource('memory');
const chaincode = require('../../lib/validate-user');
const sampledatamatrix = require('../../label/types/sampledatamatrix');
const path = require('path')
const Excel = require('exceljs')
var app = require("../../server/server");
const uniqid = require("uniqid");
var ejs = require("ejs");
const config = require('../../server/config.json')
const ccpPath = path.resolve(__dirname, '../../client/labels')


module.exports = function(Pbatch) {

    let defineBatchFormat = function(){
        let batchFormat = {
            'batchId': String,
            'gtin': String,
            'serialNumStartIdx': String,
            'mfgDate': String,
            'expiryDate': String,
            // 'gs1ApplicationIdentifiers': Object,
            'quantity': String
        };
        ds.define('batch',batchFormat);
    };
    defineBatchFormat();

    // let defineBatchUpdateFormat = function(){
    //     let batchUpdateFormat = {
    //         'batchId': String,
    //         'serialNumStartIdx': String,
    //         'mfgDate': String,
    //         'expiryDate': String
    //     };
    //     ds.define('batcha',batchUpdateFormat);
    // };
    // defineBatchUpdateFormat();

Pbatch.addBatchdata = async function (data){
    try{
        const contract = await chaincode.validateUser('user3');

        var reqData = {
            "gtin": data.gtin,
            "batchId": data.batchId
        };

        // if (data.gs1ApplicationIdentifiers === undefined || data.gs1ApplicationIdentifiers.length === 0) {
        //     data.gs1ApplicationIdentifiers = ["gtin", "batchId", "serialNo", "mfgDate", "expiryDate"]
        // }

        // data.gs1ApplicationIdentifiers = escapeJson(JSON.stringify(data.gs1ApplicationIdentifiers));


        var result = await contract.submitTransaction(
            'addBatchData',
            data.batchId,
            data.gtin,
            data.serialNumStartIdx,
            data.mfgDate,
            data.expiryDate,
            // data.gs1ApplicationIdentifiers,
            data.quantity
        );
        // console.log(JSON.parse(result.toString()));
        result = JSON.parse(result.toString());
        //some changes

        data.quantity = parseInt(data.quantity);
        data.serialNumStartIdx = parseInt(data.serialNumStartIdx);

        if(result.status){
            var serializationType = "instanceLevel";
            var reqLabels = "dataMatrix";
            var label = [];
            var productInstanceIdToken = data.batchId;
            var firstIndex = 0;
            var lastIndex = data.quantity;

            if(data.serialNumStartIdx != ''){
                firstIndex = data.serialNumStartIdx;
                lastIndex = data.serialNumStartIdx + data.quantity;
            }

            console.log('firstIndex: ', firstIndex);
            console.log('lastIndex: ', lastIndex);

            for(var index = firstIndex; index < lastIndex; index++){
                var productInstanceId = productInstanceIdToken + "-" + index;

                reqData["serialNo"] = productInstanceId;

                // var labelInfo = await app.models.Label.create(
                //     serializationType,
                //     // data.gs1ApplicationIdentifiers,
                //     reqData,
                //     reqLabels
                // );

                let testData = `(01)${reqData['gtin']}
                (10)"${reqData['batchId']}(21)$${reqData['serialNo']}`;
                var labelInfo = await sampledatamatrix.getLabel(testData);

                console.log("data label info check "+labelInfo)

                label.push({
                    // hri: labelInfo.hri,
                    code: labelInfo
                });

                console.log('loop count: ', index);
            }

            result.label = label;

            var product = await contract.evaluateTransaction(
                'queryState',
                result.gtin);
                product = JSON.parse(product.toString());

                const workbook = new Excel.Workbook();
                const worksheet = workbook.addWorksheet("My Sheet");

                worksheet.columns = [
                    {header: 'Id', key: 'id', width: 5},
                    // {header: 'HRI', key: 'hri', width: 100},
                    {header: 'Label', key: 'label', width: 1000}
                ];

                for(let index = 0; index < result.label.length; index++){
                    const lbl = result.label[index].code;
                    // const hri = result.label[index].hri;
                    
                    worksheet.addRow({id: index,
                        //  hri: hri,
                         label: lbl});
                }

                var fileName = result.gcp + "-" + uniqid();


                await workbook.xlsx.writeFile(ccpPath + `/${fileName}.xlsx`);

                var downloadUrl = config.externalUrl + '/labels' + `${fileName}.xlsx`;

                var html = await ejs.renderFile(
                    path.resolve(__dirname, "../../server/views/mail-label.ejs"),
                    {
                        downloadLink: downloadUrl,
                        batchNo: result.batchId,
                        externalUrl: config.externalUrl,
                        supportUserName: config.supportUserName
                    },
                    {
                        async: true

                    }
                );//This line data proper work

                app.models.Email.send(
                    {
                        to: [result.organisationEmail, result.locationEmail],
                        from: config.senderEmailAddress,
                        subject: 'Batch labels - ' + result.batchId,
                        html: html
                    },
                    function(err){
                        if(err){
                            return console.log("> error sending label rmail")
                        }
                    }
                ); //This mail not work show error

                result.labelDownloadLink = downloadUrl,

                delete result.organisationEmail;
                delete result.locationEmail;

                return result;

        }else{
            throw new Error(result.data);
        }
        // return JSON.parse(result.toString());
 }catch(error){
        throw error
    }
}

old data
Pbatch.getBatchdata = async function(batchId){
    const contract = await chaincode.validateUser('user3')
    var result = await contract.evaluateTransaction('queryState',batchId)
    return JSON.parse(result.toString());
}


Pbatch.deleteBatchData = async function(batchId){
    try{
        const contract = await chaincode.validateUser('user3')
        var result = await contract.submitTransaction(
            'deleteBatchDatas',
            batchId
        );
        return JSON.parse(result.toString());

    }catch(error){
        throw error;
    }
}

Pbatch.remoteMethod('deleteBatchData',{
    accepts: [
        {arg: 'batchId', type: 'string'}
    ],
    returns: {type: 'object', root: true},
    http: {verb: 'delete'},
});

Pbatch.remoteMethod('addBatchdata',{
    accepts: [
        {arg: 'data', type: 'batch', http: {source: 'body'}}
    ],
    returns: {type: 'object', root: true}
});

Pbatch.remoteMethod('getBatchdata',{
    accepts: [{arg: 'batchId',type: 'string'}],
    returns: {type: 'object', root: true},
    http: {verb: 'get'},
});
};




======================================================================================================================================================

