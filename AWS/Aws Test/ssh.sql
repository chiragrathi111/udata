Generally we are using 
ssh -i pemFile/democ.pem ubuntu@ip 

but if you want every time do not want write your pem file and user name this is possible

* mv pemFile/democ.pem ~/.ssh/
* cd ~/.ssh 
* ls -l (check permission) like pem file only read access

generate new file
* sudo nano ~/.ssh/config

paste this below code:-
Host *
    IdentityFile ~/.ssh/democ.pem 
    User ubuntu

Save and give config file write access

* sudo chmod 600 ~/.ssh/config
* ls -l (check pem config file access)

* cd 
* ssh ip (no need pem file location and username)
