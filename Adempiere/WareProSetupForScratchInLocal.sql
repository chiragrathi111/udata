WarePro complete Setup in my Local:-

1. install java 11
	sudo apt update
	sudo apt install openjdk-11-jdk -y

	Edit .bashrc file to add env varibales:-
	
	nano ~/.bashrc
	export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
	export PATH=$PATH:$JAVA_HOME/bin
	source ~/.bashrc


2. Clone in Warepro repository:-
	git clone link
	cd wms
	git checkout ui_dev

3. install eclipse through documentation
	if First type Eclipse install then Tycho Configurator setup is important:-
	 window->preference->maven->Discovery->open catalog->Tycho Configurator and complete to system restart

	after Tycho search jre and check version and compiler java path is also important:-
	
	window -> preference ->jre

	this two setup done then go to maven update and move to terminal 

4. If i changed code Webservices for API therefore Scomp command is very important otherwise i direct enter mvn verify then throw error

	cd org.idempiere.Webservices
	scomp -javasource 11 -out lib/idempiere-xmlbeans.jar WEB-INF/xsd/idempiere-schema.xsd
	if throw error

	scomp -javasource 11 -out lib WEB-INF/xsd/idempiere-schema.xsd

	working fine then enter mvn verify command

	mvn verify

	move to Eclipse

5. org.idempiere.p2.targetplatform (this folder is base folder of all project )

	org.idempiere.p2.targetplatform.target click and reload target plateform  and select all folder and dependency install

6. all error is remove 

7. go to run configuration and install app 
	fill up all details 

8. go to server.product and show runing		

9. If your system not show server.product then go to this process :-
	server.product
     download file and add file in folder (folder only show in lauch configuration)
     File->import->Run/Debug->launch configuration->choose folder and click check and finish 
     then show server.product
  		