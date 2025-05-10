'use strict';

const loopback = require('loopback');
const ds = loopback.createDataSource('memory'); //This two method using post method visible hard code data

module.exports = function(Pipra) {

    let defineDappUserFormat = function() {  //This line se start hard code data
        let newUserModel = {
                'dAppId' : String,
                'userName' : String ,
                'userType' : String ,
                'email' : String ,
                'password' : String,
                'gln':String,
                'gcp':String
            };
        ds.define('newDappUser', newUserModel);
      };
      defineDappUserFormat() ;  //This line tak use hard code data

    Pipra.addData =  function (data, cb){ //are you using async method then not using callback parameter(cb) 
        console.log("data", data);
        cb(null, data) ; //this method is POST method
    }

    Pipra.getData = function(company, cb){
        console.log("company", company);
        let data = {
            "name":"Chirag Rathi",
            "city":"Hyderabad",
            "company": "Pipra Solutions"
        };
        cb(null, data);   //This method is GET method
    }

    Pipra.remoteMethod('addData', {
        accepts: [
            { arg: 'data', type: 'newDappUser', http: { source: 'body' } }
        ],
        returns: { type: 'object', root: true }  //POST remote method
    });

    Pipra.remoteMethod('getData', {
        accepts: [{ arg: 'company', type: 'string', required: false }],
        returns: { type: 'object', root: true },
        http: {verb: 'get'},  //GET remote method
        //verb ke aage get likhne ka use ui mai screen mai get show hoga 
    });

}