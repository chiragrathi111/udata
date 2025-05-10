StatusCheck-2/3-Instance-Reachability-Process-Failed :-

Step 1: Try to Reboot
 First try to reboot if problem solve

	EC2 → Select Instance → Actions → Instance State → Reboot

Step 2: View Console Output
 Check System log

	EC2 → Select Instance → Actions → Monitor and troubleshoot → Get System Log	

 Check for:

 Kernel panic

 Failed to mount root

 Init not found

 Any weird errors during boot

 If status log not getting any error then try another way.

Step 3: Confirm Volume Health
	
	EC2 → Elastic Block Store → Volumes

 Make sure:

 It in available or in-use

 No errors or warnings

 Size is reasonable (not 100% full)	

 Check are you getting any problem or everything is working fine

Step 4: Snapshot and Create Rescue Instance (Safe Way)

 Attach the faulty volume to new EC2 :-

	* sudo mkdir /mnt/faulty
	* sudo mount /dev/xvdf1 /mnt/faulty

 Check logs and fix issues :-

	* cd /mnt/faulty/
	* /var/log/cloud-init.log
	* /var/log/syslog 

	Fix corrupted config (e.g., netplan, fstab)

Step 5: Check Network Settings

 How Can I Know If My Network Interface is Disabled or Down?

	* ip a
 e.g. - ens5: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500	

 {Results:-
 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 06:75:2a:1f:19:a1 brd ff:ff:ff:ff:ff:ff
    altname enp0s5
 }

 Key Flags:
	* UP means interface is active.

	* NO-CARRIER means the interface is up but no cable/connection/DHCP.

	* DOWN means the interface is turned off.

 Check this way also:-

	* nmcli device status     # for NetworkManager users
	* ip link show ens5       # shows status in detail

 1. Temporary solution To bring interface up:
	* sudo ip link set ens5 up
	* sudo dhclient ens5	
	* ip a                      # Shows IP addresses
	* ip route                  # Shows routing table

	{Output:-
	default via 172.31.16.1 dev ens5
}
	* ping 8.8.8.8 and ping www.google.com

	if ping command not getting below according respponse so check file size

[Output:-
ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=115 time=25.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=115 time=24.7 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=115 time=24.7 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=115 time=27.3 ms]

if you getting only:-
[Output:-
ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.]
oter line not come,so run the below command and check 

	* cat /etc/resolv.conf

	[output:-
	cat /etc/resolv.conf
# This is /run/systemd/resolve/stub-resolv.conf managed by man:systemd-resolved(8).
# Do not edit.
#
# This file might be symlinked as /etc/resolv.conf. If you're looking at
# /etc/resolv.conf and seeing this text, you have followed the symlink.
#
# This is a dynamic resolv.conf file for connecting local clients to the
# internal DNS stub resolver of systemd-resolved. This file lists all
# configured search domains.
#
# Run "resolvectl status" to see details about the uplink DNS servers
# currently in use.
#
# Third party programs should typically not access this file directly, but only
# through the symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a
# different way, replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

nameserver 127.0.0.53
options edns0 trust-ad
search hgu_lan
]

	Temporary solution fixes that work until the next reboot


 2. Persistent Configuration via Netplan (Main Solution)

	* ls /etc/netplan/ (see the 50-cloud-init.yaml file)
	* vi /etc/netplan/50-cloud-init.yaml (update this file)

	network:
  version: 2
  ethernets:
    ens5:
      dhcp4: true
      optional: true

 Added only this line
 optional: true

	* netplan apply (if not install then below code through install)
	* sudo apt update
	* sudo apt install netplan.io -y

 Final Persistent Fix (Cloud-Init Override)

 echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

 Why this?
 Cloud-Init (a tool that runs at boot time on cloud servers) overwrites your manual Netplan settings by regenerating /etc/netplan/50-cloud-init.yaml every reboot.

 This command disables Cloud-Init’s network configuration, allowing your manual Netplan setup to persist.
 If restart System use below command:-
	sudo reboot


Step 6: Check Security Group and Subnet

 A. Security Group:
 	* Inbound: port 22 (SSH) or Session Manager

	* Outbound: Allow all (0.0.0.0/0) or at least AWS SSM endpoints

 B. Subnet Route Table:
 	* Public subnet → should route to Internet Gateway

	* Private subnet → should route to NAT Gateway or VPC endpoint (for SSM)	


Step 7 : Check Volume,Ram,and free space

	* df -h
	* df -hT (show also file format)
	* du -su (show used file size summery lavel)
	* free -h (actual size Ram)
