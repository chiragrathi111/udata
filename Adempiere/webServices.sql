1. First download soapUI app through browser.
2. Go to idempiere login SuperUser/GardenAdmin
3. Search in Web Services Security create new and fill up required field

(soap create a new project and copy this link directly paste this link
https://localhost:8444/ADInterface/services/ModelADService?wsdl
this link is direct use no any changes.)

CreateUser:-

	Search key -
	Name -
	Web services - choose Model Oriented Web services
	Web services Method - choose Model Oriented Web services_Create Data
	Table - Ad_User_User/Contact
	save and create default parameters

	There is a Web Services parameters in left bottom and seen Action  value  Create (This value change and craete is also changed)

   There is a Web Services Field Input in left bottom click + icon
   choose only column name Name_Name and other reference field is not requirement and save

   There is a Web Services Access in Middle bottom click + icon
   and select a role this line provide a restriction who is seen or not and save 

   soapUI filed click createData and show the code give some required changes and go to run

   <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:createData>  (method name)
         <_0:ModelCRUDRequest>
            <_0:ModelCRUD>
               <_0:serviceType>chiUser</_0:serviceType>  (Web services Name)
               <_0:TableName>AD_User_User/Contact</_0:TableName>  (Table name enter the web services sequrity field)
               <_0:RecordID>0</_0:RecordID>  (starting enter 0 and your api is running show actual RecordId)
               
               <_0:DataRow>
                  <!--Zero or more repetitions:-->
                  <_0:field type="?" column="Name">  (column Name You are provide in web services sequrity)
                     <_0:val>Chirag</_0:val>    (Randomly name is generate your db table)
                  </_0:field>
               </_0:DataRow>
            </_0:ModelCRUD>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>    (Login user name)
               <_0:pass>System</_0:pass>		(login password)
               <_0:lang>112</_0:lang>			(language id)
               <_0:ClientID>11</_0:ClientID>	(client id)
               <_0:RoleID>102</_0:RoleID>		(role id)
               <_0:OrgID>11</_0:OrgID>			(org id)
               <_0:WarehouseID>103</_0:WarehouseID>	(Warehouse Id)
               <_0:stage>0</_0:stage>				(stage value is 0 providing)
            </_0:ADLoginRequest>
         </_0:ModelCRUDRequest>
      </_0:createData>
   </soapenv:Body>
</soapenv:Envelope>	

find the file :-wsdl

=================================================================================================================================================================

Update user:-

Search key -
Name -
Web services - choose Model Oriented Web services
Web services Method - choose Model Oriented Web services_Update Data
Table - Ad_User_User/Contact
(This all value same on CreateUser)

There is a Web Services parameters in left bottom and seen Action  value  CreateUpdate (This value change and create is also changed)


There is a Web Services Field Input in left bottom click + icon
choose only column name AD_User_ID_User/Contact and other reference field is not requirement and save

soapUI filed click createUpdateData and show the code give some required changes and go to run

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:createUpdateData>
         <_0:ModelCRUDRequest>
            <_0:ModelCRUD>
               <_0:serviceType>chiUser</_0:serviceType>    (Web services Name)
               <_0:TableName>AD_User_User/Contact</_0:TableName>   (Table name enter the web services sequrity field)
               <_0:RecordID>0</_0:RecordID>			(starting enter 0 and your api is running show actual RecordId)
               
               <_0:DataRow>
                  <!--Zero or more repetitions:-->
                  <_0:field type="?" column="Name">   (another unused field remove)
                     <_0:val>Chirag Rathi Tarighat</_0:val>  (this filed copy and paste and this new details )
                  </_0:field>

				<_0:field type="?" column="AD_User_ID">  (enter field name)
                     <_0:val>1000011</_0:val>        (If you update data this place provide user_Id (like 1000011))
                  </_0:field>
                  
               </_0:DataRow>
            </_0:ModelCRUD>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>11</_0:OrgID>
               <_0:WarehouseID>103</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
         </_0:ModelCRUDRequest>
      </_0:createData>
   </soapenv:Body>
</soapenv:Envelope>

Run the soapui and you show your existing data is update 



=============================================================================================================================================

Read Data:-


	Search key -
	Name -
	Web services - choose Model Oriented Web services
	Web services Method - choose Model Oriented Web services_Read Data
	Table - Ad_User_User/Contact
	save and create default parameters, this is a very good way because required value auto update If you are not using some error and 
	this error not easily resolve
	and you check table name and action is using constrant value not a free value

	There is a Web Services parameters in left bottom and seen Action  value  Read (This value change and create is also changed)

   There is a Web Services Access in Middle bottom click + icon
   and select a role this line provide a restriction who is seen or not and save 

   Read Data not using Input Field but it is using Output field because which data you show 

   soapUI filed click read and show the code give some required changes and go to run

RecordID must required

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:readData>
         <_0:ModelCRUDRequest>
            <_0:ModelCRUD>
               <_0:serviceType>readUser</_0:serviceType>    (web services Name)
               <_0:RecordID>1000000</_0:RecordID>            (user_Id if wrong throw result false)
            </_0:ModelCRUD>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>11</_0:OrgID>
               <_0:WarehouseID>103</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
         </_0:ModelCRUDRequest>
      </_0:readData>
   </soapenv:Body>
</soapenv:Envelope>

=============================================================================================================================================================

Query Data:-

	Search key -
	Name -
	Web services - choose Model Oriented Web services
	Web services Method - choose Model Oriented Web services_Query Data
	Table - Ad_User_User/Contact
	save and create default parameters, this is a very good way because required value auto update If you are not using some error and 
	this error not easily resolve
	and you check table name and action is using constrant value not a free value

	There is a Web Services parameters in left bottom and seen Action  value  read (This value change and create is also changed)

   There is a Web Services Access in Middle bottom click + icon
   and select a role this line provide a restriction who is seen or not and save 

   There is a Web Services Field Output in the middle Bottom
   you display output your soanUI select there field

   You also choose Web Services Input Field This field are using filtering the some data otherwise show whole data 

   RecordID not required

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:queryData>
         <_0:ModelCRUDRequest>
            <_0:ModelCRUD>
               <_0:serviceType>queryData</_0:serviceType>
             	  <_0:DataRow>
                  <_0:field column="Name">          (you are using some specific data then use this field otherwise show whole data)
                     <_0:val>Pharma agency</_0:val>  
                  </_0:field>				
               </_0:DataRow>
            </_0:ModelCRUD>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>11</_0:OrgID>
               <_0:WarehouseID>103</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
         </_0:ModelCRUDRequest>
      </_0:queryData>
   </soapenv:Body>
</soapenv:Envelope>

IF YOU ARE USING WILDCARD(*,% and other) then create a reference and put reference input filed reference name Table and value you created Input
and some line code write in Eclipse 


Query Data Show Whole Data 


=============================================================================================================================================================
Delete Data:-

	Search key -
	Name -
	Web services - choose Model Oriented Web services
	Web services Method - choose Model Oriented Web services_Delete Data
	Table - Ad_User_User/Contact  (Enter table name when delete a record )
	save and create default parameters, this is a very good way because required value auto update If you are not using some error and 
	this error not easily resolve
	and you check table name and action is using constrant value not a free value
	this name auto genereted then remove table name in this field beacuse web services input and output filed fill up tansion nahi hoga

	and go to soanUi app and choose delete method and put requied input 

	RecordID must be Required

	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:deleteData>
         <_0:ModelCRUDRequest>
            <_0:ModelCRUD>
               <_0:serviceType>deleteUser</_0:serviceType>
               <_0:RecordID>1000012</_0:RecordID>
            </_0:ModelCRUD>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>11</_0:OrgID>
               <_0:WarehouseID>103</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
         </_0:ModelCRUDRequest>
      </_0:deleteData>
   </soapenv:Body>
</soapenv:Envelope>

If your table not a primary key then remove the record this condition some extra affird and remove the table
=============================================================================================================================================================
Update data:-


	Search key -
	Name -
	Web services - choose Model Oriented Web services
	Web services Method - choose Model Oriented Web services_Update Data
	Table - Ad_User_User/Contact  (choose table name when data on updated)
	save and create default parameters, this is a very good way because required value auto update If you are not using some error and 
	this error not easily resolve
	and you check table name and action is using constrant value not a free value

	There is a Web Services parameters in left bottom and seen Action  value  update (This value change and create is also changed)

   There is a Web Services Access in Middle bottom click + icon
   and select a role this line provide a restriction who is seen or not and save 

   You also choose Web Services Input Field This field are using which field you are updated 
   choose name and value field

   RecordID must be required

   <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:updateData>
         <_0:ModelCRUDRequest>
            <_0:ModelCRUD>
               <_0:serviceType>updateUser</_0:serviceType>
               <_0:RecordID>1000001</_0:RecordID>   (Table RecordID like you use User_user then RecordID is ad_user_id)
               <_0:DataRow>
                  <_0:field column="Name">  (If you ine filed update then put your task 5 field update then put the value)
                     <_0:val>DAP</_0:val>
                  </_0:field>
                   <_0:field column="Value">  (If you ine filed update then put your task 5 field update then put the value)
                     <_0:val>DAP</_0:val>
                  </_0:field>
               </_0:DataRow>
            </_0:ModelCRUD>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>11</_0:OrgID>
               <_0:WarehouseID>103</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
         </_0:ModelCRUDRequest>
      </_0:updateData>
   </soapenv:Body>
</soapenv:Envelope>

=============================================================================================================================================================
getRefList and getTableList

When reference id to search Table then called getTableList :-

	Search key - getTableList
	Name -	getTableList
	Web services - choose Model Oriented Web services
	Web services Method - choose Model Oriented Web services_get Reference list or Reference Table
	Table - C_Greeting_greeting  (choose table name when data on updated)
	save and create default parameters, this is a very good way because required value auto update If you are not using some error and 
	this error not easily resolve
	
	Web services parameters only one field Ad_Reference_Id

	Web services output filed choose data show your output

	There is a Web Services Access in Middle bottom click + icon
    and select a role this line provide a restriction who is seen or not and save 

    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:getList>
         <_0:ModelGetListRequest>
            <_0:ModelGetList>
               <_0:serviceType>getTableList</_0:serviceType>
               <_0:AD_Reference_ID>356</_0:AD_Reference_ID>  (This record is ad_reference table ki hai)
            </_0:ModelGetList>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>11</_0:OrgID>
               <_0:WarehouseID>103</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
         </_0:ModelGetListRequest>
      </_0:getList>
   </soapenv:Body>
</soapenv:Envelope>

----------------------------------------------------------------------------------------------------------------------------------------------------
when reference list to search Table data list then called getRefList,


	Search key - getRefList
	Name -	getRefList
	Web services - choose Model Oriented Web services
	Web services Method - choose Model Oriented Web services_get Reference list or Reference Table
	Table - ad_ref_list_Reference_List  (choose table name when data on updated)
	save and create default parameters, this is a very good way because required value auto update If you are not using some error and 
	this error not easily resolve
	
	Web services parameters only one field Ad_Reference_Id

	Web services output filed choose data show your output

	There is a Web Services Access in Middle bottom click + icon
    and select a role this line provide a restriction who is seen or not and save 

    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:getList>
         <_0:ModelGetListRequest>
            <_0:ModelGetList>
               <_0:serviceType>getRefList</_0:serviceType>
               <_0:AD_Reference_ID>300</_0:AD_Reference_ID>
            </_0:ModelGetList>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>11</_0:OrgID>
               <_0:WarehouseID>103</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
         </_0:ModelGetListRequest>
      </_0:getList>
   </soapenv:Body>
</soapenv:Envelope>

=============================================================================================================================================================

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:compositeOperation>
         <_0:CompositeRequest>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>11</_0:OrgID>
               <_0:WarehouseID>103</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
            <_0:serviceType>BPnadOrder</_0:serviceType>
            <!--1 or more repetitions:-->
            <_0:operations>
               <_0:operation preCommit="false" postCommit="false">
                  <_0:TargetPort>createUserData</_0:TargetPort>
                  <_0:ModelCRUD>
                     <_0:serviceType>CreateUpdateBPartner</_0:serviceType>
                     <_0:DataRow>
                        <_0:field column="Name">
                           <_0:val>Chirag rathi</_0:val>
                        </_0:field>
                        <_0:field column="Value">
                           <_0:val>KD12345</_0:val>
                        </_0:field>
                        <_0:field column="Iscustomer">
                           <_0:val>N</_0:val>
                        </_0:field>
                     </_0:DataRow>
                  </_0:ModelCRUD>
                  <!--Optional:-->
               </_0:operation>

			<_0:operation>
                  <_0:TargetPort>createData</_0:TargetPort>
                  <_0:ModelCRUD>
                     <_0:serviceType>CreateLocation</_0:serviceType>
                     <_0:DataRow>
                        <_0:field column="Address1">
                           <_0:val>Sector -1</_0:val>
                        </_0:field>
                        <_0:field column="City">
                           <_0:val>Durg</_0:val>
                        </_0:field>
                        <_0:field column="Postal">
                           <_0:val>491111</_0:val>
                        </_0:field>
                        <_0:field column="C_CountryId">
                           <_0:val>101</_0:val>
                        </_0:field>
                     </_0:DataRow>
                  </_0:ModelCRUD>
                  <!--Optional:-->
               </_0:operation>

               <_0:operation>
                  <_0:TargetPort>createUpdateData</_0:TargetPort>
                  <_0:ModelCRUD>
                     <_0:serviceType>CreateUpdateBPartnerLocation</_0:serviceType>
                     <_0:DataRow>
                        <_0:field column="Name">
                           <_0:val>Chirag rathi ji -1</_0:val>
                        </_0:field>
                        <_0:field column="C_Location_ID">
                           <_0:val>@C_Location.C_Location_ID</_0:val>
                        </_0:field>
                        <_0:field column="C_BPartnerID">
                           <_0:val>@C_BPartner.C_BPartner_ID</_0:val>
                        </_0:field>
                        <_0:field column="IsBillTo">
                           <_0:val>Y</_0:val>
                        </_0:field>
                        <_0:field column="IsPayFrom">
                           <_0:val>Y</_0:val>
                        </_0:field>
                        <_0:field column="IsRemitTo">
                           <_0:val>Y</_0:val>
                        </_0:field>
                        <_0:field column="IsShipTo">
                           <_0:val>Y</_0:val>
                        </_0:field>
                     </_0:DataRow>
                  </_0:ModelCRUD>
                  <!--Optional:-->
               </_0:operation>

               <_0:operation>
                  <_0:TargetPort>createUpdateData</_0:TargetPort>
                  <_0:ModelCRUD>
                     <_0:serviceType>CreateUpdateUser</_0:serviceType>
                     <_0:DataRow>
                        <_0:field column="Name">
                           <_0:val>Chi rathi</_0:val>
                        </_0:field>
                        <_0:field column="Value">
                           <_0:val>chi Tarighat</_0:val>
                        </_0:field>
                        <_0:field column="Email">
                           <_0:val>chiragrathi303@gmail.com</_0:val>
                        </_0:field>
                        <_0:field column="C_BPartner_ID">
                           <_0:val>@C_BPartner.C_BPartner_ID</_0:val>
                        </_0:field>
                        <_0:field column="C_BPartner_Location_ID">
                           <_0:val>@C_BPartner_Location.C_BPartner_Location_ID</_0:val>
                        </_0:field>
                     </_0:DataRow>
                  </_0:ModelCRUD>
                  <!--Optional:-->
               </_0:operation>

                 <_0:operation>
                  <_0:TargetPort>createData</_0:TargetPort>
                  <_0:ModelCRUD>
                     <_0:serviceType>CreateOrder</_0:serviceType>
                     <_0:DataRow>
                        <_0:field column="Description">
                           <_0:val>Order via web services</_0:val>
                        </_0:field>
                        <_0:field column="C_DocTypeTarget_ID">
                           <_0:val>132</_0:val>
                        </_0:field>
                        <_0:field column="DateOrdered">
                           <_0:val>2023-07-07 12:12:12.7</_0:val>
                        </_0:field>
                        <_0:field column="C_BPartnerID">
                           <_0:val>@C_BPartner.C_BPartner_ID</_0:val>
                        </_0:field>
                        <_0:field column="C_BPartner_Location_ID">
                           <_0:val>@C_BPartner_Location.C_BPartner_Location_ID</_0:val>
                        </_0:field>
                     </_0:DataRow>
                  </_0:ModelCRUD>
                  <!--Optional:-->
               </_0:operation>
                  
                <_0:operation>
                  <_0:TargetPort>createData</_0:TargetPort>
                  <_0:ModelCRUD>
                     <_0:serviceType>CreateOrderLine</_0:serviceType>
                     <_0:DataRow>
                        <_0:field column="C_Order_ID">
                           <_0:val>@C_Order.C_Order_ID</_0:val>
                        </_0:field>
                        <_0:field column="AD_Org_ID">
                           <_0:val>11</_0:val>
                        </_0:field>
                        <_0:field column="M_Product_ID">
                           <_0:val>146</_0:val>
                        </_0:field>
                        <_0:field column="QtyEntered">
                           <_0:val>1</_0:val>
                        </_0:field>
                        <_0:field column="Description">
                           <_0:val>OrderLine Via WebService</_0:val>
                        </_0:field>
                     </_0:DataRow>
                  </_0:ModelCRUD>
                  <!--Optional:-->
               </_0:operation>


                <_0:operation>
                  <_0:TargetPort>setDocAction</_0:TargetPort>
                  <_0:ModelSetDocAction>
                     <_0:serviceType>CompleteOrder</_0:serviceType>
                     <_0:recordID></_0:recordID>
                     <_O:recordIDVariable>@C_Order.C_Order_ID</_O:recordIDVariable>
                   
                 </_0:ModelSetDocAction>
                  <!--Optional:-->
               </_0:operation>
            
            </_0:operations>
         </_0:CompositeRequest>
      </_0:compositeOperation>
   </soapenv:Body>
</soapenv:Envelope>

==================================================================================================================================================================
Current working web services:-

readData

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:readData>
         <_0:ModelCRUDRequest>
            <_0:ModelCRUD>
               <_0:serviceType>new readData</_0:serviceType>
                <_0:TableName></_0:TableName>
               <_0:RecordID>103</_0:RecordID>
            </_0:ModelCRUD>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>50007</_0:OrgID>
               <_0:WarehouseID>1000000</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
         </_0:ModelCRUDRequest>
      </_0:readData>
   </soapenv:Body>
</soapenv:Envelope>

updateData

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:_0="http://idempiere.org/ADInterface/1_0">
   <soapenv:Header/>
   <soapenv:Body>
      <_0:updateData>
         <_0:ModelCRUDRequest>
            <_0:ModelCRUD>
               <_0:serviceType>newUpdateData</_0:serviceType>
               <_0:RecordID>1000033</_0:RecordID>
                <_0:DataRow>
                  <_0:field column="Value" >
                     <_0:val>chiru</_0:val>
                  </_0:field>
               </_0:DataRow>
            </_0:ModelCRUD>
            <_0:ADLoginRequest>
               <_0:user>SuperUser</_0:user>
               <_0:pass>System</_0:pass>
               <_0:lang>112</_0:lang>
               <_0:ClientID>11</_0:ClientID>
               <_0:RoleID>102</_0:RoleID>
               <_0:OrgID>50007</_0:OrgID>
               <_0:WarehouseID>1000000</_0:WarehouseID>
               <_0:stage>0</_0:stage>
            </_0:ADLoginRequest>
         </_0:ModelCRUDRequest>
      </_0:updateData>
   </soapenv:Body>
</soapenv:Envelope>

**********************************************************************************************************************************************************

package org.idempiere.web.testing.model;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Properties;
import org.compiere.process.SvrProcess;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.compiere.util.Env;

public class WebTesting extends SvrProcess{
   
   private CLogger log = CLogger.getCLogger(WebTesting.class);
   private Properties ctx = Env.getCtx();
   private int clientId = Env.getAD_Client_ID(ctx);
   private ArrayList<String> accessebleWindows = new ArrayList<>();
   private String pur = "Purchase Order";
   private String sale = "Sales Order";
   private String mate = "Material Receipt";
   private String store = "Storage Provider";
   private boolean condtion1 = false;
   private boolean condtion2 = false;
   private boolean condtion3 = false;
   private boolean condtion4 = false;

   @Override
   protected void prepare() {
      // TODO Auto-generated method stub  
   }

   @Override
   protected String doIt() throws Exception {
      // TODO Auto-generated method stub
      try { 
      String query = "select e.name as Access_Window from adempiere.ad_user_roles a\n"
            + "join adempiere.ad_role b on a.ad_role_id = b.ad_role_id\n"
            + "join adempiere.ad_user c on a.ad_user_id = c.ad_user_id\n"
            + "join adempiere.ad_window_access d on a.ad_role_id = d.ad_role_id\n"
            + "join adempiere.ad_window e on d.ad_window_id = e.ad_window_id\n"
            + "where c.ad_user_id = 1000034 and a.ad_client_id = " + clientId + ";";
      
      PreparedStatement pstm = null;
      ResultSet rs = null;
      
      pstm = DB.prepareStatement(query.toString(), null);
      rs = pstm.executeQuery();
      
      while(rs.next()) {
         String AccessWindowsName = rs.getString("Access_Window");
         accessebleWindows.add(AccessWindowsName);
      }
      rs.close();
      pstm.close();
      
      for(String aw : accessebleWindows) {
         if (aw.equals(pur)) {
            condtion1 = true;
         }
         if(aw.equals(sale)) {
            condtion2 = true;
         }
         if(aw.equals(mate)) {
            condtion3 = true;
         }
         if(aw.equals(store)) {
            condtion4 = true;
            break;
         }
      }
      if(condtion1) {
         System.out.println("Purchase Order is Available");
      }else {
         System.out.println("Purchase Order is not Available");
      }
      if(condtion2) {
         System.out.println("Sales Order is Available");
      }else {
         System.out.println("Sales Order is not Available");
      }
      if(condtion3) {
         System.out.println("Material Recipt is Available");
      }else {
         System.out.println("Material Recipt is not Available");
      }
      if(condtion4) {
         System.out.println("Storage provider is Available");
      }else {
         System.out.println("Storage provider is not Available");
      }
      
      }catch(Exception e) {
         System.out.println("somethime error occured");
      }
      return "Role show";
   }
}

