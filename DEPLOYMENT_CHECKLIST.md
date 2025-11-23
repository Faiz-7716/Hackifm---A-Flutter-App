# Deployment Checklist ✅

## Before You Start
- [ ] GitHub account created
- [ ] Render.com account created (sign up with GitHub)
- [ ] Netlify account created (sign up with GitHub)
- [ ] Code pushed to GitHub repository

---

## Backend Deployment (Render) - 15 minutes

### Step 1: Push to GitHub
- [ ] Open terminal in project folder
- [ ] Run: `git init` (if not already initialized)
- [ ] Run: `git add .`
- [ ] Run: `git commit -m "Prepare for deployment"`
- [ ] Create new repository on GitHub
- [ ] Run: `git remote add origin YOUR_GITHUB_URL`
- [ ] Run: `git push -u origin main`

### Step 2: Deploy on Render
- [ ] Login to https://render.com
- [ ] Click "New +" → "Web Service"
- [ ] Connect GitHub repository
- [ ] Select your repository
- [ ] Configure:
  - Name: `hackifm-backend`
  - Root Directory: `backend`
  - Build Command: `pip install -r requirements.txt`
  - Start Command: `gunicorn app:app`
  - Plan: **Free**
- [ ] Add Environment Variables:
  - `FLASK_ENV=production`
  - `SECRET_KEY=your-secret-key`
  - `JWT_SECRET_KEY=your-jwt-key`
- [ ] Click "Create Web Service"
- [ ] Wait 5-10 minutes for deployment
- [ ] Copy your backend URL (e.g., `https://hackifm-backend.onrender.com`)
- [ ] Test URL in browser - should see "HackIFM API is running"

---

## Update Flutter App - 5 minutes

### Step 3: Configure Backend URL
- [ ] Open `lib/services/api_service.dart`
- [ ] Change line 10 from:
  ```dart
  static const String baseUrl = 'http://127.0.0.1:5000';
  ```
  To:
  ```dart
  static const String baseUrl = 'https://YOUR-BACKEND.onrender.com';
  ```
- [ ] Save file

### Step 4: Rebuild Flutter Web
- [ ] Open terminal in project folder
- [ ] Run: `flutter clean`
- [ ] Run: `flutter build web --release`
- [ ] Wait 1-2 minutes for build to complete
- [ ] Verify `build/web` folder exists

---

## Frontend Deployment (Netlify) - 5 minutes

### Step 5: Deploy to Netlify (Drag & Drop)

**Easiest Method:**
- [ ] Open https://app.netlify.com/drop
- [ ] Drag the `build/web` folder onto the page
- [ ] Wait for upload (1-2 minutes)
- [ ] Copy your site URL (e.g., `https://random-name.netlify.app`)
- [ ] Click "Site settings" → "Change site name" (optional)
- [ ] Change to `hackifm` → URL becomes `https://hackifm.netlify.app`

**OR Git-based Method:**
- [ ] Go to Netlify dashboard
- [ ] Click "Add new site" → "Import an existing project"
- [ ] Choose GitHub → Select repository
- [ ] Build settings:
  - Build command: (leave empty)
  - Publish directory: `build/web`
- [ ] Click "Deploy site"
- [ ] Wait 2-3 minutes

---

## Testing - 5 minutes

### Step 6: Test Your Deployed App
- [ ] Open your Netlify URL in browser
- [ ] Try signup with test account
- [ ] Try login
- [ ] Navigate to different pages
- [ ] Check if data loads from backend
- [ ] Test on mobile browser (optional)

**Note:** First backend request may take 30-50 seconds (cold start on free tier)

---

## ✅ Deployment Complete!

Your app is now live at:
- **Frontend**: https://your-app.netlify.app
- **Backend**: https://your-backend.onrender.com

---

## Common Issues & Quick Fixes

**Backend won't start:**
- Check Render logs in dashboard
- Verify `gunicorn` is in `requirements.txt`
- Check environment variables are set correctly

**Frontend can't connect:**
- Verify backend URL in `api_service.dart`
- Check browser console (F12) for errors
- Ensure backend is running (visit backend URL)

**Build fails:**
- Run `flutter clean`
- Delete `build` folder
- Run `flutter pub get`
- Try build again

**Cold start delays:**
- Normal for free tier
- Wait 30-50 seconds on first request
- Consider adding a loading message

---

## Optional Enhancements

- [ ] Set up custom domain on Netlify
- [ ] Set up custom domain on Render
- [ ] Add PostgreSQL database on Render (free tier)
- [ ] Set up email service (Gmail SMTP)
- [ ] Configure GitHub Actions for auto-deployment
- [ ] Add monitoring/analytics

---

## Save Your URLs!

Write them down:
- **Frontend URL**: _______________________________
- **Backend URL**: _______________________________
- **GitHub Repo**: _______________________________

---

**Total Time**: ~30 minutes
**Cost**: $0 (both services have free tiers)

🎉 Congratulations! Your app is deployed and accessible worldwide!
