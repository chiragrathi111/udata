# If you want details any folder enter below commands:

* du -h --max-depth=1    (This commands check which folder taking actual space)

* ps -ef | grep idempiere | grep java  (check heap size)

* ps -ef | grep java

* adduser
* passwd <user_name>

* su - <user_name>   (switch user)

* visudo  (This commands generally using root and user access priviledge)

# update ec2 if password need or not need

* sudo /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

* sudo /etc/ssh/sshd_config  (uncomment password update) (PasswordAuthentication yes)

* sudo systemctl restart ssh  (then update)

* sudo passwd ubuntu (create password)

# After updated the password both way use like with pem no need password without pem need password

* ssh <ip>  or 
* ssh ubuntu@<ip>




