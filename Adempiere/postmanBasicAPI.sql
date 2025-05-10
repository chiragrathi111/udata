If you try to create a rest API then most important point is create a Document filed and manage then your rest api is working.

1) save .xml file and show your new api name then drag and drop your rest api and url also changes with last end point name 
({{PipraCustomWebserviceImplPortBaseUrl}}/ADInterface/services/rest/pipra_customservice/po_list)

2) is go to old Header and copy Bulk Edit code and paste new Header and save
(//Content-Type:text/xml; charset=utf-8
Accept:application/json
Content-Type:application/json).

3) Old Body copy and paste new Body
({
    "POListRequest": {        //WithoutDocumentRequest
        "serviceType": "poli",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "1000002",
            "RoleID": "1000005",
            "OrgID": "1000004",
            "WarehouseID": "1000018",
            "stage": "0"
        }
    }
})

==================================================================================================================================================================
Rest API ke liye Document hona requirement hai is liye uska setup hum schema.xml mai karte hai:-

<xsd:element name="POListRequest" type="tns:POListRequest"></xsd:element>
<xsd:element name="POListResponse" type="tns:POListResponse"></xsd:element>

this method also create your request and responce method because this method is using Document or Rest api full fill action.

and interface name also change and impl method also changed

POListResponseDocument pOListResponseDocument = POListResponseDocument.Factory.newInstance();
		POListResponse listResponse = pOListResponseDocument.addNewPOListResponse();
		
		POListRequest pOListRequest = pOListRequestDocument.getPOListRequest();
		
		
		ADLoginRequest loginReq = pOListRequest.getADLoginRequest();
		String serviceType = pOListRequest.getServiceType();

		and return also pOListResponseDocument object.
