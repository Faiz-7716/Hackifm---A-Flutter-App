"""Update course thumbnails with real images"""
from app import app, db, Course

def update_course_images():
    """Update existing courses with better thumbnail images"""
    with app.app_context():
        # Get all courses
        courses = Course.query.all()
        
        # Image mappings based on course title/category
        image_updates = {
            'Web Development': 'https://images.unsplash.com/photo-1593720213428-28a5b9e94613?w=400&h=300&fit=crop',
            'Data Science': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop',
            'Mobile Development': 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=300&fit=crop',
            'Marketing': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop',
            'Cloud Computing': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&h=300&fit=crop',
        }
        
        for course in courses:
            for category, image_url in image_updates.items():
                if category.lower() in course.category.lower() if course.category else False:
                    course.thumbnail = image_url
                    print(f"Updated: {course.title} -> {category} image")
                    break
        
        db.session.commit()
        print(f"\n✅ Updated {len(courses)} courses with new images")

if __name__ == '__main__':
    update_course_images()
