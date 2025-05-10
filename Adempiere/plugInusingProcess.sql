Create a new Plug in Process :-

1. Create a new Plug in with Eclipse

	File>New>Other>Plug-in-Project
    and create a new 2 Package one Package is Model class and Second Package is Factory class
    every Package create a new class and Model class main Code and Factory class using link to Model class

    and create a new .xml file using Plug in development > Component Defination and create .xml file name, name belong to unquie and path are providing in Factory class name this is the main Way
    go to overview and add file
    Name - service.ranking
    Type - Integer
    Values - 100
    and press OK
    go to Services and Add IProcessFactory (org.adempiere.base.IProcessFactory)
    Plug in all linking is completed
    Your Plug in kis Working fine in local otherwise every time through Error.

    and once create a plug in then go to login with Sytem Adminstrator and create a new Process and provide name 
    and give existing package path and class name provide and save process is created
    last work create a new menu and process filed provide process name and save all working is doing 
    change role and login then show your Process in menu tree.


    Your Requirement then create a Schdular and attach your process abd your Process is Working fully Automation.
    Provide Specific Details:-
    Name,
    Process,
    Schdule (Mins,Hours and Days)
    SuperVisor  and SAVE 

