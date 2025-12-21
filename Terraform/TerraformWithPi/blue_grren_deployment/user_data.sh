#!/bin/bash
# User Data Script for Blue-Green Deployment
# This script runs when EC2 instances start up

# Update system packages
yum update -y

# Install required packages
yum install -y httpd wget curl

# Start and enable Apache web server
systemctl start httpd
systemctl enable httpd

# Create a simple web application that shows environment and version
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>${environment} Environment</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin: 50px;
            background-color: ${environment == "blue" ? "#e3f2fd" : "#e8f5e8"};
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            border-radius: 10px;
            background-color: white;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .environment {
            font-size: 48px;
            font-weight: bold;
            color: ${environment == "blue" ? "#1976d2" : "#388e3c"};
            margin-bottom: 20px;
        }
        .version {
            font-size: 24px;
            color: #666;
            margin-bottom: 20px;
        }
        .info {
            font-size: 16px;
            color: #888;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="environment">${upper(environment)} Environment</div>
        <div class="version">Version: ${app_version}</div>
        <div class="info">
            <p>Instance ID: <span id="instance-id">Loading...</span></p>
            <p>Availability Zone: <span id="az">Loading...</span></p>
            <p>Timestamp: $(date)</p>
        </div>
    </div>
    
    <script>
        // Fetch instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data)
            .catch(error => document.getElementById('instance-id').textContent = 'N/A');
            
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('az').textContent = data)
            .catch(error => document.getElementById('az').textContent = 'N/A');
    </script>
</body>
</html>
EOF

# Create health check endpoint
cat > /var/www/html/health << EOF
{
    "status": "healthy",
    "environment": "${environment}",
    "version": "${app_version}",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Create a simple API endpoint for testing
mkdir -p /var/www/html/api
cat > /var/www/html/api/info << EOF
{
    "environment": "${environment}",
    "version": "${app_version}",
    "instance_id": "$(curl -s http://169.254.169.254/latest/meta-data/instance-id)",
    "availability_zone": "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 644 /var/www/html

# Configure Apache to serve JSON files with correct content type
echo "AddType application/json .json" >> /etc/httpd/conf/httpd.conf

# Restart Apache to apply changes
systemctl restart httpd

# Install CloudWatch agent for monitoring (optional)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Log deployment completion
echo "$(date): ${environment} environment deployment completed - Version ${app_version}" >> /var/log/deployment.log