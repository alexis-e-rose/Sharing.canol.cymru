<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>My Bookings - Sharing Canol Cymru</title>
</head>
<body>

<?php 
$page = "my_bookings";
include("includes/connect.inc");
include("includes/miscfunctions.inc");
include("includes/booking_functions.inc");
include("includes/notification_functions.inc");
include("includes/header.inc"); 

// Handle booking status updates
if (isset($_POST["action"]) && isset($_POST["booking_id"]) && $_POST["action"] == "approve" && $_POST["booking_id"]) {
    $result = update_booking_status($_POST["booking_id"], 2, $_SESSION["member_ID"]);
    if ($result) {
        echo '<p style="color: green;">Booking approved successfully!</p>';
    } else {
        echo '<p style="color: red;">Error approving booking.</p>';
    }
}

if (isset($_POST["action"]) && isset($_POST["booking_id"]) && $_POST["action"] == "decline" && $_POST["booking_id"]) {
    $result = update_booking_status($_POST["booking_id"], 5, $_SESSION["member_ID"]);
    if ($result) {
        echo '<p style="color: green;">Booking declined.</p>';
    } else {
        echo '<p style="color: red;">Error declining booking.</p>';
    }
}

if (isset($_POST["action"]) && isset($_POST["booking_id"]) && $_POST["action"] == "mark_returned" && $_POST["booking_id"]) {
    $query = "UPDATE bookings SET booking_status = 4, booking_returned_date = NOW() 
              WHERE booking_ID = ".qq($_POST["booking_id"])." 
              AND owner_ID = ".qq($_SESSION["member_ID"]);
    $result = $mysqli->query($query);
    if ($result) {
        echo '<p style="color: green;">Item marked as returned!</p>';
    }
}

echo '<h2>My Bookings</h2>';

// Get bookings as requester
echo '<h3>Items I\'ve Requested to Borrow</h3>';
$my_requests = get_member_bookings(isset($_SESSION["member_ID"]) ? $_SESSION["member_ID"] : 0, false);

if (empty($my_requests)) {
    echo '<p>You haven\'t made any booking requests yet.</p>';
} else {
    echo '<table border="1" style="border-collapse: collapse; width: 100%;">';
    echo '<tr style="background-color: #f0f0f0;">';
    echo '<td><b>Item</b></td>';
    echo '<td><b>Owner</b></td>';
    echo '<td><b>Dates</b></td>';
    echo '<td><b>Status</b></td>';
    echo '<td><b>Notes</b></td>';
    echo '</tr>';
    
    foreach ($my_requests as $booking) {
        $status_text = get_booking_status_text($booking['booking_status']);
        $status_color = get_booking_status_color($booking['booking_status']);
        
        echo '<tr>';
        echo '<td>'.$booking['thing_title'].'</td>';
        echo '<td>'.$booking['owner_fname'].' '.$booking['owner_lname'].'</td>';
        echo '<td>'.format_display_date($booking['booking_start_date']).' to '.format_display_date($booking['booking_end_date']).'</td>';
        echo '<td style="color: '.$status_color.'">'.$status_text.'</td>';
        echo '<td>'.$booking['booking_notes'].'</td>';
        echo '</tr>';
    }
    echo '</table>';
}

echo '<br><br>';

// Get bookings as owner
echo '<h3>Requests for My Items</h3>';
$owner_requests = get_member_bookings(isset($_SESSION["member_ID"]) ? $_SESSION["member_ID"] : 0, true);

if (empty($owner_requests)) {
    echo '<p>No one has requested to borrow your items yet.</p>';
} else {
    echo '<table border="1" style="border-collapse: collapse; width: 100%;">';
    echo '<tr style="background-color: #f0f0f0;">';
    echo '<td><b>Item</b></td>';
    echo '<td><b>Requester</b></td>';
    echo '<td><b>Dates</b></td>';
    echo '<td><b>Status</b></td>';
    echo '<td><b>Notes</b></td>';
    echo '<td><b>Actions</b></td>';
    echo '</tr>';
    
    foreach ($owner_requests as $booking) {
        $status_text = get_booking_status_text($booking['booking_status']);
        $status_color = get_booking_status_color($booking['booking_status']);
        
        echo '<tr>';
        echo '<td>'.$booking['thing_title'].'</td>';
        echo '<td>'.$booking['requester_fname'].' '.$booking['requester_lname'].'</td>';
        echo '<td>'.format_display_date($booking['booking_start_date']).' to '.format_display_date($booking['booking_end_date']).'</td>';
        echo '<td style="color: '.$status_color.'">'.$status_text.'</td>';
        echo '<td>'.$booking['booking_notes'].'</td>';
        echo '<td>';
        
        // Show appropriate actions based on status
        if ($booking['booking_status'] == 1) {
            // Pending - show approve/decline
            echo '<form method="post" style="display: inline;">';
            echo '<input type="hidden" name="booking_id" value="'.$booking['booking_ID'].'">';
            echo '<input type="hidden" name="action" value="approve">';
            echo '<input type="submit" value="Approve" style="background-color: #008000; color: white; border: none; padding: 3px 8px; margin: 1px;">';
            echo '</form>';
            
            echo '<form method="post" style="display: inline;">';
            echo '<input type="hidden" name="booking_id" value="'.$booking['booking_ID'].'">';
            echo '<input type="hidden" name="action" value="decline">';
            echo '<input type="submit" value="Decline" style="background-color: #FF0000; color: white; border: none; padding: 3px 8px; margin: 1px;">';
            echo '</form>';
        } elseif ($booking['booking_status'] == 3) {
            // Active - show mark as returned
            echo '<form method="post" style="display: inline;">';
            echo '<input type="hidden" name="booking_id" value="'.$booking['booking_ID'].'">';
            echo '<input type="hidden" name="action" value="mark_returned">';
            echo '<input type="submit" value="Mark Returned" style="background-color: #0066CC; color: white; border: none; padding: 3px 8px;">';
            echo '</form>';
        } else {
            echo '-';
        }
        
        echo '</td>';
        echo '</tr>';
    }
    echo '</table>';
}

echo '<br><br>';

// Quick stats
$total_requests = count($my_requests);
$total_owner_requests = count($owner_requests);
$pending_requests = 0;
$active_loans = 0;

foreach ($my_requests as $booking) {
    if ($booking['booking_status'] == 1) $pending_requests++;
    if ($booking['booking_status'] == 3) $active_loans++;
}

echo '<h3>Quick Stats</h3>';
echo '<table>';
echo cell2("Requests I've made:", $total_requests);
echo cell2("Requests for my items:", $total_owner_requests);
echo cell2("My pending requests:", $pending_requests);
echo cell2("Items I'm currently borrowing:", $active_loans);
echo '</table>';

?>

<br><br>
<a href="search.php">← Back to Search Items</a> | 
<a href="add_listing.php">Add New Item</a> | 
<a href="account.php">My Account</a>

</body>
</html> 