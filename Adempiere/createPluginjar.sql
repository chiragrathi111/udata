Plug in se jar file create karne ka 2 ways hai:-

1) go to Eclipse
   Plug in press right click and choose Export 
   and also select Deployable plug-ins and fragments
   select your file location go to browse and press Finish
   and jar file created

2) go to terminal
  cd idempiereNewChangesUI/wms/idempiere-release-10/org.idempiere.webservices
  mvn clean install 
  this is the very good way but it consume too much time


  Lib file create with Terminal
  cd idempiereNewChangesUI/wms/idempiere-release-10/org.idempiere.webservices
  scomp -javasource 11 -out lib/idempiere-xmlbeans.jar WEB-INF/xsd/idempiere-schema.xsd

  	