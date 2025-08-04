<?php
    $servername = "localhost";
    $username = "sharingcanol_admin";
    $password = "sharing-it-2025";
    $dbname = "sharingcanol_stuff";
    $mysqli = new mysqli($servername,$username,$password,$dbname);

    // Check connection
    if ($mysqli -> connect_errno) {
        echo "Failed to connect to MySQL: " . $mysqli -> connect_error;
        exit();
    }
    
    
    session_start();
?>