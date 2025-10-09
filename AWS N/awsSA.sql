🗓️ AWS Real-Time Practice Plan (6 Weeks)
Week 1 – Networking & Compute Basics

	Mon: Create VPC with public + private subnets.

	Tue: Add Internet Gateway, NAT Gateway, and route tables.

	Wed: Launch EC2 in public subnet (web server).

	Thu: Launch EC2 in private subnet (DB server).

	Fri: Practice Security Groups vs NACL.

	Sat (2–3h): Build 2-tier app → ALB → EC2 → RDS (MySQL/Postgres).

	Sun (2–3h): Automate above setup with AWS CLI.

Week 2 – Storage & Identity

	Mon: S3 bucket – enable versioning & lifecycle rules.

	Tue: Enable S3 bucket policies & test access control.

	Wed: Host a static website on S3.

	Thu: Add CloudFront in front of S3.

	Fri: IAM roles & policies (attach to EC2).

	Sat (2–3h): Build Static Website Project: S3 + CloudFront + Route53 (custom domain if possible).

	Sun (2–3h): Set up IAM groups, roles, MFA, and test least privilege.

Week 3 – Automation

	Mon: Install & use AWS CLI, configure profiles.

	Tue: Write a shell script to create an S3 bucket + upload file.

	Wed: Create a CloudFormation stack (simple VPC + EC2).

	Thu: Update stack with more resources.

	Fri: Delete stack safely.

	Sat (2–3h): Write CloudFormation/Terraform for 3-tier architecture.

	Sun (2–3h): Add SSM Agent to EC2 and run remote commands without SSH.

Week 4 – Serverless

	Mon: Create Lambda function (Hello World).

	Tue: Connect Lambda with S3 (trigger on file upload).

	Wed: Connect Lambda with DynamoDB (insert/read items).

	Thu: Build REST API with API Gateway + Lambda.

	Fri: Secure API with API Keys.

	Sat (2–3h): Build Image Processing App: Upload image → Lambda resizes → Save to S3.

    Sun (2–3h): Deploy Serverless app via SAM or CloudFormation.

Week 5 – Containers & CI/CD

	Mon: Create Docker image locally, push to ECR.

	Tue: Deploy container in ECS (Fargate).

	Wed: Add ALB in front of ECS service.

	Thu: Enable AutoScaling for ECS tasks.

	Fri: Explore EKS (if time) or deepen ECS.

	Sat (2–3h): Build CI/CD pipeline: CodeCommit → CodeBuild → CodeDeploy → EC2.

    Sun (2–3h): Extend pipeline to ECS deployment.

Week 6 – Monitoring, Security & Cost

	Mon: Create CloudWatch dashboard for EC2 metrics.

	Tue: Create CloudWatch alarm (CPU > 70%).

	Wed: Configure SNS topic → send alerts to email.

	Thu: Enable AWS Config rules (e.g., no public S3).

	Fri: Enable GuardDuty & review findings.

	Sat (2–3h): Build End-to-End Project: E-commerce app → ALB + AutoScaling + RDS + S3 + CloudFront + Lambda for image resize.

    Sun (2–3h): Add Budgets (service-specific, like Bedrock), analyze Cost Explorer.

✅ After 6 weeks, you’ll have hands-on practice across Networking, Compute, Storage, IAM, Automation, Serverless, Containers, Monitoring, and Cost control → covering real-time architecting scenarios.