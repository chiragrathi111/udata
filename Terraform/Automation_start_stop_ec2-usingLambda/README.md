# EC2 Auto Start/Stop — Weekdays (Mon–Fri) via Terraform + Lambda

Automatically **starts** EC2 instances every weekday at **9:00 AM IST** and **stops** them at **7:00 PM IST** using AWS Lambda triggered by Amazon EventBridge.

---

## How It Works

```
EventBridge Rule (Mon-Fri 3:30 AM UTC = 9:00 AM IST)
        |
        v
  start_ec2 Lambda  <-- reads INSTANCE_IDS from environment variable
        |
        v
   EC2 StartInstances API

EventBridge Rule (Mon-Fri 1:30 PM UTC = 7:00 PM IST)
        |
        v
  stop_ec2 Lambda   <-- reads INSTANCE_IDS from environment variable
        |
        v
   EC2 StopInstances API
```

1. **EventBridge** fires two scheduled rules — one for start, one for stop.
2. **Lambda** is invoked and calls the EC2 `StartInstances` / `StopInstances` API.
3. **Instance IDs** are read from Lambda environment variables — never hardcoded.

---

## File Structure

```
.
├── provider.tf              # Terraform + AWS provider config
├── varibale.tf              # Input variables (region, instance_id)
├── terraform.tfvars         # Variable values (instance_id intentionally excluded)
├── main.tf                  # IAM role and policy shared by both Lambda functions
├── lambda.tf                # Start + Stop Lambda resources + ZIP packaging
├── event.tf                 # EventBridge rules, targets, and Lambda permissions
└── lambda_function/
    ├── start_ec2.py         # Python handler — calls ec2.start_instances()
    └── stop_ec2.py          # Python handler — calls ec2.stop_instances()
```

---

## Prerequisites

- Terraform >= 1.14
- AWS CLI configured (`aws configure`)
- IAM user/role with permission to create: Lambda, IAM, EventBridge, CloudWatch Logs

---

## Usage

### Step 1 — Set your EC2 instance IDs as an environment variable

**One instance:**
```bash
export TF_VAR_instance_id='["i-0abc1234def567890"]'
```

**Multiple instances:**
```bash
export TF_VAR_instance_id='["i-0abc1234def567890","i-0xyz9876abc54321"]'
```

> Instance IDs are never stored in `.tf` files or source code — safe to commit this folder to git.

### Step 2 — Initialize Terraform

```bash
terraform init
```

### Step 3 — Preview the changes

```bash
terraform plan
```

### Step 4 — Apply

```bash
terraform apply
```

---

## Schedule Details

| Function | IST Time | UTC Time | Cron Expression |
|---|---|---|---|
| Start EC2 | Mon–Fri 9:00 AM | 3:30 AM UTC | `cron(30 3 ? * MON-FRI *)` |
| Stop EC2 | Mon–Fri 7:00 PM | 1:30 PM UTC | `cron(30 13 ? * MON-FRI *)` |

**Cron breakdown:**
```
cron(Min  Hr   DOM  Mon  DOW      Yr)
     30   3    ?    *    MON-FRI  *    ← Start: 9:00 AM IST
     30   13   ?    *    MON-FRI  *    ← Stop:  7:00 PM IST
```

- `?` = no specific day-of-month (required when day-of-week is set)
- `MON-FRI` = weekdays only — Saturday and Sunday are skipped automatically

---

## How Instance IDs Stay Out of Code

```
Shell env var            Terraform variable      Lambda env var (string)
TF_VAR_instance_id  ->  var.instance_id      ->  INSTANCE_IDS = "i-aaa,i-bbb"
                        list(string)                     |
                                                         v
                                                  Python: raw.split(',')
                                                         |
                                                         v
                                                  ["i-aaa", "i-bbb"]  -> EC2 API
```

Lambda env vars must be strings, so Terraform uses `join(",", var.instance_id)` to convert the list, and Python splits it back. Both start and stop functions share the same `INSTANCE_IDS`.

---

## Logs

Lambda execution logs (including Python `print()` output) go to CloudWatch Logs:

```
CloudWatch → Log Groups → /aws/lambda/start-ec2-monday-9am-ist
CloudWatch → Log Groups → /aws/lambda/stop-ec2-weekdays-7pm-ist
```

---

## Troubleshooting

### Error: `Sandbox.Timeout` — Task timed out after 3.00 seconds

**Cause:** Default Lambda timeout is 3 seconds. The EC2 API call takes 5–15 seconds on first invocation (cold start + API latency), so Lambda was killed before boto3 could return a response.

**Fix applied:** Set `timeout = 30` in `lambda.tf`. Lambda now waits up to 30 seconds, which is enough for any EC2 API response.

---

### Error: `KMS access was denied` — Lambda unable to decrypt environment variables

**Cause:** A customer-managed KMS key (CMK) was attached to the Lambda function's environment variables (manually via the AWS Console after Terraform created the function). When Lambda starts, it calls `kms:Decrypt` to read env vars before any Python code runs. The IAM role had no `kms:Decrypt` permission, so Lambda failed before executing a single line.

**Why Terraform didn't fix it automatically:** The CMK was set outside Terraform, so Terraform's state file never recorded it. On `terraform apply`, Terraform saw no drift and made no changes — the CMK stayed attached.

**Fix applied (two steps):**

1. Set `kms_key_arn = ""` explicitly in `lambda.tf` so Terraform actively removes any CMK on next apply.
2. Remove the CMK manually (one-time) since Terraform still showed "No changes" due to stale state:

   **Option A — Console:**
   ```
   Lambda → Configuration → Environment variables → Edit
   → Encryption key → select "Use AWS managed key (default)" → Save
   ```

   **Option B — AWS CLI:**
   ```bash
   aws lambda update-function-configuration \
     --function-name start-ec2-monday-9am-ist \
     --kms-key-arn "" \
     --region ap-south-1
   ```

**Note:** AWS-managed encryption is still active after removing the CMK — environment variables are not plain text. The difference is that AWS manages the key internally and no IAM permission is needed.

---

## Teardown

```bash
terraform destroy

terraform destroy --auto-approve

```
