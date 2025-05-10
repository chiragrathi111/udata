QR format show list of record in json format show write below according:-

"{\"outUuid\": \"" + $F{outuuid} + "\"," +
"\"cultureUuid\": \"" + $F{uuid} + "\"," +
"\"year\": \"" + $F{yearcode}+ "\"," +
"\"cropType\": \"" + $F{croptype} + "\"," +
"\"varietyType\": \"" + $F{variety} + "\"," +
"\"parentLine\": \"" + $F{pcultureline}+ "\"," +
"\"cultureStage\": \"" + $F{culturestage} + "\"," +
"\"dateOfOperation\": \"" + $F{operationdate} + "\"," +
"\"plotTrayNumber\": \"" + $F{plotnumbertray} + "\"," +
"\"lotNumber\": \"" +$F{lotnumber}  + "\"}"