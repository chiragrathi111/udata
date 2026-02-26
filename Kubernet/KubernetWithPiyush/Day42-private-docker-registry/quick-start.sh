#!/bin/bash
# Private Docker Registry - Quick Start Script
# Run this script to set up everything automatically

set -e

echo "🚀 Private Docker Registry - Quick Setup"
echo "========================================"
echo ""

# Step 1: Create certificates
echo "📜 Step 1: Creating TLS certificates..."
mkdir -p registry/certs
openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout registry/certs/tls.key \
  -x509 -days 365 \
  -out registry/certs/tls.crt \
  -subj "/CN=docker-registry/O=MyOrg" 2>/dev/null
echo "✅ Certificates created"
echo ""

# Step 2: Create htpasswd
echo "🔑 Step 2: Creating authentication file..."
mkdir -p registry/auth
docker run --rm --entrypoint htpasswd \
  httpd:2 -Bbn admin password > registry/auth/htpasswd
echo "✅ Authentication file created (username: admin, password: password)"
echo ""

# Step 3: Create secrets
echo "🔒 Step 3: Creating Kubernetes secrets..."
kubectl create secret generic certs-secret \
  --from-file=tls.crt=registry/certs/tls.crt \
  --from-file=tls.key=registry/certs/tls.key \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic auth-secret \
  --from-file=htpasswd=registry/auth/htpasswd \
  --dry-run=client -o yaml | kubectl apply -f -
echo "✅ Secrets created"
echo ""

# Step 4: Apply volume
echo "💾 Step 4: Creating persistent volume..."
kubectl apply -f volume.yml
echo "✅ Volume created"
echo ""

# Step 5: Deploy registry
echo "🚀 Step 5: Deploying registry..."
kubectl apply -f deployment.yml
echo "✅ Deployment created"
echo ""

# Step 6: Create service
echo "🌐 Step 6: Creating service..."
kubectl apply -f service.yml
echo "✅ Service created"
echo ""

# Wait for pods
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=registry --timeout=120s
echo "✅ Pods are ready"
echo ""

# Summary
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Registry is running! Here's what to do next:"
echo ""
echo "1. Port forward to access registry:"
echo "   kubectl port-forward svc/docker-registry 5000:5000"
echo ""
echo "2. In another terminal, login:"
echo "   docker login localhost:5000 -u admin -p password"
echo ""
echo "3. Push an image:"
echo "   docker pull nginx:alpine"
echo "   docker tag nginx:alpine localhost:5000/nginx:alpine"
echo "   docker push localhost:5000/nginx:alpine"
echo ""
echo "4. Check registry:"
echo "   curl -k -u admin:password https://localhost:5000/v2/_catalog"
echo ""
echo "📝 For detailed steps, see: STEP-BY-STEP-POC.md"
echo ""
echo "✅ POC Status: READY TO USE"
