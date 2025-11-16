# QUICK START GUIDE - HackIFM Backend

## 🚀 Setup in 5 Minutes

### Step 1: Install Python Dependencies
```powershell
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### Step 2: Configure Environment
```powershell
# Copy example environment file
copy .env.example .env

# Edit .env file (optional - works with defaults for testing)
notepad .env
```

### Step 3: Run the Server
```powershell
python app.py
```

✅ Server running at: http://localhost:5000

### Step 4: Test the API
Open a NEW terminal (keep server running):
```powershell
cd backend
venv\Scripts\activate
python test_api.py
```

---

## 🔑 Default Credentials

### Admin Account
- Email: `admin@hackifm.com`
- Password: `Admin@123`
- Role: `admin`

### Test User (auto-created by test script)
- Email: `testuser@example.com`
- Password: `TestPass123!`
- Role: `user`

---

## 📡 API Endpoints Quick Reference

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/forgot-password` - Request OTP
- `POST /api/auth/reset-password` - Reset password with OTP
- `GET /api/auth/verify-token` - Verify JWT token
- `GET /api/auth/me` - Get current user

### Admin (Requires admin role)
- `GET /api/admin/dashboard` - Admin dashboard with stats

### System
- `GET /api/health` - Health check

---

## 🔐 Security Features Implemented

✅ **Password Hashing** - Bcrypt (never stores plain text)
✅ **JWT Tokens** - 24-hour expiry
✅ **Rate Limiting** - Prevents brute force
✅ **Email Validation** - Regex pattern matching
✅ **Strong Password** - 8+ chars, uppercase, lowercase, numbers, special chars
✅ **OTP System** - 6-digit code, 10-minute expiry
✅ **Role-Based Access** - Admin vs User separation
✅ **CORS Enabled** - Flutter app integration ready

---

## 🧪 Testing with cURL

### Signup
```bash
curl -X POST http://localhost:5000/api/auth/signup ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"John Doe\",\"email\":\"john@test.com\",\"password\":\"Test@123456\"}"
```

### Login
```bash
curl -X POST http://localhost:5000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"john@test.com\",\"password\":\"Test@123456\"}"
```

### Protected Route (replace TOKEN)
```bash
curl -X GET http://localhost:5000/api/auth/me ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 🔗 Flutter Integration

### 1. Add HTTP package
```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
```

### 2. Login Example (Flutter)
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('http://localhost:5000/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Store token securely
    await storage.write(key: 'jwt_token', value: data['token']);
    return data;
  } else {
    throw Exception('Login failed');
  }
}
```

### 3. Protected Request Example
```dart
Future<Map<String, dynamic>> getCurrentUser() async {
  final token = await storage.read(key: 'jwt_token');
  
  final response = await http.get(
    Uri.parse('http://localhost:5000/api/auth/me'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  return jsonDecode(response.body);
}
```

---

## 📦 Project Structure

```
backend/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── .env                   # Environment variables (create from .env.example)
├── .env.example          # Example environment file
├── .gitignore            # Git ignore rules
├── README.md             # Full documentation
├── SETUP.md              # This file
├── test_api.py           # API test script
└── hackifm.db            # SQLite database (auto-created)
```

---

## 🐛 Troubleshooting

### Port 5000 already in use
```powershell
# Find and kill process using port 5000
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### Virtual environment activation issues
```powershell
# If activation fails, use:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
venv\Scripts\activate
```

### Database issues
```powershell
# Delete and recreate database
del hackifm.db
python app.py
```

### Import errors
```powershell
# Reinstall dependencies
pip install --upgrade pip
pip install -r requirements.txt --force-reinstall
```

---

## 🚀 Production Deployment

### Option 1: Local Testing (Current Setup)
- SQLite database
- Flask development server
- Good for: Development and testing

### Option 2: Production Ready
```bash
# Install production server
pip install gunicorn

# Run with Gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### Option 3: Deploy to Cloud
- **Heroku**: Easy deployment with Procfile
- **Railway**: One-click deploy
- **DigitalOcean**: VPS deployment
- **AWS/Azure/GCP**: Enterprise-level

---

## 📞 Need Help?

1. Check server is running: http://localhost:5000/api/health
2. Check database file exists: `hackifm.db`
3. Check environment variables: `.env` file
4. Run test script: `python test_api.py`
5. Check logs in terminal

---

## ✅ What's Implemented

- [x] User Registration (Signup)
- [x] User Login (JWT)
- [x] Password Hashing (Bcrypt)
- [x] Forgot Password (OTP)
- [x] Reset Password
- [x] Token Verification
- [x] Role-Based Access (Admin/User)
- [x] Rate Limiting
- [x] Email Validation
- [x] Strong Password Validation
- [x] CORS Support
- [x] Health Check Endpoint
- [x] Error Handling
- [x] Database Models
- [x] API Documentation

---

**🎉 Your backend is ready to use!**
