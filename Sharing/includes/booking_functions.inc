<?php
// ======================================================
// BOOKING SYSTEM HELPER FUNCTIONS
// Following existing code patterns from miscfunctions.inc
// ======================================================

// Include required functions
require_once 'miscfunctions.inc';

// Check if item is available for booking on specific dates
function check_booking_availability($thing_ID, $start_date, $end_date) {
    global $mysqli;
    
    $query = "SELECT COUNT(*) as conflict_count FROM bookings 
              WHERE thing_ID = ".qq($thing_ID)." 
              AND booking_status IN (2,3) 
              AND ((booking_start_date <= ".qq($start_date)." AND booking_end_date >= ".qq($start_date).") 
                   OR (booking_start_date <= ".qq($end_date)." AND booking_end_date >= ".qq($end_date).") 
                   OR (booking_start_date >= ".qq($start_date)." AND booking_end_date <= ".qq($end_date)."))";
    
    $result = $mysqli->query($query);
    $row = $result->fetch_assoc();
    
    return $row['conflict_count'] == 0;
}

// Get booking status text
function get_booking_status_text($status) {
    switch($status) {
        case 1: return "Pending Approval";
        case 2: return "Approved";
        case 3: return "Active (Borrowed)";
        case 4: return "Completed";
        case 5: return "Cancelled";
        default: return "Unknown";
    }
}

// Get booking status color for display
function get_booking_status_color($status) {
    switch($status) {
        case 1: return "#FFA500"; // orange
        case 2: return "#008000"; // green
        case 3: return "#0066CC"; // blue
        case 4: return "#808080"; // gray
        case 5: return "#FF0000"; // red
        default: return "#000000"; // black
    }
}

// Create a booking request
function create_booking_request($thing_ID, $member_ID, $start_date, $end_date, $notes = '') {
    global $mysqli;
    
    // Get owner ID
    $query = "SELECT thing_member_ID FROM things WHERE thing_ID = ".qq($thing_ID);
    $result = $mysqli->query($query);
    $thing = $result->fetch_assoc();
    $owner_ID = $thing['thing_member_ID'];
    
    // Check availability
    if (!check_booking_availability($thing_ID, $start_date, $end_date)) {
        return false;
    }
    
    // Create booking
    $query = "INSERT INTO bookings (thing_ID, member_ID, owner_ID, booking_start_date, booking_end_date, booking_notes) 
              VALUES (".qq($thing_ID).", ".qq($member_ID).", ".qq($owner_ID).", ".qq($start_date).", ".qq($end_date).", ".qq($notes).")";
    
    $result = $mysqli->query($query);
    
    if ($result) {
        $booking_ID = $mysqli->insert_id;
        
        // Create notification for owner
        create_notification($owner_ID, 'booking_request', 'New Booking Request', 
                          'You have a new booking request for your item');
        
        return $booking_ID;
    }
    
    return false;
}

// Approve or decline a booking
function update_booking_status($booking_ID, $new_status, $member_ID) {
    global $mysqli;
    
    // Verify the member owns the item or is admin
    $query = "SELECT b.*, t.thing_member_ID, t.thing_title 
              FROM bookings b 
              JOIN things t ON b.thing_ID = t.thing_ID 
              WHERE b.booking_ID = ".qq($booking_ID);
    $result = $mysqli->query($query);
    $booking = $result->fetch_assoc();
    
    if (!$booking || $booking['thing_member_ID'] != $member_ID) {
        return false;
    }
    
    // Update status
    $query = "UPDATE bookings 
              SET booking_status = ".qq($new_status).", 
                  booking_approved_date = ".(($new_status == 2) ? "NOW()" : "NULL")." 
              WHERE booking_ID = ".qq($booking_ID);
    
    $result = $mysqli->query($query);
    
    if ($result) {
        // Create notification for requester
        $notification_type = ($new_status == 2) ? 'booking_approved' : 'booking_declined';
        $message = ($new_status == 2) ? 'Your booking request has been approved!' : 'Your booking request has been declined.';
        
        create_notification($booking['member_ID'], $notification_type, 
                          'Booking Update: '.$booking['thing_title'], $message,
                          json_encode(['booking_ID' => $booking_ID]));
        
        return true;
    }
    
    return false;
}

// Get member's bookings (as requester or owner)
function get_member_bookings($member_ID, $as_owner = false) {
    global $mysqli;
    
    $field = $as_owner ? 'owner_ID' : 'member_ID';
    
    $query = "SELECT b.*, t.thing_title, t.thing_price, t.thing_type,
                     requester.member_fname as requester_fname, requester.member_lname as requester_lname,
                     owner.member_fname as owner_fname, owner.member_lname as owner_lname
              FROM bookings b
              JOIN things t ON b.thing_ID = t.thing_ID
              JOIN members requester ON b.member_ID = requester.member_ID
              JOIN members owner ON b.owner_ID = owner.member_ID
              WHERE b.".$field." = ".qq($member_ID)."
              ORDER BY b.booking_created DESC";
    
    $result = $mysqli->query($query);
    $bookings = array();
    
    while ($row = $result->fetch_assoc()) {
        $bookings[] = $row;
    }
    
    return $bookings;
}

// Get upcoming due returns (for reminders)
function get_due_returns($days_ahead = 1) {
    global $mysqli;
    
    $target_date = date('Y-m-d', strtotime("+$days_ahead days"));
    
    $query = "SELECT b.*, t.thing_title, 
                     borrower.member_fname as borrower_fname, borrower.member_email as borrower_email,
                     owner.member_fname as owner_fname, owner.member_email as owner_email
              FROM bookings b
              JOIN things t ON b.thing_ID = t.thing_ID
              JOIN members borrower ON b.member_ID = borrower.member_ID
              JOIN members owner ON b.owner_ID = owner.member_ID
              WHERE b.booking_status = 3 
              AND b.booking_end_date = ".qq($target_date);
    
    $result = $mysqli->query($query);
    $due_returns = array();
    
    while ($row = $result->fetch_assoc()) {
        $due_returns[] = $row;
    }
    
    return $due_returns;
}

// Format date for display (consistent with existing patterns)
function format_display_date($date) {
    return date('j M Y', strtotime($date));
}

// Calculate daily price for loan items
function calculate_loan_cost($thing_price, $days) {
    return $thing_price * $days;
}

// Generate calendar availability display (simple version)
function generate_availability_calendar($thing_ID, $month = null, $year = null) {
    global $mysqli;
    
    if (!$month) $month = date('n');
    if (!$year) $year = date('Y');
    
    // Get all bookings for this item in the month
    $start_of_month = "$year-".str_pad($month, 2, '0', STR_PAD_LEFT)."-01";
    $end_of_month = date('Y-m-t', strtotime($start_of_month));
    
    $query = "SELECT booking_start_date, booking_end_date 
              FROM bookings 
              WHERE thing_ID = ".qq($thing_ID)." 
              AND booking_status IN (2,3)
              AND ((booking_start_date <= ".qq($end_of_month)." AND booking_end_date >= ".qq($start_of_month)."))";
    
    $result = $mysqli->query($query);
    $booked_dates = array();
    
    while ($row = $result->fetch_assoc()) {
        $current = strtotime($row['booking_start_date']);
        $end = strtotime($row['booking_end_date']);
        
        while ($current <= $end) {
            $booked_dates[] = date('Y-m-d', $current);
            $current = strtotime('+1 day', $current);
        }
    }
    
    return $booked_dates;
}

?> 