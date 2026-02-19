Correct Production Way (Dynamic EBS)

# This is what companies use.
# You DO NOT manually attach volume.
# Kubernetes automatically creates EBS.

Step 1 — Install AWS EBS CSI Driver

* kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

Step 2 - Create a IAM Role

AmazonEBSCSIDriverPolicy

Step 3 - Create Storage Class

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3

* kubectl apply -f storageclass.yml

Step 4 - Create a PVC not needed PV

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-pvc
spec:
  storageClassName: ebs-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi

* kubectl apply -f pvc.yml

# What Happens Automatically
# When you create PVC:
# Kubernetes calls AWS API
# AWS creates new 20GB EBS volume
# EBS attaches to worker
# Kubernetes mounts inside Pod
# You do NOTHING manually.

Step 5 - use in pod

apiVersion: v1
kind: Pod
metadata:
  name: nginx-ebs
spec:
  volumes:
    - name: storage
      persistentVolumeClaim:
        claimName: ebs-pvc
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: storage


Real Production flow:-

PVC created
     ↓
StorageClass triggered
     ↓
EBS volume auto created
     ↓
Attached to correct worker
     ↓
Mounted inside pod


Flow:-

Pod
  ↓
PVC
  ↓
StorageClass
  ↓
EBS CSI Driver
  ↓
AWS API
  ↓
Creates EBS Volume
  ↓
Attaches to Worker EC2
  ↓
Mounts into Pod
