# Phase 2 Feature Deployment Guide
**Calendar Booking System & Notification System**

## 📋 Pre-Deployment Checklist

### 1. Backup Your Current System
```bash
# Backup database
mysqldump -u username -p sharingcanol_stuff > backup_$(date +%Y%m%d).sql

# Backup files
cp -r Sharing/ Sharing_backup_$(date +%Y%m%d)/
```

### 2. Test Environment Setup
- Deploy to staging/test environment first
- Verify all existing functionality still works
- Test new features with sample data

## 🚀 Development Server Setup

### **CRITICAL: Development Server Configuration**

**Problem Analysis**: The development server startup was problematic due to:
1. **Directory Structure Confusion**: PHP files are in `Sharing/` subdirectory, not project root
2. **Server Root Issues**: Server was starting from wrong directory
3. **Document Root Specification**: Missing explicit document root specification
4. **Port Conflicts**: Multiple server instances causing conflicts

**✅ Successful Method**:
```bash
# 1. Navigate to the correct directory (where PHP files are located)
cd /home/alexisrose/Documents/Repos/Sharing.canol.cymru/Sharing

# 2. Kill any existing PHP servers to avoid conflicts
pkill -f "php -S"

# 3. Start server with explicit document root and full path
php -S localhost:8000 -t /home/alexisrose/Documents/Repos/Sharing.canol.cymru/Sharing

# 4. Verify server is running
curl http://localhost:8000/
# Expected output: "Welcome to Sharing.Canol.Cymru"
```

**Alternative Methods (if above doesn't work)**:
```bash
# Method 2: Using relative path from project root
cd /home/alexisrose/Documents/Repos/Sharing.canol.cymru
php -S localhost:8000 -t Sharing/

# Method 3: Using 127.0.0.1 instead of localhost
cd Sharing/
php -S 127.0.0.1:8000

# Method 4: With display errors for debugging
cd Sharing/
php -S localhost:8000 -d display_errors=1
```

**Troubleshooting Steps**:
1. **Check if server is running**: `ps aux | grep "php -S"`
2. **Check port availability**: `netstat -tlnp | grep 8000`
3. **Test connectivity**: `curl -I http://localhost:8000/`
4. **Check directory structure**: `ls -la index.php`
5. **Kill conflicting processes**: `pkill -f "php -S"`

**Common Issues and Solutions**:
- **404 Errors**: Server not running from correct directory
- **Connection Refused**: Port 8000 already in use
- **Permission Denied**: File permissions issues
- **PHP Errors**: Missing includes or database connection

**Verification Commands**:
```bash
# Test homepage
curl http://localhost:8000/

# Test specific page
curl http://localhost:8000/search.php

# Check server logs (if running in foreground)
# Look for PHP errors and warnings
```

## 🚀 Deployment Steps

### Step 1: Database Schema Updates
```bash
# Run the schema update script
mysql -u username -p sharingcanol_stuff < schema_updates.sql
```

**Verify tables created:**
- `bookings` - booking requests and scheduling
- `notifications` - notification queue
- `notification_templates` - email templates
- New columns added to `things` and `members` tables

### Step 2: Deploy New PHP Files
Upload these new files to your web server:
```
Sharing/
├── includes/
│   ├── booking_functions.inc          # NEW
│   └── notification_functions.inc     # NEW
├── my_bookings.php                    # NEW
├── request_booking.php                # NEW
├── notifications.php                  # NEW
└── cron_notifications.php             # NEW
```

### Step 3: Update Existing Files
These files have been modified:
- `includes/header.inc` - added new navigation links
- `search.php` - added booking functionality
- Page titles and includes updated

### Step 4: Set File Permissions
```bash
chmod 644 *.php
chmod 644 includes/*.inc
chmod 755 cron_notifications.php  # Make executable for cron
```

### Step 5: Configure Cron Job
Add to your crontab to process notifications every 15 minutes:
```bash
# Edit crontab
crontab -e

# Add this line (adjust path as needed)
*/15 * * * * /usr/bin/php /path/to/sharing/cron_notifications.php >> /var/log/sharing_notifications.log 2>&1
```

### Step 6: Email Configuration
Ensure PHP mail() function is configured on your server:
- SMTP settings in php.ini
- Or configure PHPMailer for better email delivery (future enhancement)

## 🧪 Testing Procedures

### 1. Test Basic Functionality
- [ ] Login/logout still works
- [ ] Item listing still works
- [ ] Search still works
- [ ] Private groups still work

### 2. Test New Features

#### Booking System:
- [ ] Navigate to Search → find a loan item → click "Book Item"
- [ ] Fill out booking request form
- [ ] Owner receives notification
- [ ] Owner can approve/decline in "My Bookings"
- [ ] Borrower sees status updates

#### Notification System:
- [ ] Check "Notifications" page shows test notifications
- [ ] Verify email notifications are sent (check cron log)
- [ ] Test notification preferences
- [ ] Verify unread count appears in header

### 3. Test Calendar Functionality
- [ ] Date selection works in booking form
- [ ] Cost calculation updates automatically
- [ ] Availability checking prevents double-booking
- [ ] Due date reminders are generated

## 📊 Monitoring & Maintenance

### 1. Monitor Cron Job
```bash
# Check notification processing log
tail -f /var/log/sharing_notifications.log

# Check for failed notifications
SELECT * FROM notifications WHERE notification_status = 3;
```

### 2. Database Maintenance
```sql
-- Check booking statistics
SELECT booking_status, COUNT(*) FROM bookings GROUP BY booking_status;

-- Check notification delivery rates
SELECT notification_status, COUNT(*) FROM notifications GROUP BY notification_status;

-- Clean up old read notifications (older than 30 days)
DELETE FROM notifications 
WHERE notification_status = 4 
AND notification_read < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### 3. Performance Monitoring
- Monitor database size growth
- Check email delivery rates
- Monitor cron job execution time

## 🔧 Troubleshooting

### Common Issues:

1. **Notifications not sending**
   - Check PHP mail() configuration
   - Verify cron job is running
   - Check notification table for failed status

2. **Booking conflicts**
   - Verify date validation logic
   - Check timezone settings
   - Test availability checking function

3. **Missing navigation links**
   - Clear browser cache
   - Verify header.inc was updated correctly
   - Check include paths

### Database Issues:
```sql
-- Reset a stuck booking
UPDATE bookings SET booking_status = 5 WHERE booking_ID = ?;

-- Resend failed notification
UPDATE notifications SET notification_status = 1, notification_attempts = 0 WHERE notification_ID = ?;
```

## 🎯 Next Steps

After successful deployment:

1. **User Training**
   - Create user guide for booking system
   - Explain notification preferences
   - Demo calendar functionality

2. **Feature Enhancements**
   - Install PHPMailer for better email delivery
   - Add SMS notifications (Twilio integration)
   - Implement advanced calendar widget
   - Add mobile responsive CSS

3. **Community Fund Integration**
   - Track donation percentages
   - Generate fund reports
   - Implement voting system

## 📞 Support

For deployment issues:
- Check logs in `/var/log/sharing_notifications.log`
- Review database error logs
- Test individual functions in PHP files
- Verify all include files are accessible

**Rollback Procedure:**
If issues occur, restore from backup:
```bash
# Restore database
mysql -u username -p sharingcanol_stuff < backup_YYYYMMDD.sql

# Restore files
rm -rf Sharing/
mv Sharing_backup_YYYYMMDD/ Sharing/
``` 