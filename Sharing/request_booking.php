<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Request Booking - Sharing Canol Cymru</title>
    <style>
        .booking-form { max-width: 600px; }
        .date-input { width: 150px; padding: 5px; }
        .notes-input { width: 100%; height: 80px; padding: 5px; }
        .error { color: red; background-color: #ffe6e6; padding: 10px; margin: 10px 0; }
        .success { color: green; background-color: #e6ffe6; padding: 10px; margin: 10px 0; }
        .availability-info { background-color: #f0f8ff; padding: 10px; margin: 10px 0; border-left: 4px solid #0066cc; }
        .cost-calculation { background-color: #fffacd; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>

<?php 
$page = "request_booking";
include("includes/connect.inc");
include("includes/miscfunctions.inc");
include("includes/booking_functions.inc");
include("includes/notification_functions.inc");
include("includes/header.inc"); 

$thing_ID = $_GET["thing_id"] ? intval($_GET["thing_id"]) : 0;
$error_message = '';
$success_message = '';

// Get item details
if ($thing_ID > 0) {
    $query = "SELECT t.*, m.member_fname, m.member_lname, m.member_email 
              FROM things t 
              JOIN members m ON t.thing_member_ID = m.member_ID 
              WHERE t.thing_ID = ".qq($thing_ID);
    $result = $mysqli->query($query);
    $item = $result->fetch_assoc();
    
    if (!$item) {
        $error_message = "Item not found.";
    } elseif ($item['thing_member_ID'] == $_SESSION['member_ID']) {
        $error_message = "You cannot book your own item.";
    } elseif ($item['thing_type'] != 1) {
        $error_message = "This item is not available for loan.";
    }
} else {
    $error_message = "No item specified.";
}

// Process booking request
if ($_POST["submit_booking"] && !$error_message) {
    $start_date = $_POST["start_date"];
    $end_date = $_POST["end_date"];
    $notes = $_POST["notes"];
    
    // Validate dates
    if (empty($start_date) || empty($end_date)) {
        $error_message = "Please select both start and end dates.";
    } elseif (strtotime($start_date) < strtotime('today')) {
        $error_message = "Start date cannot be in the past.";
    } elseif (strtotime($end_date) <= strtotime($start_date)) {
        $error_message = "End date must be after start date.";
    } elseif (!check_booking_availability($thing_ID, $start_date, $end_date)) {
        $error_message = "Item is not available for the selected dates.";
    } else {
        // Create booking request
        $booking_ID = create_booking_request($thing_ID, $_SESSION["member_ID"], $start_date, $end_date, $notes);
        
        if ($booking_ID) {
            $success_message = "Booking request submitted successfully! The owner will be notified and you'll hear back soon.";
            // Clear form data
            $start_date = $end_date = $notes = '';
        } else {
            $error_message = "Error creating booking request. Please try again.";
        }
    }
}

if ($error_message) {
    echo '<div class="error">'.$error_message.'</div>';
}

if ($success_message) {
    echo '<div class="success">'.$success_message.'</div>';
}

if ($item && !$error_message) {
    echo '<h2>Request to Borrow: '.$item['thing_title'].'</h2>';
    
    // Item details
    echo '<div class="availability-info">';
    echo '<h3>Item Details</h3>';
    echo '<table>';
    echo cell2("Item:", $item['thing_title']);
    echo cell2("Description:", $item['thing_description']);
    echo cell2("Owner:", $item['member_fname'].' '.$item['member_lname']);
    echo cell2("Price per day:", '£'.$item['thing_price']);
    if ($item['thing_min_loan_days']) echo cell2("Minimum loan:", $item['thing_min_loan_days'].' days');
    if ($item['thing_max_loan_days']) echo cell2("Maximum loan:", $item['thing_max_loan_days'].' days');
    echo '</table>';
    echo '</div>';
    
    // Booking form
    echo '<div class="booking-form">';
    echo '<h3>Make Your Booking Request</h3>';
    
    echo '<form method="post">';
    echo '<table>';
    
    // Date selection
    echo cell2("Start Date:", '<input type="date" name="start_date" value="'.$_POST['start_date'].'" class="date-input" min="'.date('Y-m-d').'" required>');
    echo cell2("End Date:", '<input type="date" name="end_date" value="'.$_POST['end_date'].'" class="date-input" min="'.date('Y-m-d').'" required>');
    
    // Notes
    echo '<tr><td width="200">Special requests or notes:</td><td><textarea name="notes" class="notes-input" placeholder="Any special requests, pickup arrangements, etc.">'.$_POST['notes'].'</textarea></td></tr>';
    
    // Submit button
    echo '<tr><td></td><td><br><input type="submit" name="submit_booking" value="Submit Booking Request" style="background-color: #008000; color: white; padding: 10px 20px; border: none; font-size: 16px;"></td></tr>';
    
    echo '</table>';
    echo '</form>';
    echo '</div>';
    
    // Show availability calendar (simple version)
    echo '<div class="availability-info">';
    echo '<h3>Current Bookings This Month</h3>';
    $booked_dates = generate_availability_calendar($thing_ID);
    
    if (empty($booked_dates)) {
        echo '<p>No bookings this month - item appears to be available!</p>';
    } else {
        echo '<p><strong>Booked dates:</strong> '.implode(', ', array_map('format_display_date', $booked_dates)).'</p>';
        echo '<p><em>Please select dates that avoid the booked periods above.</em></p>';
    }
    echo '</div>';
    
    // JavaScript for cost calculation
    ?>
    <script>
    function calculateCost() {
        var startDate = document.querySelector('input[name="start_date"]').value;
        var endDate = document.querySelector('input[name="end_date"]').value;
        var pricePerDay = <?php echo $item['thing_price']; ?>;
        
        if (startDate && endDate) {
            var start = new Date(startDate);
            var end = new Date(endDate);
            var days = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
            
            if (days > 0) {
                var totalCost = days * pricePerDay;
                var costDiv = document.getElementById('cost-calculation');
                if (!costDiv) {
                    costDiv = document.createElement('div');
                    costDiv.id = 'cost-calculation';
                    costDiv.className = 'cost-calculation';
                    document.querySelector('.booking-form').appendChild(costDiv);
                }
                costDiv.innerHTML = '<strong>Loan Period:</strong> ' + days + ' days<br>' +
                                   '<strong>Total Cost:</strong> £' + totalCost.toFixed(2) + ' (' + days + ' × £' + pricePerDay + ')';
            }
        }
    }
    
    // Add event listeners
    document.querySelector('input[name="start_date"]').addEventListener('change', calculateCost);
    document.querySelector('input[name="end_date"]').addEventListener('change', calculateCost);
    </script>
    <?php
    
} else {
    echo '<p><a href="search.php">← Back to Search</a></p>';
}

?>

<br><br>
<a href="search.php">← Back to Search</a> | 
<a href="my_bookings.php">My Bookings</a> | 
<a href="account.php">My Account</a>

</body>
</html> 