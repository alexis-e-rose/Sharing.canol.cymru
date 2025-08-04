#!/bin/bash

# Automated Testing Script for Sharing.canol.cymru localhost:8000
# Tests main endpoints and functionality

BASE_URL="http://localhost:8000"
LOG_FILE="test_results_$(date +%Y%m%d_%H%M%S).log"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🧪 Starting automated tests for localhost:8000" | tee -a "$LOG_FILE"
echo "===============================================" | tee -a "$LOG_FILE"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test an endpoint
test_endpoint() {
    local name="$1"
    local url="$2"
    local expected_pattern="$3"
    
    echo -e "\n${BLUE}Testing: $name${NC}" | tee -a "$LOG_FILE"
    echo "URL: $url" | tee -a "$LOG_FILE"
    
    # Make the request
    response=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME:%{time_total}s" "$url")
    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    response_time=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    content=$(echo "$response" | sed '/HTTP_CODE:/d' | sed '/TIME:/d')
    
    echo "HTTP Code: $http_code" | tee -a "$LOG_FILE"
    echo "Response Time: ${response_time}s" | tee -a "$LOG_FILE"
    
    # Check if response contains expected pattern
    if echo "$content" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✅ PASS: $name${NC}" | tee -a "$LOG_FILE"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL: $name${NC}" | tee -a "$LOG_FILE"
        echo "Expected pattern: $expected_pattern" | tee -a "$LOG_FILE"
        echo "Response preview: ${content:0:200}..." | tee -a "$LOG_FILE"
        ((TESTS_FAILED++))
    fi
}

# Test main pages
test_endpoint "Homepage" "$BASE_URL/" "Sharing"
test_endpoint "Search Page" "$BASE_URL/search.php" "search"
test_endpoint "Add Listing" "$BASE_URL/add_listing.php" "Add"
test_endpoint "My Bookings" "$BASE_URL/my_bookings.php" "booking"
test_endpoint "Notifications" "$BASE_URL/notifications.php" "notification"
test_endpoint "Account" "$BASE_URL/account.php" "account"
test_endpoint "Register" "$BASE_URL/register.php" "register"

# Test with parameters
test_endpoint "Search with Query" "$BASE_URL/search.php?q=hammer" "hammer"
test_endpoint "Search with Category" "$BASE_URL/search.php?category=tools" "tools"

# Test POST endpoints (simulate form submissions)
echo -e "\n${BLUE}Testing POST endpoints...${NC}" | tee -a "$LOG_FILE"

# Test login form submission
echo "Testing login form..." | tee -a "$LOG_FILE"
login_response=$(curl -s -X POST -d "username=test&password=test" "$BASE_URL/login_form")
if echo "$login_response" | grep -q "login"; then
    echo -e "${GREEN}✅ PASS: Login form${NC}" | tee -a "$LOG_FILE"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL: Login form${NC}" | tee -a "$LOG_FILE"
    ((TESTS_FAILED++))
fi

# Test registration form
echo "Testing registration form..." | tee -a "$LOG_FILE"
reg_response=$(curl -s -X POST -d "username=testuser&email=test@example.com&password=testpass" "$BASE_URL/register.php")
if echo "$reg_response" | grep -q "register\|success\|error"; then
    echo -e "${GREEN}✅ PASS: Registration form${NC}" | tee -a "$LOG_FILE"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL: Registration form${NC}" | tee -a "$LOG_FILE"
    ((TESTS_FAILED++))
fi

# Summary
echo -e "\n${BLUE}===============================================${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}Test Summary:${NC}" | tee -a "$LOG_FILE"
echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}" | tee -a "$LOG_FILE"
echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📊 Total Tests: $((TESTS_PASSED + TESTS_FAILED))${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📝 Log saved to: $LOG_FILE${NC}" | tee -a "$LOG_FILE"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}" | tee -a "$LOG_FILE"
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Check the log for details.${NC}" | tee -a "$LOG_FILE"
    exit 1
fi 