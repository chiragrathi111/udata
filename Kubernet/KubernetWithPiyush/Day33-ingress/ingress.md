1️⃣ Why Ingress exists (the core problem)

Without Ingress, you have only Services.

Service options you already know

ClusterIP → internal only

NodePort → expose via nodeIP:port

LoadBalancer → cloud LB per service (AWS ELB, etc.)

❌ Problems without Ingress

Imagine you have 10 apps:

frontend
backend
auth
payments
orders
users
reports
admin
api
metrics

If you expose them using LoadBalancer:

❌ 10 cloud load balancers

❌ Very expensive

❌ Hard to manage

❌ No URL-based routing

If you expose using NodePort:

❌ Random ports (30001, 30002…)

❌ Ugly URLs

❌ No domain-based routing

2️⃣ What Ingress actually is (very important)

Ingress is NOT a load balancer

👉 Ingress is a routing rule object

It says:
rules:
- host: example.com
  http:
    paths:
    - path: /
      backend:
        service:
          name: hello-world
          port:
            number: 80

example.com/  → hello-world service → pod

3️⃣ Ingress needs an Ingress Controller

Ingress by itself does nothing.

You must have:

nginx-ingress-controller

or traefik

or cilium ingress

or haproxy

In your case:
ingressClassName: nginx

4️⃣ Why kubectl get ing shows ADDRESS empty
NAME          HOSTS         ADDRESS
hello-world   example.com

❓ Why ADDRESS is empty?

Because ADDRESS comes from the Ingress Controller Service, not from Ingress itself.

Let’s check:
* kubectl get svc -n ingress-nginx

6️⃣ Why replacing LoadBalancer with NodePort “updates” address sometimes?

Important truth 👇

Ingress does not care about Service type of your app.

It only cares about:

Ingress Controller Service type

When you:

delete ingress

recreate after controller changes

Ingress controller re-registers status, so sometimes address appears / disappears.

That’s expected behavior.

7️⃣ Real-world production example (remember this)
Company: Flipkart / Amazon / Zomato

They do NOT do this:
1 LoadBalancer per service ❌

1 LoadBalancer
↓
Ingress Controller
↓
100+ services

api.example.com      → api-service
admin.example.com    → admin-service
example.com/cart     → cart-service
example.com/payments → payment-service

Benefits:

💰 Huge cost saving

🌍 Central TLS (HTTPS)

🔄 Blue/Green deploy

🚦 Rate limiting

🔐 Auth at ingress level

8️⃣ What you should remember (exam + real life)
Ingress basics

Ingress = routing rules

Needs ingress controller

Not a load balancer itself

ADDRESS field

Comes from controller service

Empty in KIND / bare metal

Filled in cloud LB

Why use Ingress

Single entry point

Domain/path-based routing

SSL termination

Cost saving

9️⃣ One-liner memory trick 🧠

Service exposes Pods
Ingress exposes Services
Ingress Controller exposes the cluster