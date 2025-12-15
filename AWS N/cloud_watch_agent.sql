Cloud Watch Agent :-

EC2 Memory Disk Monitoring

Steps:
Step 1: Create an AWS EC2 IAM Role and add CloudWatch and SSM Full Access. - Role Name: EC2-CloudWatch-Role.
Step 2: Create a Parameter in Systems Manger with the name "/alarm/AWS-CWAgentLinConfig" and store the value.
Step 3: Create an EC2 Instance, Attach the role created in Step 1 and Add the commands in the Userdata Section.

Commands that needs to be added in Userdata Section:
#!/bin/bash
wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip
unzip AmazonCloudWatchAgent.zip
sudo ./install.sh
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:/alarm/AWS-CWAgentLinConfig -s


Check if EC2 Instance has CWAgent Installed or not:
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status


Value for the SSM Parameter (/alarm/AWS-CWAgentLinConfig):

{
	"metrics": {
		"append_dimensions": {
			"InstanceId": "${aws:InstanceId}"
		},
		"metrics_collected": {
			"mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 60
			},
            "disk": {
				"measurement": [
                     "disk_used_percent"
				],
				"metrics_collection_interval": 60
			}
		}
	}
}

cloudwatch agent installing we have two method first above one second below
If you want to use above one this is automated not need to install agent manually
1. create a role and give ssm and aws cloudwatch full access
2. create a Parameter in ssm service then i use this for config of cloudwatch agent
3. above we have user data their through easily agent install and this command use user data and this command support linux os
4. then login ec2 and confirm your agent install or not if install then go to cloudwatch agent 
5. Click Matric there is the left panel, and showing region first seletc your specific region then select CWAgent this place have two different folder
one is showing for dick and second folder have Memorydata 

====================================================================================================


Commands:-

* wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

* sudo dpkg -i amazon-cloudwatch-agent.deb

* sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

If getting error in config then added commands:-


check our cloudwatch agent is running or not

* sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c ssm:AmazonCloudWatch-linux \
    -s

o/p:-

E! Error running agent: Error loading config file /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml: error parsing socket_listener, open /usr/share/collectd/types.db: no such file or directory

then run below commnds:-

* sudo apt update

* sudo apt install collectd -y

* sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c ssm:AmazonCloudWatch-linux \
    -s    

* sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status

o/p :-
{
  "status": "running",
  "configstatus": "configured",
  // ... other details
}

if this output not came then your agent setup is not correct 

* sudo systemctl status amazon-cloudwatch-agent


If you want to use this method
iam need to create
login ec2 and run command after run agent config command then enter your requirement according after that go to cloudwatch service and select matric and go to CWAgent
and showing your disk and Memory matric
If you have not saw CWAgent means your setup is not correct

