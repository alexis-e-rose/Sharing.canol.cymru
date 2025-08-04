<?php
    $servername = "localhost";
    $username = "testuser";
    $password = "testpass";
    $dbname = "sharingcanol_stuff_dev";
    $mysqli = new mysqli($servername,$username,$password,$dbname);

    // Check connection
    if ($mysqli -> connect_errno) {
        echo "Failed to connect to MySQL: " . $mysqli -> connect_error;
        exit();
    }
    
    
    session_start();
?>