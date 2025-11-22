"""Add sample courses, internships, and events to the database"""
from app import app, db, Course, Internship, Event
from datetime import datetime, timedelta

def add_sample_courses():
    """Add sample courses"""
    courses = [
        Course(
            title='Complete Web Development Bootcamp',
            description='Master HTML, CSS, JavaScript, React, Node.js and become a full-stack developer',
            category='Web Development',
            level='Beginner',
            duration='12 weeks',
            instructor='John Smith',
            price=49.99,
            thumbnail='https://images.unsplash.com/photo-1593720213428-28a5b9e94613?w=400&h=300&fit=crop',
            platform='Udemy',
            course_link='https://www.udemy.com/course/web-development',
            what_you_will_learn='HTML5, CSS3, JavaScript ES6, React.js, Node.js, Express, MongoDB, REST APIs'
        ),
        Course(
            title='Data Science & Machine Learning with Python',
            description='Learn data analysis, visualization, and machine learning with Python',
            category='Data Science',
            level='Intermediate',
            duration='16 weeks',
            instructor='Dr. Jane Doe',
            price=79.99,
            thumbnail='https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop',
            platform='Coursera',
            course_link='https://www.coursera.org/learn/data-science',
            what_you_will_learn='Python, Pandas, NumPy, Matplotlib, Scikit-learn, Machine Learning Algorithms'
        ),
        Course(
            title='Flutter & Dart - Mobile App Development',
            description='Build beautiful native iOS and Android apps with Flutter',
            category='Mobile Development',
            level='Beginner',
            duration='10 weeks',
            instructor='Mike Johnson',
            price=59.99,
            thumbnail='https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=300&fit=crop',
            platform='Udemy',
            course_link='https://www.udemy.com/course/flutter-development',
            what_you_will_learn='Flutter, Dart, Widgets, State Management, Firebase, REST APIs, App Deployment'
        ),
        Course(
            title='Digital Marketing Masterclass',
            description='Complete digital marketing course covering SEO, social media, email marketing',
            category='Marketing',
            level='Beginner',
            duration='8 weeks',
            instructor='Sarah Williams',
            price=39.99,
            thumbnail='https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop',
            platform='Skillshare',
            course_link='https://www.skillshare.com/digital-marketing',
            what_you_will_learn='SEO, Google Ads, Facebook Ads, Email Marketing, Content Marketing, Analytics'
        ),
        Course(
            title='AWS Cloud Practitioner Certification',
            description='Prepare for AWS Certified Cloud Practitioner exam',
            category='Cloud Computing',
            level='Beginner',
            duration='6 weeks',
            instructor='David Brown',
            price=44.99,
            thumbnail='https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&h=300&fit=crop',
            platform='Udemy',
            course_link='https://www.udemy.com/course/aws-cloud',
            what_you_will_learn='AWS Services, EC2, S3, RDS, Lambda, CloudFormation, Security Best Practices'
        )
    ]
    
    db.session.add_all(courses)
    db.session.commit()
    print(f"✅ Added {len(courses)} courses successfully")

def add_sample_events():
    """Add sample events"""
    today = datetime.now()
    events = [
        Event(
            title='TechHack 2025 - Annual Hackathon',
            description='48-hour hackathon with amazing prizes and networking opportunities',
            category='Hackathon',
            event_type='Online',
            start_date=today + timedelta(days=30),
            end_date=today + timedelta(days=32),
            registration_deadline=today + timedelta(days=28),
            location='Online Platform',
            organizer='TechCommunity',
            prize_pool='₹50,000',
            max_participants=500,
            status='approved'
        ),
        Event(
            title='AI & Machine Learning Workshop',
            description='Hands-on workshop on building ML models with Python',
            category='Workshop',
            event_type='Online',
            start_date=today + timedelta(days=15),
            end_date=today + timedelta(days=15),
            registration_deadline=today + timedelta(days=13),
            location='Zoom Meeting',
            organizer='DataScience Hub',
            max_participants=100,
            status='approved'
        ),
        Event(
            title='Career Fair 2025',
            description='Meet top tech companies and explore career opportunities',
            category='Career Fair',
            event_type='Offline',
            start_date=today + timedelta(days=45),
            end_date=today + timedelta(days=45),
            registration_deadline=today + timedelta(days=40),
            location='Convention Center, Mumbai',
            organizer='JobPortal',
            max_participants=1000,
            status='approved'
        )
    ]
    
    db.session.add_all(events)
    db.session.commit()
    print(f"✅ Added {len(events)} events successfully")

if __name__ == '__main__':
    with app.app_context():
        print("Adding sample data to database...")
        add_sample_courses()
        add_sample_events()
        print("\n🎉 All sample data added successfully!")
