<?php
// ======================================================
// CRON JOB SCRIPT FOR PROCESSING NOTIFICATIONS
// Run this script every 5-15 minutes via cron
// Example cron entry: */15 * * * * /usr/bin/php /path/to/sharing/cron_notifications.php
// ======================================================

// Prevent web access
if (isset($_SERVER['HTTP_HOST'])) {
    die('This script can only be run from command line.');
}

// Include required files
require_once(__DIR__ . '/includes/connect.inc');
require_once(__DIR__ . '/includes/miscfunctions.inc');
require_once(__DIR__ . '/includes/notification_functions.inc');
require_once(__DIR__ . '/includes/booking_functions.inc');

echo "[".date('Y-m-d H:i:s')."] Starting notification processing...\n";

// 1. Process pending notifications
echo "Processing pending notifications...\n";
$results = process_pending_notifications(100);
echo "Sent: {$results['sent']}, Failed: {$results['failed']}\n";

// 2. Generate due date reminders
echo "Checking for due date reminders...\n";
$due_returns = get_due_returns(1); // Items due tomorrow

foreach ($due_returns as $return) {
    // Check if reminder already sent
    $check_query = "SELECT COUNT(*) as reminder_count FROM notifications 
                    WHERE member_ID = ".qq($return['member_ID'])." 
                    AND notification_type = 'due_reminder'
                    AND notification_data LIKE '%\"booking_ID\":".$return['booking_ID']."%'
                    AND notification_created > DATE_SUB(NOW(), INTERVAL 2 DAY)";
    
    $check_result = $mysqli->query($check_query);
    $check_row = $check_result->fetch_assoc();
    
    if ($check_row['reminder_count'] == 0) {
        // Create reminder notification
        $notification_id = create_notification(
            $return['member_ID'],
            'due_reminder',
            'Reminder: '.$return['thing_title'].' due for return',
            'Don\'t forget to return '.$return['thing_title'].' to '.$return['owner_fname'].' by '.format_display_date($return['booking_end_date']),
            json_encode(['booking_ID' => $return['booking_ID']]),
            2 // High priority
        );
        
        if ($notification_id) {
            echo "Created due reminder for booking ID {$return['booking_ID']}\n";
        }
    }
}

// 3. Auto-mark overdue loans (optional)
echo "Checking for overdue returns...\n";
$overdue_query = "UPDATE bookings 
                  SET booking_status = 4
                  WHERE booking_status = 3 
                  AND booking_end_date < CURDATE() - INTERVAL 7 DAY";
$overdue_result = $mysqli->query($overdue_query);
if ($overdue_result) {
    echo "Auto-marked ".($mysqli->affected_rows)." overdue loans as completed\n";
}

// 4. Clean up old notifications (older than 30 days and read)
echo "Cleaning up old notifications...\n";
$cleanup_query = "DELETE FROM notifications 
                  WHERE notification_status = 4 
                  AND notification_read < DATE_SUB(NOW(), INTERVAL 30 DAY)";
$cleanup_result = $mysqli->query($cleanup_query);
if ($cleanup_result) {
    echo "Cleaned up ".($mysqli->affected_rows)." old notifications\n";
}

// 5. Update member last login tracking (if session data available)
// This would typically be done in the login process, but we can clean up stale data here

// 6. Generate community fund notifications (future feature)
// Check if community fund threshold reached, generate voting notifications etc.

echo "[".date('Y-m-d H:i:s')."] Notification processing complete.\n";
echo "---\n";

// Close database connection
$mysqli->close();

// Exit successfully
exit(0);

?> 