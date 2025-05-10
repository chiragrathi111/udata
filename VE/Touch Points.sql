Touch Points 
Product Master:-
1. When a new product is added in Tez ERP, an API call will be made to generate the corresponding product in Warepro.
2. When a new BOM is added or created in Tez ERP, an API call will generate the corresponding BOM data in Warepro.	
Payload for creating product API in Warepro

{ "CreateProductRequest": {
       "serviceType": "createProduct",
       "LoginRequest": {
           "user": "santosh",
           "pass": "Pipra",
           "client": "Pipra",
           "role": "Pipra Admin",
           "organization": "Pipra",
           "warehouse": "Head Warehouse" },
       "productName": "Mercury Switch",
       "productCount": 20,
       "description": "test",
       "productCategory": "Finished Goods",
       "taxCategory": "Standard",
       "uom": "each",
       "bom": true,
       "BOMReq": [{
               "productName": "Tamvast-D",
               "description": "test",
               "bomName": "Tamvast-D",
               "default": true,
               "BOMComponents": [  {
                       "productName": "Switch",
                       "description": "test",
                       "quantity": 10  }, {
                       "productName": "Mercury",
                       "description": "test",
                       "quantity": 10 }] } ] }}

Purchase flows:-
3. When a Purchase Order is created in Tez ERP, an API call will be executed to generate the Purchase Order in Warepro.
Payload to create Purchase Order in Warepro:
{"PurchaseOrderRequest": {
       "serviceType": "createPurchaseOrder",
       "LoginRequest": {"user": "santosh",
           "pass": "Pipra",
           "client": "Pipra",
           "role": "Pipra Admin",
           "organization": "Pipra",
           "warehouse": "Head Warehouse"
       },"orderReference": "1",
       "description": "test",
       "dateOrdered": "2024-07-24T14:30:00",
       "datePromised": "2024-07-24T14:30:00",
       "businessPartner": "Kaizen Pharmaceuticals",
       "invoicePartner": "Kaizen Pharmaceuticals",
       "partnerLocation": null,
       "invoiceLocation": null,
       "paymentRule": "B",
       "priceList": "Purchase 2023",
       "POLine": [{"orderLineReference": "1001",
               "productName": "Tamvast-D",
               "description": "test",
               "quantity": 2,
               "tax": null,
               "discount": 0,
               "image": null}]}}
4. When a Material Receipt is generated in Warepro, an API call will create the Goods Receipt Note (GRN) in Tez ERP.

Production and Assembly flows:-

5. Warepro will generate a Job order (Work Order) and send update to Tez ERP
6. Warepro will send an Api call in work order to close the document action and document will be marked as closed in Tez Erp
7. In warepro once Work order after completing we will update indent and stock transfer into TEZ erp 
Fields available for Manufacturing Order (Job Order/ Work order) in Warepro, To create Job/ Work Order in Tez Erp api should be given
{ "ManufacturingOrderRequest": {
       "client": "Pipra",
       "organization": "Pipra",
       "productName": "Mercury Switch",
       "description": "test",
       "resourceOrPlant": "Kaizen Pharmaceuticals",
       "workflow": "Assembly",
       "warehouse": "Head Warehouse",
       "bomFormula": "Assembly",
       "priority": "medium",
       "dateOrdered": "2024-07-24T14:30:00",
       "datePromised": "2024-07-24T14:30:00",
       "dateStartSchedule": "2024-07-24T14:30:00",
       "dateFinished": "2024-07-24T14:30:00",
       "quantity": 1,
       "yield": 100   }}
Sales flow
8. When a Sales Order is added/created in Tez ERP, an API call will be made to generate the Sales Order in Warepro
Payload to Create Sales order in Warepro:
{ "SalesOrderRequest": {
       "serviceType": "createSalesOrder",
       "LoginRequest": {
           "user": "santosh",
           "pass": "Pipra",
           "client": "Pipra",
           "role": "Pipra Admin",
           "organization": "Pipra",
           "warehouse": "Head Warehouse" },
       "orderReference": "1",
       "description": "test",
       "dateOrdered": "2024-07-24T14:30:00",
       "datePromised": "2024-07-24T14:30:00",
       "businessPartner": "Kaizen Pharmaceuticals",
       "invoicePartner": "Kaizen Pharmaceuticals",
       "partnerLocation": null,
       "invoiceLocation": null,
       "paymentRule": "B",
       "priceList": "Sales 2023",
       "SOLine": [ { "orderLineReference": "1001",
               "productName": "Tamvast-D",
               "description": "test",
               "quantity": 2,
               "tax": null,
               "discount": 0,
               "image": null}]}}

9. dispatched whenever is done an Api call will update the status into Tez Erp
10. We are generating packing list from the sales order based on Picking done shipment customer is translating into Packing list
Returns 
11. Whenever QC Failed item will be returned it will Update returns inventory in to warepro and it will update into the Tez erp

Additional Queries
12. Indent and Stock Transfer Generation: Need clarification when exactly these are generated.
13. Delivery Challan Generation: Need clarification when exactly this is generated.
14. Packing List Generation: Need clarification when exactly the packing list is generated.
