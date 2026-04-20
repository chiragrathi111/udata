# ⏰ EC2 Stop/Start — Manual Scripts + Cron Job Automation

## 📋 Two Ways to Control EC2

| Method | When to Use |
|--------|------------|
| **Terraform** (main.tf) | Change boolean, run `terraform apply` |
| **Shell Script** (this guide) | Quick one-liner OR schedule with cron job |

---

## 🛠️ Method 1: Manual Shell Scripts

### Prerequisites

```bash
# Install AWS CLI (if not installed)
sudo apt install awscli -y    # Ubuntu/Debian
# OR
brew install awscli            # macOS

# Configure credentials
aws configure
# Enter: Access Key, Secret Key, Region, Output format (json)
```

### Stop Instance

```bash
aws ec2 stop-instances --instance-ids i-YOUR_INSTANCE_ID --region ap-south-1
```

### Start Instance

```bash
aws ec2 start-instances --instance-ids i-YOUR_INSTANCE_ID --region ap-south-1
```

### Check Status

```bash
aws ec2 describe-instance-status --instance-ids i-YOUR_INSTANCE_ID --region ap-south-1
```

---

## 🛠️ Method 2: Reusable Script (ec2_control.sh)

I created this script in your folder. Here's how it works:

### Usage

```bash
# Make executable (one time only)
chmod +x ec2_control.sh

# Stop instance
./ec2_control.sh stop

# Start instance
./ec2_control.sh start

# Check status
./ec2_control.sh status
```

### What the Script Does

```
./ec2_control.sh stop
       │
       ├─ Reads INSTANCE_ID and REGION from script
       ├─ Calls: aws ec2 stop-instances
       ├─ Waits until instance is fully stopped
       └─ Prints: "✅ Instance i-xxx is now stopped"
```

---

## ⏰ Method 3: Cron Job (Automatic Schedule)

### What is Cron?

Cron is a Linux scheduler that runs commands at specific times automatically.

```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, 0=Sunday)
│ │ │ │ │
* * * * *  command
```

### Example: Stop at 8 PM, Start at 8 AM (Monday-Friday)

```bash
# Open cron editor
crontab -e

# Add these two lines:

# START instance at 8:00 AM IST (2:30 AM UTC) Monday-Friday
30 2 * * 1-5 /home/chirag/Documents/RathiData/udata/Terraform/TerraformWithPi/stopStartEc2Instance/ec2_control.sh start >> /tmp/ec2_cron.log 2>&1

# STOP instance at 8:00 PM IST (2:30 PM UTC) Monday-Friday
30 14 * * 1-5 /home/chirag/Documents/RathiData/udata/Terraform/TerraformWithPi/stopStartEc2Instance/ec2_control.sh stop >> /tmp/ec2_cron.log 2>&1
```

**⚠️ Important**: Cron uses **UTC time**, not IST.

### IST to UTC Conversion

| IST Time | UTC Time | Cron (minute hour) |
|----------|----------|---------------------|
| 6:00 AM | 12:30 AM (prev day) | `30 0` |
| 8:00 AM | 2:30 AM | `30 2` |
| 9:00 AM | 3:30 AM | `30 3` |
| 6:00 PM | 12:30 PM | `30 12` |
| 8:00 PM | 2:30 PM | `30 14` |
| 10:00 PM | 4:30 PM | `30 16` |

### More Cron Examples

```bash
# Stop every night at 11 PM IST (5:30 PM UTC)
30 17 * * * /path/to/ec2_control.sh stop

# Start every morning at 7 AM IST (1:30 AM UTC)
30 1 * * * /path/to/ec2_control.sh start

# Stop only on weekends (Saturday & Sunday)
30 2 * * 6,0 /path/to/ec2_control.sh stop

# Start only on Monday morning
30 2 * * 1 /path/to/ec2_control.sh start
```

### Verify Cron is Working

```bash
# List your cron jobs
crontab -l

# Check cron logs
tail -f /tmp/ec2_cron.log

# Check if cron service is running
systemctl status cron
```

### Remove Cron Jobs

```bash
# Edit and delete the lines
crontab -e

# OR remove ALL cron jobs
crontab -r
```

---

## 💰 Cost Savings Example

### Scenario: Dev server running only during work hours

```
Without automation:
  t2.medium running 24/7 = 720 hours × $0.0464 = $33.40/month

With cron job (8 AM - 8 PM, Mon-Fri):
  t2.medium running 12h × 22 days = 264 hours × $0.0464 = $12.25/month

  Savings: $21.15/month = $253.80/year (63% savings!)
```

### Scenario: Multiple instances

```
5 dev instances × $21.15/month savings = $105.75/month = $1,269/year
```

---

## 🔄 All Methods Compared

| Feature | Terraform | Shell Script | Cron Job |
|---------|-----------|-------------|----------|
| **How** | Change boolean + apply | Run command | Automatic schedule |
| **When** | Manual | Manual | Automatic |
| **Best For** | Infrastructure as Code | Quick one-off | Daily schedule |
| **State Tracking** | ✅ Yes | ❌ No | ❌ No |
| **Needs AWS CLI** | ❌ No | ✅ Yes | ✅ Yes |
| **Audit Trail** | ✅ tfstate | ❌ No | ✅ Log file |

### Which to Use?

- **Learning/Interview**: Use Terraform (shows IaC skills)
- **Quick stop/start**: Use shell script
- **Save money daily**: Use cron job
- **Production**: Use AWS Instance Scheduler or Lambda + EventBridge

---

## 🐛 Troubleshooting

### Cron job not running?

```bash
# 1. Check cron service
systemctl status cron

# 2. Check script has execute permission
chmod +x ec2_control.sh

# 3. Check script path is ABSOLUTE (not relative)
# ✅ /home/chirag/.../ec2_control.sh
# ❌ ./ec2_control.sh

# 4. Check AWS CLI is available in cron environment
which aws
# Add full path in script: /usr/local/bin/aws instead of just aws

# 5. Check cron logs
grep CRON /var/log/syslog
```

### "Unable to locate credentials" in cron?

Cron doesn't load your shell profile. Fix:

```bash
# Option 1: Set credentials in script (already done in ec2_control.sh)
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."

# Option 2: Use full path to AWS credentials
export AWS_SHARED_CREDENTIALS_FILE=/home/chirag/.aws/credentials
```

### Instance won't stop?

```bash
# Force stop (like pulling the power plug)
aws ec2 stop-instances --instance-ids i-xxx --force
```

---

## 🎓 Interview Talking Points

1. *"I automated EC2 cost optimization using cron-scheduled shell scripts, reducing dev environment costs by 63%"*

2. *"I implemented both Terraform-based (IaC) and script-based (operational) approaches for EC2 lifecycle management"*

3. *"For production, I'd recommend AWS Instance Scheduler or Lambda + EventBridge instead of cron, because cron depends on the local machine being running"*

---

**Pick your method and save money!** 💰
