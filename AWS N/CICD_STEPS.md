# AWS CI/CD Manual Setup Guide

This document summarizes the full steps for your GitHub → CodeBuild → CodeDeploy pipeline, plus the EC2 user-data install flow and the CodeDeploy permission fix you observed.

## 1. Repository setup

Your repo should include these files at the root:
- `buildspec.yml`
- `appspec.yml`
- `pom.xml`
- `scripts/backup_existing.sh`
- `scripts/start_server.sh`
- `scripts/stop_server.sh`
- `ubuntu-user-data.sh`

Your `buildspec.yml` should produce the jar and include `appspec.yml` + `scripts/**` as build artifacts.

## 2. EC2 instance setup with user-data

Use an Ubuntu EC2 instance. In the EC2 launch wizard, set the user data to this script:

```bash
#!/bin/bash
set -e

# Update package lists
apt-get update -y

# Install Java 11 runtime, Ruby, wget, and curl for CodeDeploy agent installation
apt-get install -y openjdk-11-jre-headless ruby wget curl

# Create application directory and set ownership
mkdir -p /home/ubuntu/student
chown -R ubuntu:ubuntu /home/ubuntu/student

# Install the AWS CodeDeploy agent if not already installed
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F'"' '{print $4}')
CODEDEPLOY_INSTALL_URL="https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install"

cd /home/ubuntu
wget "$CODEDEPLOY_INSTALL_URL" -O install_codedeploy_agent.sh
chmod +x install_codedeploy_agent.sh
sudo ./install_codedeploy_agent.sh auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent

# Verify installation
java -version
systemctl status codedeploy-agent --no-pager || true

echo "Ubuntu EC2 setup completed: Java 11 and CodeDeploy agent installed."
```

### Important notes
- If you use Amazon Linux instead of Ubuntu, the package commands should be `yum install -y ruby wget curl java-11-openjdk-devel`
- Make sure `scripts/*.sh` are executable before you build the artifact: `chmod +x scripts/*.sh`

## 3. IAM roles required

### A. EC2 instance role
This role must be attached to the EC2 instance and must allow CodeDeploy agent to read from S3.

Recommended policies:
- `AmazonS3ReadOnlyAccess`
- `AmazonSSMManagedInstanceCore` (optional, for SSH/SSM convenience)

### B. CodeDeploy service role
This is the role you select when creating the CodeDeploy application and deployment group.
Required trust policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
Attach the managed policy:
- `AWSCodeDeployRole`

### C. CodePipeline service role
This role must allow CodePipeline to invoke CodeBuild and CodeDeploy, and to access the pipeline artifact.

The error you saw means this role needed more permission for CodeDeploy.

Use this inline policy or attach it to the CodePipeline service role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetApplication",
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment",
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [
        "arn:aws:codedeploy:ap-south-2:686271800529:application:ci-cd",
        "arn:aws:codedeploy:ap-south-2:686271800529:deploymentgroup:ci-cd/*"
      ]
    }
  ]
}
```

If you want the broad quick fix, attach the managed policy:
- `AWSCodeDeployFullAccess`

## 4. CodeBuild setup

1. Create a CodeBuild project.
2. Set source to your GitHub repo.
3. Use runtime `Amazon Linux 2` or `Ubuntu` with Java 11.
4. Set the buildspec path to `buildspec.yml`.
5. Use a service role with permissions to:
   - read source from GitHub/S3
   - write build artifacts to S3 or pipeline artifact store
   - run Maven

## 5. CodeDeploy setup

1. Create a CodeDeploy application of type `EC2/On-prem`.
2. Create a deployment group.
3. Select the EC2 instance by tag or instance ID.
4. Use the CodeDeploy service role from step 3B.
5. Ensure `appspec.yml` and `scripts/` are included in your artifact.

Your `appspec.yml` should point to the correct Ubuntu path:

```yaml
version: 0.0
os: linux
files:
  - source: target/student-1.0-SNAPSHOT.jar
    destination: /home/ubuntu/student
hooks:
  ApplicationStop:
    - location: scripts/stop_server.sh
      timeout: 120
      runas: ubuntu
  BeforeInstall:
    - location: scripts/backup_existing.sh
      timeout: 120
      runas: ubuntu
  AfterInstall:
    - location: scripts/start_server.sh
      timeout: 120
      runas: ubuntu
```

## 6. CodePipeline setup

1. Create a pipeline.
2. Add Source stage: GitHub repository, branch, webhook enabled.
3. Add Build stage: CodeBuild project.
4. Add Deploy stage: CodeDeploy application and deployment group.
5. Ensure CodePipeline service role has the CodeDeploy permissions from step 3C.

## 7. Validate after EC2 launch

On the EC2 instance, verify:

```bash
sudo systemctl status codedeploy-agent --no-pager
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ -w '\n'
ls -la /home/ubuntu/student
sudo tail -n 50 /home/ubuntu/student/student.log
ps aux | grep 'student-1.0-SNAPSHOT.jar' | grep -v grep
```

If CodeDeploy did not install automatically, check logs:

```bash
sudo tail -n 200 /var/log/aws/codedeploy-agent/codedeploy-agent.log
sudo find /opt/codedeploy-agent/deployment-root -maxdepth 4 -type f -name '*.log' -print
```

## 8. If CodeDeploy fails

Common failure reasons:

- EC2 instance has no IAM instance profile or lacks S3 permissions
- CodePipeline service role lacks `codedeploy:GetApplicationRevision`
- `appspec.yml` paths don't match the instance user
- hook scripts are not executable or fail
- network issues prevented the agent from contacting AWS endpoints

### Specific fix for your observed error

The required permission you need to add to the pipeline role is:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetApplicationRevision"
      ],
      "Resource": [
        "arn:aws:codedeploy:ap-south-2:686271800529:application:ci-cd"
      ]
    }
  ]
}
```

But the safe complete policy is the one shown in section 3C.

## 9. Test the full pipeline

1. Make a small code change in your repo.
2. Commit and push to GitHub.
3. Confirm CodePipeline starts automatically.
4. Check all stages succeed: Source, Build, Deploy.
5. Confirm the deployed JAR is present on EC2:

```bash
ls -la /home/ubuntu/student
sudo tail -n 50 /home/ubuntu/student/student.log
```

## 10. Recommended production improvements

- Use a proper systemd service instead of `nohup` for the Java app
- Add a health-check endpoint if the app is a web service
- Add a CodeDeploy `ValidateService` hook if you want automated health validation

---

If you want, I can also add a second markdown file with the exact `aws iam` CLI commands to create the role and attach the policy.

----------------------------------------------------------
If Ec2 not setup automatically then we do manually :- 
1 Try IMDSv2 to get the region :-

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \  http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F'"' '{print $4}')echo "REGION=$REGION"

2 If REGION is empty, set it manually (replace with your region)

export REGION=us-east-1

3 Download & run the official installer (use sudo to write into /home/ubuntu)

sudo wget "https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install" -O /home/ubuntu/install_codedeploy_agent.shsudo chmod +x /home/ubuntu/install_codedeploy_agent.shsudo /home/ubuntu/install_codedeploy_agent.sh auto > /tmp/codedeploy-install.log 2>&1sudo tail -n 200 /tmp/codedeploy-install.log

4 Start/enable the agent (tries systemd and SysV)

sudo systemctl enable codedeploy-agent || truesudo systemctl start codedeploy-agent || sudo service codedeploy-agent start || sudo /etc/init.d/codedeploy-agent start || truesudo systemctl status codedeploy-agent --no-pager || sudo service codedeploy-agent status || true

5 Verify logs and IAM role

sudo tail -n 200 /var/log/aws/codedeploy-agent/codedeploy-agent.log || sudo journalctl -u codedeploy-agent -n 200 --no-pager || truecurl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ || true