icon added trough system config in system side
added in java code:-

PO po = new Query(ctx, MSysConfig.Table_Name, "name ='Stonex_Jasper_Report'", trxName).first();
            if (po != null && po.get_ID() == 0)
                return Response
                        .status(Status.INTERNAL_SERVER_ERROR).entity(new ErrorBuilder()
                                .status(Status.INTERNAL_SERVER_ERROR).title("No Config found").build().toString())
                        .build();


po = new Query(ctx, MSysConfig.Table_Name, "name ='ZK_LOGIN_ICON'", trxName).first();

