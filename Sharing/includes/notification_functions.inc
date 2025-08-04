<?php
// ======================================================
// NOTIFICATION SYSTEM HELPER FUNCTIONS
// Following existing code patterns from miscfunctions.inc
// ======================================================

// Create a new notification
function create_notification($member_ID, $type, $title, $message, $data = null, $priority = 3) {
    global $mysqli;
    
    // Handle NULL data properly
    $data_value = ($data === null) ? 'NULL' : qq($data);
    
    $query = "INSERT INTO notifications (member_ID, notification_type, notification_title, notification_message, notification_data, notification_priority) 
              VALUES (".qq($member_ID).", ".qq($type).", ".qq($title).", ".qq($message).", ".$data_value.", ".qq($priority).")";
    
    $result = $mysqli->query($query);
    
    if ($result) {
        return $mysqli->insert_id;
    }
    
    return false;
}

// Get notifications for a member
function get_member_notifications($member_ID, $limit = 10, $unread_only = false) {
    global $mysqli;
    
    $where_clause = "WHERE member_ID = ".qq($member_ID);
    if ($unread_only) {
        $where_clause .= " AND notification_status = 1";
    }
    
    $query = "SELECT * FROM notifications 
              $where_clause 
              ORDER BY notification_created DESC 
              LIMIT ".intval($limit);
    
    $result = $mysqli->query($query);
    $notifications = array();
    
    while ($row = $result->fetch_assoc()) {
        $notifications[] = $row;
    }
    
    return $notifications;
}

// Mark notification as read
function mark_notification_read($notification_ID, $member_ID) {
    global $mysqli;
    
    $query = "UPDATE notifications 
              SET notification_status = 4, notification_read = NOW() 
              WHERE notification_ID = ".qq($notification_ID)." 
              AND member_ID = ".qq($member_ID);
    
    return $mysqli->query($query);
}

// Get unread notification count
function get_unread_notification_count($member_ID) {
    global $mysqli;
    
    $query = "SELECT COUNT(*) as unread_count FROM notifications 
              WHERE member_ID = ".qq($member_ID)." 
              AND notification_status = 1";
    
    $result = $mysqli->query($query);
    $row = $result->fetch_assoc();
    
    return $row['unread_count'];
}

// Send pending notifications (for cron job)
function process_pending_notifications($limit = 50) {
    global $mysqli;
    
    // Get pending notifications
    $query = "SELECT n.*, m.member_email, m.member_fname, m.email_notifications, m.sms_notifications, m.phone_number
              FROM notifications n
              JOIN members m ON n.member_ID = m.member_ID
              WHERE n.notification_status = 1 
              AND n.notification_attempts < 3
              ORDER BY n.notification_priority ASC, n.notification_created ASC
              LIMIT ".intval($limit);
    
    $result = $mysqli->query($query);
    $sent_count = 0;
    $failed_count = 0;
    
    while ($row = $result->fetch_assoc()) {
        $success = false;
        $error_message = '';
        
        // Send email if enabled
        if ($row['email_notifications'] == 1) {
            $success = send_email_notification($row);
            if (!$success) {
                $error_message = 'Email sending failed';
            }
        }
        
        // Send SMS if enabled (not implemented yet)
        if ($row['sms_notifications'] == 1 && !empty($row['phone_number'])) {
            // TODO: Implement SMS sending
            // $sms_success = send_sms_notification($row);
        }
        
        // Update notification status
        $new_status = $success ? 2 : 3; // 2 = sent, 3 = failed
        $attempts = $row['notification_attempts'] + 1;
        
        $update_query = "UPDATE notifications 
                        SET notification_status = ".qq($new_status).", 
                            notification_sent = ".($success ? "NOW()" : "NULL").",
                            notification_attempts = ".qq($attempts).",
                            notification_error = ".qq($error_message)."
                        WHERE notification_ID = ".qq($row['notification_ID']);
        
        $mysqli->query($update_query);
        
        if ($success) {
            $sent_count++;
        } else {
            $failed_count++;
        }
    }
    
    return array('sent' => $sent_count, 'failed' => $failed_count);
}

// Send email notification using basic PHP mail()
function send_email_notification($notification_data) {
    // Get email template
    $template = get_notification_template($notification_data['notification_type']);
    
    if (!$template) {
        // Fallback to basic email
        $subject = $notification_data['notification_title'];
        $message = $notification_data['notification_message'];
    } else {
        // Use template
        $subject = replace_template_variables($template['template_subject'], $notification_data);
        $message = replace_template_variables($template['template_body_text'], $notification_data);
    }
    
    // Basic email headers
    $headers = array(
        'From: Sharing Canol Cymru <noreply@sharing.canol.cymru>',
        'Reply-To: noreply@sharing.canol.cymru',
        'X-Mailer: PHP/' . phpversion()
    );
    
    $headers_string = implode("\r\n", $headers);
    
    // Send email
    return mail($notification_data['member_email'], $subject, $message, $headers_string);
}

// Get notification template
function get_notification_template($template_name) {
    global $mysqli;
    
    $query = "SELECT * FROM notification_templates 
              WHERE template_name = ".qq($template_name)." 
              AND template_active = 1";
    
    $result = $mysqli->query($query);
    
    if ($result && $result->num_rows > 0) {
        return $result->fetch_assoc();
    }
    
    return null;
}

// Replace template variables
function replace_template_variables($template_text, $notification_data) {
    global $mysqli;
    
    // Parse notification data if it's JSON
    $data = array();
    if (!empty($notification_data['notification_data'])) {
        $data = json_decode($notification_data['notification_data'], true);
    }
    
    // Get member info
    $query = "SELECT * FROM members WHERE member_ID = ".qq($notification_data['member_ID']);
    $result = $mysqli->query($query);
    $member = $result->fetch_assoc();
    
    // Basic replacements
    $replacements = array(
        '{member_name}' => $member['member_fname'].' '.$member['member_lname'],
        '{member_fname}' => $member['member_fname'],
        '{member_email}' => $member['member_email'],
        '{site_url}' => 'https://sharing.canol.cymru'
    );
    
    // Booking-specific replacements
    if (isset($data['booking_ID'])) {
        $booking_query = "SELECT b.*, t.thing_title, t.thing_price,
                                 owner.member_fname as owner_fname, owner.member_email as owner_email,
                                 requester.member_fname as requester_fname, requester.member_email as requester_email
                          FROM bookings b
                          JOIN things t ON b.thing_ID = t.thing_ID
                          JOIN members owner ON b.owner_ID = owner.member_ID
                          JOIN members requester ON b.member_ID = requester.member_ID
                          WHERE b.booking_ID = ".qq($data['booking_ID']);
        
        $booking_result = $mysqli->query($booking_query);
        if ($booking_result && $booking_result->num_rows > 0) {
            $booking = $booking_result->fetch_assoc();
            
            $replacements['{item_title}'] = $booking['thing_title'];
            $replacements['{start_date}'] = format_display_date($booking['booking_start_date']);
            $replacements['{end_date}'] = format_display_date($booking['booking_end_date']);
            $replacements['{due_date}'] = format_display_date($booking['booking_end_date']);
            $replacements['{booking_notes}'] = $booking['booking_notes'];
            $replacements['{owner_name}'] = $booking['owner_fname'].' '.$booking['owner_lname'];
            $replacements['{owner_email}'] = $booking['owner_email'];
            $replacements['{requester_name}'] = $booking['requester_fname'].' '.$booking['requester_lname'];
            $replacements['{borrower_name}'] = $booking['requester_fname'].' '.$booking['requester_lname'];
            $replacements['{approval_link}'] = 'https://sharing.canol.cymru/manage_bookings.php?booking_id='.$booking['booking_ID'];
        }
    }
    
    // Perform replacements
    foreach ($replacements as $placeholder => $value) {
        $template_text = str_replace($placeholder, $value, $template_text);
    }
    
    return $template_text;
}

// Get notification type display info
function get_notification_type_info($type) {
    $types = array(
        'booking_request' => array('icon' => '📅', 'color' => '#FFA500'),
        'booking_approved' => array('icon' => '✅', 'color' => '#008000'),
        'booking_declined' => array('icon' => '❌', 'color' => '#FF0000'),
        'due_reminder' => array('icon' => '⏰', 'color' => '#FF6600'),
        'new_item' => array('icon' => '🆕', 'color' => '#0066CC'),
        'community_update' => array('icon' => '🏘️', 'color' => '#800080'),
        'system' => array('icon' => '⚙️', 'color' => '#808080')
    );
    
    return isset($types[$type]) ? $types[$type] : array('icon' => '📢', 'color' => '#000000');
}

// Format notification for display (using existing cell helper pattern)
function format_notification_row($notification) {
    $type_info = get_notification_type_info($notification['notification_type']);
    $status_color = ($notification['notification_status'] == 1) ? '#000000' : '#808080';
    $time_ago = time_ago($notification['notification_created']);
    
    $title_display = '<span style="color: '.$status_color.'">'.$type_info['icon'].' '.$notification['notification_title'].'</span>';
    $message_display = '<span style="color: '.$status_color.'">'.substr($notification['notification_message'], 0, 100).'...</span>';
    $time_display = '<span style="color: #808080; font-size: 0.9em;">'.$time_ago.'</span>';
    
    return cell3($title_display, $message_display, $time_display);
}

// Simple time ago function
function time_ago($datetime) {
    $time = time() - strtotime($datetime);
    
    if ($time < 60) return 'just now';
    if ($time < 3600) return floor($time/60).' min ago';
    if ($time < 86400) return floor($time/3600).' hours ago';
    if ($time < 2592000) return floor($time/86400).' days ago';
    
    return date('j M Y', strtotime($datetime));
}

?> 