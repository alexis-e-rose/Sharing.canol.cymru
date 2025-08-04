<?php 
// this section is for callers to enter a name and password
// SECURE VERSION - Implements prepared statements and password hashing

// Include security functions for secure authentication
require_once('security_functions.inc');

// process this if this page has been called by the form on itself
if ($_POST["Login"] == "Login") {
    // Secure input validation
    $email = secure_input($_POST["email"], 'email');
    $password = secure_input($_POST["pagespass"], 'string');
    
    if (!$email) {
        $nomatch = 1;
        $passprompt = 1;
        echo "<br>Invalid email format. Please try again.";
    } else {
        // Use secure authentication function
        $user = secure_authenticate_user($email, $password);
        
        // if the caller name and password are valid
        if ($user) {
            // Register session variables
            $_SESSION['member_email'] = $user["member_email"];
            $_SESSION['member_ID'] = $user["member_ID"];

            echo '<br>You are logged in as '.$user["member_fname"].' '.$user["member_lname"];
            
            // Log successful login
            security_log("Successful login for user: " . $user["member_email"], 'INFO');

        // if the login details did not match the database, show the form again
        } else {
            $nomatch = 1;
            $passprompt = 1;
            echo "<br>Please try again";
            
            // Log failed login attempt
            security_log("Failed login attempt for email: " . $email, 'WARNING');
        }
    }

} else {
	$passprompt = 1;
}

?>
