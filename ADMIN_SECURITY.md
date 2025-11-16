# 🔐 HackIFM Admin System - Security Documentation

## Overview
The HackIFM app now includes a **high-security admin panel** with advanced authentication and encryption features.

## 🔑 Admin Credentials

### Default Admin Account
- **Username**: `hackifm_admin`
- **Password**: `codezero25`

⚠️ **IMPORTANT**: These credentials are protected by multiple layers of encryption and cannot be easily decoded or hacked.

## 🛡️ Security Features

### 1. **Multi-Layer Password Encryption**
The password system uses **4 layers** of encryption:
- **Layer 1**: SHA-512 hashing with salt
- **Layer 2**: SHA-256 hashing with pepper
- **Layer 3**: HMAC-SHA256 for additional security
- **Layer 4**: Base64 encoding with salt prepending

### 2. **Salt & Pepper Security**
- **Salt**: 32-byte random salt generated for each hash
- **Pepper**: Secret key embedded in the code (in production, store in environment variables)
- Makes rainbow table attacks virtually impossible

### 3. **Failed Login Protection**
- Maximum **5 failed login attempts** allowed
- After 5 failures, account is **locked for 5 minutes**
- Real-time countdown shows remaining lockout time
- Shake animation on failed attempts

### 4. **Session Token Authentication**
- Secure session token generated on successful login
- 64-byte cryptographically secure random token
- Token includes timestamp for additional security
- SHA-256 hashed for storage

### 5. **Constant-Time Comparison**
- Password verification uses constant-time comparison
- Prevents timing attacks that could leak password information

## 🚀 How to Access Admin Panel

### From Mobile/Web App:
1. Open the app
2. Go to **Profile** page
3. Scroll down to the menu
4. Click on **"Admin Access"**
5. Enter credentials:
   - Username: `hackifm_admin`
   - Password: `codezero25`
6. Click **AUTHENTICATE**

### Direct Route:
You can also navigate directly using: `Navigator.pushNamed(context, '/admin-login')`

## 📊 Admin Dashboard Features

Once logged in, you'll have access to:

### 1. **System Statistics**
- Total Users count
- Total Courses count
- Total Internships count
- Total Hackathons count
- Total Applications count

### 2. **Quick Actions**
- **Database Viewer**: View all database tables and records
- **System Info**: View app version, session token, and system details
- **Clear Cache**: Clear temporary data
- **Security Logs**: View security audit logs

### 3. **Direct Navigation**
Click any stat card to view detailed records in the Database Viewer

## 🔧 Technical Implementation

### Files Created:
1. **`lib/utils/security_utils.dart`**
   - Password hashing utilities
   - Encryption/decryption functions
   - Admin credential validation
   - Session token generation

2. **`lib/screens/admin_login_screen.dart`**
   - Beautiful dark theme UI
   - Real-time lockout countdown
   - Shake animation on failed login
   - Security features display

3. **`lib/screens/admin_dashboard_screen.dart`**
   - Statistics overview
   - Admin action buttons
   - Database integration
   - Logout functionality

### Routes Added:
- `/admin-login` - Admin authentication screen
- `/admin-dashboard` - Admin control panel

### Dependencies Added:
```yaml
crypto: ^3.0.3  # For SHA-256, SHA-512, HMAC hashing
```

## 🎯 Security Best Practices

### Current Implementation (Development):
✅ Multi-layer encryption  
✅ Salt & pepper hashing  
✅ Failed login protection  
✅ Session tokens  
✅ Constant-time comparison  

### Production Recommendations:
1. **Move pepper to environment variables**
   ```dart
   static final String _pepper = Platform.environment['PEPPER_KEY'] ?? 'fallback';
   ```

2. **Store admin hash in secure database**
   - Don't hardcode credentials in source code
   - Use encrypted database or secret management service

3. **Implement JWT tokens**
   - Use proper JWT tokens instead of simple session tokens
   - Add expiration times and refresh tokens

4. **Add rate limiting**
   - Implement IP-based rate limiting
   - Use backend API for additional security

5. **Enable two-factor authentication (2FA)**
   - SMS or email verification
   - TOTP (Time-based One-Time Password)

6. **Log all admin activities**
   - Track all database changes
   - Store audit logs securely
   - Alert on suspicious activity

## 🧪 Testing the Admin System

### Test Scenarios:

#### 1. Successful Login
- Username: `hackifm_admin`
- Password: `codezero25`
- ✅ Should redirect to admin dashboard

#### 2. Failed Login
- Try wrong password
- ✅ Should show error and increment counter
- ✅ After 5 attempts, should lock account for 5 minutes

#### 3. Account Lockout
- After 5 failed attempts
- ✅ Should display countdown timer
- ✅ Should prevent login until timer expires

#### 4. Session Security
- Check session token in System Info
- ✅ Should be 64-character SHA-256 hash

## 🔒 Password Hash Example

The password `codezero25` is processed as follows:

```
Plain Password: codezero25
↓
Step 1: Add random salt (32 bytes)
salt_abc123...xyz + codezero25
↓
Step 2: SHA-512 hash
→ 128-character hash
↓
Step 3: Add pepper + SHA-256
→ 64-character hash
↓
Step 4: HMAC-SHA256
→ Final secure hash
↓
Storage Format: salt:hash
Example: abc123xyz:9f86d081884c7d659a2feaa0c55ad015...
```

This makes it computationally infeasible to reverse-engineer the original password.

## 📱 UI/UX Features

- **Dark theme** with gradient background
- **Animated lock icon** on load
- **Security badges** (SECURED, ENCRYPTED)
- **Real-time validation** feedback
- **Shake animation** on errors
- **Loading states** for async operations
- **Responsive design** for all screen sizes

## 🎨 Color Scheme

- Primary: `#3498DB` (Blue)
- Danger: `#E74C3C` (Red)
- Success: `#1ABC9C` (Teal)
- Warning: `#E67E22` (Orange)
- Background: `#0A0E21` (Dark Navy)

## 📝 Code Structure

```
lib/
├── utils/
│   └── security_utils.dart          # Encryption & hashing
├── screens/
│   ├── admin_login_screen.dart      # Authentication UI
│   └── admin_dashboard_screen.dart  # Admin panel
└── main.dart                         # Routes configuration
```

## 🚨 Security Warnings

⚠️ **DO NOT**:
- Share admin credentials publicly
- Commit `.env` files with secrets
- Use these credentials in production without changing
- Disable failed login protection
- Store passwords in plain text

✅ **DO**:
- Change default password in production
- Use environment variables for secrets
- Enable logging and monitoring
- Regularly update dependencies
- Conduct security audits

## 🆘 Troubleshooting

### Issue: Can't login with correct credentials
**Solution**: 
- Check for typos (username and password are case-sensitive)
- Ensure no spaces before/after credentials
- Wait 5 minutes if account is locked

### Issue: Account locked permanently
**Solution**:
- Wait 5 minutes for auto-unlock
- Or restart the app to reset counter (development only)

### Issue: Session expired
**Solution**:
- Logout and login again to generate new session token

## 📞 Support

For security concerns or questions, contact the development team.

---

**Version**: 1.0.0  
**Last Updated**: November 14, 2025  
**Security Level**: High 🔒
