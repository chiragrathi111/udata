FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install --testcr

COPY . .

CMD ["node","src/index.js"]

EXPOSE 3000

# Commands:-

# docker build -t day28-volume .

# docker build -t <image_name> .

# docker run -dp 3000:3000 <container_name> <image_name>

# docker exec -it <container_name/container_id> sh

# If we are not using volume then i create any container through image, like image can't modify but after creation conatiner 
# I easily modify, bvut this modification tempererory.
# If we want changes permanent,so using volume

# Create  a new docker volume
# docker volume create data_volume (name = data_volume)

# List of docker volume
# docker volume ls

# If any reason below commands not open then run 
# cd /var/lib/docker (If not run then first run sudo permission)
# sudo -s
# cd /var/lib/docker
# ls
# cd volumes/
# ls (Showing our own volume)

# After create a volume, we added volume in our container
# docker run -v data_volume:/app -dp 3000:3000 --name todocrt day28-volume

# Local Volume directory:-
# root@chirag:/var/lib/docker/volumes/data_volume/_data# 