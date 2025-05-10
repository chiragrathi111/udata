Tenant:-

		Tenant Complete setup from scratch:-

	1.	Login SuperUser and choose Tenant System then create Tenant, otherwise Tenant create option not show.
	2.	Go to Initial Tenant setup and fill the required field:-
		Tenant Name 			- Name For your requirement
		Org key 				- Organiztion search key
		Organiztion Name		- Name of Organiztion
		Adminstrative User Name - Admin (all Access)
		Normal User Name 		- User (normal user)
		Currency				- Choosh currency our requirement
		Country					- Choosh country name

		This check box select
		BP Accounting,Product Accounting,Project Accounting,Campaign Accounting,Sales Region Accounting,Activity Accounting

		Chart of Accounts File - /home/chirag/idempiere/idempiere/org.adempiere.server-feature/data/import/AccountingDefaultsOnly.csv
		file path will be accurate otherwie your Tenant not created

		if you provide other field for your requirement and go to Ok button press and finally Tenant created
		(Tenant, org,user and admin) will be created

		login  SuperUser and select your tenant name 

	3.	Create a Warehouse for your need
		searchkey,name,address and save
		create Locator field
		search key,X,Y,Z value and save, choose Reservation Location	


	4.	Go Organiztion and provide complete details for your need.
		like address,Organiztion type,Warehouse,Supervisorand logo

	5.	Create new product:-
	
	    some important field will be created
	    like Product Category,UOM,Freight Category,and bottom side Price filed choose and press + icon create new records

	    Product Category :-
	    searchkey,name,Material Policy - FiFo then save

	    UOM:-
	    UOM Code, Symbol,Name,UOM Type ans save

	    Freight Category:-
	    searchkey,name and save

	    Price:- (Purchase,Sales,Import,Export)
	    click Price List Version:-
	    Price List:-
	    Name,Currency and save
	    Version:-
	    Name, Valid From,go to price list schema (Name,Valid,Schema Type)

	    /home/chirag/idempiere/idempiere/org.adempiere.server-feature/data/import/AccountingDefaultsOnly.csv

	    /home/ubuntu/WarePro/idempiere-server/data/import/AccountingDefaultsOnly.csv

	    /home/ubuntu/WareProDemo/wms/idempiere-server-demo/data/import/AccountingDefaultsOnly.csv

	    If CSv file is not working then Choosh auto csv file generate

	    New Local path:-
	    /home/chirag/newPipra/wms/idempiere-release-10/org.adempiere.server-feature/data/import/AccountingDefaultsOnly.csv



	    if server database changes:;-
	    
	    cd /opt/idempiere-server/
    sudo nano idempiere.properties 
    sudo nano idempiereEnv.properties