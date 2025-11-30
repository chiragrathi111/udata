data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "ex_launch_template" {
  name_prefix   = "external-lt-"
  image_id      = coalesce(var.ami_id, data.aws_ami.amzn2.id)
  instance_type = var.instance_type
  key_name      = var.key_name

  # FIXED: Ubuntu commands for Apache on port 80
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y apache2
    systemctl start apache2
    systemctl enable apache2
    
    # Get instance info
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    
    echo "<h1>Web Server - External Tier</h1><p>Instance: $INSTANCE_ID</p><p>IP: $PRIVATE_IP</p><p>Port: 80</p>" > /var/www/html/index.html
  EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.web_ec2_cr_sg.id
    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "external-ec2"
      Environment = "external"
    }
  }
}


resource "aws_launch_template" "in_launch_template" {
  name_prefix   = "internal-lt-"
  image_id      = coalesce(var.ami_id, data.aws_ami.amzn2.id)
  instance_type = var.instance_type
  key_name      = var.key_name

  # FIXED: Install Node.js service on port 4000 using Ubuntu commands
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nodejs npm
    
    # Create Node.js app directory
    mkdir -p /opt/app
    cd /opt/app
    
    # Get instance info
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    
    # Create simple Node.js server on port 4000
    cat > app.js << 'NODEJS'
const http = require('http');

const server = http.createServer((req, res) => {
  const html = '<h1>App Server - Internal Tier</h1><p>Instance: ' + process.env.INSTANCE_ID + '</p><p>IP: ' + process.env.PRIVATE_IP + '</p><p>Port: 4000</p>';
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(html);
});

server.listen(4000, '0.0.0.0', () => {
  console.log('Server running on port 4000');
});
NODEJS
    
    # Create systemd service
    cat > /etc/systemd/system/nodeapp.service << SERVICE
[Unit]
Description=Node.js App
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/app
Environment=INSTANCE_ID=$INSTANCE_ID
Environment=PRIVATE_IP=$PRIVATE_IP
ExecStart=/usr/bin/node app.js
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE
    
    # Set permissions and start service
    chown -R ubuntu:ubuntu /opt/app
    systemctl daemon-reload
    systemctl enable nodeapp
    systemctl start nodeapp
  EOF
  )

  vpc_security_group_ids = [
    aws_security_group.app_ec2_cr_sg.id
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "internal-ec2"
      Environment = "internal"
    }
  }
}
