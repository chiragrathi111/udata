**Project Overview**
- **Repo:**: Terraform configuration to create a custom AWS VPC, one public subnet, one private subnet, NAT/EIP, route tables, a security group, and two EC2 instances (one public, one private).

**What This Setup Achieves**
- **VPC**: Creates a VPC `aws_vpc.chirag_vpc` with CIDR `10.0.0.0/16`.
- **Subnets**: Creates one public subnet (`aws_subnet.public_cr1`) and one private subnet (`aws_subnet.private_cr1`).
- **Internet Access**: Creates an Internet Gateway (`aws_internet_gateway.igw`) for public subnet routing.
- **NAT Gateway**: Allocates an Elastic IP (`aws_eip.eip1`) and a NAT Gateway (`aws_nat_gateway.nat_gw1`) so instances in the private subnet can reach the Internet.
- **Route Tables**: Configures a public route table (IGW) and a private route table (NAT) with associations to the respective subnets.
- **Security Group**: Creates one security group `aws_security_group.albb_sg` (now associated with the VPC) and opens ports defined by `var.port`.
- **EC2 Instances**: Launches two EC2 instances: `aws_instance.cr1` (public subnet, public IP) and `aws_instance.cr2` (private subnet, no public IP).

**Files of Interest**
- `credential.tf` - provider and required versions.
- `vpc.tf` - VPC, subnets, IGW, EIP, NAT gateway, route tables and associations.
- `sg.tf` - Security group (updated to include `vpc_id = aws_vpc.chirag_vpc.id`).
- `instance.tf` - EC2 instances configuration.
- `key_pair.tf` - (commented) example of creating a key-pair resource from a public key file.
- `variable.tf` - input variables.
- `terraform.tfvars` - local variable values (contains sensitive values; see Security Notes).

**Important Security Notes**
- **Do not commit AWS credentials or `terraform.tfstate` to a public repo.** `terraform.tfvars` in this repo contains `access_key` and `secret_key` — rotate these keys immediately if they are real and remove them from the repo.
- Prefer using environment variables (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`) or the AWS credentials file for authentication.

**Key Pair: usage and how-to**
- For EC2 `key_name` use only the AWS key-pair name (e.g. `cr`). Do NOT pass a `.pem` filename.
- Two recommended ways to create/access a key pair:

1) Generate keys locally and import public key to AWS (recommended):
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/cr_key -N ""
aws ec2 import-key-pair --key-name cr --public-key-material fileb://~/.ssh/cr_key.pub
```
- This keeps the private key (`~/.ssh/cr_key`) on your machine and registers the public key in AWS as key pair `cr`.

2) Create key pair using AWS and save private key locally:
```bash
aws ec2 create-key-pair --key-name cr --query 'KeyMaterial' --output text > cr.pem
chmod 400 cr.pem
```
- This returns private key material from AWS; store `cr.pem` securely.

3) Let Terraform create the key pair from a local public key (optionally):
- Add or uncomment `key_pair.tf` and place a public key file next to the module, e.g. `cr.pub`.
```terraform
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("${path.module}/${var.key_name}.pub")
}
```

**How to run (quick commands)**
- Initialize Terraform and provider plugins:
```bash
terraform init
```
- Validate configuration:
```bash
terraform validate
```
- Preview changes:
```bash
terraform plan
```
- Apply (creates resources):
```bash
terraform apply
# or
terraform apply -auto-approve
```
- Destroy resources when finished:
```bash
terraform destroy
# or
terraform destroy -auto-approve
```

**Common Issues & Troubleshooting**
- `Security group ... and subnet ... belong to different networks`:
  - Cause: security group was created in the wrong VPC. Fix: set `vpc_id = aws_vpc.chirag_vpc.id` in `sg.tf`. This repository already has `sg.tf` updated.
- `Error acquiring the state lock`:
  - Terraform locks the state during apply. If you are sure no other Terraform process is running, use:
  ```bash
  terraform force-unlock <LOCK_ID>
  ```
  - Replace `<LOCK_ID>` with the ID shown in the error message.
- NAT Gateway EIP allocation reference:
  - If you get an error creating NAT gateway, ensure `allocation_id` uses the EIP's `allocation_id` attribute, not its `id`:
  ```hcl
  allocation_id = aws_eip.eip1.allocation_id
  ```

**Changes I made**
- Updated `sg.tf` to attach the security group to the VPC: added `vpc_id = aws_vpc.chirag_vpc.id` (fixes the "different networks" error when launching EC2 instances).

**Recommended Improvements (optional)**
- Create one NAT gateway per AZ and separate private subnets each in their AZ for high availability.
- Use separate security groups: one for public-facing load/servers and another for private instances.
- Restrict SSH access (port 22) to trusted IPs instead of `0.0.0.0/0`.
- Move secrets out of `terraform.tfvars` and into environment variables or a secrets manager.

**Next steps I can help with**
- Add an `aws_key_pair` Terraform resource and create a `cr.pub` placeholder.
- Replace plaintext credentials with an example `providers.tf` using environment variables.
- Create additional subnets and NAT gateways for HA.

If you want, I can now:
- Add `aws_key_pair` resource and a sample public key file in the repo, or
- Walk you through generating/importing a key pair and then run `terraform plan` here.

End of README.
