* docker ps
* docker ps -a
* docker ps -s
* docker - compose -f docler.yaml up -d
* docker exec -it <contanerId> sh           (login docker) if not working then use bash
* docker logs -f <contanerId>
* docker inspect <contanerId>

list of all docker with cpu & memory :-
* docker stats --no-stream

* docker exec -it iot-sync-db psql -U iot_sync -d iot_sync  (db Container login)

* docker logs --tail 500 <container_name_or_id>

* docker restart <container_name_or_id>