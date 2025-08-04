-- ======================================================
-- SHARING.CANOL.CYMRU - SCHEMA UPDATES FOR PHASE 2
-- Calendar Booking System & Notification System
-- ======================================================

-- Calendar Booking System Tables
-- ======================================================

-- Main bookings table for loan scheduling
CREATE TABLE `bookings` (
  `booking_ID` int(11) NOT NULL AUTO_INCREMENT,
  `thing_ID` int(11) NOT NULL,
  `member_ID` int(11) NOT NULL COMMENT 'person requesting the loan',
  `owner_ID` int(11) NOT NULL COMMENT 'person who owns the item',
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
  `member_ID` int(11) NOT NULL,
  `notification_type` varchar(50) NOT NULL COMMENT 'booking_request, booking_approved, due_reminder, etc',
  `notification_title` varchar(255) NOT NULL,
  `notification_message` text NOT NULL,
  `notification_data` json DEFAULT NULL COMMENT 'structured data for the notification',
  `notification_status` tinyint(4) DEFAULT 1 COMMENT '1=pending, 2=sent, 3=failed, 4=read',
  `notification_priority` tinyint(4) DEFAULT 3 COMMENT '1=urgent, 2=high, 3=normal, 4=low',
  `notification_created` datetime DEFAULT current_timestamp(),
  `notification_sent` datetime DEFAULT NULL,
  `notification_read` datetime DEFAULT NULL,
  `notification_attempts` int(11) DEFAULT 0 COMMENT 'delivery attempt count',
  `notification_error` text DEFAULT NULL COMMENT 'error message if failed',
  PRIMARY KEY (`notification_ID`),
  FOREIGN KEY (`member_ID`) REFERENCES `members`(`member_ID`) ON DELETE CASCADE,
  KEY `idx_notification_status` (`notification_status`),
  KEY `idx_notification_type` (`notification_type`),
  KEY `idx_notification_created` (`notification_created`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Email templates for consistent messaging
CREATE TABLE `notification_templates` (
  `template_ID` int(11) NOT NULL AUTO_INCREMENT,
  `template_name` varchar(100) NOT NULL,
  `template_subject` varchar(255) NOT NULL,
  `template_body_html` text NOT NULL,
  `template_body_text` text NOT NULL,
  `template_variables` json DEFAULT NULL COMMENT 'available template variables',
  `template_active` tinyint(1) DEFAULT 1,
  `template_created` datetime DEFAULT current_timestamp(),
  `template_updated` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`template_ID`),
  UNIQUE KEY `template_name` (`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Add notification preferences to existing members table
ALTER TABLE `members` 
ADD COLUMN `email_notifications` tinyint(1) DEFAULT 1 COMMENT 'receive email notifications',
ADD COLUMN `sms_notifications` tinyint(1) DEFAULT 0 COMMENT 'receive SMS notifications',
ADD COLUMN `phone_number` varchar(20) DEFAULT NULL COMMENT 'mobile number for SMS',
ADD COLUMN `notification_frequency` varchar(20) DEFAULT 'immediate' COMMENT 'immediate, daily, weekly',
ADD COLUMN `last_login` datetime DEFAULT NULL COMMENT 'track user activity',
ADD COLUMN `timezone` varchar(50) DEFAULT 'Europe/London' COMMENT 'user timezone';

-- Insert default notification templates
INSERT INTO `notification_templates` (`template_name`, `template_subject`, `template_body_html`, `template_body_text`, `template_variables`) VALUES

('booking_request', 
'New Booking Request for {item_title}', 
'<h2>New Booking Request</h2><p>Hello {owner_name},</p><p>{requester_name} would like to borrow your <strong>{item_title}</strong> from {start_date} to {end_date}.</p><p><strong>Notes:</strong> {booking_notes}</p><p><a href="{approval_link}">Approve or Decline Request</a></p><p>Best regards,<br>Sharing Canol Cymru</p>',
'New Booking Request\n\nHello {owner_name},\n\n{requester_name} would like to borrow your {item_title} from {start_date} to {end_date}.\n\nNotes: {booking_notes}\n\nApprove or decline: {approval_link}\n\nBest regards,\nSharing Canol Cymru',
'["owner_name", "requester_name", "item_title", "start_date", "end_date", "booking_notes", "approval_link"]'),

('booking_approved', 
'Your Booking Request Approved: {item_title}', 
'<h2>Booking Approved!</h2><p>Hello {requester_name},</p><p>Good news! {owner_name} has approved your request to borrow <strong>{item_title}</strong> from {start_date} to {end_date}.</p><p><strong>Owner Contact:</strong> {owner_email}</p><p>Please arrange collection details directly with the owner.</p><p>Best regards,<br>Sharing Canol Cymru</p>',
'Booking Approved!\n\nHello {requester_name},\n\nGood news! {owner_name} has approved your request to borrow {item_title} from {start_date} to {end_date}.\n\nOwner Contact: {owner_email}\n\nPlease arrange collection details directly with the owner.\n\nBest regards,\nSharing Canol Cymru',
'["requester_name", "owner_name", "item_title", "start_date", "end_date", "owner_email"]'),

('due_reminder', 
'Reminder: {item_title} Due for Return', 
'<h2>Return Reminder</h2><p>Hello {borrower_name},</p><p>This is a friendly reminder that <strong>{item_title}</strong> is due for return on {due_date}.</p><p>Please contact {owner_name} at {owner_email} to arrange return.</p><p>Thank you for using Sharing Canol Cymru!</p>',
'Return Reminder\n\nHello {borrower_name},\n\nThis is a friendly reminder that {item_title} is due for return on {due_date}.\n\nPlease contact {owner_name} at {owner_email} to arrange return.\n\nThank you for using Sharing Canol Cymru!',
'["borrower_name", "item_title", "due_date", "owner_name", "owner_email"]');

-- ======================================================
-- INDEXES FOR PERFORMANCE
-- ======================================================

-- Booking system indexes
CREATE INDEX idx_things_availability ON things(thing_available_from, thing_available_until);
CREATE INDEX idx_things_type_status ON things(thing_type, thing_status);

-- Notification system indexes  
CREATE INDEX idx_notifications_pending ON notifications(notification_status, notification_created);
CREATE INDEX idx_notifications_member_unread ON notifications(member_ID, notification_status);

-- ======================================================
-- SAMPLE DATA (for testing)
-- ======================================================

-- Sample booking (uncomment for testing)
-- INSERT INTO bookings (thing_ID, member_ID, owner_ID, booking_start_date, booking_end_date, booking_notes) 
-- VALUES (31, 97, 85, '2025-08-15', '2025-08-20', 'Need for DIY project');

-- ======================================================
-- DEPLOYMENT NOTES
-- ======================================================

-- To deploy this schema:
-- 1. Backup existing database
-- 2. Run this script against your sharingcanol_stuff database
-- 3. Update includes/connect.inc if needed
-- 4. Test with sample data
-- 5. Deploy new PHP files

-- Rollback script (if needed):
-- DROP TABLE IF EXISTS bookings;
-- DROP TABLE IF EXISTS notifications; 
-- DROP TABLE IF EXISTS notification_templates;
-- ALTER TABLE things DROP COLUMN thing_available_from;
-- ALTER TABLE things DROP COLUMN thing_available_until;
-- ALTER TABLE things DROP COLUMN thing_min_loan_days;
-- ALTER TABLE things DROP COLUMN thing_max_loan_days;
-- ALTER TABLE things DROP COLUMN thing_advance_booking_days;
-- ALTER TABLE members DROP COLUMN email_notifications;
-- ALTER TABLE members DROP COLUMN sms_notifications;
-- ALTER TABLE members DROP COLUMN phone_number;
-- ALTER TABLE members DROP COLUMN notification_frequency;
-- ALTER TABLE members DROP COLUMN last_login;
-- ALTER TABLE members DROP COLUMN timezone; 