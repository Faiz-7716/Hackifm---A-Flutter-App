from app import app, db
from app import (User, Internship, Course, Event, Notification, ViewHistory, 
                 ReportedContent, UserPreferences, Application, SavedItem, 
                 LoginActivity)

def migrate_database():
    """Create all database tables"""
    with app.app_context():
        print("Creating database tables...")
        db.create_all()
        print("✓ All tables created successfully!")
        
        # Check if admin exists
        admin = User.query.filter_by(email='admin@hackifm.com').first()
        if not admin:
            from flask_bcrypt import Bcrypt
            bcrypt = Bcrypt(app)
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
            print("✓ Default admin created: admin@hackifm.com / Admin@123")
        else:
            print("✓ Admin user already exists")

if __name__ == '__main__':
    migrate_database()
