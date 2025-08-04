<?php
/**
 * Enhanced Problem Matcher for Sharing.canol.cymru
 * Analyzes PHP files for security issues and undefined functions
 * Now includes VSCode-style function definition checking
 */

class ProblemMatcher {
    private $problems = [];
    private $basePath;
    private $definedFunctions = [];      // Track all defined functions
    private $includeDependencies = [];   // Track include/require statements
    private $functionCalls = [];         // Track function calls per file
    private $builtinFunctions = [];      // PHP built-in functions
    
    public function __construct($basePath = './Sharing') {
        $this->basePath = realpath($basePath);
        $this->initializeBuiltinFunctions();
    }
    
    private function initializeBuiltinFunctions() {
        // Common PHP built-in functions to avoid false positives
        $this->builtinFunctions = [
            // String functions
            'strlen', 'substr', 'str_replace', 'trim', 'preg_match', 'preg_replace',
            'explode', 'implode', 'strtolower', 'strtoupper', 'htmlspecialchars',
            'strpos', 'strstr', 'substr_replace', 'ucfirst', 'ucwords', 'strip_tags',
            'addslashes', 'stripslashes', 'nl2br', 'wordwrap', 'str_pad',
            
            // Array functions
            'array_merge', 'array_keys', 'array_values', 'count', 'array_push',
            'array_pop', 'in_array', 'array_search', 'sort', 'ksort', 'asort',
            'array_slice', 'array_splice', 'array_shift', 'array_unshift',
            'array_reverse', 'array_flip', 'array_map', 'array_filter',
            
            // Math functions
            'abs', 'ceil', 'floor', 'round', 'max', 'min', 'rand', 'mt_rand',
            'sqrt', 'pow', 'exp', 'log', 'sin', 'cos', 'tan', 'pi', 'number_format',
            
            // Type checking functions
            'is_array', 'is_string', 'is_int', 'is_float', 'is_bool', 'is_null',
            'is_numeric', 'is_scalar', 'is_object', 'is_resource', 'is_callable',
            'isset', 'empty', 'gettype', 'settype', 'intval', 'floatval', 'strval',
            
            // Database functions
            'mysql_connect', 'mysql_query', 'mysql_fetch_array', 'mysql_fetch_assoc',
            'mysqli_connect', 'mysqli_query', 'mysqli_fetch_array', 'mysqli_fetch_assoc',
            'mysqli_real_escape_string', 'mysqli_error', 'mysqli_close', 'mysqli_num_rows',
            
            // File functions
            'file_get_contents', 'file_put_contents', 'fopen', 'fclose', 'fread',
            'fwrite', 'file_exists', 'is_file', 'is_dir', 'glob', 'realpath',
            'dirname', 'basename', 'pathinfo', 'mkdir', 'rmdir', 'unlink',
            
            // Date/Time functions
            'date', 'time', 'strtotime', 'mktime', 'strftime', 'microtime',
            'gettimeofday', 'gmdate', 'gmstrftime',
            
            // PHP language constructs and functions
            'echo', 'print', 'printf', 'sprintf', 'isset', 'empty', 'unset',
            'die', 'exit', 'include', 'require', 'include_once', 'require_once',
            'function_exists', 'class_exists', 'method_exists', 'var_dump', 'print_r',
            'serialize', 'unserialize', 'base64_encode', 'base64_decode',
            
            // JSON functions
            'json_encode', 'json_decode',
            
            // Session functions
            'session_start', 'session_destroy', 'session_id', 'session_name',
            'session_save_path', 'session_set_cookie_params',
            
            // Error functions
            'error_reporting', 'ini_set', 'ini_get', 'set_error_handler',
            'trigger_error', 'error_get_last',
            
            // URL/HTTP functions
            'urlencode', 'urldecode', 'rawurlencode', 'rawurldecode',
            'http_build_query', 'parse_url', 'header', 'headers_sent',
            
            // Regular expression functions
            'preg_match_all', 'preg_split', 'preg_quote', 'preg_grep',
            
            // Variable functions
            'extract', 'compact', 'get_defined_vars', 'get_defined_functions'
        ];
    }
    
    public function analyze() {
        $this->problems = [];
        $this->definedFunctions = [];
        $this->includeDependencies = [];
        $this->functionCalls = [];
        
        // First pass: Build function registry and include dependencies
        $this->buildFunctionRegistry($this->basePath);
        
        // Second pass: Analyze files for security issues and undefined functions
        $this->scanDirectory($this->basePath);
        
        return $this->problems;
    }
    
    private function buildFunctionRegistry($dir) {
        // Scan both .php and .inc files for function definitions
        $phpFiles = glob($dir . '/*.php');
        $incFiles = glob($dir . '/*.inc');
        $files = array_merge($phpFiles, $incFiles);
        
        foreach ($files as $file) {
            $this->extractFunctionsAndIncludes($file);
        }
        
        // Recursively scan subdirectories
        $subdirs = glob($dir . '/*', GLOB_ONLYDIR);
        foreach ($subdirs as $subdir) {
            $this->buildFunctionRegistry($subdir);
        }
    }
    
    private function extractFunctionsAndIncludes($filePath) {
        $content = file_get_contents($filePath);
        $lines = explode("\n", $content);
        $relativePath = str_replace($this->basePath . '/', '', $filePath);
        
        foreach ($lines as $lineNum => $line) {
            $lineNum++; // 1-based line numbers
            
            // Extract function definitions - improved pattern
            if (preg_match('/^\s*function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/i', $line, $matches)) {
                $functionName = $matches[1];
                $this->definedFunctions[$functionName] = [
                    'file' => $relativePath,
                    'line' => $lineNum,
                    'definition' => trim($line)
                ];
            }
            
            // Extract include/require statements - improved pattern
            if (preg_match('/(?:include|require)(?:_once)?\s*\(?["\']([^"\']+)["\']/', $line, $matches)) {
                $includePath = $matches[1];
                if (!isset($this->includeDependencies[$relativePath])) {
                    $this->includeDependencies[$relativePath] = [];
                }
                $this->includeDependencies[$relativePath][] = [
                    'path' => $includePath,
                    'line' => $lineNum,
                    'statement' => trim($line)
                ];
            }
        }
    }
    
    private function scanDirectory($dir) {
        // Only scan .php files for security analysis and undefined function checking
        $files = glob($dir . '/*.php');
        
        foreach ($files as $file) {
            $this->analyzeFile($file);
        }
        
        // Recursively scan subdirectories
        $subdirs = glob($dir . '/*', GLOB_ONLYDIR);
        foreach ($subdirs as $subdir) {
            $this->scanDirectory($subdir);
        }
    }
    
    private function analyzeFile($filePath) {
        $content = file_get_contents($filePath);
        $lines = explode("\n", $content);
        $relativePath = str_replace($this->basePath . '/', '', $filePath);
        
        // Track function calls in this file
        $this->functionCalls[$relativePath] = [];
        
        foreach ($lines as $lineNum => $line) {
            $lineNum++; // 1-based line numbers
            
            // EXISTING SECURITY CHECKS (preserved)
            
            // Check for potential security issues
            if (preg_match('/\$_GET\[.*\]|\$_POST\[.*\]/', $line) && !preg_match('/htmlspecialchars|filter_input|mysqli_real_escape_string/', $line)) {
                $this->addProblem($relativePath, $lineNum, 'SECURITY', 'Unescaped user input detected', $line);
            }
            
            // Check for SQL injection risks
            if (preg_match('/mysql_query|mysqli_query/', $line) && preg_match('/\$_/', $line)) {
                $this->addProblem($relativePath, $lineNum, 'SECURITY', 'Potential SQL injection risk', $line);
            }
            
            // Check for plain text password storage
            if (preg_match('/password.*=.*\$_POST/', $line) && !preg_match('/password_hash|hash|crypt/', $line)) {
                $this->addProblem($relativePath, $lineNum, 'SECURITY', 'Plain text password storage', $line);
            }
            
            // Check for missing error handling
            if (preg_match('/mysql_query|mysqli_query|file_get_contents|fopen/', $line) && !preg_match('/if\s*\(|or\s+die|&&|\|\|/', $line)) {
                $this->addProblem($relativePath, $lineNum, 'ERROR_HANDLING', 'Missing error handling', $line);
            }
            
            // Check for deprecated functions
            if (preg_match('/mysql_connect|mysql_query|mysql_fetch/', $line)) {
                $this->addProblem($relativePath, $lineNum, 'DEPRECATED', 'Deprecated MySQL function', $line);
            }
            
            // Check for TODO/FIXME comments
            if (preg_match('/\/\/.*(?:TODO|FIXME|BUG|HACK)/i', $line)) {
                $this->addProblem($relativePath, $lineNum, 'TODO', 'Development note found', trim($line));
            }
            
            // NEW FUNCTIONALITY: Check for undefined functions
            $this->checkUndefinedFunctions($relativePath, $lineNum, $line);
        }
    }
    
    private function checkUndefinedFunctions($file, $lineNum, $line) {
        // Skip comments, function definitions, and HTML/JavaScript sections
        if (preg_match('/^\s*\/\/|^\s*\/\*|^\s*\*|^\s*function\s+|<script|<\/script|querySelector|addEventListener/', $line)) {
            return;
        }
        
        // Skip lines that are clearly SQL statements
        if (preg_match('/\b(SELECT|INSERT|UPDATE|DELETE|FROM|WHERE|VALUES|INTO|SET)\b/i', $line)) {
            return;
        }
        
        // Find function calls - improved pattern to avoid false positives
        if (preg_match_all('/\b([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/', $line, $matches, PREG_OFFSET_CAPTURE)) {
            foreach ($matches[1] as $match) {
                $functionName = $match[0];
                $position = $match[1];
                
                // Skip PHP language constructs, control structures, and common SQL keywords
                $skipPatterns = [
                    'if', 'while', 'for', 'foreach', 'switch', 'catch', 'elseif', 'else',
                    'try', 'finally', 'return', 'throw', 'new', 'class', 'function',
                    // SQL keywords that might appear in PHP strings
                    'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'FROM', 'WHERE', 'VALUES', 
                    'INTO', 'SET', 'JOIN', 'GROUP', 'ORDER', 'LIMIT', 'HAVING',
                    // SQL functions
                    'COUNT', 'SUM', 'AVG', 'MAX', 'MIN', 'NOW', 'CURDATE', 'DATE_SUB',
                    // Table/column names that might look like functions
                    'communities', 'members', 'things', 'member_communities', 'thing_community',
                    // Object methods (these should be handled differently)
                    'query', 'fetch_assoc', 'fetch_array', 'close', 'prepare', 'bind_param', 'execute',
                    // JavaScript functions
                    'querySelector', 'getElementById', 'createElement', 'appendChild', 
                    'addEventListener', 'setTimeout', 'setInterval',
                    // PHP array/string functions that are common
                    'array', 'string', 'object', 'resource', 'boolean', 'integer', 'float', 'double'
                ];
                
                if (in_array($functionName, $skipPatterns) || in_array(strtolower($functionName), $skipPatterns)) {
                    continue;
                }
                
                // Skip if it looks like an object method call (preceded by ->)
                $beforeFunction = substr($line, max(0, $position - 10), 10);
                if (preg_match('/\->\s*$/', $beforeFunction)) {
                    continue;
                }
                
                // Skip if it's clearly a SQL keyword in context
                if (preg_match('/\b(select|insert|update|delete)\b.*\b' . preg_quote($functionName, '/') . '\b/i', $line)) {
                    continue;
                }
                
                // Track this function call
                $this->functionCalls[$file][] = [
                    'name' => $functionName,
                    'line' => $lineNum,
                    'position' => $position
                ];
                
                // Check if function is defined
                if (!$this->isFunctionDefined($functionName, $file)) {
                    $this->addProblem(
                        $file, 
                        $lineNum, 
                        'UNDEFINED_FUNCTION', 
                        "Undefined function '{$functionName}'", 
                        $line
                    );
                }
            }
        }
    }
    
    private function isFunctionDefined($functionName, $currentFile) {
        // Check built-in PHP functions
        if (in_array(strtolower($functionName), $this->builtinFunctions)) {
            return true;
        }
        
        // Check user-defined functions
        if (isset($this->definedFunctions[$functionName])) {
            return true;
        }
        
        // Check if function might be available through includes
        if ($this->isFunctionAvailableThroughIncludes($functionName, $currentFile)) {
            return true;
        }
        
        return false;
    }
    
    private function isFunctionAvailableThroughIncludes($functionName, $currentFile) {
        // Check direct includes in current file
        if (isset($this->includeDependencies[$currentFile])) {
            foreach ($this->includeDependencies[$currentFile] as $include) {
                $includePath = $this->resolveIncludePath($include['path'], $currentFile);
                if ($includePath && $this->functionDefinedInFile($functionName, $includePath)) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    private function resolveIncludePath($includePath, $currentFile) {
        // Handle different include path formats
        
        // Direct includes/ prefix
        if (strpos($includePath, 'includes/') === 0) {
            return $includePath;
        }
        
        // Just the filename (assume it's in includes/)
        if (strpos($includePath, '/') === false && strpos($includePath, '.inc') !== false) {
            return "includes/{$includePath}";
        }
        
        // Relative path from current directory
        $currentDir = dirname($currentFile);
        if ($currentDir !== '.') {
            $resolvedPath = $currentDir . '/' . $includePath;
        } else {
            $resolvedPath = $includePath;
        }
        
        // Check if the resolved path exists in our scanned files
        foreach ($this->definedFunctions as $funcName => $funcDetails) {
            if ($funcDetails['file'] === $resolvedPath || $funcDetails['file'] === $includePath) {
                return $funcDetails['file'];
            }
        }
        
        return $includePath;
    }
    
    private function functionDefinedInFile($functionName, $filePath) {
        foreach ($this->definedFunctions as $name => $definition) {
            if ($name === $functionName && 
                ($definition['file'] === $filePath || 
                 "includes/" . basename($definition['file']) === $filePath ||
                 $definition['file'] === "includes/" . basename($filePath))) {
                return true;
            }
        }
        return false;
    }
    
    private function addProblem($file, $line, $severity, $message, $code) {
        $this->problems[] = [
            'file' => $file,
            'line' => $line,
            'severity' => $severity,
            'message' => $message,
            'code' => trim($code)
        ];
    }
    
    // New method to get debugging information
    public function getDebugInfo() {
        $info = [
            'scanned_files' => [],
            'total_functions_found' => count($this->definedFunctions),
            'include_dependencies_count' => count($this->includeDependencies)
        ];
        
        // Get list of scanned files
        foreach ($this->definedFunctions as $name => $details) {
            if (!in_array($details['file'], $info['scanned_files'])) {
                $info['scanned_files'][] = $details['file'];
            }
        }
        
        return $info;
    }
    
    public function outputText() {
        $output = "=== ENHANCED PROBLEM MATCHER REPORT ===\n";
        $output .= "Generated: " . date('Y-m-d H:i:s') . "\n";
        $output .= "Total Issues: " . count($this->problems) . "\n";
        $output .= "Defined Functions: " . count($this->definedFunctions) . "\n";
        
        // Add debug info if very few functions found
        if (count($this->definedFunctions) < 5) {
            $debug = $this->getDebugInfo();
            $output .= "\n🔍 DEBUG INFO (few functions found):\n";
            $output .= "Scanned files: " . implode(', ', $debug['scanned_files']) . "\n";
            $output .= "Include dependencies: " . $debug['include_dependencies_count'] . "\n";
        }
        $output .= "\n";
        
        $groupedProblems = [];
        foreach ($this->problems as $problem) {
            $groupedProblems[$problem['severity']][] = $problem;
        }
        
        // Define severity order for consistent reporting
        $severityOrder = ['SECURITY', 'UNDEFINED_FUNCTION', 'ERROR_HANDLING', 'DEPRECATED', 'TODO'];
        
        foreach ($severityOrder as $severity) {
            if (isset($groupedProblems[$severity])) {
                $problems = $groupedProblems[$severity];
                $output .= "## {$severity} ISSUES (" . count($problems) . ")\n";
                foreach ($problems as $problem) {
                    $output .= sprintf(
                        "%s:%d - %s\n  Code: %s\n\n",
                        $problem['file'],
                        $problem['line'],
                        $problem['message'],
                        $problem['code']
                    );
                }
            }
        }
        
        // Add function registry summary
        if (count($this->definedFunctions) > 0) {
            $output .= "## DEFINED FUNCTIONS REGISTRY\n";
            foreach ($this->definedFunctions as $name => $details) {
                $output .= "- {$name}() in {$details['file']}:{$details['line']}\n";
            }
            $output .= "\n";
        }
        
        return $output;
    }
    
    public function outputJson() {
        return json_encode([
            'timestamp' => date('c'),
            'total_issues' => count($this->problems),
            'defined_functions_count' => count($this->definedFunctions),
            'problems' => $this->problems,
            'defined_functions' => $this->definedFunctions,
            'include_dependencies' => $this->includeDependencies
        ], JSON_PRETTY_PRINT);
    }
    
    // New method to get function analysis summary
    public function getFunctionAnalysisSummary() {
        $summary = [
            'total_defined_functions' => count($this->definedFunctions),
            'undefined_function_issues' => 0,
            'files_with_undefined_functions' => []
        ];
        
        foreach ($this->problems as $problem) {
            if ($problem['severity'] === 'UNDEFINED_FUNCTION') {
                $summary['undefined_function_issues']++;
                $summary['files_with_undefined_functions'][$problem['file']] = 
                    ($summary['files_with_undefined_functions'][$problem['file']] ?? 0) + 1;
            }
        }
        
        return $summary;
    }
}

// Run the analysis
$matcher = new ProblemMatcher();
$matcher->analyze();

// Output to file for AI context
file_put_contents('problems_report.txt', $matcher->outputText());
file_put_contents('problems_report.json', $matcher->outputJson());

// Also output to console
echo $matcher->outputText();

echo "\nReports saved to:\n";
echo "- problems_report.txt (human readable)\n";
echo "- problems_report.json (structured data)\n";

// Display function analysis summary
$summary = $matcher->getFunctionAnalysisSummary();
echo "\n=== FUNCTION ANALYSIS SUMMARY ===\n";
echo "Defined Functions: {$summary['total_defined_functions']}\n";
echo "Undefined Function Issues: {$summary['undefined_function_issues']}\n";
if (count($summary['files_with_undefined_functions']) > 0) {
    echo "Files with undefined functions:\n";
    foreach ($summary['files_with_undefined_functions'] as $file => $count) {
        echo "  - {$file}: {$count} issues\n";
    }
}
?> 