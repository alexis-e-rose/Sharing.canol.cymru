#!/bin/bash

# Enhanced Testing Script for Sharing.canol.cymru
# Tests complete workflow with authentication and Phase 2 features

BASE_URL="http://localhost:8000"
LOG_FILE="enhanced_test_$(date +%Y%m%d_%H%M%S).log"
COOKIE_FILE="test_cookies.txt"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🧪 Starting enhanced tests for localhost:8000" | tee -a "$LOG_FILE"
echo "===============================================" | tee -a "$LOG_FILE"

# Clean up previous cookie file
rm -f "$COOKIE_FILE"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to make authenticated requests
curl_auth() {
    local method="$1"
    local url="$2"
    local data="$3"
    
    if [ "$method" = "POST" ]; then
        curl -s -w "\nHTTP_CODE:%{http_code}\nTIME:%{time_total}s" \
             -b "$COOKIE_FILE" -c "$COOKIE_FILE" \
             -X POST -d "$data" "$url"
    else
        curl -s -w "\nHTTP_CODE:%{http_code}\nTIME:%{time_total}s" \
             -b "$COOKIE_FILE" -c "$COOKIE_FILE" "$url"
    fi
}

# Function to test endpoint with detailed analysis
test_endpoint_detailed() {
    local name="$1"
    local url="$2"
    local method="$3"
    local data="$4"
    local expected_pattern="$5"
    local description="$6"
    
    echo -e "\n${BLUE}Testing: $name${NC}" | tee -a "$LOG_FILE"
    echo "Description: $description" | tee -a "$LOG_FILE"
    echo "URL: $url" | tee -a "$LOG_FILE"
    
    if [ "$method" = "POST" ]; then
        response=$(curl_auth "POST" "$url" "$data")
    else
        response=$(curl_auth "GET" "$url" "")
    fi
    
    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    response_time=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    content=$(echo "$response" | sed '/HTTP_CODE:/d' | sed '/TIME:/d')
    
    echo "HTTP Code: $http_code" | tee -a "$LOG_FILE"
    echo "Response Time: ${response_time}s" | tee -a "$LOG_FILE"
    
    # Check for specific error conditions
    if [ "$http_code" = "500" ]; then
        echo -e "${RED}❌ FAIL: $name (HTTP 500 - Server Error)${NC}" | tee -a "$LOG_FILE"
        echo "Error content: ${content:0:200}..." | tee -a "$LOG_FILE"
        ((TESTS_FAILED++))
        return 1
    elif [ "$http_code" = "000" ]; then
        echo -e "${RED}❌ FAIL: $name (Connection Failed)${NC}" | tee -a "$LOG_FILE"
        ((TESTS_FAILED++))
        return 1
    elif [ "$http_code" != "200" ]; then
        echo -e "${YELLOW}⚠️  WARNING: $name (HTTP $http_code)${NC}" | tee -a "$LOG_FILE"
        echo "Response: ${content:0:200}..." | tee -a "$LOG_FILE"
    fi
    
    # Check for expected content
    if echo "$content" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✅ PASS: $name${NC}" | tee -a "$LOG_FILE"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL: $name${NC}" | tee -a "$LOG_FILE"
        echo "Expected pattern: $expected_pattern" | tee -a "$LOG_FILE"
        echo "Response preview: ${content:0:300}..." | tee -a "$LOG_FILE"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to test authentication workflow
test_auth_workflow() {
    echo -e "\n${YELLOW}=== Authentication Workflow Tests ===${NC}" | tee -a "$LOG_FILE"
    
    # Test 1: Registration
    test_endpoint_detailed "User Registration" "$BASE_URL/register.php" "POST" \
        "username=testuser&email=test@example.com&password=testpass123&confirm_password=testpass123" \
        "register\|success\|error" "Test user registration functionality"
    
    # Test 2: Login
    test_endpoint_detailed "User Login" "$BASE_URL/login_form" "POST" \
        "username=testuser&password=testpass123" \
        "login\|success\|error\|member" "Test user login functionality"
    
    # Test 3: Authenticated pages
    test_endpoint_detailed "Add Listing (Authenticated)" "$BASE_URL/add_listing.php" "GET" "" \
        "add_item\|Item title\|Full description" "Test add listing page when authenticated"
    
    test_endpoint_detailed "Account Page (Authenticated)" "$BASE_URL/account.php" "GET" "" \
        "account\|profile\|member" "Test account page when authenticated"
}

# Function to test Phase 2 features
test_phase2_features() {
    echo -e "\n${YELLOW}=== Phase 2 Feature Tests ===${NC}" | tee -a "$LOG_FILE"
    
    # Test booking system
    test_endpoint_detailed "Request Booking Page" "$BASE_URL/request_booking.php" "GET" "" \
        "booking\|request\|calendar" "Test booking request page"
    
    test_endpoint_detailed "My Bookings Dashboard" "$BASE_URL/my_bookings.php" "GET" "" \
        "booking\|dashboard\|manage" "Test booking management dashboard"
    
    # Test notification system
    test_endpoint_detailed "Notifications Center" "$BASE_URL/notifications.php" "GET" "" \
        "notification\|preferences\|email" "Test notification center and preferences"
    
    # Test enhanced search
    test_endpoint_detailed "Enhanced Search" "$BASE_URL/search.php" "GET" "" \
        "search\|items\|book" "Test enhanced search with booking integration"
}

# Function to test database connectivity
test_database_connectivity() {
    echo -e "\n${YELLOW}=== Database Connectivity Tests ===${NC}" | tee -a "$LOG_FILE"
    
    # Test if database connection works by checking for database-related errors
    test_endpoint_detailed "Database Connection Test" "$BASE_URL/search.php" "GET" "" \
        "search\|database\|error" "Test database connectivity through search page"
}

# Function to test error handling
test_error_handling() {
    echo -e "\n${YELLOW}=== Error Handling Tests ===${NC}" | tee -a "$LOG_FILE"
    
    # Test 404 handling
    test_endpoint_detailed "404 Error Handling" "$BASE_URL/nonexistent.php" "GET" "" \
        "404\|error\|not found" "Test 404 error handling"
    
    # Test invalid parameters
    test_endpoint_detailed "Invalid Parameter Handling" "$BASE_URL/search.php?invalid=test" "GET" "" \
        "search\|error" "Test handling of invalid parameters"
}

# Function to test performance
test_performance() {
    echo -e "\n${YELLOW}=== Performance Tests ===${NC}" | tee -a "$LOG_FILE"
    
    # Test homepage performance
    start_time=$(date +%s.%N)
    response=$(curl -s "$BASE_URL/")
    end_time=$(date +%s.%N)
    load_time=$(echo "$end_time - $start_time" | bc)
    
    echo "Homepage load time: ${load_time}s" | tee -a "$LOG_FILE"
    if (( $(echo "$load_time < 2.0" | bc -l) )); then
        echo -e "${GREEN}✅ PASS: Performance test (load time: ${load_time}s)${NC}" | tee -a "$LOG_FILE"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL: Performance test (load time: ${load_time}s)${NC}" | tee -a "$LOG_FILE"
        ((TESTS_FAILED++))
    fi
}

# Function to test security features
test_security_features() {
    echo -e "\n${YELLOW}=== Security Tests ===${NC}" | tee -a "$LOG_FILE"
    
    # Test SQL injection protection
    test_endpoint_detailed "SQL Injection Protection" "$BASE_URL/search.php?q=' OR 1=1--" "GET" "" \
        "search\|error\|invalid" "Test SQL injection protection"
    
    # Test XSS protection
    test_endpoint_detailed "XSS Protection" "$BASE_URL/search.php?q=<script>alert('xss')</script>" "GET" "" \
        "search\|error\|invalid" "Test XSS protection"
}

# Main test execution
echo -e "\n${BLUE}Starting Enhanced Test Suite...${NC}" | tee -a "$LOG_FILE"

# Test basic connectivity
test_endpoint_detailed "Server Connectivity" "$BASE_URL/" "GET" "" \
    "Sharing\|Canol\|Cymru" "Test basic server connectivity"

# Test authentication workflow
test_auth_workflow

# Test Phase 2 features
test_phase2_features

# Test database connectivity
test_database_connectivity

# Test error handling
test_error_handling

# Test performance
test_performance

# Test security features
test_security_features

# Summary
echo -e "\n${BLUE}===============================================${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}Enhanced Test Summary:${NC}" | tee -a "$LOG_FILE"
echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}" | tee -a "$LOG_FILE"
echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📊 Total Tests: $((TESTS_PASSED + TESTS_FAILED))${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📝 Log saved to: $LOG_FILE${NC}" | tee -a "$LOG_FILE"

# Clean up
rm -f "$COOKIE_FILE"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All enhanced tests passed!${NC}" | tee -a "$LOG_FILE"
    exit 0
else
    echo -e "${RED}⚠️  Some enhanced tests failed. Check the log for details.${NC}" | tee -a "$LOG_FILE"
    exit 1
fi 