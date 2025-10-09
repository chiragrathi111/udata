#!/bin/bash
# Update system
sudo yum update -y

# Install/update SSM Agent
sudo yum install -y amazon-ssm-agent

# Start and enable SSM Agent
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent

# Set password for ec2-user (for serial console access)
echo 'ec2-user:Chirag123!' | chpasswd

# Enable password authentication for SSH (optional)
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Create log file to confirm script ran
echo "User data script completed at $(date)" > /tmp/userdata-completed.log
