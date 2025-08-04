#!/bin/bash

# Agentic Browser Testing Script for Sharing.canol.cymru
# Simulates real user interactions and browsing behavior

BASE_URL="http://localhost:8000"
LOG_FILE="browser_test_$(date +%Y%m%d_%H%M%S).log"
COOKIE_FILE="browser_cookies.txt"
SESSION_FILE="browser_session.txt"
ERROR_LOG="server_errors_$(date +%Y%m%d_%H%M%S).log"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🤖 Starting Agentic Browser Tests for localhost:8000" | tee -a "$LOG_FILE"
echo "===============================================" | tee -a "$LOG_FILE"

# Clean up previous files
rm -f "$COOKIE_FILE" "$SESSION_FILE" "$ERROR_LOG"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
ERRORS_DETECTED=0

# Function to analyze server logs for errors
analyze_server_logs() {
    echo -e "\n${YELLOW}🔍 Analyzing Server Logs for Errors...${NC}" | tee -a "$LOG_FILE"
    
    # Common PHP error patterns to look for
    error_patterns=(
        "PHP Warning:"
        "PHP Fatal error:"
        "PHP Parse error:"
        "Undefined array key"
        "Undefined variable"
        "Uncaught Error"
        "mysqli_sql_exception"
    )
    
    # Check if we can access server logs (this would need to be implemented based on server setup)
    # For now, we'll analyze the response content for error indicators
    echo "Server log analysis would be implemented here" | tee -a "$ERROR_LOG"
    echo "Current implementation focuses on HTTP response analysis" | tee -a "$ERROR_LOG"
}

# Function to simulate browser navigation
browser_navigate() {
    local url="$1"
    local description="$2"
    
    echo -e "\n${BLUE}🌐 Navigating to: $url${NC}" | tee -a "$LOG_FILE"
    echo "Description: $description" | tee -a "$LOG_FILE"
    
    response=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME:%{time_total}s" \
        -b "$COOKIE_FILE" -c "$COOKIE_FILE" \
        -H "User-Agent: Mozilla/5.0 (Agentic Browser Test)" \
        "$url")
    
    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    response_time=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    content=$(echo "$response" | sed '/HTTP_CODE:/d' | sed '/TIME:/d')
    
    echo "HTTP Code: $http_code" | tee -a "$LOG_FILE"
    echo "Response Time: ${response_time}s" | tee -a "$LOG_FILE"
    
    # Check for error indicators in content
    error_indicators=(
        "PHP Warning"
        "PHP Fatal error"
        "Undefined array key"
        "Undefined variable"
        "mysqli_sql_exception"
        "You have an error in your SQL syntax"
    )
    
    for indicator in "${error_indicators[@]}"; do
        if echo "$content" | grep -q "$indicator"; then
            echo -e "${RED}⚠️  ERROR DETECTED: $indicator${NC}" | tee -a "$LOG_FILE"
            echo -e "${RED}Error content: ${content:0:200}...${NC}" | tee -a "$ERROR_LOG"
            ((ERRORS_DETECTED++))
        fi
    done
    
    # Save session state
    echo "$url|$http_code|$response_time" >> "$SESSION_FILE"
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ Navigation successful${NC}" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "${RED}❌ Navigation failed (HTTP $http_code)${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Function to simulate form submission
browser_submit_form() {
    local url="$1"
    local data="$2"
    local description="$3"
    
    echo -e "\n${BLUE}📝 Submitting form to: $url${NC}" | tee -a "$LOG_FILE"
    echo "Description: $description" | tee -a "$LOG_FILE"
    echo "Data: $data" | tee -a "$LOG_FILE"
    
    response=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME:%{time_total}s" \
        -b "$COOKIE_FILE" -c "$COOKIE_FILE" \
        -H "User-Agent: Mozilla/5.0 (Agentic Browser Test)" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -X POST -d "$data" "$url")
    
    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    response_time=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    content=$(echo "$response" | sed '/HTTP_CODE:/d' | sed '/TIME:/d')
    
    echo "HTTP Code: $http_code" | tee -a "$LOG_FILE"
    echo "Response Time: ${response_time}s" | tee -a "$LOG_FILE"
    
    # Check for error indicators in content
    error_indicators=(
        "PHP Warning"
        "PHP Fatal error"
        "Undefined array key"
        "Undefined variable"
        "mysqli_sql_exception"
        "You have an error in your SQL syntax"
    )
    
    for indicator in "${error_indicators[@]}"; do
        if echo "$content" | grep -q "$indicator"; then
            echo -e "${RED}⚠️  ERROR DETECTED: $indicator${NC}" | tee -a "$LOG_FILE"
            echo -e "${RED}Error content: ${content:0:200}...${NC}" | tee -a "$ERROR_LOG"
            ((ERRORS_DETECTED++))
        fi
    done
    
    # Save session state
    echo "$url|$http_code|$response_time" >> "$SESSION_FILE"
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ Form submission successful${NC}" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "${RED}❌ Form submission failed (HTTP $http_code)${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Function to extract links from page
extract_links() {
    local content="$1"
    echo "$content" | grep -o 'href="[^"]*"' | sed 's/href="//g' | sed 's/"//g' | sort | uniq
}

# Function to extract forms from page
extract_forms() {
    local content="$1"
    echo "$content" | grep -c '<form' || echo "0"
}

# Function to analyze page content
analyze_page() {
    local url="$1"
    local description="$2"
    
    echo -e "\n${BLUE}🔍 Analyzing: $url${NC}" | tee -a "$LOG_FILE"
    echo "Description: $description" | tee -a "$LOG_FILE"
    
    response=$(curl -s "$url")
    
    # Check for specific functionality
    if echo "$response" | grep -q "login\|Login"; then
        echo -e "${GREEN}✅ Login form detected${NC}" | tee -a "$LOG_FILE"
    fi
    
    if echo "$response" | grep -q "register\|Register"; then
        echo -e "${GREEN}✅ Registration link detected${NC}" | tee -a "$LOG_FILE"
    fi
    
    if echo "$response" | grep -q "search\|Search"; then
        echo -e "${GREEN}✅ Search functionality detected${NC}" | tee -a "$LOG_FILE"
    fi
    
    # Count links and forms
    links=$(extract_links "$response" | wc -l)
    forms=$(extract_forms "$response")
    
    echo "🔗 Links found: $links" | tee -a "$LOG_FILE"
    echo "📝 Forms found: $forms" | tee -a "$LOG_FILE"
}

# Main test execution
echo "Starting Agentic Browser Tests..." | tee -a "$LOG_FILE"

echo -e "\n${BLUE}=== Simulating Real User Workflow ===${NC}" | tee -a "$LOG_FILE"

# Test homepage
if browser_navigate "$BASE_URL/" "User visits homepage"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Test registration
if browser_navigate "$BASE_URL/register.php" "User goes to registration page"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Test registration form submission
if browser_submit_form "$BASE_URL/register.php" "username=testuser&email=test@example.com&password=testpass123&confirm_password=testpass123" "User registers new account"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Test login page
if browser_navigate "$BASE_URL/login_form" "User goes to login page"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Test login form submission
if browser_submit_form "$BASE_URL/login_form" "username=testuser&password=testpass123" "User logs in"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Test authenticated pages
if browser_navigate "$BASE_URL/account.php" "User visits account page"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if browser_navigate "$BASE_URL/add_listing.php" "User visits add listing page"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Test search functionality
if browser_navigate "$BASE_URL/search.php" "User searches for items"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Test Phase 2 features
if browser_navigate "$BASE_URL/request_booking.php" "User visits booking page"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if browser_navigate "$BASE_URL/notifications.php" "User visits notifications"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if browser_navigate "$BASE_URL/my_bookings.php" "User visits my bookings"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

echo -e "\n${BLUE}=== Simulating Booking Workflow ===${NC}" | tee -a "$LOG_FILE"

# Test booking workflow
if browser_navigate "$BASE_URL/search.php?item_type=1" "Search for loan items"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if browser_navigate "$BASE_URL/request_booking.php?thing_id=1" "Try to book item ID 1"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if browser_submit_form "$BASE_URL/request_booking.php" "thing_id=1&start_date=2025-08-05&end_date=2025-08-06&notes=Test booking&submit_booking=1" "Submit booking request"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if browser_navigate "$BASE_URL/my_bookings.php" "Check booking status"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

echo -e "\n${BLUE}=== Simulating Notification Workflow ===${NC}" | tee -a "$LOG_FILE"

# Test notification workflow
if browser_navigate "$BASE_URL/notifications.php" "Visit notifications center"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if browser_submit_form "$BASE_URL/notifications.php" "email_notifications=1&booking_notifications=1&notification_frequency=immediate" "Update notification preferences"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

echo -e "\n${BLUE}=== Testing Page Interactions ===${NC}" | tee -a "$LOG_FILE"

# Analyze key pages
analyze_page "$BASE_URL/" "Homepage analysis"
analyze_page "$BASE_URL/search.php" "Search page analysis"
analyze_page "$BASE_URL/register.php" "Registration page analysis"
analyze_page "$BASE_URL/login_form" "Login page analysis"

# Analyze server logs for errors
analyze_server_logs

echo -e "\n${BLUE}=== Session Report ===${NC}" | tee -a "$LOG_FILE"
echo "📊 Navigation History:" | tee -a "$LOG_FILE"
while IFS='|' read -r url http_code response_time; do
    if [ "$http_code" = "200" ]; then
        echo "  ✅ $url (HTTP $http_code, ${response_time}s)" | tee -a "$LOG_FILE"
    else
        echo "  ❌ $url (HTTP $http_code, ${response_time}s)" | tee -a "$LOG_FILE"
    fi
done < "$SESSION_FILE"

echo -e "\n${BLUE}===============================================${NC}" | tee -a "$LOG_FILE"
echo "Agentic Browser Test Summary:" | tee -a "$LOG_FILE"
echo "📝 Log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
echo "📊 Session data saved to: $SESSION_FILE" | tee -a "$LOG_FILE"
echo "⚠️  Errors detected: $ERRORS_DETECTED" | tee -a "$LOG_FILE"
if [ -f "$ERROR_LOG" ]; then
    echo "🔍 Error log saved to: $ERROR_LOG" | tee -a "$LOG_FILE"
fi

if [ $ERRORS_DETECTED -gt 0 ]; then
    echo -e "${YELLOW}⚠️  WARNING: $ERRORS_DETECTED errors detected in server logs${NC}" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}Check $ERROR_LOG for details${NC}" | tee -a "$LOG_FILE"
fi

echo "🎉 Agentic browser testing complete!" | tee -a "$LOG_FILE" 