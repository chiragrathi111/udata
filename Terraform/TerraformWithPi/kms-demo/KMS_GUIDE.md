# 🔐 AWS KMS (Key Management Service) Demo

## 📋 Overview

AWS KMS manages encryption keys for securing data. This demo shows envelope encryption - encrypting data with a data key, then encrypting the data key with a master key.

## 🎯 Envelope Encryption Concept

```
Your Data → Encrypted with Data Key → Encrypted Data
Data Key → Encrypted with Master Key (CMK) → Encrypted Data Key
```

**Why?** Large data encryption is slow with KMS. Solution: Use fast local encryption with data key, protect data key with KMS.

## 🔄 Complete Workflow

### 1. Create KMS Key (CMK)

```bash
# Via Console or CLI
aws kms create-key --description "Demo encryption key"
aws kms create-alias --alias-name alias/demo-key --target-key-id <key-id>
```

### 2. Generate Data Key

```bash
# Generate data key from CMK
aws kms generate-data-key \
  --key-id alias/demo-key \
  --key-spec AES_256 \
  --region us-east-1
```

**Output:**
```json
{
  "KeyId": "arn:aws:kms:us-east-1:123456789:key/abc-123",
  "Plaintext": "7DmPVPgzJ8exc9+AekcEmVL7jdv0RWMxPgA4JlrpE4k=",
  "CiphertextBlob": "ADIDAHiiF6PCTM1Hou+61r+M/pyUfwSizO02..."
}
```

**Save keys:**
```bash
# Save plaintext data key
echo "7DmPVPgzJ8exc9+AekcEmVL7jdv0RWMxPgA4JlrpE4k=" | base64 --decode > datakey

# Save encrypted data key (keep this!)
echo "ADIDAHiiF6PCTM1Hou+61r+M/pyUfwSizO02..." | base64 --decode > encrypted-datakey
```

### 3. Encrypt Data with Data Key

```bash
# Create sensitive file
echo "MyDatabasePassword123!" > password.txt

# Encrypt with data key
openssl enc -in password.txt -out password-encrypted.txt -e -aes256 -k fileb://datakey

# Delete sensitive files (security!)
rm datakey
rm password.txt
```

**Now you have:**
- ✅ `password-encrypted.txt` - Encrypted data
- ✅ `encrypted-datakey` - Encrypted data key
- ❌ `datakey` - Deleted (security)
- ❌ `password.txt` - Deleted (security)

### 4. Decrypt Data

```bash
# Decrypt data key using KMS
aws kms decrypt \
  --ciphertext-blob fileb://encrypted-datakey \
  --region us-east-1

# Output gives plaintext data key
# Save it temporarily
echo "7DmPVPgzJ8exc9+AekcEmVL7jdv0RWMxPgA4JlrpE4k=" | base64 --decode > datakey

# Decrypt data with data key
openssl enc -in password-encrypted.txt -out password-decrypted.txt -d -aes256 -k fileb://datakey

# View decrypted data
cat password-decrypted.txt

# Delete data key again
rm datakey
```

## 🎓 Key Concepts

### Customer Master Key (CMK)
- Master encryption key managed by KMS
- Never leaves KMS
- Used to encrypt/decrypt data keys

### Data Key
- Used to encrypt actual data
- Generated from CMK
- Can be used outside KMS (faster)

### Envelope Encryption
- Data encrypted with data key (fast, local)
- Data key encrypted with CMK (secure, KMS)
- Best of both worlds

## 💡 Real-World Use Cases

### 1. Database Encryption
```bash
# Encrypt database backup
mysqldump mydb > backup.sql
openssl enc -in backup.sql -out backup.sql.enc -e -aes256 -k fileb://datakey
rm backup.sql datakey
```

### 2. Application Secrets
```bash
# Encrypt API keys
echo "sk_live_abc123xyz" > api-key.txt
openssl enc -in api-key.txt -out api-key.enc -e -aes256 -k fileb://datakey
rm api-key.txt datakey
```

### 3. File Storage
```bash
# Encrypt before S3 upload
openssl enc -in document.pdf -out document.pdf.enc -e -aes256 -k fileb://datakey
aws s3 cp document.pdf.enc s3://my-bucket/
rm document.pdf datakey
```

## 🔒 Security Best Practices

1. **Never commit plaintext data keys** to version control
2. **Delete plaintext data keys** after encryption
3. **Keep encrypted data keys** safe (they're useless without KMS access)
4. **Use IAM policies** to control KMS access
5. **Enable key rotation** for CMKs
6. **Audit key usage** with CloudTrail

## 🎯 Interview Questions

**Q: Why use envelope encryption instead of encrypting directly with KMS?**
A: KMS has 4KB data limit and network latency. Envelope encryption uses fast local encryption with data keys, only using KMS to protect the data key.

**Q: What happens if encrypted data key is stolen?**
A: Useless without KMS access. Attacker needs IAM permissions to decrypt it.

**Q: Can I use same data key for multiple files?**
A: Yes, but best practice is unique data key per file for better security.

**Q: What's the difference between CMK and data key?**
A: CMK stays in KMS (master key), data key is generated from CMK and used locally (working key).

## 💰 Cost

- KMS CMK: $1/month per key
- API requests: $0.03 per 10,000 requests
- **Example**: 10,000 encrypt/decrypt operations = $1.03/month

## 🧹 Cleanup

```bash
# Delete test files
rm password-encrypted.txt encrypted-datakey password-decrypted.txt

# Delete KMS key (via console or CLI)
aws kms schedule-key-deletion --key-id <key-id> --pending-window-in-days 7
```

---

**Built for learning AWS KMS encryption** 🔐
