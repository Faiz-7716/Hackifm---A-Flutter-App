"""
Seed the database with sample internships and courses
"""
from app import app, db, Internship, Course
from datetime import datetime, timedelta

def seed_data():
    with app.app_context():
        # Clear existing data
        print("Clearing existing data...")
        Internship.query.delete()
        Course.query.delete()
        db.session.commit()
        
        # Create sample internships
        print("\nCreating sample internships...")
        internships = [
            Internship(
                title="Software Engineering Intern",
                company="Google",
                description="Join our team to work on cutting edge technologies and gain hands-on experience in software development.",
                work_type="Remote",
                is_paid=True,
                stipend_min=50000,
                stipend_max=75000,
                duration="3 months",
                skills_required="Python, JavaScript, React, Node.js",
                location="Remote",
                category="Software Development",
                status="approved",
                company_logo="https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png",
                internship_type="Remote",
                experience_level="Intermediate",
                tools_technologies="Git, Docker, AWS",
                eligibility="Currently pursuing Bachelor's or Master's in Computer Science",
                responsibilities="Develop and maintain web applications, Write clean code, Collaborate with team",
                what_you_will_learn="Modern web development, Cloud technologies, Team collaboration",
                application_deadline=(datetime.utcnow() + timedelta(days=30)),
                apply_link="https://careers.google.com",
                apply_through_platform=False,
                is_active=True
            ),
            Internship(
                title="Product Design Intern",
                company="Microsoft",
                description="Design user-centered experiences for millions of users worldwide. Work with cross-functional teams.",
                work_type="Hybrid",
                is_paid=True,
                stipend_min=40000,
                stipend_max=60000,
                duration="2 months",
                skills_required="Figma, Adobe XD, User Research",
                location="Seattle, WA",
                category="Design",
                status="approved",
                company_logo="https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE1Mu3b",
                internship_type="Hybrid",
                experience_level="Beginner",
                tools_technologies="Figma, Sketch, InVision",
                eligibility="Pursuing degree in Design, HCI, or related field",
                responsibilities="Create wireframes and prototypes, Conduct user research, Design UI components",
                what_you_will_learn="UX design principles, User research methods, Design systems",
                application_deadline=(datetime.utcnow() + timedelta(days=45)),
                apply_link="https://careers.microsoft.com",
                apply_through_platform=False,
                is_active=True
            ),
            Internship(
                title="Data Science Intern",
                company="Amazon",
                description="Work on machine learning models and data analysis projects that impact millions of customers.",
                work_type="Remote",
                is_paid=True,
                stipend_min=60000,
                stipend_max=80000,
                duration="6 months",
                skills_required="Python, Machine Learning, SQL, Statistics",
                location="Remote",
                category="Data Science",
                status="approved",
                company_logo="https://upload.wikimedia.org/wikipedia/commons/a/a9/Amazon_logo.svg",
                internship_type="Remote",
                experience_level="Advanced",
                tools_technologies="Python, TensorFlow, AWS SageMaker, SQL",
                eligibility="Graduate students in Computer Science, Statistics, or related field",
                responsibilities="Build ML models, Analyze large datasets, Create visualizations",
                what_you_will_learn="Machine learning at scale, Big data processing, Cloud ML infrastructure",
                application_deadline=(datetime.utcnow() + timedelta(days=20)),
                apply_link="https://amazon.jobs",
                apply_through_platform=False,
                is_active=True
            ),
            Internship(
                title="Frontend Developer Intern",
                company="Meta",
                description="Build beautiful and responsive user interfaces for Facebook and Instagram.",
                work_type="On-site",
                is_paid=True,
                stipend_min=55000,
                stipend_max=70000,
                duration="3 months",
                skills_required="React, TypeScript, CSS, HTML",
                location="Menlo Park, CA",
                category="Software Development",
                status="approved",
                company_logo="https://upload.wikimedia.org/wikipedia/commons/7/7b/Meta_Platforms_Inc._logo.svg",
                internship_type="On-site",
                experience_level="Intermediate",
                tools_technologies="React, Redux, GraphQL, Jest",
                eligibility="Currently enrolled in BS/MS Computer Science program",
                responsibilities="Develop React components, Optimize performance, Write tests",
                what_you_will_learn="React best practices, Performance optimization, Large-scale web apps",
                application_deadline=(datetime.utcnow() + timedelta(days=25)),
                apply_link="https://www.metacareers.com",
                apply_through_platform=False,
                is_active=True
            ),
        ]
        
        for internship in internships:
            db.session.add(internship)
        
        db.session.commit()
        print(f"✅ Created {len(internships)} internships")
        
        # Create sample courses
        print("\nCreating sample courses...")
        courses = [
            Course(
                title="Complete Web Development Bootcamp",
                platform="Udemy",
                instructor="Angela Yu",
                description="Learn HTML, CSS, JavaScript, Node, React, MongoDB, and more!",
                course_link="https://www.udemy.com/course/the-complete-web-development-bootcamp/",
                thumbnail="https://img-b.udemycdn.com/course/240x135/1565838_e54e_16.jpg",
                what_you_will_learn='["HTML5 & CSS3", "JavaScript ES6+", "React.js", "Node.js", "MongoDB", "REST APIs"]',
                duration="65 hours",
                level="Beginner",
                category="Web Dev",
                is_paid=True,
                price=84.99,
                rating=4.7,
                status="approved"
            ),
            Course(
                title="Machine Learning A-Z",
                platform="Udemy",
                instructor="Kirill Eremenko",
                description="Learn to create Machine Learning Algorithms in Python and R from two Data Science experts.",
                course_link="https://www.udemy.com/course/machinelearning/",
                thumbnail="https://img-b.udemycdn.com/course/240x135/950390_270f_3.jpg",
                what_you_will_learn='["Regression", "Classification", "Clustering", "Deep Learning", "NLP", "Reinforcement Learning"]',
                duration="44 hours",
                level="Intermediate",
                category="AI/ML",
                is_paid=True,
                price=84.99,
                rating=4.5,
                status="approved"
            ),
            Course(
                title="The Complete JavaScript Course 2024",
                platform="Udemy",
                instructor="Jonas Schmedtmann",
                description="The modern JavaScript course for everyone! Master JavaScript with projects, challenges and theory.",
                course_link="https://www.udemy.com/course/the-complete-javascript-course/",
                thumbnail="https://img-b.udemycdn.com/course/240x135/851712_fc61_6.jpg",
                what_you_will_learn='["Modern JavaScript", "ES6+", "Async/Await", "OOP", "Functional Programming", "DOM Manipulation"]',
                duration="69 hours",
                level="Beginner",
                category="Web Dev",
                is_paid=True,
                price=84.99,
                rating=4.8,
                status="approved"
            ),
            Course(
                title="Python for Everybody",
                platform="FreeCodeCamp",
                instructor="Dr. Charles Severance",
                description="Learn Python programming from scratch. Perfect for beginners!",
                course_link="https://www.freecodecamp.org/learn/scientific-computing-with-python/",
                thumbnail="https://www.freecodecamp.org/news/content/images/size/w2000/2022/05/Python-Blog-Cover.png",
                what_you_will_learn='["Python Basics", "Data Structures", "Web Scraping", "Databases", "Data Visualization"]',
                duration="20 hours",
                level="Beginner",
                category="Programming",
                is_paid=False,
                price=0,
                rating=4.9,
                status="approved"
            ),
            Course(
                title="React - The Complete Guide",
                platform="Udemy",
                instructor="Maximilian Schwarzmüller",
                description="Dive in and learn React.js from scratch! Learn Reactjs, Hooks, Redux, React Routing, Next.js!",
                course_link="https://www.udemy.com/course/react-the-complete-guide-incl-redux/",
                thumbnail="https://img-b.udemycdn.com/course/240x135/1362070_b9a1_2.jpg",
                what_you_will_learn='["React Fundamentals", "Hooks", "Redux", "React Router", "Next.js", "TypeScript with React"]',
                duration="49 hours",
                level="Intermediate",
                category="Web Dev",
                is_paid=True,
                price=84.99,
                rating=4.6,
                status="approved"
            ),
        ]
        
        for course in courses:
            db.session.add(course)
        
        db.session.commit()
        print(f"✅ Created {len(courses)} courses")
        
        print("\n" + "="*50)
        print("✅ Database seeded successfully!")
        print("="*50)

if __name__ == '__main__':
    seed_data()
