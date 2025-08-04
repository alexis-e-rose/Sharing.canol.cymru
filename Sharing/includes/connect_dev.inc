<?php
    // Development database connection for localhost testing
    $servername = "localhost";
    $username = "root";  // Default MariaDB root user
    $password = "";      // Empty password for local development
    $dbname = "sharingcanol_stuff_dev";
    
    // Try PDO connection first (for secure functions)
    try {
        $dsn = "mysql:host=$servername;dbname=$dbname;charset=utf8mb4";
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];
        $pdo = new PDO($dsn, $username, $password, $options);
        echo "<!-- PDO Connection: Success -->";
    } catch(PDOException $e) {
        echo "<!-- PDO Connection Failed: " . $e->getMessage() . " -->";
    }
    
    // Legacy mysqli connection (for existing code)
    $mysqli = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($mysqli->connect_errno) {
        echo "Failed to connect to MySQL: " . $mysqli->connect_error;
        echo "<br><strong>Setup Instructions:</strong>";
        echo "<br>1. Create database: <code>mysql -u root -e 'CREATE DATABASE sharingcanol_stuff_dev;'</code>";
        echo "<br>2. Import schema: <code>mysql -u root sharingcanol_stuff_dev < Sharing/sharingcanol_stuff.sql</code>";
        echo "<br>3. If you have a MySQL password, update this file with your credentials.";
        exit();
    } else {
        echo "<!-- MySQL Connection: Success -->";
    }
    
    session_start();
?> 