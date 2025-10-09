Resize Root Volume:-

* lsblk
 (if showing 2 volume like nvme0n1 = 40G, but nvme0n1p1 = 16G)

* sudo apt-get update

* sudo apt-get install cloud-guest-utils -y

* sudo growpart /dev/nvme0n1 1

* lsblk (check showing part size 40)

* sudo resize2fs /dev/nvme0n1p1 (file format ext4)

* df- h
 