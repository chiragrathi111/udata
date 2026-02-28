#!/bin/bash

echo "🏪 Setting up Private Docker Registry..."
echo "========================================="

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Deploy resources
echo ""
echo "📦 Creating namespace and storage..."
kubectl apply -f kubernetes/01-namespace-storage.yaml

echo ""
echo "🔐 Creating authentication secrets..."
kubectl apply -f kubernetes/02-secrets.yaml

echo ""
echo "🗄️ Deploying Docker Registry..."
kubectl apply -f kubernetes/03-registry.yaml

echo ""
echo "🌐 Deploying Registry UI..."
kubectl apply -f kubernetes/04-registry-ui.yaml

echo ""
echo "💾 Setting up backup CronJob..."
kubectl apply -f kubernetes/05-backup.yaml

echo ""
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=docker-registry -n registry --timeout=120s
kubectl wait --for=condition=ready pod -l app=registry-ui -n registry --timeout=60s

echo ""
echo "✅ Setup Complete!"
echo ""
echo "📊 Status:"
echo "=========="
kubectl get pods -n registry
echo ""
kubectl get svc -n registry
echo ""
kubectl get pvc -n registry
echo ""

echo "🌐 Access Information:"
echo "======================"
echo ""
echo "Registry API (NodePort):"
echo "  http://localhost:30500"
echo ""
echo "Registry UI (NodePort):"
echo "  http://localhost:30800"
echo ""
echo "Or use port-forward:"
echo "  kubectl port-forward -n registry svc/docker-registry 5000:5000"
echo "  kubectl port-forward -n registry svc/registry-ui 8080:80"
echo ""

echo "🔑 Login Credentials:"
echo "====================="
echo "  Username: admin"
echo "  Password: admin123"
echo ""

echo "🧪 Test Commands:"
echo "================="
echo ""
echo "# Login to registry"
echo "docker login localhost:30500"
echo ""
echo "# Tag an image"
echo "docker tag nginx:latest localhost:30500/nginx:latest"
echo ""
echo "# Push image"
echo "docker push localhost:30500/nginx:latest"
echo ""
echo "# List images via API"
echo "curl -u admin:admin123 http://localhost:30500/v2/_catalog"
echo ""

echo "💾 Backup Commands:"
echo "==================="
echo "# Run manual backup"
echo "kubectl create job --from=cronjob/registry-backup manual-backup-1 -n registry"
echo ""
echo "# Check backup logs"
echo "kubectl logs -n registry job/registry-backup-manual"
echo ""
echo "# List backups"
echo "kubectl exec -n registry deployment/docker-registry -- ls -lh /backup"
echo ""

echo "🗑️ Cleanup:"
echo "==========="
echo "kubectl delete namespace registry"
