# 🔄 EC2 Instance Stop/Start Controller

## What Is This?

A simple Terraform project that **stops or starts** your existing EC2 instance using a **boolean switch**.

```
instance_running = true   → Instance STARTS ✅
instance_running = false  → Instance STOPS  🛑
```

That's it. Change one value, run `terraform apply`, done.

---

## 🏗️ How It Works

```
terraform.tfvars                    AWS
┌─────────────────────┐           ┌──────────────────┐
│ instance_id = "i-xx" │           │                  │
│ instance_running =   │──apply──►│  EC2 Instance     │
│   true  → RUNNING    │           │  i-0abc123...     │
│   false → STOPPED    │           │                  │
└─────────────────────┘           └──────────────────┘
```

### Step by Step:

1. You put your **instance_id** and **credentials** in `terraform.tfvars`
2. Set `instance_running = true` (start) or `false` (stop)
3. Run `terraform apply`
4. Terraform calls AWS API to start/stop your instance
5. Done! Instance state changes in ~30 seconds

---

## 📁 Files

```
stopStartEc2Instance/
├── provider.tf              # AWS provider with credentials from tfvars
├── variable.tf              # All variables (credentials, instance_id, boolean switch)
├── main.tf                  # Core logic - aws_ec2_instance_state resource
├── output.tf                # Shows instance status after apply
├── terraform.tfvars         # YOUR values (⚠️ NEVER push to GitHub)
├── terraform.tfvars.example # Safe template (push this to GitHub)
├── .gitignore               # Blocks tfvars from GitHub
└── README.md                # This file
```

---

## 🚀 Setup & Usage

### Step 1: Configure

```bash
cd stopStartEc2Instance

# Copy example to actual tfvars
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Fill in your values:
```hcl
access_key       = "AKIA..."           # Your AWS access key
secret_key       = "wJalr..."          # Your AWS secret key
region           = "us-east-1"         # Region of your EC2
instance_id      = "i-0abc123def456"   # Your EC2 instance ID
instance_running = true                # true=start, false=stop
```

### Step 2: Initialize

```bash
terraform init
```

### Step 3: Stop Instance

```bash
# Edit terraform.tfvars
instance_running = false

# Apply
terraform apply -auto-approve
```

Output:
```
current_state    = "stopped"
status_message   = "🛑 Instance is STOPPED"
```

### Step 4: Start Instance

```bash
# Edit terraform.tfvars
instance_running = true

# Apply
terraform apply -auto-approve
```

Output:
```
current_state    = "running"
status_message   = "✅ Instance is RUNNING"
```

---

## 🔒 Security: Protecting terraform.tfvars

### Why?
`terraform.tfvars` has your **AWS access key and secret key**. If pushed to GitHub, anyone can use your AWS account and run up charges.

### How We Protect It:

**1. .gitignore blocks it:**
```gitignore
terraform.tfvars
*.tfvars
```

**2. terraform.tfvars.example is the safe template:**
- Push `.example` to GitHub (empty values)
- Team members copy it to `terraform.tfvars` and fill their own keys
- Actual `terraform.tfvars` stays local only

**3. Variables marked `sensitive = true`:**
```hcl
variable "access_key" {
  type      = string
  sensitive = true  # Terraform hides this in all logs and output
}
```

### Verify .gitignore works:
```bash
git status
# terraform.tfvars should NOT appear in the list
```

---

## 🔍 Key Concept: aws_ec2_instance_state

```hcl
resource "aws_ec2_instance_state" "this" {
  instance_id = var.instance_id
  state       = var.instance_running ? "running" : "stopped"
}
```

### What this does:
- **Does NOT create** a new EC2 instance
- **Controls the state** of an EXISTING instance
- `state = "running"` → calls AWS StartInstances API
- `state = "stopped"` → calls AWS StopInstances API

### The ternary operator:
```
var.instance_running ? "running" : "stopped"
│                      │            │
│                      │            └─ if false, use "stopped"
│                      └─ if true, use "running"
└─ the boolean variable
```

---

## 💡 Real-World Use Cases

### 1. Save Money on Dev/Test Instances
```
Morning:  instance_running = true   → Start dev server
Evening:  instance_running = false  → Stop dev server
Savings:  ~70% cost reduction (only pay 8 hours instead of 24)
```

### 2. Scheduled Maintenance
```
Before maintenance: instance_running = false  → Stop safely
After maintenance:  instance_running = true   → Start back up
```

### 3. CI/CD Pipeline Integration
```bash
# In your CI/CD pipeline:
# Stop instance before deployment
sed -i 's/instance_running = true/instance_running = false/' terraform.tfvars
terraform apply -auto-approve

# Deploy new code...

# Start instance after deployment
sed -i 's/instance_running = false/instance_running = true/' terraform.tfvars
terraform apply -auto-approve
```

### 4. Multiple Instances
```hcl
# You can manage multiple instances by adding more variables:
variable "instance_ids" {
  type    = map(bool)
  default = {
    "i-0abc123" = true   # running
    "i-0def456" = false  # stopped
    "i-0ghi789" = true   # running
  }
}
```

---

## 🐛 Troubleshooting

### Error: "InvalidInstanceID.NotFound"
**Cause**: Wrong instance_id or wrong region  
**Fix**: Check instance_id in AWS Console, make sure region matches

### Error: "UnauthorizedOperation"
**Cause**: Your access key doesn't have EC2 permissions  
**Fix**: Attach `AmazonEC2FullAccess` policy to your IAM user (or at minimum `ec2:StartInstances`, `ec2:StopInstances`, `ec2:DescribeInstances`)

### Error: "IncorrectInstanceState"
**Cause**: Instance is in a transitional state (pending, shutting-down)  
**Fix**: Wait 1-2 minutes and try again

### Instance stopped but public IP changed after start
**Cause**: EC2 assigns new public IP on every start (unless you use Elastic IP)  
**Fix**: Use Elastic IP for a permanent public IP

---

## 🎓 Interview Questions

### Q: Why use Terraform instead of AWS CLI to stop/start?

**Answer**: 
- **State tracking**: Terraform knows the current state and only makes changes if needed
- **Idempotent**: Running `terraform apply` twice with same values does nothing (safe)
- **Version control**: Infrastructure changes are tracked in code
- **Team collaboration**: Everyone uses same config, no manual CLI mistakes

### Q: How do you protect credentials in Terraform?

**Answer**:
1. Store in `terraform.tfvars` (not in .tf files)
2. Add `terraform.tfvars` to `.gitignore`
3. Mark variables as `sensitive = true`
4. Provide `.tfvars.example` as template
5. Better approach for production: Use AWS IAM roles, environment variables, or AWS Vault

### Q: What's the difference between `data` and `resource` in main.tf?

**Answer**:
```hcl
data "aws_instance" "target" { }     # READ-ONLY: fetches info about existing instance
resource "aws_ec2_instance_state" { } # READ-WRITE: changes the instance state
```
- `data` = "tell me about this thing" (doesn't change anything)
- `resource` = "create or change this thing" (makes changes)

---

## 💰 Cost Impact

| Scenario | Monthly Cost (t2.micro) |
|----------|------------------------|
| Running 24/7 | ~$8.50 |
| Running 8 hours/day (weekdays only) | ~$2.40 |
| **Savings** | **~72%** |

Stopping instances when not needed is one of the easiest AWS cost optimizations.

---

## 📊 Quick Reference

| Action | terraform.tfvars | Command |
|--------|-----------------|---------|
| **Start** | `instance_running = true` | `terraform apply -auto-approve` |
| **Stop** | `instance_running = false` | `terraform apply -auto-approve` |
| **Check status** | - | `terraform output current_state` |

---

**Simple, secure, and saves money.** 🚀
