sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
8161                       ALLOW IN    Anywhere                  
61616                      ALLOW IN    Anywhere                  
61613                      ALLOW IN    Anywhere                  
8443                       ALLOW IN    Anywhere                  
8080                       ALLOW IN    Anywhere                  
80                         ALLOW IN    Anywhere                  
5432                       ALLOW IN    Anywhere                  
5901                       ALLOW IN    Anywhere                  
8161/tcp                   ALLOW IN    Anywhere                  
61616/tcp                  ALLOW IN    Anywhere                  
22/tcp                     ALLOW IN    Anywhere                  
443                        ALLOW IN    Anywhere                  
8161 (v6)                  ALLOW IN    Anywhere (v6)             
61616 (v6)                 ALLOW IN    Anywhere (v6)             
61613 (v6)                 ALLOW IN    Anywhere (v6)             
8443 (v6)                  ALLOW IN    Anywhere (v6)             
8080 (v6)                  ALLOW IN    Anywhere (v6)             
80 (v6)                    ALLOW IN    Anywhere (v6)             
5432 (v6)                  ALLOW IN    Anywhere (v6)             
5901 (v6)                  ALLOW IN    Anywhere (v6)             
8161/tcp (v6)              ALLOW IN    Anywhere (v6)             
61616/tcp (v6)             ALLOW IN    Anywhere (v6)             
22/tcp (v6)                ALLOW IN    Anywhere (v6)             
443 (v6)                   ALLOW IN    Anywhere (v6)             

ubuntu@ip-172-31-43-3:~$ sudo iptables -L -n -v
Chain INPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
 1600  457K ufw-before-logging-input  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
 1600  457K ufw-before-input  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    1    52 ufw-after-input  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    1    52 ufw-after-logging-input  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    1    52 ufw-reject-input  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    1    52 ufw-track-input  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
  22M 2807M DOCKER-USER  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
  22M 2807M DOCKER-ISOLATION-STAGE-1  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ACCEPT     all  --  *      docker0  0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
    0     0 DOCKER     all  --  *      docker0  0.0.0.0/0            0.0.0.0/0           
    0     0 ACCEPT     all  --  docker0 !docker0  0.0.0.0/0            0.0.0.0/0           
    0     0 ACCEPT     all  --  docker0 docker0  0.0.0.0/0            0.0.0.0/0           
  22M 2807M ACCEPT     all  --  *      br-c7c5ab0f30b4  0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
  587 34148 DOCKER     all  --  *      br-c7c5ab0f30b4  0.0.0.0/0            0.0.0.0/0           
 1303 73266 ACCEPT     all  --  br-c7c5ab0f30b4 !br-c7c5ab0f30b4  0.0.0.0/0            0.0.0.0/0           
  476 28560 ACCEPT     all  --  br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-before-logging-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-before-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-after-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-after-logging-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-reject-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-track-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
 1574  462K ufw-before-logging-output  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
 1574  462K ufw-before-output  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
   12  1073 ufw-after-output  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
   12  1073 ufw-after-logging-output  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
   12  1073 ufw-reject-output  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
   12  1073 ufw-track-output  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain DOCKER (2 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ACCEPT     tcp  --  !br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            172.19.0.2           tcp dpt:5984
    0     0 ACCEPT     tcp  --  !br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            172.19.0.3           tcp dpt:5984
    0     0 ACCEPT     tcp  --  !br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            172.19.0.4           tcp dpt:9443
    0     0 ACCEPT     tcp  --  !br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            172.19.0.4           tcp dpt:7053
    0     0 ACCEPT     tcp  --  !br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            172.19.0.4           tcp dpt:7050
  111  5588 ACCEPT     tcp  --  !br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            172.19.0.5           tcp dpt:9444
    0     0 ACCEPT     tcp  --  !br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            172.19.0.6           tcp dpt:9445
    0     0 ACCEPT     tcp  --  !br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            172.19.0.5           tcp dpt:7051
    0     0 ACCEPT     tcp  --  !br-c7c5ab0f30b4 br-c7c5ab0f30b4  0.0.0.0/0            172.19.0.6           tcp dpt:9051

Chain DOCKER-ISOLATION-STAGE-1 (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DOCKER-ISOLATION-STAGE-2  all  --  docker0 !docker0  0.0.0.0/0            0.0.0.0/0           
 1303 73266 DOCKER-ISOLATION-STAGE-2  all  --  br-c7c5ab0f30b4 !br-c7c5ab0f30b4  0.0.0.0/0            0.0.0.0/0           
  22M 2807M RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain DOCKER-ISOLATION-STAGE-2 (2 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DROP       all  --  *      docker0  0.0.0.0/0            0.0.0.0/0           
    0     0 DROP       all  --  *      br-c7c5ab0f30b4  0.0.0.0/0            0.0.0.0/0           
 1303 73266 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain DOCKER-USER (1 references)
 pkts bytes target     prot opt in     out     source               destination         
  22M 2807M RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-after-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-after-input (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ufw-skip-to-policy-input  udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:137
    0     0 ufw-skip-to-policy-input  udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:138
    0     0 ufw-skip-to-policy-input  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:139
    0     0 ufw-skip-to-policy-input  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:445
    0     0 ufw-skip-to-policy-input  udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:67
    0     0 ufw-skip-to-policy-input  udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:68
    0     0 ufw-skip-to-policy-input  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type BROADCAST

Chain ufw-after-logging-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            limit: avg 3/min burst 10 LOG flags 0 level 4 prefix "[UFW BLOCK] "

Chain ufw-after-logging-input (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            limit: avg 3/min burst 10 LOG flags 0 level 4 prefix "[UFW BLOCK] "

Chain ufw-after-logging-output (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-after-output (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-before-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 3
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 11
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 12
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 8
    0     0 ufw-user-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-before-input (1 references)
 pkts bytes target     prot opt in     out     source               destination         
 1505  450K ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0           
   93  7241 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
    0     0 ufw-logging-deny  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate INVALID
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate INVALID
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 3
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 11
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 12
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 8
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp spt:67 dpt:68
    1    40 ufw-not-local  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            224.0.0.251          udp dpt:5353
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            239.255.255.250      udp dpt:1900
    1    40 ufw-user-input  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-before-logging-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-before-logging-input (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-before-logging-output (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-before-output (1 references)
 pkts bytes target     prot opt in     out     source               destination         
 1505  450K ACCEPT     all  --  *      lo      0.0.0.0/0            0.0.0.0/0           
   57 11160 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
   12  1073 ufw-user-output  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-logging-allow (0 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            limit: avg 3/min burst 10 LOG flags 0 level 4 prefix "[UFW ALLOW] "

Chain ufw-logging-deny (2 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate INVALID limit: avg 3/min burst 10
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            limit: avg 3/min burst 10 LOG flags 0 level 4 prefix "[UFW BLOCK] "

Chain ufw-not-local (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    1    40 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type MULTICAST
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type BROADCAST
    0     0 ufw-logging-deny  all  --  *      *       0.0.0.0/0            0.0.0.0/0            limit: avg 3/min burst 10
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-reject-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-reject-input (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-reject-output (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-skip-to-policy-forward (0 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-skip-to-policy-input (7 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-skip-to-policy-output (0 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-track-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-track-input (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-track-output (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW
   12  1073 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW

Chain ufw-user-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-user-input (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:8161
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:8161
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:61616
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:61616
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:61613
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:61613
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:8443
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:8443
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:8080
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:8080
    1    40 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:80
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:5432
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:5432
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:5901
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:5901
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:8161
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:61616
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:443
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:443

Chain ufw-user-limit (0 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            limit: avg 3/min burst 5 LOG flags 0 level 4 prefix "[UFW LIMIT BLOCK] "
    0     0 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-port-unreachable

Chain ufw-user-limit-accept (0 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-user-logging-forward (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-user-logging-input (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-user-logging-output (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain ufw-user-output (1 references)
 pkts bytes target     prot opt in     out     source               destination         
ubuntu@ip-172-31-43-3:~$ 

