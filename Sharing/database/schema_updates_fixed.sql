-- ======================================================
-- SHARING.CANOL.CYMRU - SCHEMA UPDATES FOR PHASE 2 (FIXED)
-- Calendar Booking System & Notification System
-- ======================================================

-- Calendar Booking System Tables
-- ======================================================

-- Main bookings table for loan scheduling
CREATE TABLE `bookings` (
  `booking_ID` int(11) NOT NULL AUTO_INCREMENT,
  `thing_ID` int(11) NOT NULL,
  `member_ID` int(10) unsigned NOT NULL COMMENT 'person requesting the loan',
  `owner_ID` int(10) unsigned NOT NULL COMMENT 'person who owns the item',
  `booking_start_date` date NOT NULL,
  `booking_end_date` date NOT NULL,
  `booking_status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1=pending, 2=approved, 3=active, 4=completed, 5=cancelled',
  `booking_created` datetime DEFAULT current_timestamp(),
  `booking_notes` text COMMENT 'special requests or notes',
  `booking_approved_date` datetime DEFAULT NULL,
  `booking_returned_date` datetime DEFAULT NULL,
  PRIMARY KEY (`booking_ID`),
  FOREIGN KEY (`thing_ID`) REFERENCES `things`(`thing_ID`) ON DELETE CASCADE,
  FOREIGN KEY (`member_ID`) REFERENCES `members`(`member_ID`) ON DELETE CASCADE,
  FOREIGN KEY (`owner_ID`) REFERENCES `members`(`member_ID`) ON DELETE CASCADE,
  KEY `idx_booking_dates` (`booking_start_date`, `booking_end_date`),
  KEY `idx_booking_status` (`booking_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Add availability tracking columns to existing things table
ALTER TABLE `things` 
ADD COLUMN `thing_available_from` date DEFAULT NULL COMMENT 'earliest available date',
ADD COLUMN `thing_available_until` date DEFAULT NULL COMMENT 'latest available date', 
ADD COLUMN `thing_min_loan_days` int(11) DEFAULT 1 COMMENT 'minimum loan period',
ADD COLUMN `thing_max_loan_days` int(11) DEFAULT 30 COMMENT 'maximum loan period',
ADD COLUMN `thing_advance_booking_days` int(11) DEFAULT 7 COMMENT 'how far ahead bookings allowed';

-- Notification System Tables
-- ======================================================

-- Main notifications queue
CREATE TABLE `notifications` (
  `notification_ID` int(11) NOT NULL AUTO_INCREMENT,
  `member_ID` int(10) unsigned NOT NULL,
  `notification_type` varchar(50) NOT NULL COMMENT 'booking_request, booking_approved, due_reminder, etc',
  `notification_title` varchar(255) NOT NULL,
  `notification_message` text NOT NULL,
  `notification_data` json DEFAULT NULL COMMENT 'structured data for the notification',
  `notification_status` tinyint(4) DEFAULT 1 COMMENT '1=pending, 2=sent, 3=failed, 4=read',
  `notification_priority` tinyint(4) DEFAULT 3 COMMENT '1=urgent, 2=high, 3=normal, 4=low',
  `notification_attempts` tinyint(4) DEFAULT 0 COMMENT 'number of delivery attempts',
  `notification_created` datetime DEFAULT current_timestamp(),
  `notification_sent` datetime DEFAULT NULL,
  `notification_read` datetime DEFAULT NULL,
  PRIMARY KEY (`notification_ID`),
  FOREIGN KEY (`member_ID`) REFERENCES `members`(`member_ID`) ON DELETE CASCADE,
  KEY `idx_notification_status` (`notification_status`),
  KEY `idx_notification_type` (`notification_type`),
  KEY `idx_notification_member` (`member_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Email notification templates
CREATE TABLE `notification_templates` (
  `template_ID` int(11) NOT NULL AUTO_INCREMENT,
  `template_type` varchar(50) NOT NULL COMMENT 'matches notification_type',
  `template_name` varchar(100) NOT NULL,
  `template_subject` varchar(255) NOT NULL,
  `template_body` text NOT NULL COMMENT 'HTML template with {{variables}}',
  `template_variables` json DEFAULT NULL COMMENT 'available template variables',
  `template_active` tinyint(1) DEFAULT 1,
  `template_created` datetime DEFAULT current_timestamp(),
  `template_updated` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`template_ID`),
  UNIQUE KEY `unique_template_type` (`template_type`),
  KEY `idx_template_active` (`template_active`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Insert default notification templates
INSERT INTO `notification_templates` (`template_type`, `template_name`, `template_subject`, `template_body`, `template_variables`) VALUES
('booking_request', 'Booking Request Received', 'New booking request for {{item_title}}', 
 '<h2>Booking Request</h2><p>{{borrower_name}} has requested to borrow your item "{{item_title}}" from {{start_date}} to {{end_date}}.</p><p><strong>Cost:</strong> £{{total_cost}}</p><p><strong>Notes:</strong> {{notes}}</p><p><a href="{{booking_url}}">View and respond to this request</a></p>', 
 '{"borrower_name": "Borrower full name", "item_title": "Item title", "start_date": "Start date", "end_date": "End date", "total_cost": "Total cost", "notes": "Special notes", "booking_url": "URL to booking page"}'),

('booking_approved', 'Booking Approved', 'Your booking for {{item_title}} has been approved', 
 '<h2>Booking Approved!</h2><p>Great news! {{owner_name}} has approved your booking for "{{item_title}}" from {{start_date}} to {{end_date}}.</p><p><strong>Cost:</strong> £{{total_cost}}</p><p><a href="{{booking_url}}">View booking details</a></p>', 
 '{"owner_name": "Owner full name", "item_title": "Item title", "start_date": "Start date", "end_date": "End date", "total_cost": "Total cost", "booking_url": "URL to booking page"}'),

('booking_declined', 'Booking Declined', 'Your booking request for {{item_title}} was declined', 
 '<h2>Booking Request Declined</h2><p>Unfortunately, {{owner_name}} has declined your booking request for "{{item_title}}" from {{start_date}} to {{end_date}}.</p><p>You can search for similar items or try different dates.</p><p><a href="{{search_url}}">Search for similar items</a></p>', 
 '{"owner_name": "Owner full name", "item_title": "Item title", "start_date": "Start date", "end_date": "End date", "search_url": "URL to search page"}'),

('due_reminder', 'Return Reminder', 'Reminder: {{item_title}} is due back {{due_date}}', 
 '<h2>Return Reminder</h2><p>This is a friendly reminder that "{{item_title}}" is due to be returned to {{owner_name}} on {{due_date}}.</p><p>Please arrange return with the owner. Contact: {{owner_email}}</p><p><a href="{{booking_url}}">View booking details</a></p>', 
 '{"item_title": "Item title", "due_date": "Due date", "owner_name": "Owner full name", "owner_email": "Owner email", "booking_url": "URL to booking page"}'),

('overdue_notice', 'Item Overdue', '{{item_title}} is now overdue', 
 '<h2>Item Overdue</h2><p>"{{item_title}}" was due back on {{due_date}} and is now overdue.</p><p>Please contact {{owner_name}} immediately to arrange return: {{owner_email}}</p><p><a href="{{booking_url}}">View booking details</a></p>', 
 '{"item_title": "Item title", "due_date": "Due date", "owner_name": "Owner full name", "owner_email": "Owner email", "booking_url": "URL to booking page"}');

-- Add notification preferences to members table
ALTER TABLE `members` 
ADD COLUMN `member_email_notifications` tinyint(1) DEFAULT 1 COMMENT 'receive email notifications',
ADD COLUMN `member_sms_notifications` tinyint(1) DEFAULT 0 COMMENT 'receive SMS notifications',
ADD COLUMN `member_phone_number` varchar(20) DEFAULT NULL COMMENT 'phone number for SMS',
ADD COLUMN `member_notification_frequency` varchar(20) DEFAULT 'immediate' COMMENT 'immediate, daily, weekly';

-- Create indexes for better performance
CREATE INDEX `idx_things_member` ON `things` (`thing_member_ID`);
CREATE INDEX `idx_things_type_status` ON `things` (`thing_type`, `thing_status`);

-- Add sample data for testing (optional)
-- You can comment these out for production deployment

-- Set some default availability for existing items
UPDATE `things` SET 
  `thing_available_from` = CURDATE(),
  `thing_available_until` = DATE_ADD(CURDATE(), INTERVAL 1 YEAR),
  `thing_min_loan_days` = 1,
  `thing_max_loan_days` = 14,
  `thing_advance_booking_days` = 7
WHERE `thing_available_from` IS NULL;

-- Enable notifications for all existing members
UPDATE `members` SET 
  `member_email_notifications` = 1,
  `member_notification_frequency` = 'immediate'
WHERE `member_email_notifications` IS NULL; 