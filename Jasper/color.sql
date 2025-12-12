Added color in rectangel:-

<rectangle>
				<reportElement x="190" y="0" width="210" height="171" backcolor="#F7FF0D" uuid="af97f6a9-336d-46ae-9af3-706923ce3efc">
					<printWhenExpression><![CDATA[$F{stage}.equals("Initiation")]]></printWhenExpression>
				</reportElement>
			</rectangle>


<rectangle>
				<reportElement x="170" y="1" width="116" height="20" forecolor="#FAF7F7" uuid="3a1ec733-88d1-4f25-8485-10c5f10fad55">
					<printWhenExpression><![CDATA[$F{stage}.equals("Night Mode")]]></printWhenExpression>
				</reportElement>
			</rectangle>			