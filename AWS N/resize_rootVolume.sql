* df -hT
output:-
Filesystem      Type      Size  Used Avail Use% Mounted on
/dev/root       ext4       38G   19G   20G  49% /
tmpfs           tmpfs     3.9G     0  3.9G   0% /dev/shm
tmpfs           tmpfs     1.6G  928K  1.6G   1% /run
tmpfs           tmpfs     5.0M     0  5.0M   0% /run/lock
efivarfs        efivarfs  128K  3.6K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16 ext4      881M   89M  730M  11% /boot
/dev/nvme0n1p15 vfat      105M  6.2M   99M   6% /boot/efi
tmpfs           tmpfs     783M   12K  783M   1% /run/user/1000

* lsblk -f
output:-
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0          7:0    0 27.6M  1 loop /snap/amazon-ssm-agent/11797
loop1          7:1    0   74M  1 loop /snap/core22/2163
loop2          7:2    0 50.9M  1 loop /snap/snapd/25577
nvme0n1      259:0    0   60G  0 disk 
├─nvme0n1p1  259:1    0   39G  0 part /
├─nvme0n1p14 259:2    0    4M  0 part 
├─nvme0n1p15 259:3    0  106M  0 part /boot/efi
└─nvme0n1p16 259:4    0  913M  0 part /boot

* sudo growpart /dev/nvme0n1 1
output:-
CHANGED: partition=1 start=2099200 old: size=81786847 end=83886046 new: size=123729887 end=125829086

* sudo resize2fs /dev/nvme0n1p1
output:-
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/nvme0n1p1 is mounted on /; on-line resizing required
old_desc_blocks = 5, new_desc_blocks = 8
The filesystem on /dev/nvme0n1p1 is now 15466235 (4k) blocks long.

* df -hT
Volume resized.