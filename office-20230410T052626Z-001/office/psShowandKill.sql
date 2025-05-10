1. check any port is running or not

	lsof -i (show all ps)

	lsof -i | grep 3000 (show specific port ps)

	fuser 3000/tcp (any specific port ps show using this line)

2. kill running ps 

	kill -9 <ps id>	

3. 	

