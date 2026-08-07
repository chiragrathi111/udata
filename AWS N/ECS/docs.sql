Step 1: Launch Apache container and modify index.html

# Run Apache container
docker run -dit --name apache-temp -p 80:80 httpd:latest

# Go inside the container
docker exec -it apache-temp bash

Inside the container:

echo "<h1>Chirag Rathi</h1>" > /usr/local/apache2/htdocs/index.html

exit


Step 2: Test locally before committing

docker restart apache-temp
curl localhost:80


Step 3: Commit the modified container as a new image

docker commit apache-temp my-chirag-app:latest
docker images   # verify it's there


Step 4: Create ECR repository (Console)

ECR → Repositories → Create repository
Private → name: my-chirag-app
Create


Step 5: Tag and push image to ECR
Click your repo → View push commands, or run manually:

this below commads using our ecr push commands -

aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com

docker tag my-chirag-app:latest <account-id>.dkr.ecr.ap-south-1.amazonaws.com/my-chirag-app:latest

docker push <account-id>.dkr.ecr.ap-south-1.amazonaws.com/my-chirag-app:latest

Verify image shows up in ECR console.


Step 6: IAM Role
IAM → Roles → Create role

Trusted entity: ECS → Elastic Container Service Task
Attach policy: AmazonECSTaskExecutionRolePolicy
Name: ecsTaskExecutionRole

(No task role needed here — your container does not call any AWS APIs.)


Step 7: Security Groups
a) ALB SG — inbound 80 from 0.0.0.0/0
b) ECS Task SG — inbound 80 only from ALB SG


Step 8: Target Group
EC2 → Target Groups → Create

Target type: IP addresses
Protocol: HTTP, Port 80
VPC: yours
Health check path: /


Step 9: Load Balancer
EC2 → Load Balancers → Create → Application Load Balancer

Internet-facing
2+ public subnets (different AZs)
SG: ALB SG from Step 7a
Listener HTTP:80 → forward to Target Group from Step 8


Step 10: ECS Cluster
ECS → Clusters → Create → Networking only (Fargate) → name it → Create


Step 11: Task Definition

ECS → Task Definitions → Create
Fargate
Task Execution Role → ecsTaskExecutionRole
Task size: 0.5 vCPU / 1GB (plenty for a static Apache page)
Add container:

Name: chirag-container
Image URI: your ECR image
Port mapping: 80
Logging → enable awslogs

Create


Step 12: ECS Service

Cluster → Services → Create
Fargate → select task definition
Desired tasks: 2 (2 containers running, as you wanted)
Networking: subnets, ECS Task SG from Step 7b, no public IP needed (ALB handles external access)
Load Balancing: attach ALB from Step 9, map chirag-container:80 → Target Group from Step 8
Create


Step 13: Verify

ECS → Service → Tasks — 2 tasks running
Target Groups → Targets tab — both healthy
Copy ALB DNS name (EC2 → Load Balancers) → paste in browser
You should see: Chirag Rathi 🎉