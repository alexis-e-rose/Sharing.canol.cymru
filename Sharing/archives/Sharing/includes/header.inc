<?php
echo '<br><table><tr><td>Menu<br>';

//echo '<a href="index.php">Home </a><br>';

if (!isset($_SESSION["member_ID"])){ echo '<a href="index.php?showlogin=1">     Login</a><br>';}
if (!isset($_SESSION["member_ID"])){ echo '<a href="register.php">              Register</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="account.php">               Your Account</a><br>';}
if (1                             ){ echo '<a href="index.php?logout=1">        Log out</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="add_listing.php">           Add listing</a><br>';}
//if ( isset($_SESSION["member_ID"])){ echo '<a href="create_private.php">        Manage your private groups</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="joingroup.php">        Join a private groups</a><br>';}
if ( isset($_SESSION["member_ID"])){ echo '<a href="search.php">        Search the database</a><br>';}


echo '</td></tr></table>';

if ( isset($_SESSION["member_ID"]) ) {
    $query6 = "SELECT * FROM members WHERE member_ID = ".qq($_SESSION['member_ID']);
    $result6 = $mysqli -> query($query6);
    $member = $result6 -> fetch_assoc();
    echo 'You are logged in as  '. $member["member_fname"]." ".$member["member_lname"];
} else {
    echo "you cannot access this page";
    end;
}
echo '<br><br>';

?>