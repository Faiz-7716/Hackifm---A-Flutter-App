# 📧 Email Configuration Guide for HackIFM Backend

## Using Gmail SMTP

### Step 1: Enable 2-Step Verification
1. Go to your Google Account: https://myaccount.google.com/
2. Click **Security** in the left menu
3. Under "Signing in to Google," select **2-Step Verification**
4. Follow the steps to enable it

### Step 2: Generate App Password
1. After enabling 2-Step Verification, go back to **Security**
2. Under "Signing in to Google," select **App passwords**
3. Select app: Choose **Mail**
4. Select device: Choose **Other (Custom name)** and type "HackIFM Backend"
5. Click **Generate**
6. Copy the 16-character password (e.g., `abcd efgh ijkl mnop`)

### Step 3: Update .env File
Edit `backend/.env` and add your credentials:

```env
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=abcd efgh ijkl mnop
```

**Note:** Remove spaces from the app password or keep them - both work.

## Testing Email

Run the backend server:
```bash
cd backend
pip install Flask-Mail
python app.py
```

Test forgot password endpoint:
```bash
curl -X POST http://localhost:5000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

## Security Tips

✅ **DO:**
- Use App Passwords (not your main Gmail password)
- Keep your `.env` file in `.gitignore`
- Use environment variables in production

❌ **DON'T:**
- Commit `.env` file to git
- Share your app password
- Use your main Gmail password

## Alternative Email Services

### SendGrid (Recommended for Production)
```env
MAIL_SERVER=smtp.sendgrid.net
MAIL_PORT=587
MAIL_USERNAME=apikey
MAIL_PASSWORD=your-sendgrid-api-key
```

### Outlook/Hotmail
```env
MAIL_SERVER=smtp-mail.outlook.com
MAIL_PORT=587
MAIL_USERNAME=your-email@outlook.com
MAIL_PASSWORD=your-password
```

## Troubleshooting

### "SMTPAuthenticationError"
- Make sure 2-Step Verification is enabled
- Generate a new App Password
- Check if MAIL_USERNAME and MAIL_PASSWORD are correct

### "Connection refused"
- Check if MAIL_PORT is 587
- Ensure MAIL_USE_TLS is True
- Check firewall settings

### Email not received
- Check spam/junk folder
- Verify recipient email exists in database
- Check terminal logs for email send confirmation
