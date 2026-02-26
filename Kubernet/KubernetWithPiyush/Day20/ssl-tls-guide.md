# SSL/TLS Complete Guide 🔐
## Secure Communication Basics

---

## What is SSL/TLS? 🤔

**SSL/TLS** = Encryption protocol for secure communication over internet

**Simple Explanation:**
- HTTP = Postcard (anyone can read)
- HTTPS = Sealed envelope (only recipient can read)
- TLS = The seal!

---

## Why Use SSL/TLS? 💡

### Without SSL/TLS:
```
User → Password: admin123 → Server
Hacker intercepts → Sees password ❌
```

### With SSL/TLS:
```
User → Encrypted: xK9#mP2$qL → Server
Hacker intercepts → Sees gibberish ✅
```

---

## How SSL/TLS Works 🔄

```
1. Client: "Hello, let's use TLS"
   ↓
2. Server: "Here's my certificate"
   ↓
3. Client: Verifies certificate
   ↓
4. Client: Generates session key
   ↓
5. Client: Encrypts key with server's public key
   ↓
6. Server: Decrypts with private key
   ↓
7. Both use session key for encryption
   ↓
8. Secure communication! ✅
```

---

## Key Concepts 🎯

### 1. Certificate
**What:** Digital ID card
**Contains:** Domain name, public key, issuer
**Like:** Passport for websites

### 2. Public Key
**What:** Lock (anyone can use)
**Use:** Encrypt data

### 3. Private Key
**What:** Key (only owner has)
**Use:** Decrypt data

### 4. Certificate Authority (CA)
**What:** Trusted organization
**Examples:** Let's Encrypt, DigiCert
**Does:** Issues certificates

---

## SSL/TLS in Kubernetes 🚀

### 1. Ingress with TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
spec:
  tls:
  - hosts:
    - www.example.com
    secretName: tls-secret
  rules:
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp
            port:
              number: 80
```

### 2. TLS Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-certificate>
  tls.key: <base64-encoded-private-key>
```

---

## Creating TLS Certificate 🛠️

### Method 1: Self-Signed (Testing)

```bash
# Generate private key
openssl genrsa -out tls.key 2048

# Generate certificate
openssl req -new -x509 -key tls.key -out tls.crt -days 365 \
  -subj "/CN=www.example.com"

# Create Kubernetes secret
kubectl create secret tls tls-secret \
  --cert=tls.crt \
  --key=tls.key
```

### Method 2: Let's Encrypt (Production)

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create ClusterIssuer
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# Ingress with cert-manager
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - www.example.com
    secretName: tls-secret
  rules:
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp
            port:
              number: 80
```

---

## Real-World Example 🌍

```yaml
# Complete HTTPS setup
---
# 1. Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx
        ports:
        - containerPort: 80
---
# 2. Service
apiVersion: v1
kind: Service
metadata:
  name: webapp
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
---
# 3. TLS Secret
apiVersion: v1
kind: Secret
metadata:
  name: webapp-tls
type: kubernetes.io/tls
stringData:
  tls.crt: |
    -----BEGIN CERTIFICATE-----
    MIIDXTCCAkWgAwIBAgIJAKL...
    -----END CERTIFICATE-----
  tls.key: |
    -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0...
    -----END PRIVATE KEY-----
---
# 4. Ingress with TLS
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - www.example.com
    - api.example.com
    secretName: webapp-tls
  rules:
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp
            port:
              number: 80
```

---

## Commands 🔧

```bash
# Create TLS secret from files
kubectl create secret tls my-tls-secret \
  --cert=path/to/cert.crt \
  --key=path/to/key.key

# View secret
kubectl get secret my-tls-secret -o yaml

# Describe secret
kubectl describe secret my-tls-secret

# Delete secret
kubectl delete secret my-tls-secret

# Test HTTPS
curl https://www.example.com

# Check certificate
openssl s_client -connect www.example.com:443 -servername www.example.com
```

---

## Best Practices 📚

### 1. Use Let's Encrypt for Production
```yaml
# Free, automated, trusted
cert-manager.io/cluster-issuer: letsencrypt-prod
```

### 2. Force HTTPS Redirect
```yaml
annotations:
  nginx.ingress.kubernetes.io/ssl-redirect: "true"
```

### 3. Use Strong Ciphers
```yaml
annotations:
  nginx.ingress.kubernetes.io/ssl-ciphers: "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384"
```

### 4. Rotate Certificates
```bash
# Certificates expire!
# Let's Encrypt: 90 days
# Renew before expiry
```

---

## Troubleshooting 🔍

### Issue 1: Certificate not trusted
```bash
# Self-signed certificate
# Browser shows warning

# Solution: Use Let's Encrypt or buy certificate
```

### Issue 2: Certificate expired
```bash
# Check expiry
openssl x509 -in tls.crt -noout -dates

# Renew certificate
```

### Issue 3: Wrong certificate
```bash
# Certificate for wrong domain
# Check CN (Common Name)
openssl x509 -in tls.crt -noout -subject
```

---

## Key Takeaways 🎯

1. **TLS** = Encrypted communication
2. **Certificate** = Digital ID
3. **Let's Encrypt** = Free certificates
4. **cert-manager** = Automate certificates
5. **Always use HTTPS** = In production

**SSL/TLS = Secure Communication! 🔐**
