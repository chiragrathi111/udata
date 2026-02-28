#!/bin/bash

echo "🚀 Deploying E-Commerce Microservices Platform..."
echo "=================================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Deploy all resources
echo ""
echo "📦 Creating namespace..."
kubectl apply -f kubernetes/01-namespace.yaml

echo ""
echo "🔧 Creating ConfigMaps and Secrets..."
kubectl apply -f kubernetes/02-configmap-secrets.yaml

echo ""
echo "🗄️ Deploying MongoDB (StatefulSet)..."
kubectl apply -f kubernetes/03-mongodb.yaml

echo ""
echo "⚡ Deploying Redis..."
kubectl apply -f kubernetes/04-redis.yaml

echo ""
echo "📦 Deploying Product Service..."
kubectl apply -f kubernetes/05-product-service.yaml

echo ""
echo "👤 Deploying User Service..."
kubectl apply -f kubernetes/06-user-service.yaml

echo ""
echo "🛍️ Deploying Order Service..."
kubectl apply -f kubernetes/07-order-service.yaml

echo ""
echo "🚪 Deploying API Gateway..."
kubectl apply -f kubernetes/08-api-gateway.yaml

echo ""
echo "🌐 Deploying Frontend..."
kubectl apply -f kubernetes/09-frontend.yaml

echo ""
echo "🔀 Creating Ingress..."
kubectl apply -f kubernetes/10-ingress.yaml

echo ""
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb -n ecommerce --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis -n ecommerce --timeout=60s
kubectl wait --for=condition=ready pod -l app=product-service -n ecommerce --timeout=90s
kubectl wait --for=condition=ready pod -l app=user-service -n ecommerce --timeout=90s
kubectl wait --for=condition=ready pod -l app=order-service -n ecommerce --timeout=90s
kubectl wait --for=condition=ready pod -l app=api-gateway -n ecommerce --timeout=90s
kubectl wait --for=condition=ready pod -l app=frontend -n ecommerce --timeout=60s

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "📊 Checking Status:"
echo "==================="
kubectl get pods -n ecommerce
echo ""
kubectl get svc -n ecommerce
echo ""

echo "🌐 Access the application:"
echo "=========================="
echo "NodePort: http://localhost:30080"
echo ""
echo "Or add to /etc/hosts:"
echo "127.0.0.1 ecommerce.local"
echo "Then visit: http://ecommerce.local"
echo ""

echo "🧪 Test API directly:"
echo "===================="
echo "kubectl port-forward -n ecommerce svc/api-gateway 3000:3000"
echo "Then visit: http://localhost:3000"
echo ""

echo "📋 Useful Commands:"
echo "==================="
echo "View logs: kubectl logs -f deployment/api-gateway -n ecommerce"
echo "Check HPA: kubectl get hpa -n ecommerce"
echo "Scale service: kubectl scale deployment product-service --replicas=5 -n ecommerce"
echo "Delete all: kubectl delete namespace ecommerce"
