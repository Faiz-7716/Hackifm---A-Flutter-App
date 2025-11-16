# HackIFM Backend API

Complete authentication backend for HackIFM Flutter app with role-based access control.

## 🚀 Features

- ✅ **Secure User Registration** with email validation and password strength checks
- ✅ **JWT Authentication** with 24-hour token expiry
- ✅ **Password Hashing** using Bcrypt (never stores plain text passwords)
- ✅ **Forgot Password** with OTP (6-digit) and token-based reset
- ✅ **Role-Based Access Control** (User/Admin separation)
- ✅ **Rate Limiting** to prevent brute force attacks
- ✅ **CORS enabled** for Flutter app integration
- ✅ **RESTful API** design

## 📋 Prerequisites

- Python 3.8 or higher
- pip (Python package manager)

## 🛠️ Installation

### 1. Clone the repository
```bash
cd backend
```

### 2. Create virtual environment
```bash
python -m venv venv
```

### 3. Activate virtual environment

**Windows:**
```bash
venv\Scripts\activate
```

**Mac/Linux:**
```bash
source venv/bin/activate
```

### 4. Install dependencies
```bash
pip install -r requirements.txt
```

### 5. Configure environment variables
```bash
# Copy the example file
copy .env.example .env

# Edit .env and set your own secret keys
```

**Generate secure secret keys:**
```python
import secrets
print(secrets.token_hex(32))  # For SECRET_KEY
print(secrets.token_hex(32))  # For JWT_SECRET_KEY
```

## 🚀 Running the Server

```bash
python app.py
```

Server will start at: `http://localhost:5000`

## 📚 API Endpoints

### Authentication Endpoints

#### 1. User Signup
```http
POST /api/auth/signup
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Account created successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user",
    "verified": false,
    "created_at": "2025-11-15T10:30:00"
  }
}
```

#### 2. User Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user",
    "verified": false
  }
}
```

#### 3. Forgot Password (Request OTP)
```http
POST /api/auth/forgot-password
Content-Type: application/json

{
  "email": "john@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "OTP sent to your email",
  "reset_token": "abc123...",
  "otp_for_testing": "123456"
}
```

#### 4. Reset Password
```http
POST /api/auth/reset-password
Content-Type: application/json

{
  "email": "john@example.com",
  "otp": "123456",
  "reset_token": "abc123...",
  "new_password": "NewSecurePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

### Protected Endpoints (Require JWT Token)

#### 5. Verify Token
```http
GET /api/auth/verify-token
Authorization: Bearer <your-jwt-token>
```

#### 6. Get Current User
```http
GET /api/auth/me
Authorization: Bearer <your-jwt-token>
```

### Admin Endpoints (Require Admin Role)

#### 7. Admin Dashboard
```http
GET /api/admin/dashboard
Authorization: Bearer <admin-jwt-token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Welcome to admin dashboard",
  "stats": {
    "total_users": 10,
    "admins": 1,
    "users": 9
  }
}
```

## 🔐 Security Features

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

### Rate Limiting
- Signup: 5 requests per hour
- Login: 10 requests per hour
- Forgot Password: 3 requests per hour
- Reset Password: 5 requests per hour

### JWT Token
- Expires after 24 hours
- Contains user ID, email, and role
- Signed with secret key

### OTP System
- 6-digit random code
- Expires after 10 minutes
- Single-use (invalidated after successful reset)

## 👤 Default Admin Account

**Email:** `admin@hackifm.com`  
**Password:** `Admin@123`  
**Role:** `admin`

⚠️ **CHANGE THIS PASSWORD IN PRODUCTION!**

## 🗄️ Database Schema

### Users Table
```sql
- id (Primary Key)
- name (String, 100)
- email (String, 120, Unique)
- password_hash (String, 255)
- role (String, 20) - 'user' or 'admin'
- verified (Boolean, default: False)
- created_at (DateTime)
- updated_at (DateTime)
```

### Password Resets Table
```sql
- id (Primary Key)
- email (String, 120)
- otp (String, 6)
- token (String, 100, Unique)
- expires_at (DateTime)
- used (Boolean, default: False)
- created_at (DateTime)
```

## 🔌 Integration with Flutter App

### 1. Store JWT Token
After successful login, store the token in secure storage:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'jwt_token', value: response['token']);
```

### 2. Send Token in Requests
```dart
final token = await storage.read(key: 'jwt_token');
final response = await http.get(
  Uri.parse('http://localhost:5000/api/auth/me'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

### 3. Check User Role
```dart
if (user['role'] == 'admin') {
  // Show admin dashboard
  Navigator.pushNamed(context, '/admin-home');
} else {
  // Show user dashboard
  Navigator.pushNamed(context, '/home');
}
```

## 📦 Required Flutter Packages

Add to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  provider: ^6.1.1  # For state management
```

## 🧪 Testing with Postman/cURL

### Test Signup
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"Test@123456"}'
```

### Test Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test@123456"}'
```

## 🚨 Production Deployment Checklist

- [ ] Change all secret keys in `.env`
- [ ] Set `FLASK_ENV=production`
- [ ] Set `FLASK_DEBUG=False`
- [ ] Use PostgreSQL/MySQL instead of SQLite
- [ ] Enable HTTPS
- [ ] Configure email service for OTP
- [ ] Remove `otp_for_testing` from forgot password response
- [ ] Set up proper CORS origins
- [ ] Use production-grade server (Gunicorn + Nginx)
- [ ] Set up database backups
- [ ] Configure firewall rules
- [ ] Monitor rate limits
- [ ] Set up logging

## 🔧 Environment Variables

Copy `.env.example` to `.env` and configure:

```env
SECRET_KEY=your-super-secret-key
JWT_SECRET_KEY=your-jwt-secret-key
DATABASE_URL=sqlite:///hackifm.db
FLASK_ENV=development
FLASK_DEBUG=True
```

## 📝 License

This project is part of the HackIFM Flutter App.

## 👥 Support

For issues or questions, contact the development team.

---

**Built with ❤️ for HackIFM**
