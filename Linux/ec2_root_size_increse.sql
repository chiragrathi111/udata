# If you want to increse ec2 size then first do console then run loin to terminal and run belows commands:-

* fdisk -l (show list of file)

* lsblk (showing list of blocks)

* df -h (showing actual volumne size)

* cat /etc/fstab (This commands showing actual file type)

* growpart <device_name> 1 (This commands merge our volumne) 

* xfs_growfs -d /

* df -h