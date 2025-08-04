<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>My Notifications - Sharing Canol Cymru</title>
    <style>
        .notification { border: 1px solid #ddd; margin: 10px 0; padding: 10px; }
        .notification.unread { background-color: #f0f8ff; border-left: 4px solid #0066cc; }
        .notification.read { background-color: #f8f8f8; }
        .notification-actions { margin-top: 10px; }
        .mark-read-btn { background-color: #0066cc; color: white; border: none; padding: 3px 8px; font-size: 12px; }
    </style>
</head>
<body>

<?php 
$page = "notifications";
include("includes/connect.inc");
include("includes/miscfunctions.inc");
include("includes/notification_functions.inc");
include("includes/header.inc"); 

// Handle mark as read
if ($_POST["mark_read"] && $_POST["notification_id"]) {
    mark_notification_read($_POST["notification_id"], $_SESSION["member_ID"]);
    echo '<p style="color: green;">Notification marked as read.</p>';
}

// Handle mark all as read
if ($_POST["mark_all_read"]) {
    $query = "UPDATE notifications 
              SET notification_status = 4, notification_read = NOW() 
              WHERE member_ID = ".qq($_SESSION["member_ID"])." 
              AND notification_status = 1";
    $mysqli->query($query);
    echo '<p style="color: green;">All notifications marked as read.</p>';
}

echo '<h2>My Notifications</h2>';

// Get notification counts
$unread_count = get_unread_notification_count($_SESSION["member_ID"]);
$all_notifications = get_member_notifications($_SESSION["member_ID"], 20, false);

echo '<p>';
if ($unread_count > 0) {
    echo '<strong>'.$unread_count.' unread notifications</strong> | ';
    echo '<form method="post" style="display: inline;">';
    echo '<input type="hidden" name="mark_all_read" value="1">';
    echo '<input type="submit" value="Mark All as Read" class="mark-read-btn">';
    echo '</form>';
} else {
    echo '<em>No unread notifications</em>';
}
echo '</p>';

if (empty($all_notifications)) {
    echo '<p>You have no notifications yet.</p>';
} else {
    foreach ($all_notifications as $notification) {
        $is_unread = ($notification['notification_status'] == 1);
        $type_info = get_notification_type_info($notification['notification_type']);
        
        echo '<div class="notification '.($is_unread ? 'unread' : 'read').'">';
        echo '<div style="display: flex; justify-content: space-between; align-items: flex-start;">';
        echo '<div style="flex: 1;">';
        echo '<strong style="color: '.$type_info['color'].'">'.$type_info['icon'].' '.$notification['notification_title'].'</strong>';
        if ($is_unread) echo ' <span style="color: #0066cc; font-size: 12px;">[NEW]</span>';
        echo '<br>';
        echo '<div style="margin: 8px 0;">'.$notification['notification_message'].'</div>';
        echo '<small style="color: #666;">'.time_ago($notification['notification_created']).'</small>';
        echo '</div>';
        
        if ($is_unread) {
            echo '<div class="notification-actions">';
            echo '<form method="post" style="display: inline;">';
            echo '<input type="hidden" name="notification_id" value="'.$notification['notification_ID'].'">';
            echo '<input type="hidden" name="mark_read" value="1">';
            echo '<input type="submit" value="Mark Read" class="mark-read-btn">';
            echo '</form>';
            echo '</div>';
        }
        echo '</div>';
        echo '</div>';
    }
}

// Notification preferences
echo '<br><hr><br>';
echo '<h3>Notification Preferences</h3>';

// Get current preferences
$query = "SELECT member_email_notifications, member_sms_notifications, member_phone_number, member_notification_frequency 
          FROM members WHERE member_ID = ".qq($_SESSION["member_ID"]);
$result = $mysqli->query($query);
$prefs = $result->fetch_assoc();

// Handle preference updates
    if (isset($_POST["update_preferences"]) && $_POST["update_preferences"]) {
        $email_notifications = isset($_POST["email_notifications"]) ? 1 : 0;
        $sms_notifications = isset($_POST["sms_notifications"]) ? 1 : 0;
        $phone_number = isset($_POST["phone_number"]) ? $_POST["phone_number"] : '';
        $notification_frequency = isset($_POST["notification_frequency"]) ? $_POST["notification_frequency"] : 'immediate';
    
    $query = "UPDATE members 
              SET member_email_notifications = ".qq($email_notifications).", 
                  member_sms_notifications = ".qq($sms_notifications).",
                  member_phone_number = ".qq($phone_number).",
                  member_notification_frequency = ".qq($notification_frequency)."
              WHERE member_ID = ".qq($_SESSION["member_ID"]);
    
    if ($mysqli->query($query)) {
        echo '<p style="color: green;">Preferences updated successfully!</p>';
        // Refresh preferences
        $prefs['member_email_notifications'] = $email_notifications;
        $prefs['member_sms_notifications'] = $sms_notifications;
        $prefs['member_phone_number'] = $phone_number;
        $prefs['member_notification_frequency'] = $notification_frequency;
    } else {
        echo '<p style="color: red;">Error updating preferences.</p>';
    }
}

echo '<form method="post">';
echo '<table>';

// Email notifications
$email_checked = isset($prefs['member_email_notifications']) && $prefs['member_email_notifications'] ? 'checked' : '';
echo cell2("Email Notifications:", '<input type="checkbox" name="email_notifications" value="1" '.$email_checked.'> Receive notifications by email');

// SMS notifications (future feature)
$sms_checked = isset($prefs['member_sms_notifications']) && $prefs['member_sms_notifications'] ? 'checked' : '';
echo cell2("SMS Notifications:", '<input type="checkbox" name="sms_notifications" value="1" '.$sms_checked.'> Receive urgent notifications by SMS <em>(coming soon)</em>');

// Phone number
$phone_value = isset($prefs['member_phone_number']) ? $prefs['member_phone_number'] : '';
echo cell2("Mobile Number:", '<input type="tel" name="phone_number" value="'.$phone_value.'" placeholder="+44 7xxx xxx xxx"> For SMS notifications');

// Frequency
$frequency_options = array(
    'immediate' => 'Immediate (as they happen)',
    'daily' => 'Daily digest (once per day)',
    'weekly' => 'Weekly digest (once per week)'
);

$frequency_select = '<select name="notification_frequency">';
foreach ($frequency_options as $value => $label) {
    $current_frequency = isset($prefs['member_notification_frequency']) ? $prefs['member_notification_frequency'] : 'immediate';
    $selected = ($current_frequency == $value) ? 'selected' : '';
    $frequency_select .= '<option value="'.$value.'" '.$selected.'>'.$label.'</option>';
}
$frequency_select .= '</select>';

echo cell2("Email Frequency:", $frequency_select);

echo cell2("", '<input type="submit" name="update_preferences" value="Update Preferences" style="background-color: #008000; color: white; padding: 8px 16px; border: none;">');

echo '</table>';
echo '</form>';

?>

<br><br>
<a href="account.php">← Back to Account</a> | 
<a href="my_bookings.php">My Bookings</a>

</body>
</html> 