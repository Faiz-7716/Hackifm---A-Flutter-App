# HackIFM Deployment Guide
## Frontend (Netlify) + Backend (Render)

## 🚀 Complete Step-by-Step Deployment

### PART 1: Deploy Backend to Render (Free)

#### Step 1.1: Push Code to GitHub
```bash
# Navigate to your project root
cd C:\Users\WELCOME\StudioProjects\Hackifm

# Initialize git if not already done
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial commit for deployment"

# Create repository on GitHub (https://github.com/new)
# Then link and push:
git remote add origin https://github.com/YOUR_USERNAME/hackifm-app.git
git branch -M main
git push -u origin main
```

#### Step 1.2: Sign Up for Render
1. Go to https://render.com
2. Click "Get Started for Free"
3. Sign up with GitHub account (recommended)
4. Authorize Render to access your repositories

#### Step 1.3: Create Web Service on Render
1. **Dashboard** → Click "New +" → Select "Web Service"

2. **Connect Repository**:
   - Click "Connect a repository"
   - Find your `hackifm-app` repository
   - Click "Connect"

3. **Configure Service**:
   - **Name**: `hackifm-backend`
   - **Region**: Choose closest to your users
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Runtime**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn app:app`

4. **Select Plan**:
   - Choose **Free** (scroll down to find it)

5. **Advanced Settings** (Click to expand):

   Add Environment Variables (click "+ Add Environment Variable"):
   ```
   FLASK_ENV=production
   SECRET_KEY=change-this-super-secret-key-12345
   JWT_SECRET_KEY=change-jwt-secret-key-67890
   ```

6. **Create Web Service**:
   - Click "Create Web Service" button
   - Wait 5-10 minutes for build and deployment
   - Note your service URL: `https://hackifm-backend.onrender.com`

#### Step 1.4: Test Backend
Once deployed, test it:
```bash
# Test health endpoint
curl https://YOUR-APP.onrender.com/api/test

# Or open in browser:
https://YOUR-APP.onrender.com
```

---

### PART 2: Update Flutter App with Backend URL

#### Step 2.1: Update API Service

Open `lib/services/api_service.dart` and change line 10:

**From:**
```dart
static const String baseUrl = 'http://127.0.0.1:5000';
```

**To:**
```dart
static const String baseUrl = 'https://YOUR-APP.onrender.com';
```
Replace `YOUR-APP` with your actual Render service name.

#### Step 2.2: Rebuild Flutter Web App
```bash
cd C:\Users\WELCOME\StudioProjects\Hackifm
flutter build web --release
```

---

### PART 3: Deploy Frontend to Netlify (Free)

#### Step 3.1: Prepare build/web Folder
Your Flutter build is already in `build/web/`

#### Step 3.2: Sign Up for Netlify
1. Go to https://netlify.com
2. Click "Sign up"
3. Sign up with GitHub (recommended)

#### Step 3.3: Deploy via Drag & Drop Method

**EASIEST METHOD:**

1. Go to https://app.netlify.com/drop
2. Drag the entire `build/web` folder into the drop zone
3. Wait for upload (1-2 minutes)
4. Your site is live! URL: `https://random-name.netlify.app`

**Optional - Customize Domain:**
- Click "Site settings" → "Change site name"
- Change to: `hackifm` → `https://hackifm.netlify.app`

#### Step 3.4: Alternative - Git-based Deployment

1. **New Site from Git**:
   - Dashboard → "Add new site" → "Import an existing project"
   - Choose GitHub
   - Select your `hackifm-app` repository
   - Authorize Netlify

2. **Build Settings**:
   - **Build command**: Leave empty (we'll upload pre-built files)
   - **Publish directory**: `build/web`
   - **Base directory**: Leave empty

3. **Deploy**:
   - Click "Deploy site"
   - Wait 2-3 minutes
   - Your site: `https://YOUR-SITE.netlify.app`

---

### PART 4: Final Configuration

#### Step 4.1: Configure CORS on Backend

Your Flask backend already has CORS enabled in `app.py`:
```python
CORS(app, resources={r"/api/*": {"origins": "*"}})
```

This allows your Netlify frontend to call the Render backend.

#### Step 4.2: Test Full Application

1. Open your Netlify URL: `https://your-site.netlify.app`
2. Try to sign up a new user
3. Try to log in
4. Navigate through the app

---

### 📋 Quick Reference

| Service | URL | Purpose |
|---------|-----|---------|
| Backend (Render) | `https://hackifm-backend.onrender.com` | Flask API |
| Frontend (Netlify) | `https://hackifm.netlify.app` | Flutter Web App |

### 🔧 Environment Variables (Render)

Required variables for your Render backend:
```
FLASK_ENV=production
SECRET_KEY=your-secret-key-here
JWT_SECRET_KEY=your-jwt-secret-here
```

Optional (for email features):
```
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_DEFAULT_SENDER=your-email@gmail.com
```

---

### ⚠️ Important Notes

**Render Free Tier Limitations:**
- Service spins down after 15 minutes of inactivity
- First request after wake-up takes ~30-50 seconds (cold start)
- 512 MB RAM
- 750 hours/month free

**Netlify Free Tier:**
- 100 GB bandwidth/month
- 300 build minutes/month
- Automatic HTTPS
- Global CDN

**Database Warning:**
- SQLite database on Render will be wiped on redeployment
- For production, upgrade to PostgreSQL (Render offers free tier)

---

### 🐛 Troubleshooting

**Backend not starting:**
1. Check Render logs: Dashboard → Your service → "Logs"
2. Verify all dependencies in `requirements.txt`
3. Check environment variables are set

**Frontend can't connect to backend:**
1. Verify backend URL in `api_service.dart`
2. Check browser console for CORS errors
3. Ensure backend is deployed and running

**Cold start delays:**
- Normal on free tier
- First request takes 30-50 seconds
- Subsequent requests are fast
- Consider a "wake-up" button on your frontend

**Build fails:**
1. Clear Flutter cache: `flutter clean`
2. Rebuild: `flutter build web --release`
3. Check for errors in terminal

---

### 🚀 You're Done!

Your app is now live:
- **Backend API**: https://your-backend.onrender.com
- **Web App**: https://your-app.netlify.app

Share the Netlify URL with users!

---

### 📱 Optional: Custom Domain

**Netlify:**
1. Site settings → Domain management → Add custom domain
2. Follow DNS configuration instructions

**Render:**
1. Settings → Custom Domains → Add custom domain
2. Update DNS CNAME record

---

### 💰 Upgrade Options

**If you need better performance:**

**Render:**
- Starter Plan: $7/month (no spin-down, faster response)
- PostgreSQL: Free tier available

**Netlify:**
- Pro Plan: $19/month (better bandwidth, build minutes)

---

### Need Help?

- Render Docs: https://render.com/docs
- Netlify Docs: https://docs.netlify.com
- Flutter Web Docs: https://docs.flutter.dev/platform-integration/web
