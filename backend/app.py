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


class Internship(db.Model):
    __tablename__ = 'internships'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    company = db.Column(db.String(200), nullable=False)
    company_logo = db.Column(db.String(500))  # Company logo URL
    company_description = db.Column(db.Text)  # Company info
    description = db.Column(db.Text)
    
    # Job Details
    work_type = db.Column(db.String(20))  # 'Remote', 'Hybrid', 'Onsite'
    internship_type = db.Column(db.String(50))  # 'Full-time', 'Part-time', 'Project-based', 'Research'
    is_paid = db.Column(db.Boolean, default=False)
    stipend_type = db.Column(db.String(50))  # 'Fixed', 'Performance-based', 'Unpaid'
    stipend_min = db.Column(db.Integer)
    stipend_max = db.Column(db.Integer)
    duration = db.Column(db.String(50))
    location = db.Column(db.String(200))
    category = db.Column(db.String(100))
    
    # Skills & Experience
    skills_required = db.Column(db.Text)  # JSON array of skills
    experience_level = db.Column(db.String(20))  # 'Beginner', 'Intermediate', 'Advanced'
    tools_technologies = db.Column(db.Text)  # JSON array of tools
    
    # Eligibility
    eligibility = db.Column(db.Text)  # JSON: students_only, graduates_allowed, degree_required, branch_specific
    
    # Job Description
    responsibilities = db.Column(db.Text)  # What intern will do
    what_you_will_learn = db.Column(db.Text)  # Learning outcomes
    
    # Application Details
    application_deadline = db.Column(db.DateTime)
    apply_link = db.Column(db.String(500))  # Direct application URL
    apply_through_platform = db.Column(db.Boolean, default=True)  # Apply through HackIFM or external
    
    # Analytics
    views_count = db.Column(db.Integer, default=0)  # Impressions
    clicks_count = db.Column(db.Integer, default=0)  # Total clicks on card
    applied_count = db.Column(db.Integer, default=0)  # Applications through platform
    
    # Admin/Status
    status = db.Column(db.String(20), default='pending')  # 'pending', 'approved', 'rejected'
    is_active = db.Column(db.Boolean, default=True)  # Admin can deactivate
    submitted_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'company': self.company,
            'company_logo': self.company_logo,
            'company_description': self.company_description,
            'description': self.description,
            'work_type': self.work_type,
            'internship_type': self.internship_type,
            'is_paid': self.is_paid,
            'stipend_type': self.stipend_type,
            'stipend_min': self.stipend_min,
            'stipend_max': self.stipend_max,
            'duration': self.duration,
            'location': self.location,
            'category': self.category,
            'skills_required': self.skills_required,
            'experience_level': self.experience_level,
            'tools_technologies': self.tools_technologies,
            'eligibility': self.eligibility,
            'responsibilities': self.responsibilities,
            'what_you_will_learn': self.what_you_will_learn,
            'application_deadline': self.application_deadline.isoformat() if self.application_deadline else None,
            'apply_link': self.apply_link,
            'apply_through_platform': self.apply_through_platform,
            'views_count': self.views_count,
            'clicks_count': self.clicks_count,
            'applied_count': self.applied_count,
            'status': self.status,
            'is_active': self.is_active,
            'submitted_by': self.submitted_by,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }


class Course(db.Model):
    __tablename__ = 'courses'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    platform = db.Column(db.String(100))  # 'Udemy', 'Scaler', 'FreeCodeCamp', etc.
    instructor = db.Column(db.String(200))
    description = db.Column(db.Text)
    course_link = db.Column(db.String(500))  # External course URL
    thumbnail = db.Column(db.String(500))  # Course thumbnail/image URL
    what_you_will_learn = db.Column(db.Text)  # JSON array of learning points
    duration = db.Column(db.String(50))  # "30 hours", "6 weeks"
    level = db.Column(db.String(20))  # 'Beginner', 'Intermediate', 'Advanced'
    category = db.Column(db.String(100))  # 'Web Dev', 'Data Science', 'AI', etc.
    is_paid = db.Column(db.Boolean, default=False)
    price = db.Column(db.Float)
    
    # Metrics
    views_count = db.Column(db.Integer, default=0)  # Impressions - card shown
    enrolled_count = db.Column(db.Integer, default=0)  # Applied - clicked "Start Learning"
    rating = db.Column(db.Float, default=0.0)
    
    # Admin/Status
    status = db.Column(db.String(20), default='approved')  # Admin adds directly = approved
    submitted_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'platform': self.platform,
            'instructor': self.instructor,
            'description': self.description,
            'course_link': self.course_link,
            'thumbnail': self.thumbnail,
            'what_you_will_learn': self.what_you_will_learn,
            'duration': self.duration,
            'level': self.level,
            'category': self.category,
            'is_paid': self.is_paid,
            'price': self.price,
            'views_count': self.views_count,
            'enrolled_count': self.enrolled_count,
            'rating': self.rating,
            'status': self.status,
            'submitted_by': self.submitted_by,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }


class Event(db.Model):
    __tablename__ = 'events'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    organizer = db.Column(db.String(200))
    description = db.Column(db.Text)
    event_type = db.Column(db.String(20))  # 'Online', 'Offline', 'Hybrid'
    category = db.Column(db.String(100))  # 'Hackathon', 'Workshop', 'Conference', etc.
    start_date = db.Column(db.DateTime)
    end_date = db.Column(db.DateTime)
    location = db.Column(db.String(200))
    registration_deadline = db.Column(db.DateTime)
    max_participants = db.Column(db.Integer)
    current_participants = db.Column(db.Integer, default=0)
    views_count = db.Column(db.Integer, default=0)
    prize_pool = db.Column(db.String(100))
    status = db.Column(db.String(20), default='pending')
    submitted_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'organizer': self.organizer,
            'description': self.description,
            'event_type': self.event_type,
            'category': self.category,
            'start_date': self.start_date.isoformat() if self.start_date else None,
            'end_date': self.end_date.isoformat() if self.end_date else None,
            'location': self.location,
            'registration_deadline': self.registration_deadline.isoformat() if self.registration_deadline else None,
            'max_participants': self.max_participants,
            'current_participants': self.current_participants,
            'views_count': self.views_count,
            'prize_pool': self.prize_pool,
            'status': self.status,
            'submitted_by': self.submitted_by,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }


class Notification(db.Model):
    __tablename__ = 'notifications'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    title = db.Column(db.String(200), nullable=False)
    message = db.Column(db.Text, nullable=False)
    type = db.Column(db.String(50))  # 'approval', 'completion', 'reminder', 'submission', 'report', 'error'
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'title': self.title,
            'message': self.message,
            'type': self.type,
            'is_read': self.is_read,
            'created_at': self.created_at.isoformat()
        }


class ViewHistory(db.Model):
    __tablename__ = 'view_history'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    opportunity_type = db.Column(db.String(50), nullable=False)
    opportunity_id = db.Column(db.Integer, nullable=False)
    viewed_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'opportunity_type': self.opportunity_type,
            'opportunity_id': self.opportunity_id,
            'viewed_at': self.viewed_at.isoformat()
        }


class ReportedContent(db.Model):
    __tablename__ = 'reported_content'
    
    id = db.Column(db.Integer, primary_key=True)
    reported_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    content_type = db.Column(db.String(50), nullable=False)  # 'internship', 'course', 'event'
    content_id = db.Column(db.Integer, nullable=False)
    reason = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), default='pending')  # 'pending', 'reviewed', 'resolved'
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    reviewed_at = db.Column(db.DateTime)
    reviewed_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    
    def to_dict(self):
        return {
            'id': self.id,
            'reported_by': self.reported_by,
            'content_type': self.content_type,
            'content_id': self.content_id,
            'reason': self.reason,
            'status': self.status,
            'created_at': self.created_at.isoformat(),
            'reviewed_at': self.reviewed_at.isoformat() if self.reviewed_at else None
        }


class UserPreferences(db.Model):
    __tablename__ = 'user_preferences'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, unique=True)
    dark_mode = db.Column(db.Boolean, default=False)
    notification_enabled = db.Column(db.Boolean, default=True)
    email_notifications = db.Column(db.Boolean, default=True)
    interests = db.Column(db.Text)  # JSON string
    preferred_locations = db.Column(db.Text)  # JSON string
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'dark_mode': self.dark_mode,
            'notification_enabled': self.notification_enabled,
            'email_notifications': self.email_notifications,
            'interests': self.interests,
            'preferred_locations': self.preferred_locations,
            'updated_at': self.updated_at.isoformat()
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


def admin_required():
    """Decorator to require admin role"""
    from functools import wraps
    def decorator(f):
        @wraps(f)
        @jwt_required()
        def decorated_function(*args, **kwargs):
            current_user_id = get_jwt_identity()
            user = User.query.get(current_user_id)
            
            if not user or user.role != 'admin':
                return jsonify({
                    'success': False,
                    'message': 'Admin access required'
                }), 403
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator


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
        token = create_access_token(identity=str(new_user.id))
        
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
            identity=str(user.id),
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
        user = User.query.get(int(current_user_id))
        
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

# ==================== INTERNSHIP APIs ====================

@app.route('/api/internships', methods=['GET', 'POST'])
def manage_internships():
    """Get all internships or create new (user submission)"""
    try:
        if request.method == 'GET':
            # Get filters from query params
            work_type = request.args.get('work_type')
            is_paid = request.args.get('is_paid')
            duration = request.args.get('duration')
            stipend_min = request.args.get('stipend_min', type=int)
            stipend_max = request.args.get('stipend_max', type=int)
            skills = request.args.get('skills')
            company = request.args.get('company')
            date_posted = request.args.get('date_posted')  # '24h', '7d', '30d'
            status = request.args.get('status', 'approved')
            
            query = Internship.query
            
            # Apply filters
            if status:
                query = query.filter_by(status=status)
            if work_type:
                query = query.filter_by(work_type=work_type)
            if is_paid is not None:
                query = query.filter_by(is_paid=is_paid.lower() == 'true')
            if duration:
                query = query.filter_by(duration=duration)
            if stipend_min is not None:
                query = query.filter(Internship.stipend_min >= stipend_min)
            if stipend_max is not None:
                query = query.filter(Internship.stipend_max <= stipend_max)
            if company:
                query = query.filter(Internship.company.ilike(f'%{company}%'))
            if skills:
                query = query.filter(Internship.skills_required.ilike(f'%{skills}%'))
            
            # Date filter
            if date_posted:
                now = datetime.utcnow()
                if date_posted == '24h':
                    cutoff = now - timedelta(hours=24)
                elif date_posted == '7d':
                    cutoff = now - timedelta(days=7)
                elif date_posted == '30d':
                    cutoff = now - timedelta(days=30)
                else:
                    cutoff = now - timedelta(days=30)
                query = query.filter(Internship.created_at >= cutoff)
            
            internships = query.order_by(Internship.created_at.desc()).all()
            
            return jsonify({
                'success': True,
                'internships': [i.to_dict() for i in internships]
            }), 200
        
        elif request.method == 'POST':
            # User submission
            data = request.get_json()
            
            new_internship = Internship(
                title=data.get('title'),
                company=data.get('company'),
                description=data.get('description'),
                work_type=data.get('work_type'),
                is_paid=data.get('is_paid', False),
                stipend_min=data.get('stipend_min'),
                stipend_max=data.get('stipend_max'),
                duration=data.get('duration'),
                skills_required=data.get('skills_required'),
                location=data.get('location'),
                category=data.get('category'),
                status='pending',
                submitted_by=data.get('user_id')
            )
            
            db.session.add(new_internship)
            db.session.commit()
            
            # Notify admins
            admins = User.query.filter_by(role='admin').all()
            for admin in admins:
                notification = Notification(
                    user_id=admin.id,
                    title='New Internship Submission',
                    message=f'New internship "{new_internship.title}" submitted for review',
                    type='submission'
                )
                db.session.add(notification)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Internship submitted for review',
                'internship': new_internship.to_dict()
            }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/internships/<int:id>', methods=['GET', 'PUT', 'DELETE'])
def internship_detail(id):
    """Get, update, or delete specific internship"""
    try:
        internship = Internship.query.get_or_404(id)
        
        if request.method == 'GET':
            # Increment view count
            internship.views_count += 1
            db.session.commit()
            
            # Track view history if user is logged in
            auth_header = request.headers.get('Authorization')
            if auth_header:
                try:
                    from flask_jwt_extended import decode_token
                    token = auth_header.split(' ')[1]
                    decoded = decode_token(token)
                    user_id = decoded['sub']
                    
                    view_history = ViewHistory(
                        user_id=user_id,
                        opportunity_type='internship',
                        opportunity_id=id
                    )
                    db.session.add(view_history)
                    db.session.commit()
                except:
                    pass
            
            return jsonify({
                'success': True,
                'internship': internship.to_dict()
            }), 200
        
        elif request.method == 'PUT':
            # Update internship (admin only)
            data = request.get_json()
            
            for key, value in data.items():
                if hasattr(internship, key):
                    setattr(internship, key, value)
            
            internship.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Internship updated successfully',
                'internship': internship.to_dict()
            }), 200
        
        elif request.method == 'DELETE':
            # Delete internship (admin only)
            db.session.delete(internship)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Internship deleted successfully'
            }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/internships/<int:id>/apply', methods=['POST'])
@jwt_required()
def apply_internship(id):
    """Apply to internship"""
    try:
        current_user_id = get_jwt_identity()
        internship = Internship.query.get_or_404(id)
        
        # Check if already applied
        existing = Application.query.filter_by(
            user_id=current_user_id,
            opportunity_type='internship',
            opportunity_id=id
        ).first()
        
        if existing:
            return jsonify({
                'success': False,
                'message': 'Already applied to this internship'
            }), 400
        
        # Create application
        application = Application(
            user_id=current_user_id,
            opportunity_type='internship',
            opportunity_id=id,
            opportunity_title=internship.title,
            opportunity_company=internship.company,
            status='pending'
        )
        
        # Increment applied count
        internship.applied_count += 1
        
        db.session.add(application)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Application submitted successfully',
            'application': application.to_dict()
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/internships/<int:id>/report', methods=['POST'])
@jwt_required()
def report_internship(id):
    """Report an internship"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        report = ReportedContent(
            reported_by=current_user_id,
            content_type='internship',
            content_id=id,
            reason=data.get('reason', '')
        )
        
        db.session.add(report)
        db.session.commit()
        
        # Notify admins
        admins = User.query.filter_by(role='admin').all()
        for admin in admins:
            notification = Notification(
                user_id=admin.id,
                title='Content Reported',
                message=f'Internship ID {id} has been reported',
                type='report'
            )
            db.session.add(notification)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Report submitted successfully'
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# ==================== COURSE APIs ====================

@app.route('/api/courses', methods=['GET', 'POST'])
def manage_courses():
    """Get all courses or create new"""
    try:
        if request.method == 'GET':
            level = request.args.get('level')
            is_paid = request.args.get('is_paid')
            category = request.args.get('category')
            status = request.args.get('status', 'approved')
            
            query = Course.query
            
            if status:
                query = query.filter_by(status=status)
            if level:
                query = query.filter_by(level=level)
            if is_paid is not None:
                query = query.filter_by(is_paid=is_paid.lower() == 'true')
            if category:
                query = query.filter_by(category=category)
            
            courses = query.order_by(Course.rating.desc()).all()
            
            return jsonify({
                'success': True,
                'courses': [c.to_dict() for c in courses]
            }), 200
        
        elif request.method == 'POST':
            data = request.get_json()
            
            new_course = Course(
                title=data.get('title'),
                instructor=data.get('instructor'),
                description=data.get('description'),
                duration=data.get('duration'),
                level=data.get('level'),
                is_paid=data.get('is_paid', False),
                price=data.get('price'),
                category=data.get('category'),
                status='pending',
                submitted_by=data.get('user_id')
            )
            
            db.session.add(new_course)
            db.session.commit()
            
            # Notify admins
            admins = User.query.filter_by(role='admin').all()
            for admin in admins:
                notification = Notification(
                    user_id=admin.id,
                    title='New Course Submission',
                    message=f'New course "{new_course.title}" submitted for review',
                    type='submission'
                )
                db.session.add(notification)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Course submitted for review',
                'course': new_course.to_dict()
            }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/courses/<int:id>', methods=['GET', 'PUT', 'DELETE'])
def course_detail(id):
    """Get, update, or delete specific course"""
    try:
        course = Course.query.get_or_404(id)
        
        if request.method == 'GET':
            course.views_count += 1
            db.session.commit()
            
            # Track view history
            auth_header = request.headers.get('Authorization')
            if auth_header:
                try:
                    from flask_jwt_extended import decode_token
                    token = auth_header.split(' ')[1]
                    decoded = decode_token(token)
                    user_id = decoded['sub']
                    
                    view_history = ViewHistory(
                        user_id=user_id,
                        opportunity_type='course',
                        opportunity_id=id
                    )
                    db.session.add(view_history)
                    db.session.commit()
                except:
                    pass
            
            return jsonify({
                'success': True,
                'course': course.to_dict()
            }), 200
        
        elif request.method == 'PUT':
            data = request.get_json()
            
            for key, value in data.items():
                if hasattr(course, key):
                    setattr(course, key, value)
            
            course.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Course updated successfully',
                'course': course.to_dict()
            }), 200
        
        elif request.method == 'DELETE':
            db.session.delete(course)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Course deleted successfully'
            }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# ==================== EVENT APIs ====================

@app.route('/api/events', methods=['GET', 'POST'])
def manage_events():
    """Get all events or create new"""
    try:
        if request.method == 'GET':
            event_type = request.args.get('event_type')
            category = request.args.get('category')
            status = request.args.get('status', 'approved')
            
            query = Event.query
            
            if status:
                query = query.filter_by(status=status)
            if event_type:
                query = query.filter_by(event_type=event_type)
            if category:
                query = query.filter_by(category=category)
            
            events = query.order_by(Event.start_date.desc()).all()
            
            return jsonify({
                'success': True,
                'events': [e.to_dict() for e in events]
            }), 200
        
        elif request.method == 'POST':
            data = request.get_json()
            
            new_event = Event(
                title=data.get('title'),
                organizer=data.get('organizer'),
                description=data.get('description'),
                event_type=data.get('event_type'),
                category=data.get('category'),
                start_date=datetime.fromisoformat(data.get('start_date')) if data.get('start_date') else None,
                end_date=datetime.fromisoformat(data.get('end_date')) if data.get('end_date') else None,
                location=data.get('location'),
                registration_deadline=datetime.fromisoformat(data.get('registration_deadline')) if data.get('registration_deadline') else None,
                max_participants=data.get('max_participants'),
                prize_pool=data.get('prize_pool'),
                status='pending',
                submitted_by=data.get('user_id')
            )
            
            db.session.add(new_event)
            db.session.commit()
            
            # Notify admins
            admins = User.query.filter_by(role='admin').all()
            for admin in admins:
                notification = Notification(
                    user_id=admin.id,
                    title='New Event Submission',
                    message=f'New event "{new_event.title}" submitted for review',
                    type='submission'
                )
                db.session.add(notification)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Event submitted for review',
                'event': new_event.to_dict()
            }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/events/<int:id>', methods=['GET', 'PUT', 'DELETE'])
def event_detail(id):
    """Get, update, or delete specific event"""
    try:
        event = Event.query.get_or_404(id)
        
        if request.method == 'GET':
            event.views_count += 1
            db.session.commit()
            
            # Track view history
            auth_header = request.headers.get('Authorization')
            if auth_header:
                try:
                    from flask_jwt_extended import decode_token
                    token = auth_header.split(' ')[1]
                    decoded = decode_token(token)
                    user_id = decoded['sub']
                    
                    view_history = ViewHistory(
                        user_id=user_id,
                        opportunity_type='event',
                        opportunity_id=id
                    )
                    db.session.add(view_history)
                    db.session.commit()
                except:
                    pass
            
            return jsonify({
                'success': True,
                'event': event.to_dict()
            }), 200
        
        elif request.method == 'PUT':
            data = request.get_json()
            
            for key, value in data.items():
                if hasattr(event, key) and key not in ['start_date', 'end_date', 'registration_deadline']:
                    setattr(event, key, value)
            
            if 'start_date' in data:
                event.start_date = datetime.fromisoformat(data['start_date'])
            if 'end_date' in data:
                event.end_date = datetime.fromisoformat(data['end_date'])
            if 'registration_deadline' in data:
                event.registration_deadline = datetime.fromisoformat(data['registration_deadline'])
            
            event.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Event updated successfully',
                'event': event.to_dict()
            }), 200
        
        elif request.method == 'DELETE':
            db.session.delete(event)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Event deleted successfully'
            }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# ==================== NOTIFICATION APIs ====================

@app.route('/api/notifications', methods=['GET'])
@jwt_required()
def get_notifications():
    """Get user notifications"""
    try:
        current_user_id = get_jwt_identity()
        limit = request.args.get('limit', 50, type=int)
        
        notifications = Notification.query.filter_by(
            user_id=current_user_id
        ).order_by(Notification.created_at.desc()).limit(limit).all()
        
        return jsonify({
            'success': True,
            'notifications': [n.to_dict() for n in notifications]
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/notifications/<int:id>/read', methods=['PUT'])
@jwt_required()
def mark_notification_read(id):
    """Mark notification as read"""
    try:
        current_user_id = get_jwt_identity()
        notification = Notification.query.get_or_404(id)
        
        if notification.user_id != current_user_id:
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        notification.is_read = True
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Notification marked as read'
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# ==================== RECOMMENDATIONS & TRENDING ====================

@app.route('/api/recommendations', methods=['GET'])
@jwt_required()
def get_recommendations():
    """Get personalized recommendations based on user activity"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get user's view history
        recent_views = ViewHistory.query.filter_by(
            user_id=current_user_id
        ).order_by(ViewHistory.viewed_at.desc()).limit(20).all()
        
        # Get user's applications
        applications = Application.query.filter_by(
            user_id=current_user_id
        ).all()
        
        # Simple recommendation: get similar categories/types
        recommendations = {
            'internships': [],
            'courses': [],
            'events': []
        }
        
        # Get trending internships (high views + applications)
        trending_internships = Internship.query.filter_by(
            status='approved'
        ).order_by(
            (Internship.views_count + Internship.applied_count * 2).desc()
        ).limit(10).all()
        
        recommendations['internships'] = [i.to_dict() for i in trending_internships]
        
        # Get top-rated courses
        trending_courses = Course.query.filter_by(
            status='approved'
        ).order_by(Course.rating.desc()).limit(10).all()
        
        recommendations['courses'] = [c.to_dict() for c in trending_courses]
        
        # Get upcoming events
        upcoming_events = Event.query.filter_by(
            status='approved'
        ).filter(
            Event.start_date >= datetime.utcnow()
        ).order_by(Event.start_date.asc()).limit(10).all()
        
        recommendations['events'] = [e.to_dict() for e in upcoming_events]
        
        return jsonify({
            'success': True,
            'recommendations': recommendations
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/recently-viewed', methods=['GET'])
@jwt_required()
def get_recently_viewed():
    """Get user's recently viewed items"""
    try:
        current_user_id = get_jwt_identity()
        limit = request.args.get('limit', 10, type=int)
        
        recent_views = ViewHistory.query.filter_by(
            user_id=current_user_id
        ).order_by(ViewHistory.viewed_at.desc()).limit(limit).all()
        
        items = []
        for view in recent_views:
            item_data = view.to_dict()
            
            # Fetch actual item details
            if view.opportunity_type == 'internship':
                item = Internship.query.get(view.opportunity_id)
                if item:
                    item_data['details'] = item.to_dict()
            elif view.opportunity_type == 'course':
                item = Course.query.get(view.opportunity_id)
                if item:
                    item_data['details'] = item.to_dict()
            elif view.opportunity_type == 'event':
                item = Event.query.get(view.opportunity_id)
                if item:
                    item_data['details'] = item.to_dict()
            
            items.append(item_data)
        
        return jsonify({
            'success': True,
            'recently_viewed': items
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/trending', methods=['GET'])
def get_trending():
    """Get trending opportunities (daily/weekly)"""
    try:
        period = request.args.get('period', 'weekly')  # 'daily' or 'weekly'
        
        now = datetime.utcnow()
        if period == 'daily':
            cutoff = now - timedelta(days=1)
        else:
            cutoff = now - timedelta(days=7)
        
        # Trending internships
        trending_internships = Internship.query.filter_by(
            status='approved'
        ).filter(
            Internship.created_at >= cutoff
        ).order_by(
            (Internship.views_count + Internship.applied_count * 3).desc()
        ).limit(10).all()
        
        # Trending courses
        trending_courses = Course.query.filter_by(
            status='approved'
        ).filter(
            Course.created_at >= cutoff
        ).order_by(
            (Course.views_count + Course.enrolled_count * 2).desc()
        ).limit(10).all()
        
        # Trending events
        trending_events = Event.query.filter_by(
            status='approved'
        ).filter(
            Event.created_at >= cutoff
        ).order_by(
            (Event.views_count + Event.current_participants * 2).desc()
        ).limit(10).all()
        
        return jsonify({
            'success': True,
            'period': period,
            'trending': {
                'internships': [i.to_dict() for i in trending_internships],
                'courses': [c.to_dict() for c in trending_courses],
                'events': [e.to_dict() for e in trending_events]
            }
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


# ==================== SEARCH APIs ====================

@app.route('/api/search', methods=['GET'])
def global_search():
    """Search across all content types"""
    try:
        query = request.args.get('q', '')
        content_type = request.args.get('type')  # 'internship', 'course', 'event', or None for all
        
        if not query:
            return jsonify({
                'success': False,
                'message': 'Search query is required'
            }), 400
        
        results = {}
        
        if not content_type or content_type == 'internship':
            internships = Internship.query.filter_by(status='approved').filter(
                db.or_(
                    Internship.title.ilike(f'%{query}%'),
                    Internship.company.ilike(f'%{query}%'),
                    Internship.description.ilike(f'%{query}%'),
                    Internship.skills_required.ilike(f'%{query}%')
                )
            ).limit(20).all()
            results['internships'] = [i.to_dict() for i in internships]
        
        if not content_type or content_type == 'course':
            courses = Course.query.filter_by(status='approved').filter(
                db.or_(
                    Course.title.ilike(f'%{query}%'),
                    Course.instructor.ilike(f'%{query}%'),
                    Course.description.ilike(f'%{query}%')
                )
            ).limit(20).all()
            results['courses'] = [c.to_dict() for c in courses]
        
        if not content_type or content_type == 'event':
            events = Event.query.filter_by(status='approved').filter(
                db.or_(
                    Event.title.ilike(f'%{query}%'),
                    Event.organizer.ilike(f'%{query}%'),
                    Event.description.ilike(f'%{query}%')
                )
            ).limit(20).all()
            results['events'] = [e.to_dict() for e in events]
        
        return jsonify({
            'success': True,
            'query': query,
            'results': results
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


# ==================== USER PREFERENCES APIs ====================

@app.route('/api/preferences', methods=['GET', 'PUT'])
@jwt_required()
def manage_preferences():
    """Get or update user preferences (including dark mode)"""
    try:
        current_user_id = get_jwt_identity()
        
        if request.method == 'GET':
            prefs = UserPreferences.query.filter_by(user_id=current_user_id).first()
            
            if not prefs:
                # Create default preferences
                prefs = UserPreferences(user_id=current_user_id)
                db.session.add(prefs)
                db.session.commit()
            
            return jsonify({
                'success': True,
                'preferences': prefs.to_dict()
            }), 200
        
        elif request.method == 'PUT':
            data = request.get_json()
            prefs = UserPreferences.query.filter_by(user_id=current_user_id).first()
            
            if not prefs:
                prefs = UserPreferences(user_id=current_user_id)
                db.session.add(prefs)
            
            if 'dark_mode' in data:
                prefs.dark_mode = data['dark_mode']
            if 'notification_enabled' in data:
                prefs.notification_enabled = data['notification_enabled']
            if 'email_notifications' in data:
                prefs.email_notifications = data['email_notifications']
            if 'interests' in data:
                prefs.interests = data['interests']
            if 'preferred_locations' in data:
                prefs.preferred_locations = data['preferred_locations']
            
            prefs.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Preferences updated successfully',
                'preferences': prefs.to_dict()
            }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# ==================== ADMIN APIs ====================

@app.route('/api/admin/analytics', methods=['GET'])
@jwt_required()
def admin_analytics():
    """Get comprehensive admin analytics"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if user.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        # User stats
        total_users = User.query.count()
        active_users = LoginActivity.query.filter_by(is_active=True).distinct(LoginActivity.user_id).count()
        
        # Registration stats (last 7 days)
        seven_days_ago = datetime.utcnow() - timedelta(days=7)
        new_registrations = User.query.filter(User.created_at >= seven_days_ago).count()
        
        # Content stats
        total_internships = Internship.query.filter_by(status='approved').count()
        total_courses = Course.query.filter_by(status='approved').count()
        total_events = Event.query.filter_by(status='approved').count()
        
        pending_internships = Internship.query.filter_by(status='pending').count()
        pending_courses = Course.query.filter_by(status='pending').count()
        pending_events = Event.query.filter_by(status='pending').count()
        
        # Engagement stats
        total_views = Internship.query.with_entities(db.func.sum(Internship.views_count)).scalar() or 0
        total_views += Course.query.with_entities(db.func.sum(Course.views_count)).scalar() or 0
        total_views += Event.query.with_entities(db.func.sum(Event.views_count)).scalar() or 0
        
        total_applications = Application.query.count()
        course_enrollments = Course.query.with_entities(db.func.sum(Course.enrolled_count)).scalar() or 0
        event_registrations = Event.query.with_entities(db.func.sum(Event.current_participants)).scalar() or 0
        
        return jsonify({
            'success': True,
            'analytics': {
                'users': {
                    'total': total_users,
                    'active': active_users,
                    'new_registrations_7d': new_registrations
                },
                'content': {
                    'internships': {
                        'approved': total_internships,
                        'pending': pending_internships
                    },
                    'courses': {
                        'approved': total_courses,
                        'pending': pending_courses
                    },
                    'events': {
                        'approved': total_events,
                        'pending': pending_events
                    }
                },
                'engagement': {
                    'total_views': total_views,
                    'internship_applications': total_applications,
                    'course_enrollments': course_enrollments,
                    'event_registrations': event_registrations
                }
            }
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/users', methods=['GET'])
@jwt_required()
def admin_get_users():
    """Get all users (admin only)"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if user.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        users = User.query.all()
        
        return jsonify({
            'success': True,
            'users': [u.to_dict() for u in users]
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/users/<int:user_id>/ban', methods=['POST'])
@jwt_required()
def admin_ban_user(user_id):
    """Ban/unban a user (admin only)"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        user = User.query.get_or_404(user_id)
        data = request.get_json()
        
        # Add banned field to User model or use verified field
        user.verified = not data.get('ban', True)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f"User {'banned' if not user.verified else 'unbanned'} successfully"
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/content/<content_type>/<int:content_id>/approve', methods=['POST'])
@jwt_required()
def admin_approve_content(content_type, content_id):
    """Approve or reject submitted content (admin only)"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        data = request.get_json()
        action = data.get('action', 'approved')  # 'approved' or 'rejected'
        
        content = None
        if content_type == 'internship':
            content = Internship.query.get_or_404(content_id)
        elif content_type == 'course':
            content = Course.query.get_or_404(content_id)
        elif content_type == 'event':
            content = Event.query.get_or_404(content_id)
        else:
            return jsonify({'success': False, 'message': 'Invalid content type'}), 400
        
        content.status = action
        db.session.commit()
        
        # Notify submitter
        if content.submitted_by:
            notification = Notification(
                user_id=content.submitted_by,
                title=f'{content_type.capitalize()} {action.capitalize()}',
                message=f'Your {content_type} "{content.title}" has been {action}',
                type='approval'
            )
            db.session.add(notification)
            db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f'{content_type.capitalize()} {action} successfully'
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/reports', methods=['GET'])
@jwt_required()
def admin_get_reports():
    """Get all reported content (admin only)"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        status = request.args.get('status', 'pending')
        
        reports = ReportedContent.query.filter_by(status=status).order_by(
            ReportedContent.created_at.desc()
        ).all()
        
        return jsonify({
            'success': True,
            'reports': [r.to_dict() for r in reports]
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


# ==================== ADMIN CONTENT MANAGEMENT ====================

@app.route('/api/admin/courses/add', methods=['POST'])
@jwt_required()
def admin_add_course():
    """Admin adds a new course directly (auto-approved)"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Admin access required'}), 403
        
        data = request.get_json()
        
        new_course = Course(
            title=data.get('title'),
            platform=data.get('platform'),
            instructor=data.get('instructor'),
            description=data.get('description'),
            course_link=data.get('course_link'),
            thumbnail=data.get('thumbnail'),
            what_you_will_learn=data.get('what_you_will_learn'),
            duration=data.get('duration'),
            level=data.get('level'),
            category=data.get('category'),
            is_paid=data.get('is_paid', False),
            price=data.get('price'),
            status='approved',  # Admin-added courses are auto-approved
            submitted_by=current_user_id
        )
        
        db.session.add(new_course)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Course added successfully',
            'course': new_course.to_dict()
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/courses/<int:id>', methods=['PUT', 'DELETE'])
@jwt_required()
def admin_manage_course(id):
    """Admin updates or deletes a course"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Admin access required'}), 403
        
        course = Course.query.get_or_404(id)
        
        if request.method == 'PUT':
            data = request.get_json()
            
            # Update all fields
            for key, value in data.items():
                if hasattr(course, key) and key not in ['id', 'created_at']:
                    setattr(course, key, value)
            
            course.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Course updated successfully',
                'course': course.to_dict()
            }), 200
        
        elif request.method == 'DELETE':
            db.session.delete(course)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Course deleted successfully'
            }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/internships/add', methods=['POST'])
@jwt_required()
def admin_add_internship():
    """Admin adds a new internship directly (auto-approved)"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Admin access required'}), 403
        
        data = request.get_json()
        
        new_internship = Internship(
            title=data.get('title'),
            company=data.get('company'),
            description=data.get('description'),
            work_type=data.get('work_type'),
            is_paid=data.get('is_paid', False),
            stipend_min=data.get('stipend_min'),
            stipend_max=data.get('stipend_max'),
            duration=data.get('duration'),
            skills_required=data.get('skills_required'),
            location=data.get('location'),
            category=data.get('category'),
            status='approved',
            submitted_by=current_user_id
        )
        
        db.session.add(new_internship)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Internship added successfully',
            'internship': new_internship.to_dict()
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/internships/<int:id>', methods=['PUT', 'DELETE'])
@jwt_required()
def admin_manage_internship(id):
    """Admin updates or deletes an internship"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Admin access required'}), 403
        
        internship = Internship.query.get_or_404(id)
        
        if request.method == 'PUT':
            data = request.get_json()
            
            for key, value in data.items():
                if hasattr(internship, key) and key not in ['id', 'created_at']:
                    setattr(internship, key, value)
            
            internship.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Internship updated successfully',
                'internship': internship.to_dict()
            }), 200
        
        elif request.method == 'DELETE':
            db.session.delete(internship)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Internship deleted successfully'
            }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/events/add', methods=['POST'])
@jwt_required()
def admin_add_event():
    """Admin adds a new event/hackathon directly (auto-approved)"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Admin access required'}), 403
        
        data = request.get_json()
        
        new_event = Event(
            title=data.get('title'),
            organizer=data.get('organizer'),
            description=data.get('description'),
            event_type=data.get('event_type'),
            category=data.get('category'),
            start_date=datetime.fromisoformat(data.get('start_date')) if data.get('start_date') else None,
            end_date=datetime.fromisoformat(data.get('end_date')) if data.get('end_date') else None,
            location=data.get('location'),
            registration_deadline=datetime.fromisoformat(data.get('registration_deadline')) if data.get('registration_deadline') else None,
            max_participants=data.get('max_participants'),
            prize_pool=data.get('prize_pool'),
            status='approved',
            submitted_by=current_user_id
        )
        
        db.session.add(new_event)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Event added successfully',
            'event': new_event.to_dict()
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/events/<int:id>', methods=['PUT', 'DELETE'])
@jwt_required()
def admin_manage_event(id):
    """Admin updates or deletes an event"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Admin access required'}), 403
        
        event = Event.query.get_or_404(id)
        
        if request.method == 'PUT':
            data = request.get_json()
            
            for key, value in data.items():
                if hasattr(event, key) and key not in ['id', 'created_at', 'start_date', 'end_date', 'registration_deadline']:
                    setattr(event, key, value)
            
            if 'start_date' in data:
                event.start_date = datetime.fromisoformat(data['start_date'])
            if 'end_date' in data:
                event.end_date = datetime.fromisoformat(data['end_date'])
            if 'registration_deadline' in data:
                event.registration_deadline = datetime.fromisoformat(data['registration_deadline'])
            
            event.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Event updated successfully',
                'event': event.to_dict()
            }), 200
        
        elif request.method == 'DELETE':
            db.session.delete(event)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Event deleted successfully'
            }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/submissions/pending', methods=['GET'])
@jwt_required()
def admin_get_pending_submissions():
    """Get all pending submissions from students"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Admin access required'}), 403
        
        pending_internships = Internship.query.filter_by(status='pending').all()
        pending_courses = Course.query.filter_by(status='pending').all()
        pending_events = Event.query.filter_by(status='pending').all()
        
        return jsonify({
            'success': True,
            'submissions': {
                'internships': [i.to_dict() for i in pending_internships],
                'courses': [c.to_dict() for c in pending_courses],
                'events': [e.to_dict() for e in pending_events]
            }
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/view-applications', methods=['GET'])
@jwt_required()
def admin_view_all_applications():
    """Admin views all student applications"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Admin access required'}), 403
        
        applications = Application.query.order_by(Application.applied_at.desc()).all()
        
        # Enrich with user details
        application_list = []
        for app in applications:
            app_dict = app.to_dict()
            user = User.query.get(app.user_id)
            if user:
                app_dict['user_name'] = user.name
                app_dict['user_email'] = user.email
            application_list.append(app_dict)
        
        return jsonify({
            'success': True,
            'applications': application_list
        }), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


# ==================== STUDENT-SPECIFIC ACTIONS ====================

@app.route('/api/courses/<int:id>/enroll', methods=['POST'])
@jwt_required()
def enroll_course(id):
    """Student clicks 'Start Learning' - increment enrolled_count"""
    try:
        current_user_id = get_jwt_identity()
        course = Course.query.get_or_404(id)
        
        # Increment enrolled count (applied metric)
        course.enrolled_count += 1
        db.session.commit()
        
        # Track application
        existing = Application.query.filter_by(
            user_id=current_user_id,
            opportunity_type='course',
            opportunity_id=id
        ).first()
        
        if not existing:
            application = Application(
                user_id=current_user_id,
                opportunity_type='course',
                opportunity_id=id,
                opportunity_title=course.title,
                opportunity_company=course.platform,
                status='enrolled'
            )
            db.session.add(application)
            db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Enrollment tracked',
            'course_link': course.course_link
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/admin/reports/<int:report_id>/resolve', methods=['POST'])
@jwt_required()
def admin_resolve_report(report_id):
    """Resolve a report (admin only)"""
    try:
        current_user_id = get_jwt_identity()
        admin = User.query.get(current_user_id)
        
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        report = ReportedContent.query.get_or_404(report_id)
        report.status = 'resolved'
        report.reviewed_at = datetime.utcnow()
        report.reviewed_by = current_user_id
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Report resolved successfully'
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


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
