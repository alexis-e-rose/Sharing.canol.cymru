<?php
/**
 * Security Functions for Sharing.canol.cymru
 * Provides secure database operations and password handling
 * Created: 2025-08-04 for Emergency Security Patch
 * 
 * Features:
 * - PDO prepared statements for SQL injection prevention
 * - Secure password hashing and verification
 * - Backward compatible with existing qq() function usage
 * - Input validation and sanitization
 */

// Global PDO connection for prepared statements
global $pdo;

/**
 * Initialize secure PDO connection
 * Called once to establish secure database connection
 */
function init_secure_connection() {
    global $pdo;
    
    try {
        $servername = "localhost";
        $username = "testuser";  // Development credentials
        $password = "testpass";  // Test password for local development
        $dbname = "sharingcanol_stuff_dev";  // Development database
        
        $dsn = "mysql:host=$servername;dbname=$dbname;charset=utf8mb4";
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];
        
        $pdo = new PDO($dsn, $username, $password, $options);
        return true;
    } catch(PDOException $e) {
        error_log("Secure connection failed: " . $e->getMessage());
        return false;
    }
}

/**
 * Execute a secure prepared statement query
 * @param string $query SQL query with placeholders
 * @param array $params Parameters to bind to placeholders
 * @param string $fetch_mode 'all', 'one', 'execute' (default: 'all')
 * @return mixed Query results or boolean for execute
 */
function secure_query($query, $params = [], $fetch_mode = 'all') {
    global $pdo;
    
    // Initialize connection if not done
    if (!$pdo) {
        init_secure_connection();
    }
    
    // Check if connection is still null
    if (!$pdo) {
        error_log("SECURITY: PDO connection is null, cannot execute secure query");
        return false;
    }
    
    try {
        $stmt = $pdo->prepare($query);
        $stmt->execute($params);
        
        switch($fetch_mode) {
            case 'one':
                return $stmt->fetch();
            case 'execute':
                return $stmt->rowCount() > 0;
            case 'count':
                return $stmt->rowCount();
            case 'lastId':
                return $pdo->lastInsertId();
            default:
                return $stmt->fetchAll();
        }
    } catch(PDOException $e) {
        error_log("Secure query failed: " . $e->getMessage() . " Query: " . $query);
        return false;
    }
}

/**
 * Enhanced qq() function - backward compatible with security improvements
 * Maintains existing behavior while supporting prepared statements
 * @param mixed $str Input value to be quoted
 * @return string Safely quoted string
 */
function qq_secure($str) {
    // Maintain original qq() behavior for backward compatibility
    $str = str_replace("'", "&#39;", $str);
    $str = str_replace('"', "&#34;", $str);
    $str = trim($str);
    
    // Add additional security sanitization
    $str = htmlspecialchars($str, ENT_QUOTES, 'UTF-8');
    
    return '"' . $str . '"';
}

/**
 * Secure password hashing
 * @param string $password Plain text password
 * @return string Hashed password
 */
function secure_password_hash($password) {
    return password_hash($password, PASSWORD_DEFAULT);
}

/**
 * Secure password verification
 * @param string $password Plain text password
 * @param string $hash Stored password hash
 * @return bool True if password matches hash
 */
function secure_password_verify($password, $hash) {
    return password_verify($password, $hash);
}

/**
 * Check if a password is hashed (vs plain text)
 * @param string $password_field Database password field
 * @return bool True if already hashed
 */
function is_password_hashed($password_field) {
    // password_hash() creates hashes starting with $2y$ (bcrypt)
    return strlen($password_field) >= 60 && (
        strpos($password_field, '$2y$') === 0 || 
        strpos($password_field, '$2a$') === 0 ||
        strpos($password_field, '$2b$') === 0
    );
}

/**
 * Secure user authentication
 * @param string $email User email
 * @param string $password Plain text password
 * @return array|false User data if authenticated, false otherwise
 */
function secure_authenticate_user($email, $password) {
    $query = "SELECT member_ID, member_email, member_password, member_fname, member_lname FROM members WHERE member_email = ?";
    $user = secure_query($query, [$email], 'one');
    
    if (!$user) {
        return false;
    }
    
    // Handle both hashed and legacy plain text passwords during transition
    if (is_password_hashed($user['member_password'])) {
        // Secure password verification
        if (secure_password_verify($password, $user['member_password'])) {
            return $user;
        }
    } else {
        // Legacy plain text comparison (during transition only)
        if ($password === $user['member_password']) {
            // Automatically upgrade to secure hash
            $new_hash = secure_password_hash($password);
            $update_query = "UPDATE members SET member_password = ? WHERE member_ID = ?";
            secure_query($update_query, [$new_hash, $user['member_ID']], 'execute');
            
            return $user;
        }
    }
    
    return false;
}

/**
 * Secure user registration
 * @param array $user_data User registration data
 * @return int|false New user ID if successful, false otherwise
 */
function secure_register_user($user_data) {
    // Hash password securely
    $hashed_password = secure_password_hash($user_data['password']);
    
    $query = "INSERT INTO members (member_fname, member_email, member_password, member_lname, member_pcode) VALUES (?, ?, ?, ?, ?)";
    $params = [
        $user_data['fname'],
        $user_data['email'],
        $hashed_password,
        $user_data['lname'],
        $user_data['pcode']
    ];
    
    if (secure_query($query, $params, 'execute')) {
        return secure_query("SELECT LAST_INSERT_ID() as id", [], 'one')['id'];
    }
    
    return false;
}

/**
 * Input validation and sanitization
 * @param mixed $input Raw input data
 * @param string $type Expected data type (email, int, string, etc.)
 * @return mixed Sanitized input or false if invalid
 */
function secure_input($input, $type = 'string') {
    switch($type) {
        case 'email':
            return filter_var($input, FILTER_VALIDATE_EMAIL);
        case 'int':
            return filter_var($input, FILTER_VALIDATE_INT);
        case 'float':
            return filter_var($input, FILTER_VALIDATE_FLOAT);
        case 'string':
            return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
        case 'url':
            return filter_var($input, FILTER_VALIDATE_URL);
        default:
            return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
    }
}

/**
 * Convert legacy mysqli query to secure prepared statement
 * @param string $legacy_query Query with qq() style concatenation
 * @param array $values Values that were being concatenated
 * @return array ['query' => prepared_query, 'params' => parameters]
 */
function convert_legacy_query($legacy_query, $values = []) {
    // Convert qq() concatenated queries to prepared statements
    $prepared_query = $legacy_query;
    $params = [];
    
    // Replace quoted values with placeholders
    foreach($values as $value) {
        $prepared_query = preg_replace('/"[^"]*"/', '?', $prepared_query, 1);
        $params[] = $value;
    }
    
    return ['query' => $prepared_query, 'params' => $params];
}

/**
 * Security logging function
 * @param string $message Security event to log
 * @param string $level Log level (INFO, WARNING, ERROR)
 */
function security_log($message, $level = 'INFO') {
    $timestamp = date('Y-m-d H:i:s');
    $log_entry = "[$timestamp] [$level] SECURITY: $message" . PHP_EOL;
    error_log($log_entry, 3, __DIR__ . '/../../security.log');
}

// Initialize secure connection when file is included
init_secure_connection();

?> 