Every Year change admin and user both:-


Tip:- After one year complted then server is not working because wallet name admin and user3 is expire 

1. remove this admin and user folder
	realmed/network/api/wallet/
	rm -rf admin
	rm -rf user3

2. go to realmeds loopback side and create admin and new user

	Network

	enter name admin
	enter name user4(every year change name)

3. and create a new uniqe user added server two file then you working properly

    first search and chage user name

    realmeds/network/api/lib/validateuser.js

    realmeds/network/api/lib/register-fabric-event.js

    and server stop and start

    realmeds/network/api/

    forever stop server/server.js

    forever start server/server.js


and problem is solved.
