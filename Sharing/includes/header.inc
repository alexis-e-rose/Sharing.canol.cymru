<?php
echo '<br><table><tr><td>Menu<br>';

//echo '<a href="index.php">Home </a><br>';

if (!isset($_SESSION["member_ID"])){ echo '<a href="index.php?showlogin=1">     Login</a><br>';}
if (!isset($_SESSION["member_ID"])){ echo '<a href="register.php">              Register</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="account.php">               Your Account</a><br>';}
if (1                             ){ echo '<a href="index.php?logout=1">        Log out</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="add_listing.php">           Add listing</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="my_bookings.php">           My Bookings</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="notifications.php">         Notifications</a><br>';}
//if ( isset($_SESSION["member_ID"])){ echo '<a href="create_private.php">        Manage your private groups</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="joingroup.php">        Join a private groups</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="search.php">        Search the database</a><br>';}


echo '</td></tr></table>';

if ( isset($_SESSION["member_ID"]) ) {
    $query6 = "SELECT * FROM members WHERE member_ID = ".qq($_SESSION['member_ID']);
    $result6 = $mysqli -> query($query6);
    $member = $result6 -> fetch_assoc();
    echo 'You are logged in as  '. $member["member_fname"]." ".$member["member_lname"];
    
    // Show notification count if functions are available
    if (function_exists('get_unread_notification_count')) {
        $unread_count = get_unread_notification_count($_SESSION["member_ID"]);
        if ($unread_count > 0) {
            echo ' <span style="color: #0066cc; font-weight: bold;">('.$unread_count.' new notifications)</span>';
        }
    }
} else {
    echo "Please log in to access member features";
}
echo '<br><br>';

?>