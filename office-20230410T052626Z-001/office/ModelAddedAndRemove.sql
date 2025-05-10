1. If create a Model two method first direct type and second command run:-
	1) * cd network/api/comman/model/ 
		manually create a js and json file then you copy json formet and paste but change your model name,
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

		second thing is go to cd realmeds/network/api/server/ 
		  open model-config-json file and create new model detils like
		  "Person": {
    	  "dataSource": null,
   		  "public": true
 		 }


 	2) If you created terminal you not any write model-config.json file automatic generated
		* cd network/api/comman/model/
		* lb model  enter model name(First word capital),base choose Model other thing enter (if you any mistake then old json file replced and change Model name)

2. If you remove your API (js and json file)
	most important thing if you remove js and json file and network/api/ node. 
	you throw the error:-

	node .
/home/chirag/Tissue Culture R/realmeds/network/api/node_modules/loopback/lib/registry.js:319
  throw new Error(g.f('Model not found: %s', modelName));
  ^

Error: Model not found: Pipra
    at Registry.getModel (/home/chirag/Tissue Culture R/realmeds/network/api/node_modules/loopback/lib/registry.js:319:9)
    at /home/chirag/Tissue Culture R/realmeds/network/api/node_modules/loopback-boot/lib/executor.js:234:24
    at Array.forEach (<anonymous>)
    at defineModels (/home/chirag/Tissue Culture R/realmeds/network/api/node_modules/loopback-boot/lib/executor.js:229:23)
    at setupModels (/home/chirag/Tissue Culture R/realmeds/network/api/node_modules/loopback-boot/lib/executor.js:197:3)
    at execute (/home/chirag/Tissue Culture R/realmeds/network/api/node_modules/loopback-boot/lib/executor.js:40:3)
    at bootLoopBackApp (/home/chirag/Tissue Culture R/realmeds/network/api/node_modules/loopback-boot/index.js:154:3)
    at Object.<anonymous> (/home/chirag/Tissue Culture R/realmeds/network/api/server/server.js:32:1)
    at Module._compile (internal/modules/cjs/loader.js:778:30)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:789:10)
    at Module.load (internal/modules/cjs/loader.js:653:32)
    at tryModuleLoad (internal/modules/cjs/loader.js:593:12)
    at Function.Module._load (internal/modules/cjs/loader.js:585:3)
    at Function.Module.runMain (internal/modules/cjs/loader.js:831:12)
    at startup (internal/bootstrap/node.js:283:19)
    at bootstrapNodeJSCore (internal/bootstrap/node.js:623:3)


    this error means you remove js and json file but you not remove model-config.json file define model class then every time throw error
    please you remove any js and json file you also remove defined value in model-config.json file  


    		
