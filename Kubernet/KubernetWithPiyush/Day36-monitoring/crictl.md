🔹 What is crictl?

crictl = CRI CLI tool

It is a command-line tool used to talk directly to the container runtime through the Container Runtime Interface (CRI).

Kubernetes does NOT run containers itself.

It uses a runtime like:

containerd

CRI-O

crictl talks directly to that runtime.

🔹 Big Picture Architecture

kubectl
   ↓
kube-apiserver
   ↓
kubelet
   ↓
containerd (inside kind node)
   ↓
containers

crictl skips Kubernetes API and talks directly to: containerd

🔥 Why Do We Need crictl?

Because sometimes:

👉 Kubernetes is broken
👉 API server is down
👉 Pods stuck in ContainerCreating
👉 Image pull issues
👉 CNI issues
👉 kubelet errors

🚀 Real Benefits of crictl
1️⃣ Debug When Kubernetes API Is Down

If kube-apiserver crashes:

kubectl get pods → not working

But:

crictl ps

Still shows running containers.
Very useful for troubleshooting control plane failures.


2️⃣ See Real Container State

kubectl get pods shows Kubernetes view.

But crictl shows runtime view.

Example:

crictl ps -a

Shows:

Created
Running
Exited
Failed containers


3️⃣ Check Container Logs (Low Level)
crictl logs <container-id>

Sometimes better than:

kubectl logs
Especially when pod never fully started..


4️⃣ Inspect Image Pull Problems
crictl images

Shows which images actually exist in runtime.
If pod stuck in ImagePullBackOff, this helps.

5️⃣ Restart / Remove Containers Manually
crictl stop <id>
crictl rm <id>

Used in disaster recovery.


kubectl  → talks to Kubernetes API
crictl   → talks to container runtime
docker   → talks to Docker daemon


kubectl = logical layer
crictl  = physical container layer


----------------------
🔥 Real Advanced Example 1
Scenario: Pod Stuck in ContainerCreating

You run:

kubectl get pods


Shows:

nginx   ContainerCreating


Now use:

crictl ps -a


You might see container created but exited.

Then:

crictl logs <container-id>


Now you see actual error:

permission denied
port already in use
CNI error

🔥 Real Advanced Example 2
Scenario: kube-apiserver Down

If API server crashes:

kubectl get pods
→ connection refused


Now go to node:

crictl ps | grep kube-apiserver


Then:

crictl logs <id>


Now you see exact crash reason.

This is how real SRE debug production clusters.

🔹 Advanced Commands You Should Know
See running containers
crictl ps

See all containers
crictl ps -a

See images in runtime
crictl images

Inspect container deeply
crictl inspect <container-id>

Inspect pod sandbox
crictl pods

Logs
crictl logs <container-id>

🧠 Important Concept: Pod Sandbox

Kubernetes creates:

Pod sandbox container
+ actual application container


You can see that with:

crictl pods

This is advanced internal understanding.

# crictl -h

