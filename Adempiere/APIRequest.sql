CreateMR Request:-
// {
//     "CreateMRRequest": {
//         "serviceType": "createMR",
//         "cOrderId": "1000174",
//         "ADLoginRequest": {
//             "user": "SuperUser",
//             "pass": "System",
//             "lang": "112",
//             "ClientID": "11",
//             "RoleID": "102",
//             "OrgID": "0",
//             "WarehouseID": "0",
//             "stage": "0"
//         },
//         "mRLines": [
//             {
//                 "productId": 137,
//                 "productName": "Mulch 10#",
//                 "cOrderlineId": 1000224,
//                 "uomId": 100,
//                 "qnty": 5,
//                 "locator": 101
//             },
//             {
//                 "productId": 133,
//                 "productName": "Patio Chair",
//                 "cOrderlineId": 1000225,
//                 "uomId": 100,
//                 "qnty": 15,
//                 "locator": 101
//             }
//         ]
//     }
// }
//localhost
// {
//     "CreateMRRequest": {
//         "serviceType": "createMR",
//         "cOrderId": "1000188",
//         "ADLoginRequest": {
//             "user": "SuperUser",
//             "pass": "System",
//             "lang": "112",
//             "ClientID": "11",
//             "RoleID": "102",
//             "OrgID": "0",
//             "WarehouseID": "0",
//             "stage": "0"
//         },
//         "mRLines": [
//             {
//                 "productId": 1000004,
//                 "productName": "Lifeboy 10/-",
//                 "cOrderlineId": 1000199,
//                 "uomId": 100,
//                 "qnty": 7,
//                 "locator": 1000001
//             },
//             {
//                 "productId": 1000002,
//                 "productName": "Lux 30/-",
//                 "cOrderlineId": 1000200,
//                 "uomId": 100,
//                 "qnty": 11,
//                 "locator": 1000001
//             }
//         ]
//     }
// }
////localhost Austrak
{
    "CreateMRRequest": {
        "serviceType": "createMR",
        "cOrderId": "1000195",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "1000002",
            "RoleID": "1000005",
            "OrgID": "0",
            "WarehouseID": "0",
            "stage": "0"
        },
        "mRLines": [
            {
                "productId": 1000041,
                "productName": "Antwar",
                "cOrderlineId": 1000209,
                "uomId": 100,
                "qnty": 17,
                "locator": 1000031
            },
            {
                "productId": 1000043,
                "productName": "POLQ",
                "cOrderlineId": 1000210,
                "uomId": 100,
                "qnty": 27,
                "locator": 1000031
            }
        ]
    }
}
====================================================================================================================================================================
PO DataList:-
// {
//     "PODataRequest": {
//         "serviceType": "poData",
//         "documentNo": "10000561",
//         "ADLoginRequest": {
//             "user": "SuperUser",
//             "pass": "System",
//             "lang": "112",
//             "ClientID": "1000001",
//             "RoleID": "1000002",
//             "OrgID": "0",
//             "WarehouseID": "0",
//             "stage": "0"
//         }
//     }
// }
// // //localhost abcPharma
{
    "PODataRequest": {
        "serviceType": "poData",
        "documentNo": "ch800015",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "1000002",
            "RoleID": "1000005",
            "OrgID": "0",
            "WarehouseID": "0",
            "stage": "0"
        }
    }
}
// //localhost Austrak
// {
//     "PODataRequest": {
//         "serviceType": "poData",
//         "documentNo": "800015",
//         "ADLoginRequest": {
//             "user": "SuperUser",
//             "pass": "System",
//             "lang": "112",
//             "ClientID": "1000001",
//             "RoleID": "1000003",
//             "OrgID": "0",
//             "WarehouseID": "0",
//             "stage": "0"
//         }
//     }
// }
==================================================================================================================================================================
POList:-
{
    "POListRequest": {
        "serviceType": "poli",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "11",
            "RoleID": "102",
            "OrgID": "11",
            "WarehouseID": "103",
            "stage": "0"
        }
    }
}
==================================================================================================================================================================
RoleConfig:-
{
    "RoleConfigureRequest": {
        "serviceType": "roleConfig",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "11",
            "RoleID": "102",
            "OrgID": "11",
            "WarehouseID": "103",
            "stage": "0"
        }
    }
}
==================================================================================================================================================================
DocAction:-
{
    "ModelSetDocActionRequest": {
        "ModelSetDocAction": {
            "serviceType": "CompleteOrder",
            "tableName": "m_inout",
            "recordID": "1000131",
            "docAction": "CO"
        },
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "11",
            "RoleID": "102",
            "OrgID": "0",
            "WarehouseID": "0",
            "stage": "0"
        }
    }
}
==================================================================================================================================================================
PIList:-
{
    "PIListRequest": {
        "serviceType": "pIList",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "1000002",
            "RoleID": "1000005",
            "OrgID": "0",
            "WarehouseID": "0",
            "stage": "0"
        }
    }
}

==================================================================================================================================================================
PIDetails:-
{
    "pIDeatilsRequest": {
        "serviceType": "pIDetails",
        "mInventoryId": "1000032",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "1000002",
            "RoleID": "1000005",
            "OrgID": "0",
            "WarehouseID": "0",
            "stage": "0"
        }
    }
}

==================================================================================================================================================================
PIQtyChanges:-



==================================================================================================================================================================
SOLIst:-
// {
//     "SOListRequest": {
//         "serviceType": "sOList",
//         "ADLoginRequest": {
//             "user": "SuperUser",
//             "pass": "System",
//             "lang": "112",
//             "ClientID": "1000001",
//             "RoleID": "1000002",
//             "OrgID": "0",
//             "WarehouseID": "0",
//             "stage": "0"
//         }
//     }
// }//server
{
    "SOListRequest": {
        "serviceType": "sOList",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "1000002",
            "RoleID": "1000005",
            "OrgID": "0",
            "WarehouseID": "0",
            "stage": "0"
        }
    }
} //localhost
==================================================================================================================================================================
SODetails:-
// {
//     "SODetailRequest": {
//         "serviceType": "sODetail",
//         "documentNo": "50005",
//         "ADLoginRequest": {
//             "user": "SuperUser",
//             "pass": "System",
//             "lang": "112",
//             "ClientID": "11",
//             "RoleID": "102",
//             "OrgID": "0",
//             "WarehouseID": "0",
//             "stage": "0"
//         }
//     }
// }//server
{
    "SODetailRequest": {
        "serviceType": "sODetail",
        "documentNo": "50010",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "1000002",
            "RoleID": "1000005",
            "OrgID": "0",
            "WarehouseID": "0",
            "stage": "0"
        }
    }
}
==================================================================================================================================================================
Create Shipment :-
// {
//     "CreateSCRequest": {
//         "serviceType": "createSC",
//         "cOrderId": "1000030",
//         "ADLoginRequest": {
//             "user": "SuperUser",
//             "pass": "System",
//             "lang": "112",
//             "ClientID": "1000001",
//             "RoleID": "1000002",
//             "OrgID": "0",
//             "WarehouseID": "0",
//             "stage": "0"
//         },
//         "shipmentLines": [
//             {
//                 "productId": 136,
//                 "productName": "Mulch 10#",
//                 "cOrderlineId": 1000042,
//                 "uomId": 100,
//                 "qnty": 10,
//                 "locator": 101
//             },
//             {
//                 "productId": 136,
//                 "productName": "Mulch 10#",
//                 "cOrderlineId": 1000043,
//                 "uomId": 100,
//                 "qnty": 20,
//                 "locator": 101
//             },
//             {
//                 "productId": 136,
//                 "productName": "Mulch 10#",
//                 "cOrderlineId": 1000044,
//                 "uomId": 100,
//                 "qnty": 30,
//                 "locator": 101
//             }
//             ,
//             {
//                 "productId": 137,
//                 "productName": "Mulch 10#",
//                 "cOrderlineId": 1000045,
//                 "uomId": 100,
//                 "qnty": 2,
//                 "locator": 101
//             }
//         ]
//     }
// }//server
{
    "CreateSCRequest": {
        "serviceType": "createSC",
        "cOrderId": "1000232",
        "ADLoginRequest": {
            "user": "SuperUser",
            "pass": "System",
            "lang": "112",
            "ClientID": "1000002",
            "RoleID": "1000005",
            "OrgID": "0",
            "WarehouseID": "0",
            "stage": "0"
        },
        "shipmentLines": [
            {
                "productId": 1000041,
                "productName": "Antwar",
                "cOrderlineId": 1000268,
                "uomId": 100,
                "qnty": 5,
                "locator": 1000031
            },
            {
                "productId": 1000043,
                "productName": "POLQ",
                "cOrderlineId": 1000269,
                "uomId": 100,
                "qnty": 1,
                "locator": 1000031
            }
        ]
    }
}
