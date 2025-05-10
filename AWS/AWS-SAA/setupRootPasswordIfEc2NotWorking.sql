Follow below scenario and resolve problem:-

1. Stop the Problematic EC2 Instance

2. Detach the Root Volume

3. Attach Volume to Helper Instance

4. Connect to Helper Instance via SSH
	* ssh -i democ.pem ubuntu@helper-instance-ip

5. Mount the Attached Volume

	* df -hT (not show our new Volume)
	* lsblk (show volume)
	* sudo mkdir /mnt/temproot (Create directory)
	* sudo mount /dev/xvdf1 /mnt/temproot (mount directory and volume),(xvdf1 replace lsblk name)

6. Chroot into the Mounted Filesystem

	# Mount necessary directories
	* sudo mount --bind /dev /mnt/temproot/dev
	* sudo mount --bind /proc /mnt/temproot/proc
	* sudo mount --bind /sys /mnt/temproot/sys

	# Chroot into the filesystem
	* sudo chroot /mnt/temproot	

	(This above code using show our temp volume all access doing same directory not every time press/mnt/temproot)

7. Reset Root Password
	* passwd root (Enter your uwn password)

8. Clean Up

	# Exit chroot
	* exit

	# Unmount everything
	* sudo umount /mnt/temproot/dev
	* sudo umount /mnt/temproot/proc
	* sudo umount /mnt/temproot/sys
	* sudo umount /mnt/temproot		

9. Detach Volume from Helper Instance

10. Reattach to Original Instance

11. Start Original Instance

12. Connect via Serial Console