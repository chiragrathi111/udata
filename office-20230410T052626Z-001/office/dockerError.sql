Error1 :- permission denied in docker-compose on linux

Solution:- 
sudo usermod -aG docker $USER 
sudo chgrp docker /usr/local/bin/docker-compose 
sudo chmod 750 /usr/local/bin/docker-compose