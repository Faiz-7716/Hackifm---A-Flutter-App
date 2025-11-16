from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_mail import Mail, Message
from datetime import datetime, timedelta
import re
import secrets
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)

# Configuration
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-change-in-production')
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///hackifm.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'jwt-secret-key-change-in-production')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)

# Email Configuration
app.config['MAIL_SERVER'] = os.getenv('MAIL_SERVER', 'smtp.gmail.com')
app.config['MAIL_PORT'] = int(os.getenv('MAIL_PORT', 587))
app.config['MAIL_USE_TLS'] = os.getenv('MAIL_USE_TLS', 'True') == 'True'
app.config['MAIL_USERNAME'] = os.getenv('MAIL_USERNAME')
app.config['MAIL_PASSWORD'] = os.getenv('MAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('MAIL_USERNAME')

# Initialize extensions
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
jwt = JWTManager(app)
mail = Mail(app)
CORS(app)

# Rate limiting
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://"
)

# ==================== MODELS ====================

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default='user', nullable=False)  # 'user' or 'admin'
    verified = db.Column(db.Boolean, default=False)
    phone = db.Column(db.String(20), nullable=True)
    bio = db.Column(db.Text, nullable=True)
    profile_picture = db.Column(db.String(500), nullable=True)
    resume_path = db.Column(db.String(500), nullable=True)
    two_factor_enabled = db.Column(db.Boolean, default=False)
    two_factor_secret = db.Column(db.String(100), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'role': self.role,
            'verified': self.verified,
            'phone': self.phone,
            'bio': self.bio,
            'profile_picture': self.profile_picture,
            'resume_path': self.resume_path,
            'two_factor_enabled': self.two_factor_enabled,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }


class PasswordReset(db.Model):
    __tablename__ = 'password_resets'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), nullable=False, index=True)
    otp = db.Column(db.String(6), nullable=False)
    token = db.Column(db.String(100), unique=True, nullable=False)
    expires_at = db.Column(db.DateTime, nullable=False)
    used = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


class SignupOTP(db.Model):
    __tablename__ = 'signup_otps'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), nullable=False, index=True)
    otp_hash = db.Column(db.String(255), nullable=False)  # Store hashed OTP
    expires_at = db.Column(db.DateTime, nullable=False)
    attempts = db.Column(db.Integer, default=0)  # Failed verification attempts
    verified = db.Column(db.Boolean, default=False)
    locked_until = db.Column(db.DateTime, nullable=True)  # Lock after 5 failed attempts
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Store user data temporarily until verification
    temp_name = db.Column(db.String(100))
    temp_password_hash = db.Column(db.String(255))


class OTPSendLog(db.Model):
    __tablename__ = 'otp_send_logs'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), nullable=False, index=True)
    sent_at = db.Column(db.DateTime, default=datetime.utcnow)
    ip_address = db.Column(db.String(45))


class LoginActivity(db.Model):
    __tablename__ = 'login_activities'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    device_model = db.Column(db.String(200))
    browser = db.Column(db.String(100))
    operating_system = db.Column(db.String(100))
    ip_address = db.Column(db.String(45))
    city = db.Column(db.String(100))
    country = db.Column(db.String(100))
    login_time = db.Column(db.DateTime, default=datetime.utcnow)
    logout_time = db.Column(db.DateTime, nullable=True)
    session_token = db.Column(db.String(100), unique=True)
    is_active = db.Column(db.Boolean, default=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'device_model': self.device_model,
            'browser': self.browser,
            'operating_system': self.operating_system,
            'ip_address': self.ip_address,
            'city': self.city,
            'country': self.country,
            'login_time': self.login_time.isoformat(),
            'logout_time': self.logout_time.isoformat() if self.logout_time else None,
            'is_active': self.is_active,
            'session_token': self.session_token
        }


class Application(db.Model):
    __tablename__ = 'applications'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    opportunity_type = db.Column(db.String(50), nullable=False)  # 'internship', 'course', 'hackathon', 'event'
    opportunity_id = db.Column(db.Integer, nullable=False)
    opportunity_title = db.Column(db.String(200), nullable=False)
    opportunity_company = db.Column(db.String(200))
    status = db.Column(db.String(50), default='pending')  # 'pending', 'accepted', 'rejected', 'withdrawn'
    applied_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'opportunity_type': self.opportunity_type,
            'opportunity_id': self.opportunity_id,
            'opportunity_title': self.opportunity_title,
            'opportunity_company': self.opportunity_company,
            'status': self.status,
            'applied_at': self.applied_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }


class SavedItem(db.Model):
    __tablename__ = 'saved_items'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    opportunity_type = db.Column(db.String(50), nullable=False)  # 'internship', 'course', 'hackathon', 'event'
    opportunity_id = db.Column(db.Integer, nullable=False)
    opportunity_title = db.Column(db.String(200), nullable=False)
    opportunity_company = db.Column(db.String(200))
    saved_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'opportunity_type': self.opportunity_type,
            'opportunity_id': self.opportunity_id,
            'opportunity_title': self.opportunity_title,
            'opportunity_company': self.opportunity_company,
            'saved_at': self.saved_at.isoformat()
        }


# ==================== HELPER FUNCTIONS ====================

def validate_email(email):
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None


def validate_password_strength(password):
    """
    Validate password strength:
    - At least 8 characters
    - Contains uppercase and lowercase
    - Contains numbers
    - Contains special characters
    """
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"
    
    if not re.search(r'[A-Z]', password):
        return False, "Password must contain at least one uppercase letter"
    
    if not re.search(r'[a-z]', password):
        return False, "Password must contain at least one lowercase letter"
    
    if not re.search(r'\d', password):
        return False, "Password must contain at least one number"
    
    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        return False, "Password must contain at least one special character"
    
    return True, "Password is strong"


def parse_user_agent(user_agent_string):
    """Parse user agent to extract browser, OS, and device info"""
    if not user_agent_string:
        return {
            'browser': 'Unknown',
            'operating_system': 'Unknown',
            'device_model': 'Unknown'
        }
    
    ua = user_agent_string.lower()
    
    # Detect browser
    if 'edg' in ua:
        browser = 'Edge'
    elif 'chrome' in ua:
        browser = 'Chrome'
    elif 'firefox' in ua:
        browser = 'Firefox'
    elif 'safari' in ua and 'chrome' not in ua:
        browser = 'Safari'
    elif 'opera' in ua or 'opr' in ua:
        browser = 'Opera'
    else:
        browser = 'Unknown'
    
    # Detect OS
    if 'windows' in ua:
        operating_system = 'Windows'
    elif 'mac os' in ua or 'macos' in ua:
        operating_system = 'macOS'
    elif 'linux' in ua:
        operating_system = 'Linux'
    elif 'android' in ua:
        operating_system = 'Android'
    elif 'ios' in ua or 'iphone' in ua or 'ipad' in ua:
        operating_system = 'iOS'
    else:
        operating_system = 'Unknown'
    
    # Detect device model
    if 'mobile' in ua or 'android' in ua or 'iphone' in ua:
        if 'iphone' in ua:
            device_model = 'iPhone'
        elif 'ipad' in ua:
            device_model = 'iPad'
        elif 'android' in ua:
            device_model = 'Android Device'
        else:
            device_model = 'Mobile Device'
    else:
        device_model = 'Desktop'
    
    return {
        'browser': browser,
        'operating_system': operating_system,
        'device_model': device_model
    }


def get_location_from_ip(ip_address):
    """Get approximate location from IP address using ipapi.co (free tier)"""
    try:
        if ip_address in ['127.0.0.1', 'localhost', '::1']:
            return {'city': 'Local', 'country': 'Local'}
        
        import requests
        response = requests.get(f'https://ipapi.co/{ip_address}/json/', timeout=3)
        if response.status_code == 200:
            data = response.json()
            return {
                'city': data.get('city', 'Unknown'),
                'country': data.get('country_name', 'Unknown')
            }
    except:
        pass
    
    return {'city': 'Unknown', 'country': 'Unknown'}


def generate_otp():
    """Generate 6-digit OTP"""
    return str(secrets.randbelow(900000) + 100000)


def generate_reset_token():
    """Generate secure reset token"""
    return secrets.token_urlsafe(32)


def send_signup_otp_email(name, email, otp):
    """Send OTP for signup email verification"""
    try:
        msg = Message(
            subject='HackIFM - Verify Your Email',
            recipients=[email]
        )
        
        msg.html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; background-color: #f5f5f5; padding: 20px; }}
                .container {{ max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
                .header {{ text-align: center; color: #E91E63; font-size: 28px; font-weight: bold; margin-bottom: 20px; }}
                .otp-box {{ background: linear-gradient(135deg, #E91E63, #F06292); color: white; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0; }}
                .otp {{ font-size: 36px; font-weight: bold; letter-spacing: 8px; }}
                .content {{ color: #333; line-height: 1.6; }}
                .footer {{ margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; text-align: center; }}
                .warning {{ background: #fff3cd; border-left: 4px solid #ffc107; padding: 10px; margin: 15px 0; color: #856404; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">🎓 Welcome to HackIFM!</div>
                
                <div class="content">
                    <p>Hi <strong>{name}</strong>,</p>
                    <p>Thank you for signing up! Please verify your email address using the OTP below:</p>
                </div>
                
                <div class="otp-box">
                    <p style="margin: 0; font-size: 14px;">Your Verification Code</p>
                    <div class="otp">{otp}</div>
                    <p style="margin: 0; font-size: 12px;">Valid for 10 minutes</p>
                </div>
                
                <div class="warning">
                    ⚠️ <strong>Security Notice:</strong> Never share this OTP with anyone. HackIFM will never ask for your OTP.
                </div>
                
                <div class="content">
                    <p>If you didn't create an account, please ignore this email.</p>
                </div>
                
                <div class="footer">
                    <p>© 2025 HackIFM - Ideas, Future, Mastery</p>
                    <p>This is an automated email, please do not reply.</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        mail.send(msg)
        print(f"✅ Signup OTP email sent successfully to {email}")
        return True
        
    except Exception as e:
        print(f"❌ Failed to send signup OTP email: {str(e)}")
        return False


def send_otp_email(name, email, otp):
    """Send OTP to user's email"""
    try:
        msg = Message(
            subject='HackIFM - Password Reset OTP',
            recipients=[email]
        )
        
        msg.html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; background-color: #f5f5f5; padding: 20px; }}
                .container {{ max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
                .header {{ text-align: center; color: #E91E63; font-size: 28px; font-weight: bold; margin-bottom: 20px; }}
                .otp-box {{ background: linear-gradient(135deg, #E91E63, #F06292); color: white; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0; }}
                .otp {{ font-size: 36px; font-weight: bold; letter-spacing: 8px; }}
                .content {{ color: #333; line-height: 1.6; }}
                .footer {{ margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; text-align: center; }}
                .warning {{ background: #fff3cd; border-left: 4px solid #ffc107; padding: 10px; margin: 15px 0; color: #856404; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">🔐 HackIFM Password Reset</div>
                
                <div class="content">
                    <p>Hi <strong>{name}</strong>,</p>
                    <p>You requested to reset your password. Use the OTP below to proceed:</p>
                </div>
                
                <div class="otp-box">
                    <p style="margin: 0; font-size: 14px;">Your OTP Code</p>
                    <div class="otp">{otp}</div>
                    <p style="margin: 0; font-size: 12px;">Valid for 10 minutes</p>
                </div>
                
                <div class="warning">
                    ⚠️ <strong>Security Notice:</strong> Never share this OTP with anyone. HackIFM will never ask for your OTP.
                </div>
                
                <div class="content">
                    <p>If you didn't request this password reset, please ignore this email and your password will remain unchanged.</p>
                </div>
                
                <div class="footer">
                    <p>© 2025 HackIFM - Ideas, Future, Mastery</p>
                    <p>This is an automated email, please do not reply.</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        mail.send(msg)
        print(f"✅ OTP email sent successfully to {email}")
        return True
        
    except Exception as e:
        print(f"❌ Failed to send OTP email to {email}: {str(e)}")
        raise e


# ==================== AUTHENTICATION ENDPOINTS ====================

# -------------------- NEW SIGNUP FLOW --------------------

@app.route('/api/auth/check-email', methods=['POST'])
@limiter.limit("10 per minute")
def check_email():
    """
    Check if email is already registered
    
    Request Body:
    {
        "email": "user@example.com"
    }
    """
    try:
        data = request.get_json()
        
        if 'email' not in data:
            return jsonify({
                'success': False,
                'message': 'Email is required'
            }), 400
        
        email = data['email'].strip().lower()
        
        # Validate email format
        if not validate_email(email):
            return jsonify({
                'success': False,
                'message': 'Invalid email format'
            }), 400
        
        # Check if user exists
        existing_user = User.query.filter_by(email=email).first()
        
        if existing_user:
            return jsonify({
                'success': False,
                'email_available': False,
                'message': 'This email is already registered. Try Login.'
            }), 200
        
        return jsonify({
            'success': True,
            'email_available': True,
            'message': 'Email is available'
        }), 200
        
    except Exception as e:
        print(f"❌ Error in check_email: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Server error occurred'
        }), 500


@app.route('/api/auth/send-signup-otp', methods=['POST'])
@limiter.limit("3 per hour")  # Max 3 OTPs per email per hour
def send_signup_otp():
    """
    Send OTP for email verification during signup
    
    Request Body:
    {
        "name": "John Doe",
        "email": "user@example.com"
    }
    """
    try:
        data = request.get_json()
        
        if not all(k in data for k in ['name', 'email']):
            return jsonify({
                'success': False,
                'message': 'Name and email are required'
            }), 400
        
        name = data['name'].strip()
        email = data['email'].strip().lower()
        
        # Validate email
        if not validate_email(email):
            return jsonify({
                'success': False,
                'message': 'Invalid email format'
            }), 400
        
        # Check if email already registered
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            return jsonify({
                'success': False,
                'message': 'Email already registered'
            }), 409
        
        # Rate limiting: Check OTP send logs (max 3 per hour)
        one_hour_ago = datetime.utcnow() - timedelta(hours=1)
        recent_otps = OTPSendLog.query.filter(
            OTPSendLog.email == email,
            OTPSendLog.sent_at > one_hour_ago
        ).count()
        
        if recent_otps >= 3:
            return jsonify({
                'success': False,
                'message': 'Too many OTP requests. Please try again after 1 hour.'
            }), 429
        
        # Generate OTP
        otp = generate_otp()
        otp_hash = bcrypt.generate_password_hash(otp).decode('utf-8')
        
        # Delete any existing OTP for this email
        SignupOTP.query.filter_by(email=email).delete()
        
        # Create new OTP record
        signup_otp = SignupOTP(
            email=email,
            otp_hash=otp_hash,
            expires_at=datetime.utcnow() + timedelta(minutes=10),
            temp_name=name
        )
        
        db.session.add(signup_otp)
        
        # Log OTP send
        ip_address = request.remote_addr or 'unknown'
        log_entry = OTPSendLog(email=email, ip_address=ip_address)
        db.session.add(log_entry)
        
        db.session.commit()
        
        # Send OTP email
        email_sent = send_signup_otp_email(name, email, otp)
        
        if not email_sent:
            return jsonify({
                'success': False,
                'message': 'Failed to send OTP email. Please try again.'
            }), 500
        
        return jsonify({
            'success': True,
            'message': 'OTP sent to your email',
            'expires_in': 600  # 10 minutes in seconds
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ Error in send_signup_otp: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Server error occurred'
        }), 500


@app.route('/api/auth/verify-signup-otp', methods=['POST'])
@limiter.limit("10 per minute")
def verify_signup_otp():
    """
    Verify OTP for signup
    
    Request Body:
    {
        "email": "user@example.com",
        "otp": "123456"
    }
    """
    try:
        data = request.get_json()
        
        if not all(k in data for k in ['email', 'otp']):
            return jsonify({
                'success': False,
                'message': 'Email and OTP are required'
            }), 400
        
        email = data['email'].strip().lower()
        otp = data['otp'].strip()
        
        # Find OTP record
        otp_record = SignupOTP.query.filter_by(email=email).first()
        
        if not otp_record:
            return jsonify({
                'success': False,
                'message': 'No OTP found. Please request a new one.'
            }), 404
        
        # Check if OTP is locked (5 failed attempts)
        if otp_record.locked_until and otp_record.locked_until > datetime.utcnow():
            remaining = int((otp_record.locked_until - datetime.utcnow()).total_seconds() / 60)
            return jsonify({
                'success': False,
                'message': f'Too many failed attempts. Try again in {remaining} minutes.',
                'locked': True
            }), 429
        
        # Check if OTP expired
        if otp_record.expires_at < datetime.utcnow():
            return jsonify({
                'success': False,
                'message': 'OTP has expired. Please request a new one.',
                'expired': True
            }), 400
        
        # Check if already verified
        if otp_record.verified:
            return jsonify({
                'success': True,
                'message': 'Email already verified. Please set your password.',
                'verified': True
            }), 200
        
        # Verify OTP
        if not bcrypt.check_password_hash(otp_record.otp_hash, otp):
            # Increment failed attempts
            otp_record.attempts += 1
            
            # Lock after 5 failed attempts
            if otp_record.attempts >= 5:
                otp_record.locked_until = datetime.utcnow() + timedelta(minutes=15)
                db.session.commit()
                return jsonify({
                    'success': False,
                    'message': 'Too many failed attempts. OTP locked for 15 minutes.',
                    'locked': True,
                    'attempts_remaining': 0
                }), 429
            
            db.session.commit()
            attempts_remaining = 5 - otp_record.attempts
            return jsonify({
                'success': False,
                'message': f'Invalid OTP. {attempts_remaining} attempts remaining.',
                'attempts_remaining': attempts_remaining
            }), 400
        
        # OTP is valid - mark as verified
        otp_record.verified = True
        otp_record.attempts = 0
        db.session.commit()
        
        print(f"✅ OTP verified successfully for {email}. Verified status: {otp_record.verified}")
        
        return jsonify({
            'success': True,
            'message': 'Email verified successfully',
            'verified': True
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ Error in verify_signup_otp: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Server error occurred'
        }), 500


@app.route('/api/auth/complete-signup', methods=['POST'])
@limiter.limit("5 per hour")
def complete_signup():
    """
    Complete signup after email verification
    
    Request Body:
    {
        "email": "user@example.com",
        "password": "SecurePass123!"
    }
    """
    try:
        data = request.get_json()
        
        if not all(k in data for k in ['email', 'password']):
            return jsonify({
                'success': False,
                'message': 'Email and password are required'
            }), 400
        
        email = data['email'].strip().lower()
        password = data['password']
        
        print(f"🔍 Complete signup request for email: {email}")
        
        # Find OTP record for this email (with fresh query)
        db.session.expire_all()  # Clear session cache
        otp_record = SignupOTP.query.filter_by(email=email).first()
        
        if not otp_record:
            print(f"❌ No OTP record found for {email}")
            return jsonify({
                'success': False,
                'message': 'No verification record found. Please start signup again.'
            }), 400
        
        print(f"✅ OTP record found. Verified: {otp_record.verified}, Expires: {otp_record.expires_at}")
        
        # Check if verified
        if not otp_record.verified:
            print(f"❌ OTP not verified for {email}")
            return jsonify({
                'success': False,
                'message': 'Email not verified. Please verify your email first.'
            }), 400
        
        # Check if OTP expired
        if otp_record.expires_at < datetime.utcnow():
            print(f"❌ OTP expired for {email}")
            db.session.delete(otp_record)
            db.session.commit()
            return jsonify({
                'success': False,
                'message': 'Verification expired. Please start signup again.'
            }), 400
        
        # Check if user already exists
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            return jsonify({
                'success': False,
                'message': 'Email already registered'
            }), 409
        
        # Validate password strength
        is_strong, message = validate_password_strength(password)
        if not is_strong:
            return jsonify({
                'success': False,
                'message': message
            }), 400
        
        # Hash password
        password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
        
        # Create new user
        new_user = User(
            name=otp_record.temp_name,
            email=email,
            password_hash=password_hash,
            role='user',
            verified=True  # Email already verified
        )
        
        db.session.add(new_user)
        
        # Delete OTP record
        db.session.delete(otp_record)
        
        db.session.commit()
        
        # Generate JWT token
        token = create_access_token(identity=new_user.id)
        
        return jsonify({
            'success': True,
            'message': 'Account created successfully',
            'token': token,
            'user': new_user.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ Error in complete_signup: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Server error occurred'
        }), 500


# -------------------- OLD SIGNUP ENDPOINT (Keep for backward compatibility) --------------------

@app.route('/api/auth/signup', methods=['POST'])
@limiter.limit("5 per hour")
def signup():
    """
    User Registration Endpoint
    
    Request Body:
    {
        "name": "John Doe",
        "email": "john@example.com",
        "password": "SecurePass123!"
    }
    """
    try:
        data = request.get_json()
        
        # Validate required fields
        if not all(k in data for k in ['name', 'email', 'password']):
            return jsonify({
                'success': False,
                'message': 'Missing required fields: name, email, password'
            }), 400
        
        name = data['name'].strip()
        email = data['email'].strip().lower()
        password = data['password']
        
        # Validate name
        if len(name) < 2:
            return jsonify({
                'success': False,
                'message': 'Name must be at least 2 characters long'
            }), 400
        
        # Validate email format
        if not validate_email(email):
            return jsonify({
                'success': False,
                'message': 'Invalid email format'
            }), 400
        
        # Check if user already exists
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            return jsonify({
                'success': False,
                'message': 'Email already registered'
            }), 409
        
        # Validate password strength
        is_strong, message = validate_password_strength(password)
        if not is_strong:
            return jsonify({
                'success': False,
                'message': message
            }), 400
        
        # Hash password
        password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
        
        # Create new user
        new_user = User(
            name=name,
            email=email,
            password_hash=password_hash,
            role='user'  # Default role
        )
        
        db.session.add(new_user)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Account created successfully',
            'user': new_user.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error creating account: {str(e)}'
        }), 500


@app.route('/api/auth/login', methods=['POST'])
@limiter.limit("10 per hour")
def login():
    """
    User Login Endpoint
    
    Request Body:
    {
        "email": "john@example.com",
        "password": "SecurePass123!"
    }
    """
    try:
        data = request.get_json()
        
        # Validate required fields
        if not all(k in data for k in ['email', 'password']):
            return jsonify({
                'success': False,
                'message': 'Missing required fields: email, password'
            }), 400
        
        email = data['email'].strip().lower()
        password = data['password']
        
        # Find user by email
        user = User.query.filter_by(email=email).first()
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'Invalid email or password'
            }), 401
        
        # Verify password
        if not bcrypt.check_password_hash(user.password_hash, password):
            return jsonify({
                'success': False,
                'message': 'Invalid email or password'
            }), 401
        
        # Generate JWT token with session tracking
        session_token = secrets.token_urlsafe(32)
        access_token = create_access_token(
            identity=user.id,
            additional_claims={
                'email': user.email,
                'role': user.role,
                'session': session_token
            }
        )
        
        # Capture device and location information
        user_agent_string = request.headers.get('User-Agent', '')
        ip_address = request.headers.get('X-Forwarded-For', request.remote_addr)
        if ip_address and ',' in ip_address:
            ip_address = ip_address.split(',')[0].strip()
        
        device_info = parse_user_agent(user_agent_string)
        location_info = get_location_from_ip(ip_address)
        
        # Store login activity
        login_activity = LoginActivity(
            user_id=user.id,
            device_model=device_info['device_model'],
            browser=device_info['browser'],
            operating_system=device_info['operating_system'],
            ip_address=ip_address,
            city=location_info['city'],
            country=location_info['country'],
            session_token=session_token,
            is_active=True
        )
        db.session.add(login_activity)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Login successful',
            'token': access_token,
            'user': {
                'id': user.id,
                'name': user.name,
                'email': user.email,
                'role': user.role,
                'verified': user.verified
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error during login: {str(e)}'
        }), 500


@app.route('/api/auth/forgot-password', methods=['POST'])
@limiter.limit("3 per hour")
def forgot_password():
    """
    Forgot Password Request Endpoint
    
    Request Body:
    {
        "email": "john@example.com"
    }
    """
    try:
        data = request.get_json()
        
        if 'email' not in data:
            return jsonify({
                'success': False,
                'message': 'Email is required'
            }), 400
        
        email = data['email'].strip().lower()
        
        # Check if user exists
        user = User.query.filter_by(email=email).first()
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found with this email'
            }), 404
        
        # Generate OTP and reset token
        otp = generate_otp()
        reset_token = generate_reset_token()
        expires_at = datetime.utcnow() + timedelta(minutes=10)
        
        # Invalidate any existing reset requests for this email
        PasswordReset.query.filter_by(email=email, used=False).update({'used': True})
        
        # Create new password reset entry
        password_reset = PasswordReset(
            email=email,
            otp=otp,
            token=reset_token,
            expires_at=expires_at
        )
        
        db.session.add(password_reset)
        db.session.commit()
        
        # Send OTP via email
        try:
            send_otp_email(user.name, email, otp)
        except Exception as e:
            print(f"Email send error: {e}")
            # Continue anyway - return OTP for testing if email fails
            return jsonify({
                'success': True,
                'message': 'OTP generated (email service unavailable)',
                'reset_token': reset_token,
                'otp': otp  # For testing when email is not configured
            }), 200
        
        return jsonify({
            'success': True,
            'message': 'OTP sent to your email',
            'reset_token': reset_token
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error processing request: {str(e)}'
        }), 500


@app.route('/api/auth/reset-password', methods=['POST'])
@limiter.limit("5 per hour")
def reset_password():
    """
    Reset Password Endpoint
    
    Request Body:
    {
        "email": "john@example.com",
        "otp": "123456",
        "reset_token": "token_here",
        "new_password": "NewSecurePass123!"
    }
    """
    try:
        data = request.get_json()
        
        # Validate required fields
        if not all(k in data for k in ['email', 'otp', 'reset_token', 'new_password']):
            return jsonify({
                'success': False,
                'message': 'Missing required fields'
            }), 400
        
        email = data['email'].strip().lower()
        otp = data['otp']
        reset_token = data['reset_token']
        new_password = data['new_password']
        
        # Find valid reset request
        reset_request = PasswordReset.query.filter_by(
            email=email,
            otp=otp,
            token=reset_token,
            used=False
        ).first()
        
        if not reset_request:
            return jsonify({
                'success': False,
                'message': 'Invalid or expired reset request'
            }), 400
        
        # Check if expired
        if datetime.utcnow() > reset_request.expires_at:
            reset_request.used = True
            db.session.commit()
            return jsonify({
                'success': False,
                'message': 'OTP has expired'
            }), 400
        
        # Validate new password strength
        is_strong, message = validate_password_strength(new_password)
        if not is_strong:
            return jsonify({
                'success': False,
                'message': message
            }), 400
        
        # Find user
        user = User.query.filter_by(email=email).first()
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        # Hash new password
        new_password_hash = bcrypt.generate_password_hash(new_password).decode('utf-8')
        
        # Update password
        user.password_hash = new_password_hash
        user.updated_at = datetime.utcnow()
        
        # Mark reset request as used
        reset_request.used = True
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Password reset successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error resetting password: {str(e)}'
        }), 500


# ==================== PROTECTED ROUTES ====================

@app.route('/api/auth/verify-token', methods=['GET'])
@jwt_required()
def verify_token():
    """Verify if JWT token is valid"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        return jsonify({
            'success': True,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Invalid token: {str(e)}'
        }), 401


@app.route('/api/auth/me', methods=['GET'])
@jwt_required()
def get_current_user():
    """Get current user details"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        return jsonify({
            'success': True,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/auth/login-activity', methods=['GET'])
@jwt_required()
def get_login_activity():
    """
    Get user's login activity history (last 10 logins)
    """
    try:
        current_user_id = get_jwt_identity()
        
        # Get last 10 login activities for the current user
        activities = LoginActivity.query.filter_by(
            user_id=current_user_id
        ).order_by(
            LoginActivity.login_time.desc()
        ).limit(10).all()
        
        return jsonify({
            'success': True,
            'activities': [activity.to_dict() for activity in activities]
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/auth/logout-all', methods=['POST'])
@jwt_required()
def logout_all_devices():
    """
    Logout from all devices by deactivating all sessions
    """
    try:
        current_user_id = get_jwt_identity()
        
        # Deactivate all active sessions except current one
        from flask_jwt_extended import get_jwt
        current_jwt = get_jwt()
        current_session = current_jwt.get('session')
        
        if current_session:
            # Deactivate all sessions except current
            LoginActivity.query.filter_by(
                user_id=current_user_id,
                is_active=True
            ).filter(
                LoginActivity.session_token != current_session
            ).update({'is_active': False})
        else:
            # Deactivate all sessions
            LoginActivity.query.filter_by(
                user_id=current_user_id,
                is_active=True
            ).update({'is_active': False})
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Logged out from all other devices successfully'
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


# ==================== ROLE-BASED ACCESS ====================

def admin_required():
    """Decorator to check if user is admin"""
    def wrapper(fn):
        @jwt_required()
        def decorator(*args, **kwargs):
            current_user_id = get_jwt_identity()
            user = User.query.get(current_user_id)
            
            if not user or user.role != 'admin':
                return jsonify({
                    'success': False,
                    'message': 'Admin access required'
                }), 403
            
            return fn(*args, **kwargs)
        return decorator
    return wrapper


@app.route('/api/admin/dashboard', methods=['GET'])
@jwt_required()
def admin_dashboard():
    """Admin dashboard - requires admin role"""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if not user or user.role != 'admin':
        return jsonify({
            'success': False,
            'message': 'Admin access required'
        }), 403
    
    # Get statistics
    total_users = User.query.count()
    admin_count = User.query.filter_by(role='admin').count()
    user_count = User.query.filter_by(role='user').count()
    
    return jsonify({
        'success': True,
        'message': 'Welcome to admin dashboard',
        'stats': {
            'total_users': total_users,
            'admins': admin_count,
            'users': user_count
        }
    }), 200


# ==================== PROFILE MANAGEMENT ====================

@app.route('/api/profile/update', methods=['PUT'])
@jwt_required()
def update_profile():
    """
    Update user profile information
    
    Request Body:
    {
        "name": "John Doe",
        "phone": "+1234567890",
        "bio": "Software developer passionate about AI"
    }
    """
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        data = request.get_json()
        
        # Update allowed fields
        if 'name' in data and data['name']:
            user.name = data['name'].strip()
        
        if 'phone' in data:
            user.phone = data['phone'].strip() if data['phone'] else None
        
        if 'bio' in data:
            user.bio = data['bio'].strip() if data['bio'] else None
        
        user.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error updating profile: {str(e)}'
        }), 500


@app.route('/api/profile/change-password', methods=['POST'])
@jwt_required()
def change_password():
    """
    Change user password
    
    Request Body:
    {
        "current_password": "OldPass123!",
        "new_password": "NewPass456!"
    }
    """
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        data = request.get_json()
        
        if not all(k in data for k in ['current_password', 'new_password']):
            return jsonify({
                'success': False,
                'message': 'Missing required fields'
            }), 400
        
        # Verify current password
        if not bcrypt.check_password_hash(user.password_hash, data['current_password']):
            return jsonify({
                'success': False,
                'message': 'Current password is incorrect'
            }), 401
        
        # Validate new password strength
        is_strong, message = validate_password_strength(data['new_password'])
        if not is_strong:
            return jsonify({
                'success': False,
                'message': message
            }), 400
        
        # Update password
        user.password_hash = bcrypt.generate_password_hash(data['new_password']).decode('utf-8')
        user.updated_at = datetime.utcnow()
        
        # Deactivate all other sessions for security
        LoginActivity.query.filter_by(
            user_id=user.id,
            is_active=True
        ).update({'is_active': False})
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Password changed successfully. Please login again on other devices.'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error changing password: {str(e)}'
        }), 500


@app.route('/api/profile/upload-resume', methods=['POST'])
@jwt_required()
def upload_resume():
    """
    Upload user resume (accepts file upload or base64 string)
    
    For now, this stores the file path/URL
    In production, integrate with cloud storage (AWS S3, Google Cloud Storage, etc.)
    """
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        # Check if file is uploaded or base64 provided
        if 'resume_url' in request.json:
            # Direct URL/path provided
            user.resume_path = request.json['resume_url']
        elif 'file' in request.files:
            # File upload handling (to be implemented with storage service)
            file = request.files['file']
            if file.filename:
                # TODO: Upload to cloud storage and get URL
                # For now, just store a placeholder path
                user.resume_path = f'/uploads/resumes/{current_user_id}_{file.filename}'
        else:
            return jsonify({
                'success': False,
                'message': 'No resume file or URL provided'
            }), 400
        
        user.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Resume uploaded successfully',
            'resume_path': user.resume_path
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error uploading resume: {str(e)}'
        }), 500


@app.route('/api/profile/resume', methods=['GET', 'DELETE'])
@jwt_required()
def manage_resume():
    """Get or delete resume"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        if request.method == 'GET':
            if not user.resume_path:
                return jsonify({
                    'success': False,
                    'message': 'No resume uploaded'
                }), 404
            
            return jsonify({
                'success': True,
                'resume_path': user.resume_path
            }), 200
        
        elif request.method == 'DELETE':
            if not user.resume_path:
                return jsonify({
                    'success': False,
                    'message': 'No resume to delete'
                }), 404
            
            # TODO: Delete file from cloud storage
            user.resume_path = None
            user.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Resume deleted successfully'
            }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/profile/two-factor', methods=['POST'])
@jwt_required()
def toggle_two_factor():
    """
    Enable or disable two-factor authentication
    
    Request Body:
    {
        "enabled": true/false
    }
    """
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        data = request.get_json()
        
        if 'enabled' not in data:
            return jsonify({
                'success': False,
                'message': 'Missing enabled field'
            }), 400
        
        enabled = data['enabled']
        
        if enabled:
            # Enable 2FA - generate secret
            user.two_factor_enabled = True
            user.two_factor_secret = secrets.token_urlsafe(32)
            message = 'Two-factor authentication enabled'
        else:
            # Disable 2FA
            user.two_factor_enabled = False
            user.two_factor_secret = None
            message = 'Two-factor authentication disabled'
        
        user.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': message,
            'two_factor_enabled': user.two_factor_enabled
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


# ==================== APPLICATIONS ====================

@app.route('/api/applications', methods=['GET', 'POST'])
@jwt_required()
def manage_applications():
    """Get user applications or create new application"""
    try:
        current_user_id = get_jwt_identity()
        
        if request.method == 'GET':
            # Get all applications for current user
            applications = Application.query.filter_by(
                user_id=current_user_id
            ).order_by(Application.applied_at.desc()).all()
            
            return jsonify({
                'success': True,
                'applications': [app.to_dict() for app in applications]
            }), 200
        
        elif request.method == 'POST':
            # Create new application
            data = request.get_json()
            
            required_fields = ['opportunity_type', 'opportunity_id', 'opportunity_title']
            if not all(k in data for k in required_fields):
                return jsonify({
                    'success': False,
                    'message': 'Missing required fields'
                }), 400
            
            # Check if already applied
            existing = Application.query.filter_by(
                user_id=current_user_id,
                opportunity_type=data['opportunity_type'],
                opportunity_id=data['opportunity_id']
            ).first()
            
            if existing:
                return jsonify({
                    'success': False,
                    'message': 'You have already applied to this opportunity'
                }), 400
            
            application = Application(
                user_id=current_user_id,
                opportunity_type=data['opportunity_type'],
                opportunity_id=data['opportunity_id'],
                opportunity_title=data['opportunity_title'],
                opportunity_company=data.get('opportunity_company'),
                status='pending'
            )
            
            db.session.add(application)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Application submitted successfully',
                'application': application.to_dict()
            }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/applications/<int:application_id>', methods=['DELETE'])
@jwt_required()
def withdraw_application(application_id):
    """Withdraw an application"""
    try:
        current_user_id = get_jwt_identity()
        
        application = Application.query.filter_by(
            id=application_id,
            user_id=current_user_id
        ).first()
        
        if not application:
            return jsonify({
                'success': False,
                'message': 'Application not found'
            }), 404
        
        application.status = 'withdrawn'
        application.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Application withdrawn successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


# ==================== SAVED ITEMS ====================

@app.route('/api/saved-items', methods=['GET', 'POST'])
@jwt_required()
def manage_saved_items():
    """Get saved items or add new saved item"""
    try:
        current_user_id = get_jwt_identity()
        
        if request.method == 'GET':
            # Get all saved items for current user
            saved_items = SavedItem.query.filter_by(
                user_id=current_user_id
            ).order_by(SavedItem.saved_at.desc()).all()
            
            return jsonify({
                'success': True,
                'saved_items': [item.to_dict() for item in saved_items]
            }), 200
        
        elif request.method == 'POST':
            # Add new saved item
            data = request.get_json()
            
            required_fields = ['opportunity_type', 'opportunity_id', 'opportunity_title']
            if not all(k in data for k in required_fields):
                return jsonify({
                    'success': False,
                    'message': 'Missing required fields'
                }), 400
            
            # Check if already saved
            existing = SavedItem.query.filter_by(
                user_id=current_user_id,
                opportunity_type=data['opportunity_type'],
                opportunity_id=data['opportunity_id']
            ).first()
            
            if existing:
                return jsonify({
                    'success': False,
                    'message': 'Item already saved'
                }), 400
            
            saved_item = SavedItem(
                user_id=current_user_id,
                opportunity_type=data['opportunity_type'],
                opportunity_id=data['opportunity_id'],
                opportunity_title=data['opportunity_title'],
                opportunity_company=data.get('opportunity_company')
            )
            
            db.session.add(saved_item)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Item saved successfully',
                'saved_item': saved_item.to_dict()
            }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/saved-items/<int:item_id>', methods=['DELETE'])
@jwt_required()
def remove_saved_item(item_id):
    """Remove a saved item"""
    try:
        current_user_id = get_jwt_identity()
        
        saved_item = SavedItem.query.filter_by(
            id=item_id,
            user_id=current_user_id
        ).first()
        
        if not saved_item:
            return jsonify({
                'success': False,
                'message': 'Saved item not found'
            }), 404
        
        db.session.delete(saved_item)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Item removed from saved list'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


# ==================== SESSION MANAGEMENT ====================

@app.route('/api/sessions/active', methods=['GET'])
@jwt_required()
def get_active_sessions():
    """Get all active sessions for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        sessions = LoginActivity.query.filter_by(
            user_id=current_user_id,
            is_active=True
        ).order_by(LoginActivity.login_time.desc()).all()
        
        # Mark current session
        from flask_jwt_extended import get_jwt
        current_jwt = get_jwt()
        current_session_token = current_jwt.get('session')
        
        sessions_data = []
        for session in sessions:
            session_dict = session.to_dict()
            session_dict['is_current'] = session.session_token == current_session_token
            sessions_data.append(session_dict)
        
        return jsonify({
            'success': True,
            'sessions': sessions_data
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/sessions/<int:session_id>/revoke', methods=['POST'])
@jwt_required()
def revoke_session(session_id):
    """Revoke a specific session"""
    try:
        current_user_id = get_jwt_identity()
        
        session = LoginActivity.query.filter_by(
            id=session_id,
            user_id=current_user_id
        ).first()
        
        if not session:
            return jsonify({
                'success': False,
                'message': 'Session not found'
            }), 404
        
        session.is_active = False
        session.logout_time = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Session revoked successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/sessions/revoke-all', methods=['POST'])
@jwt_required()
def revoke_all_sessions():
    """Revoke all sessions except current one"""
    try:
        current_user_id = get_jwt_identity()
        
        from flask_jwt_extended import get_jwt
        current_jwt = get_jwt()
        current_session_token = current_jwt.get('session')
        
        # Deactivate all sessions except current
        sessions = LoginActivity.query.filter_by(
            user_id=current_user_id,
            is_active=True
        ).filter(
            LoginActivity.session_token != current_session_token
        ).all()
        
        for session in sessions:
            session.is_active = False
            session.logout_time = datetime.utcnow()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f'{len(sessions)} session(s) revoked successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


# ==================== HEALTH CHECK ====================

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'success': True,
        'message': 'HackIFM Backend API is running',
        'timestamp': datetime.utcnow().isoformat()
    }), 200


# ==================== ERROR HANDLERS ====================

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'message': 'Endpoint not found'
    }), 404


@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return jsonify({
        'success': False,
        'message': 'Internal server error'
    }), 500


# ==================== DATABASE INITIALIZATION ====================

def create_tables():
    """Create database tables"""
    with app.app_context():
        db.create_all()
        
        # Create default admin if not exists
        admin = User.query.filter_by(email='admin@hackifm.com').first()
        if not admin:
            admin_password_hash = bcrypt.generate_password_hash('Admin@123').decode('utf-8')
            admin_user = User(
                name='HackIFM Admin',
                email='admin@hackifm.com',
                password_hash=admin_password_hash,
                role='admin',
                verified=True
            )
            db.session.add(admin_user)
            db.session.commit()
            print("Default admin created: admin@hackifm.com / Admin@123")


# ==================== RUN APP ====================

if __name__ == '__main__':
    create_tables()
    app.run(debug=True, host='0.0.0.0', port=5000)
