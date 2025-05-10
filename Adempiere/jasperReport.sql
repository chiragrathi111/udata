1. download jasper report app:-
	* https://sourceforge.net/projects/jasperstudio/
	  and download this link for linux

	* first download then open the app and setup your Idempiere Database Connection:-
		Data Adapter right click and create Data Adapter  
		choose Database JDBC Connection and go next 

		Choose Driver :- Postgres
		JDBC url :- last name idempiere replace database
		Username :- adempiere
		Password :- adempiere

	* Click Create a new Jasper Report :-
		choose page Lanscape or normal page
		enter file name 
		enter main query name like (SELECT * FROM C_Order) and Next
		press >> button -> next -> next -> finish
			show your jasper page which location you show in your report other row remove your page
			and your requirement drag and drop statis filed and enter field name your requirement 

		If you show display Table format then drag and Drop table:-

		Next -> enter Dataset Name and Next -> paste query for table 
		>> -> next -> next -> next -> >> -> next Add Table Header check box checked other box unchecked

		Table fixed for page according  and enter two time table 
		table column field name change static value enter and your field accroding resize

	* If you provide any Parameter to add First Main report Parameter and second one add Parameter to Table side and both parameter create a relationship both Parameter
		Enter Table Name 
		right side show Dataset enter Dataset Name 
		bottom side choose Parameters show new window
		enter add choose Parameter name and choose Parameter Extension (Extention is ${} this format every time)
		OK -> finish	
		Your Parameter relationship is completed

		And go to testing for Preview


=================================================================================================================================================================
How to add jasper file in jasperstudio:-
go to file -> open file -> and choose file for your location and open

first you check Preview it is working or not
