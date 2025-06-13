#Ubuntu
* wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

* sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

#Amazon Linux 2 
* sudo yum install amazon-cloudwatch-agent

* sudo nano /opt/aws/amazon-cloudwatch-agent/bin/config.json

paste code:-
{
   "metrics":{
      "metrics_collected":{
         "mem":{
            "measurement":[
               "mem_used_percent"
            ],
            "metrics_collection_interval":60
         }
      },
      "append_dimensions": {
        "InstanceId": "${aws:InstanceId}"
      }
   }
}



* sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

* sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status

* sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a stop

