If you want every time not enter pem file so 
first added below file and hit direct command
ssh ip
=============================================
Host *
    IdentityFile ~/.ssh/democ.pem
    User ubuntu

Host *.rwpl
    IdentityFile ~/.ssh/rwpl-warepro.pem
    User ubuntu

===================================================
This config file added inside .ssh folder
(file name every time using config otherwise you not fill your requirement)     
