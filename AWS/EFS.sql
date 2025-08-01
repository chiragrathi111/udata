first SG inoud added 2049 port

command:-

* sudo apt-get update

* sudo apt-get install -y nfs-common
(Ubuntu)

* sudo yum install -y nfs-utils
(Linux)

* mkdir efs

* sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-05576595e5bf418af.efs.ap-south-1.amazonaws.com:/ efs
  (This above command get to EFS file with attch section)