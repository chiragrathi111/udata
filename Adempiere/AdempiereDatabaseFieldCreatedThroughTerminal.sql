1. Create a new filed in idempiere :-
	* sudo -i -u postgres
	* psql
	* \l 
	* \c idempiere
	* ALTER TABLE adempiere.C_Orderline ADD COLUMN ExpiryDate DATE;
	this line code using idempiere filed is proper created 

2. add a column in idempiere login with Sytem user:-
	* search table and column window
	* Your requirement DB enter
	* enter name <c_orderline> in search DB table name field option
	* Click the up side show symbol process and choose first one (create column for DB)
		and press ok you see you field name is show
	* go to column tab and your column tab show in full screen window go to grid view and find your field name and click edit option
	     your requirement reference enter and press save

	* search Window,Tab and filed 
	* Your requirement DB enter
	* enter name <Purchase Order> in search DB table name field option
	* go to second one tab <PO LINE> and click editable
		scroll down and enter create field and you see get your field name
	* your requirement according change your filed sequence
	
	and last restart your eclipse or server then your field is working other wise your field is not working throw error.		     	