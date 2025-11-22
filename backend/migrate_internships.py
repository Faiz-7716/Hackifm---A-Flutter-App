"""
Database Migration Script for Enhanced Internship Module
Adds new fields to internships table for complete feature set
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import app, db
from sqlalchemy import text

def migrate_internship_table():
    """Add new columns to internships table"""
    
    with app.app_context():
        print("🔄 Starting internship table migration...")
        
        try:
            # List of new columns to add
            migrations = [
                # Company Info
                ("company_logo", "VARCHAR(500)"),
                ("company_description", "TEXT"),
                
                # Job Details
                ("internship_type", "VARCHAR(50)"),
                ("stipend_type", "VARCHAR(50)"),
                
                # Skills & Experience
                ("experience_level", "VARCHAR(20)"),
                ("tools_technologies", "TEXT"),
                
                # Eligibility
                ("eligibility", "TEXT"),
                
                # Job Description
                ("responsibilities", "TEXT"),
                ("what_you_will_learn", "TEXT"),
                
                # Application Details
                ("application_deadline", "DATETIME"),
                ("apply_link", "VARCHAR(500)"),
                ("apply_through_platform", "BOOLEAN DEFAULT 1"),
                
                # Analytics
                ("clicks_count", "INTEGER DEFAULT 0"),
                
                # Admin/Status
                ("is_active", "BOOLEAN DEFAULT 1"),
            ]
            
            conn = db.engine.connect()
            
            for column_name, column_type in migrations:
                try:
                    # Check if column exists
                    result = conn.execute(text(f"PRAGMA table_info(internships)"))
                    columns = [row[1] for row in result]
                    
                    if column_name not in columns:
                        # Add the column
                        alter_query = f"ALTER TABLE internships ADD COLUMN {column_name} {column_type}"
                        conn.execute(text(alter_query))
                        conn.commit()
                        print(f"  ✅ Added column: {column_name}")
                    else:
                        print(f"  ⏭️  Column already exists: {column_name}")
                        
                except Exception as e:
                    print(f"  ❌ Error adding {column_name}: {str(e)}")
            
            conn.close()
            
            print("\n✅ Internship table migration completed successfully!")
            print("\n📊 New Features Available:")
            print("  • Company logo and description")
            print("  • Internship type (Full-time, Part-time, Project-based, Research)")
            print("  • Stipend type (Fixed, Performance-based, Unpaid)")
            print("  • Experience level tracking")
            print("  • Tools & technologies")
            print("  • Eligibility criteria")
            print("  • Responsibilities and learning outcomes")
            print("  • Application deadline")
            print("  • Direct apply link option")
            print("  • Click tracking")
            print("  • Admin activate/deactivate")
            
        except Exception as e:
            print(f"\n❌ Migration failed: {str(e)}")
            db.session.rollback()

if __name__ == '__main__':
    migrate_internship_table()
