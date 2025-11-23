# HackIFM Backend Deployment Guide

## Render.com Free Tier Deployment

### Prerequisites
- GitHub account
- Render.com account (free tier)

### Step 1: Push Backend Code to GitHub
1. Ensure your backend folder is in a Git repository
2. Push to GitHub:
```bash
cd backend
git add .
git commit -m "Prepare backend for Render deployment"
git push origin main
```

### Step 2: Deploy on Render

1. **Sign up/Login to Render**: https://render.com

2. **Create New Web Service**:
   - Click "New +" button → "Web Service"
   - Connect your GitHub repository
   - Select the repository containing your backend code

3. **Configure Service**:
   - **Name**: `hackifm-backend` (or your choice)
   - **Root Directory**: `backend` (if backend is in a subfolder)
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn app:app`
   - **Plan**: Select **Free** tier

4. **Environment Variables**:
   Click "Advanced" and add these environment variables:
   ```
   FLASK_ENV=production
   SECRET_KEY=your-super-secret-key-change-this-in-production
   JWT_SECRET_KEY=your-jwt-secret-key-change-this-too
   DATABASE_URL=sqlite:///hackifm.db
   MAIL_SERVER=smtp.gmail.com
   MAIL_PORT=587
   MAIL_USERNAME=your-email@gmail.com
   MAIL_PASSWORD=your-app-password
   MAIL_DEFAULT_SENDER=your-email@gmail.com
   ```

5. **Deploy**:
   - Click "Create Web Service"
   - Wait 5-10 minutes for deployment
   - Your backend URL will be: `https://hackifm-backend.onrender.com`

### Step 3: Test Backend

Test your deployed API:
```bash
curl https://your-app.onrender.com/api/test
```

### Step 4: Update Flutter App

Update `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-app.onrender.com';
```

### Important Notes

**Free Tier Limitations**:
- Service spins down after 15 minutes of inactivity
- First request after spin-down takes 30-50 seconds (cold start)
- 512 MB RAM limit
- 750 hours/month free

**Database**:
- SQLite database will reset on each deployment
- For persistent data, consider upgrading to PostgreSQL (Render provides free PostgreSQL database)

**CORS**:
- Already configured in `app.py` with `Flask-CORS`
- Frontend at any domain can access your API

### Troubleshooting

**Build Fails**:
- Check `requirements.txt` has all dependencies
- Verify Python version in `runtime.txt`

**Service Won't Start**:
- Check logs in Render dashboard
- Ensure `gunicorn` is in requirements.txt
- Verify `Procfile` or start command is correct

**Cold Starts**:
- Free tier services sleep after 15 min
- Use a ping service to keep warm (optional)
- Or accept the cold start delay

### Upgrade Options

For production use, consider:
- **PostgreSQL Database**: Free tier available on Render
- **Paid Plan**: Removes spin-down, better performance
- **CDN**: For static assets and images
