<jr:QRCode xmlns:jr="http://jasperreports.sourceforge.net/jasperreports/components" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports/components http://jasperreports.sourceforge.net/xsd/components.xsd">
					<jr:codeExpression><![CDATA[$F{secondaryhardeninguuid}]]></jr:codeExpression>
				</jr:QRCode>


<jr:QRCode xmlns:jr="http://jasperreports.sourceforge.net/jasperreports/components" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports/components http://jasperreports.sourceforge.net/xsd/components.xsd">
					<jr:codeExpression><![CDATA["http://tc.warepro.in/salecode/" + $F{secondaryhardeninguuid} + ""]]></jr:codeExpression>
				</jr:QRCode>

<jr:QRCode xmlns:jr="http://jasperreports.sourceforge.net/jasperreports/components" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports/components http://jasperreports.sourceforge.net/xsd/components.xsd">
					<jr:codeExpression><![CDATA["http://tissueculture.kdisc.kerala.gov.in/salecode/" + $F{secondaryhardeninguuid} + ""]]></jr:codeExpression>
				</jr:QRCode>				
tissueculture.kdisc.kerala.gov.in

'https://tc.warepro.in/tcapi/gettracedataforqr'


	<jr:QRCode xmlns:jr="http://jasperreports.sourceforge.net/jasperreports/components" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports/components http://jasperreports.sourceforge.net/xsd/components.xsd">
					<jr:codeExpression><![CDATA["{\"outUuid\": \"" + $F{outuuid} + "\"," +
"\"inId\": \"" + $F{inid} + "\"," +
"\"cultureUuid\": \"" + $F{uuid} + "\"," +
"\"cropType\": \"" + $F{croptype} + "\"," +
"\"varietyType\": \"" + $F{variety} + "\"," +
"\"parentLine\": \"" + $F{parentcultureline} + "\"," +
"\"natureOfSample\": \"" + $F{naturesample} + "\"," +
"\"cultureStage\": \"" + $F{culturestageid} + "\"," +
"\"cycle\": \"" + $F{cycleno} + "\"," +
"\"virusTesting\": \"" + $F{virusid} + "\"," +
"\"dateOfSourcing\": \"" + $F{culturedate} + "\"," +
"\"tcpf\": \"" + $F{tcpf} + "\"," +
"\"dateOfOperation\": \"" + $F{cultureoperationdate} + "\"," +
"\"personnelCode\": \"" + $F{personalcode} + "\"," +
"\"machineCode\": \"" + $F{machinename} + "\"}"]]></jr:codeExpression>
				</jr:QRCode>				