# Dynamic Internship Detail Page - Design Document

## Overview
This system allows admins to customize the internship detail page sections, including icons, colors, text labels, and visibility.

## Database Schema

### 1. internship_detail_sections
Stores configurable sections for internship detail pages

```sql
CREATE TABLE internship_detail_sections (
    id INTEGER PRIMARY KEY,
    section_key VARCHAR(50) UNIQUE NOT NULL,  -- e.g., 'basic_info', 'skills', 'eligibility'
    section_title VARCHAR(100) NOT NULL,       -- Display title
    icon_name VARCHAR(50),                      -- Material Icon name
    icon_color VARCHAR(20),                     -- Hex color code
    display_order INTEGER NOT NULL,             -- Order of display
    is_enabled BOOLEAN DEFAULT TRUE,            -- Show/hide section
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. internship_info_chips
Configurable info chips in the Basic Information section

```sql
CREATE TABLE internship_info_chips (
    id INTEGER PRIMARY KEY,
    chip_key VARCHAR(50) UNIQUE NOT NULL,     -- e.g., 'work_type', 'duration', 'stipend'
    label_text VARCHAR(50) NOT NULL,           -- Display label
    icon_name VARCHAR(50),                      -- Material Icon name
    color_hex VARCHAR(20),                      -- Chip color
    display_order INTEGER NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Default Configuration

### Default Sections:
1. Header (always visible, not configurable for structure)
2. Basic Information - customizable chips
3. Skills Required - customizable section header
4. Eligibility - customizable section header
5. Job Description - customizable section header
6. Application Details - customizable section header
7. Analytics - customizable section header
8. About Company - customizable section header

### Default Info Chips:
1. Work Type (work_outline, blue)
2. Duration (schedule, green)
3. Internship Type (type_specimen, purple)
4. Stipend (payments, green/grey)
5. Experience Level (bar_chart, orange)
6. Category (category, teal)

## API Endpoints

### GET /api/internship-sections
Returns all section configurations

### PUT /api/internship-sections/:id
Update section configuration

### GET /api/internship-info-chips
Returns all info chip configurations

### PUT /api/internship-info-chips/:id
Update info chip configuration

### POST /api/internship-sections/reorder
Reorder sections

## Admin Interface Features

1. **Section Manager**
   - Toggle visibility
   - Edit section title
   - Change icon (from preset list)
   - Change color
   - Reorder sections (drag & drop)

2. **Info Chip Manager**
   - Toggle visibility
   - Edit label text
   - Change icon
   - Change color
   - Reorder chips

3. **Preview**
   - Live preview of changes
   - Reset to defaults option

## Icon Preset List (Material Icons)
- work_outline, schedule, type_specimen, payments, bar_chart
- category, lightbulb_outline, check_circle_outline, description
- assignment, calendar_today, link, analytics, visibility
- touch_app, people, business, location_on, school

## Color Presets
- Blue: #2196F3, #3498DB
- Green: #4CAF50, #27AE60
- Purple: #9C27B0, #8E44AD
- Orange: #FF9800, #E67E22
- Teal: #009688, #16A085
- Red: #F44336, #E74C3C
- Grey: #757575, #95A5A6
- Indigo: #3F51B5, #34495E
