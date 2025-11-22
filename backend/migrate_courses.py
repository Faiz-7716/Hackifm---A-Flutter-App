"""
Migration script to add platform column to courses table
Run this if you get "no such column: courses.platform" error
"""
import sqlite3
import os

def migrate_courses():
    db_path = os.path.join('instance', 'hackifm.db')
    
    if not os.path.exists(db_path):
        print(f"Database not found at {db_path}")
        return
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # Check if platform column exists
        cursor.execute("PRAGMA table_info(courses)")
        columns = [col[1] for col in cursor.fetchall()]
        
        if 'platform' not in columns:
            print("Adding 'platform' column to courses table...")
            cursor.execute("ALTER TABLE courses ADD COLUMN platform VARCHAR(100)")
            conn.commit()
            print("✅ Successfully added 'platform' column!")
        else:
            print("✓ 'platform' column already exists.")
        
        # Verify all required columns
        required_columns = [
            'id', 'title', 'platform', 'instructor', 'description', 
            'course_link', 'thumbnail', 'what_you_will_learn', 'duration',
            'level', 'category', 'is_paid', 'price', 'views_count',
            'enrolled_count', 'rating', 'status', 'submitted_by',
            'created_at', 'updated_at'
        ]
        
        missing = [col for col in required_columns if col not in columns and col != 'platform']
        
        if missing:
            print(f"\n⚠️  Missing columns: {', '.join(missing)}")
            print("You may need to recreate the database or add these columns manually.")
        else:
            print("\n✅ All required columns present in courses table!")
        
    except sqlite3.Error as e:
        print(f"❌ Error: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == '__main__':
    print("=" * 50)
    print("Courses Table Migration")
    print("=" * 50)
    migrate_courses()
    print("\nMigration complete!")
