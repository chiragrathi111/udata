# EC2 Auto Start/Stop — Complete Guide

---

## 1. What Is This Automation?

This project automatically **starts** and **stops** one or more AWS EC2 instances on a fixed weekday schedule using two AWS services:

- **Amazon EventBridge** — acts as a timer/cron that fires at a set time
- **AWS Lambda** — receives the trigger and calls the EC2 API to start or stop the server

No manual login to AWS Console is needed. The server starts itself every morning and stops itself every evening.

---

## 2. Current Schedule

| Action | Days | IST Time | UTC Time |
|---|---|---|---|
| Start EC2 | Monday – Friday | 9:00 AM | 3:30 AM |
| Stop EC2 | Monday – Friday | 7:00 PM | 1:30 PM |

On **Saturday and Sunday** the server stays off — no trigger fires on weekends.

---

## 3. AWS Services Used and Why

| Service | Purpose |
|---|---|
| **EventBridge** | Cron scheduler — fires Lambda at the right time automatically |
| **Lambda** | Serverless function — runs Python code to start/stop EC2, no server needed to run it |
| **IAM Role** | Gives Lambda permission to call EC2 and write logs |
| **CloudWatch Logs** | Stores Lambda execution logs for debugging |
| **EC2** | The actual server being started and stopped |

---

## 4. Why Use This Automation?

### Cost Saving
EC2 instances charge by the hour. A server running 24×7 costs 3× more than one running only during business hours (9 AM – 7 PM = 10 hours/day × 5 days).

| Running mode | Hours/week | Relative cost |
|---|---|---|
| Always ON (24×7) | 168 hours | 100% |
| Auto Start/Stop (this setup) | 50 hours | ~30% |

You save approximately **70% on EC2 cost** for that instance.

### No Manual Work
Without automation, someone must remember to start the server every morning and stop it every evening. This automation removes that dependency completely.

### Reliable and Consistent
Lambda + EventBridge never forget, never sleep in, and never accidentally leave the server running over the weekend.

### Scales to Multiple Instances
The `INSTANCE_IDS` environment variable accepts a comma-separated list. All instances start and stop together with a single Lambda invocation.

---

## 5. How to Modify EC2 Instance IDs

There are two ways — **Terraform (recommended)** and **AWS Console**.

---

### Method A — Via Terraform (Recommended)

This is the correct way. Changes made via Terraform are tracked in state and stay permanent.

**Step 1 — Set the environment variable with your new instance IDs**

```bash
# One instance
export TF_VAR_instance_id='["i-0abc1234def567890"]'

# Multiple instances
export TF_VAR_instance_id='["i-0abc1234def567890","i-0xyz9876abc54321"]'
```

**Step 2 — Preview what will change**

```bash
terraform plan
```

**Step 3 — Apply**

```bash
terraform apply
```

Terraform updates the `INSTANCE_IDS` environment variable on both Lambda functions automatically.

---

### Method B — Via AWS Console (Quick one-time change)

Use this only for a quick temporary test. If you run `terraform apply` again afterward, Terraform will overwrite the console change.

**For the START Lambda:**

```
AWS Console → Lambda
→ function: start-ec2-weekdays-9am-ist
→ tab: Configuration
→ left menu: Environment variables
→ click Edit
→ find INSTANCE_IDS
→ change value to new instance IDs (comma-separated): i-0abc123,i-0xyz456
→ click Save
```

**For the STOP Lambda:**

```
AWS Console → Lambda
→ function: stop-ec2-weekdays-7pm-ist
→ tab: Configuration
→ left menu: Environment variables
→ click Edit
→ find INSTANCE_IDS
→ change value to same instance IDs
→ click Save
```

> You must update BOTH Lambda functions. The start and stop functions have separate environment variables.

---

## 6. How to Modify the Schedule (Event Time)

There are two ways — **Terraform (recommended)** and **AWS Console**.

### IST to UTC Conversion (IST = UTC + 5:30)

| IST Time | UTC Time | Cron Expression |
|---|---|---|
| 8:00 AM | 2:30 AM | `cron(30 2 ? * MON-FRI *)` |
| 9:00 AM | 3:30 AM | `cron(30 3 ? * MON-FRI *)` |
| 10:00 AM | 4:30 AM | `cron(30 4 ? * MON-FRI *)` |
| 6:00 PM | 12:30 PM | `cron(30 12 ? * MON-FRI *)` |
| 7:00 PM | 1:30 PM | `cron(30 13 ? * MON-FRI *)` |
| 8:00 PM | 2:30 PM | `cron(30 14 ? * MON-FRI *)` |
| 9:00 PM | 3:30 PM | `cron(30 15 ? * MON-FRI *)` |

**Formula: IST time − 5 hours 30 minutes = UTC time**

---

### Method A — Via Terraform (Recommended)

**Step 1 — Open `event.tf`**

Find the two `schedule_expression` lines:

```hcl
# START rule (currently 9:00 AM IST = 3:30 AM UTC)
schedule_expression = "cron(30 3 ? * MON-FRI *)"

# STOP rule (currently 7:00 PM IST = 1:30 PM UTC)
schedule_expression = "cron(30 13 ? * MON-FRI *)"
```

**Step 2 — Change the cron expression**

Example: change start to 8:30 AM IST (= 3:00 AM UTC):

```hcl
schedule_expression = "cron(0 3 ? * MON-FRI *)"
```

Example: change stop to 6:30 PM IST (= 1:00 PM UTC):

```hcl
schedule_expression = "cron(0 13 ? * MON-FRI *)"
```

**Step 3 — Apply**

```bash
terraform apply
```

---

### Method B — Via AWS Console

**For the START schedule:**

```
AWS Console → Amazon EventBridge
→ left menu: Rules
→ find rule: start-ec2-weekdays-0900am-ist
→ click the rule name
→ click Edit (top right)
→ Step 1: Define rule detail → click Next
→ Step 2: Build schedule
   → Schedule pattern: Cron-based schedule
   → Cron expression: change to your new time (in UTC)
   → click Next
→ Step 3: Select target → click Next
→ Step 4: Configure tags → click Next
→ click Update rule
```

**For the STOP schedule:**

```
AWS Console → Amazon EventBridge
→ left menu: Rules
→ find rule: stop-ec2-weekdays-0700pm-ist
→ click the rule name
→ click Edit (top right)
→ follow same steps as above with new cron time
→ click Update rule
```

> EventBridge always uses **UTC time** in the cron expression. Always convert your IST time to UTC before entering it.

---

## 7. Cron Expression Format Reference

```
cron(Minutes  Hours  Day-of-month  Month  Day-of-week  Year)
```

| Field | Allowed values | Example |
|---|---|---|
| Minutes | 0–59 | `30` = at :30 past the hour |
| Hours | 0–23 | `3` = 3 AM UTC |
| Day-of-month | 1–31 or `?` | `?` = not specified (use when DOW is set) |
| Month | 1–12 or `*` | `*` = every month |
| Day-of-week | MON–SUN or `*` | `MON-FRI` = weekdays only |
| Year | 1970–2199 or `*` | `*` = every year |

**Common day-of-week values:**

| Value | Meaning |
|---|---|
| `MON` | Monday only |
| `MON-FRI` | Monday to Friday |
| `MON,WED,FRI` | Monday, Wednesday, Friday |
| `*` | Every day |

---

## 8. File Structure Reference

```
Automation_start_stop_ec2-usingLambda/
│
├── provider.tf          → AWS region and Terraform version config
├── varibale.tf          → Input variables: region and instance_id list
├── terraform.tfvars     → Actual variable values (gitignored — contains instance IDs)
├── main.tf              → IAM role + policy (permissions for Lambda)
├── lambda.tf            → Two Lambda functions: start and stop
├── event.tf             → Two EventBridge rules + targets + Lambda permissions
├── .gitignore           → Excludes state files, ZIPs, tfvars from git
├── README.md            → Technical reference + troubleshooting
├── GUIDE.md             → This file — purpose, benefits, how to modify
│
└── lambda_function/
    ├── start_ec2.py     → Python: reads INSTANCE_IDS env var, calls start_instances()
    └── stop_ec2.py      → Python: reads INSTANCE_IDS env var, calls stop_instances()
```

---

## 9. Checking Logs After a Trigger

To confirm the Lambda ran and see which instances were started/stopped:

```
AWS Console → CloudWatch
→ left menu: Log groups
→ /aws/lambda/start-ec2-weekdays-9am-ist   ← start logs
→ /aws/lambda/stop-ec2-weekdays-7pm-ist    ← stop logs
→ click the latest log stream
→ look for lines like:
   Instance i-0abc123 -> pending    (start)
   Instance i-0abc123 -> stopping   (stop)
```

---

## 10. Teardown (Remove Everything)

To delete all AWS resources created by this project:

```bash
terraform destroy
```

This removes both Lambda functions, both EventBridge rules, the IAM role and policy, and CloudWatch log groups.
