"""
Database Migration Script for Dynamic Internship Detail Configuration
Run this script to add the new tables and seed default data
"""

import sys
import os

# Prevent Flask from running
os.environ['WERKZEUG_RUN_MAIN'] = 'true'

from app import app, db, InternshipDetailSection, InternshipInfoChip
from sqlalchemy import text
from datetime import datetime

def create_tables():
    """Create new tables for dynamic configuration"""
    with app.app_context():
        # Create all tables defined in models
        db.create_all()
        print("✓ Tables created successfully")

def seed_default_sections():
    """Insert default section configurations"""
    with app.app_context():
        sections_data = [
            {'section_key': 'basic_info', 'title': 'Basic Information', 'icon_name': 'info_outline', 'color': '#2196F3', 'display_order': 1},
            {'section_key': 'skills', 'title': 'Skills Required', 'icon_name': 'lightbulb_outline', 'color': '#2196F3', 'display_order': 2},
            {'section_key': 'eligibility', 'title': 'Eligibility', 'icon_name': 'check_circle_outline', 'color': '#4CAF50', 'display_order': 3},
            {'section_key': 'description', 'title': 'Job Description', 'icon_name': 'description', 'color': '#FF9800', 'display_order': 4},
            {'section_key': 'application', 'title': 'Application Details', 'icon_name': 'assignment', 'color': '#9C27B0', 'display_order': 5},
            {'section_key': 'analytics', 'title': 'Analytics', 'icon_name': 'analytics', 'color': '#009688', 'display_order': 6},
            {'section_key': 'company', 'title': 'About Company', 'icon_name': 'business', 'color': '#3F51B5', 'display_order': 7},
        ]
        
        for section_data in sections_data:
            # Check if section already exists
            existing = InternshipDetailSection.query.filter_by(section_key=section_data['section_key']).first()
            if not existing:
                section = InternshipDetailSection(**section_data)
                db.session.add(section)
        
        db.session.commit()
        print("✓ Default sections seeded")

def seed_default_info_chips():
    """Insert default info chip configurations"""
    with app.app_context():
        chips_data = [
            {'chip_key': 'work_type', 'label': 'Mode', 'icon_name': 'work_outline', 'color': '#2196F3', 'display_order': 1},
            {'chip_key': 'duration', 'label': 'Duration', 'icon_name': 'schedule', 'color': '#4CAF50', 'display_order': 2},
            {'chip_key': 'internship_type', 'label': 'Type', 'icon_name': 'type_specimen', 'color': '#9C27B0', 'display_order': 3},
            {'chip_key': 'stipend', 'label': 'Stipend', 'icon_name': 'payments', 'color': '#4CAF50', 'display_order': 4},
            {'chip_key': 'experience_level', 'label': 'Level', 'icon_name': 'bar_chart', 'color': '#FF9800', 'display_order': 5},
            {'chip_key': 'category', 'label': 'Category', 'icon_name': 'category', 'color': '#009688', 'display_order': 6},
        ]
        
        for chip_data in chips_data:
            # Check if chip already exists
            existing = InternshipInfoChip.query.filter_by(chip_key=chip_data['chip_key']).first()
            if not existing:
                chip = InternshipInfoChip(**chip_data)
                db.session.add(chip)
        
        db.session.commit()
        print("✓ Default info chips seeded")

if __name__ == '__main__':
    print("Starting migration...")
    try:
        create_tables()
        seed_default_sections()
        seed_default_info_chips()
        print("\n✅ Migration completed successfully!")
    except Exception as e:
        print(f"\n❌ Migration failed: {e}")
