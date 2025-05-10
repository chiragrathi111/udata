1) if you run ./stopFabric script then you also remove your volume other wise you faced error


if you run script ./stopFabric then throw error

Endorser and orderer connections initialized
Error: got unexpected status: BAD_REQUEST -- error applying config update to existing channel 'channel': error authorizing update:
 error validating ReadSet: proposed update requires that key [Group]  /Channel/Application be at version 0, but it is currently at version 1


how can solve this error?

Error solution:-

* ./stopFabric
* docker volume prumn
* docker volume ls (if show any other volumn then remove)
* docker volume rm <volume ID> (all volume remove then run startfabric script)
* ./startFabric

