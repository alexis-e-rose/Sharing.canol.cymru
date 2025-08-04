<?php 
// this section is for callers to enter a name and password


// process this if this page has been called by the form on itself
if ($_POST["Login"] == "Login") {
    $query = "SELECT * FROM members WHERE member_email = ".qq($_POST["email"])." and member_password = ".qq($_POST["pagespass"])." ";
    $result = $mysqli -> query($query);

	// if the caller name and password are valid
	if ($result -> num_rows > 0) {
		// find the callerID and register it as a session variable
		$record = $result -> fetch_assoc();
		
		$_SESSION['member_email']=$record["member_email"];
		$_SESSION['member_ID']   =$record["member_ID"];

		echo '<br>You are logged in as '.$record["member_fname"].' '.$record["member_lname"];


	// if the login details did not match the database, show the form again
	} else {
		$nomatch = 1;
		$passprompt = 1;
		echo "<br>please try again";
	}

} else {
	$passprompt = 1;
}

?>
