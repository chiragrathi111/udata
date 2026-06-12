# 09 — CURL Testing Guide

## CURL Flags Reference
| Flag | What it does | Example |
|---|---|---|
| `-X POST` | Set HTTP method | `-X POST`, `-X DELETE` |
| `-H "key: val"` | Add header | `-H "Content-Type: application/json"` |
| `-d '{...}'` | Set JSON body | `-d '{"name":"Ravi"}'` |
| `-s` | Silent (no progress) | `-s` |
| `-o /dev/null` | Discard response body | `-o /dev/null` |
| `-w "%{http_code}"` | Print status code only | `-w "Status: %{http_code}\n"` |
| `-v` | Verbose (show all headers) | `-v` |

---

## Save Token to Variable (Linux/Mac)
```bash
# Login and save token automatically
TOKEN=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Token: $TOKEN"

# Windows CMD — paste token manually:
# set TOKEN=eyJhbGci...
```

---

## Auth Endpoints

### Register ADMIN user
```bash
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123",
    "role": "ADMIN"
  }'

# Expected: 201 Created
# {
#   "message": "User registered successfully!",
#   "email": "admin@example.com",
#   "role": "ADMIN"
# }
```

### Register USER
```bash
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "user123",
    "role": "USER"
  }'
```

### Login
```bash
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }'

# Expected: 200 OK
# {
#   "token": "eyJhbGciOiJIUzI1NiJ9...",
#   "email": "admin@example.com",
#   "role": "ADMIN",
#   "message": "Login successful!"
# }
```

### Login with wrong password
```bash
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"wrongpassword"}'

# Expected: 401 Unauthorized
# {"error": "Invalid email or password"}
```

---

## Student CRUD Endpoints

### Create student (ADMIN only)
```bash
curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Ravi Kumar",
    "email": "ravi@example.com",
    "age": 21
  }'

# Expected: 201 Created
# {"id":1,"name":"Ravi Kumar","email":"ravi@example.com","age":21}
```

### Create multiple students
```bash
curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Priya Sharma","email":"priya@example.com","age":22}'

curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Amit Patel","email":"amit@example.com","age":20}'
```

### Get all students
```bash
curl http://localhost:8081/api/students \
  -H "Authorization: Bearer $TOKEN"

# Expected: 200 OK
# [{"id":1,"name":"Ravi Kumar",...}, {"id":2,"name":"Priya Sharma",...}]
```

### Get student by ID
```bash
curl http://localhost:8081/api/students/1 \
  -H "Authorization: Bearer $TOKEN"

# Expected: 200 OK — single student object
```

### Get student that doesn't exist
```bash
curl http://localhost:8081/api/students/999 \
  -H "Authorization: Bearer $TOKEN"

# Expected: 404 Not Found
# {"status":404,"message":"Student not found with id: 999","timestamp":"..."}
```

### Update student (ADMIN only)
```bash
curl -X PUT http://localhost:8081/api/students/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Ravi Kumar Updated",
    "email": "ravi@example.com",
    "age": 25
  }'

# Expected: 200 OK — updated student object
```

### Delete student (ADMIN only)
```bash
curl -X DELETE http://localhost:8081/api/students/1 \
  -H "Authorization: Bearer $TOKEN"

# Expected: 200 OK
# "Student deleted successfully!"
```

---

## Security Tests

### No token → 401
```bash
curl http://localhost:8081/api/students

# Expected: 401 Unauthorized
```

### USER tries to create → 403
```bash
# First login as USER
USER_TOKEN=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"user123"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# USER can GET
curl http://localhost:8081/api/students \
  -H "Authorization: Bearer $USER_TOKEN"
# Expected: 200 OK ✅

# USER cannot POST
curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -d '{"name":"Test","email":"test@example.com","age":20}'
# Expected: 403 Forbidden ❌

# USER cannot DELETE
curl -X DELETE http://localhost:8081/api/students/1 \
  -H "Authorization: Bearer $USER_TOKEN"
# Expected: 403 Forbidden ❌
```

---

## Validation Tests

### Empty name → 400
```bash
curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"","email":"ravi@example.com","age":21}'

# Expected: 400 Bad Request
# {"status":400,"message":"Validation failed...","errors":{"name":"Name is required"}}
```

### Invalid email → 400
```bash
curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Ravi","email":"not-an-email","age":21}'

# Expected: 400 — {"errors":{"email":"Please provide a valid email address"}}
```

### Multiple validation errors at once → 400
```bash
curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"","email":"bad","age":-5}'

# Expected: 400 — all 3 errors at once
# {
#   "errors": {
#     "name": "Name is required",
#     "email": "Please provide a valid email address",
#     "age": "Age must be at least 1"
#   }
# }
```

### Duplicate email → 409
```bash
# Create student
curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Ravi","email":"ravi@example.com","age":21}'

# Try creating same email again
curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Another","email":"ravi@example.com","age":22}'

# Expected: 409 Conflict
# {"status":409,"message":"Email already exists: ravi@example.com"}
```

---

## Rate Limit Test

```bash
# Spam 12 requests with token — 11th gets 429
for i in {1..12}; do
  echo -n "Request $i: "
  curl -s -o /dev/null -w "%{http_code}\n" \
    http://localhost:8081/api/students \
    -H "Authorization: Bearer $TOKEN"
done

# Expected:
# Request 1: 200
# Request 2: 200
# ...
# Request 10: 200
# Request 11: 429  ← rate limit!
# Request 12: 429

# Wait 1 minute → tokens refill
sleep 60

# Now works again
curl -s -o /dev/null -w "After refill: %{http_code}\n" \
  http://localhost:8081/api/students \
  -H "Authorization: Bearer $TOKEN"
# After refill: 200
```

---

## Complete Test Flow — Run in Order

```bash
# 1. Register
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123","role":"ADMIN"}'

# 2. Login + save token
TOKEN=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# 3. Create 2 students
curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Ravi Kumar","email":"ravi@example.com","age":21}'

curl -X POST http://localhost:8081/api/students \
  -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Priya Sharma","email":"priya@example.com","age":22}'

# 4. Get all
curl http://localhost:8081/api/students -H "Authorization: Bearer $TOKEN"

# 5. Get by ID
curl http://localhost:8081/api/students/1 -H "Authorization: Bearer $TOKEN"

# 6. Update
curl -X PUT http://localhost:8081/api/students/1 \
  -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Ravi Updated","email":"ravi@example.com","age":25}'

# 7. Delete
curl -X DELETE http://localhost:8081/api/students/2 -H "Authorization: Bearer $TOKEN"

# 8. Confirm deleted
curl http://localhost:8081/api/students -H "Authorization: Bearer $TOKEN"
```
