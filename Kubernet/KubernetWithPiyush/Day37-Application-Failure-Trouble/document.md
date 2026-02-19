# If youwant create all yaml file then run below commands:-
* kubectl apply -f .

🔥 Most Common Real Problems
1️⃣ Wrong Service Selector

Pods running but service not routing.

2️⃣ Wrong TargetPort

Service port 80 → targetPort 8080 mismatch.

3️⃣ DB Service Name Wrong

App trying to connect to localhost.

4️⃣ NetworkPolicy Blocking
5️⃣ DNS Resolution Failure
6️⃣ Application Config Error

7 Sometime pod and service label name mismatch thatis the main reason, if we describe svc endpoint showing
blank.
so that is the check 
* kubectl get pod --show-labels 
* kubectl get svc --show-labels

if mismatch then modify