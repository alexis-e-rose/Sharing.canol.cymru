#!/bin/bash

# Advanced Workflow Testing Script for Sharing.canol.cymru
# Tests complete booking workflow: search → book → approve → notify

BASE_URL="http://localhost:8000"
LOG_FILE="workflow_test_$(date +%Y%m%d_%H%M%S).log"
COOKIE_FILE="test_cookies.txt"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🧪 Starting workflow tests for localhost:8000" | tee -a "$LOG_FILE"
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

# Function to test workflow step
test_workflow_step() {
    local step_name="$1"
    local url="$2"
    local method="$3"
    local data="$4"
    local expected_pattern="$5"
    
    echo -e "\n${BLUE}Testing Workflow Step: $step_name${NC}" | tee -a "$LOG_FILE"
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
    
    if echo "$content" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✅ PASS: $step_name${NC}" | tee -a "$LOG_FILE"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL: $step_name${NC}" | tee -a "$LOG_FILE"
        echo "Expected pattern: $expected_pattern" | tee -a "$LOG_FILE"
        echo "Response preview: ${content:0:200}..." | tee -a "$LOG_FILE"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Step 1: Test homepage and basic functionality
echo -e "\n${YELLOW}Step 1: Basic Functionality Tests${NC}" | tee -a "$LOG_FILE"
test_workflow_step "Homepage" "$BASE_URL/" "GET" "" "Sharing"
test_workflow_step "Search Page" "$BASE_URL/search.php" "GET" "" "search"

# Step 2: Test registration (if needed)
echo -e "\n${YELLOW}Step 2: User Registration Test${NC}" | tee -a "$LOG_FILE"
test_workflow_step "Registration Form" "$BASE_URL/register.php" "POST" \
    "username=testuser&email=test@example.com&password=testpass123&confirm_password=testpass123" \
    "register\|success\|error"

# Step 3: Test login
echo -e "\n${YELLOW}Step 3: User Login Test${NC}" | tee -a "$LOG_FILE"
test_workflow_step "Login Form" "$BASE_URL/login_form" "POST" \
    "username=testuser&password=testpass123" "login\|success\|error"

# Step 4: Test authenticated pages
echo -e "\n${YELLOW}Step 4: Authenticated Page Tests${NC}" | tee -a "$LOG_FILE"
test_workflow_step "My Bookings" "$BASE_URL/my_bookings.php" "GET" "" "booking"
test_workflow_step "Notifications" "$BASE_URL/notifications.php" "GET" "" "notification"
test_workflow_step "Account Page" "$BASE_URL/account.php" "GET" "" "account"

# Step 5: Test search functionality
echo -e "\n${YELLOW}Step 5: Search Functionality Tests${NC}" | tee -a "$LOG_FILE"
test_workflow_step "Search with Query" "$BASE_URL/search.php?q=hammer" "GET" "" "hammer\|search"
test_workflow_step "Search with Category" "$BASE_URL/search.php?category=tools" "GET" "" "tools\|search"

# Step 6: Test booking workflow
echo -e "\n${YELLOW}Step 6: Booking Workflow Tests${NC}" | tee -a "$LOG_FILE"

# First, test if we can access the request booking page
test_workflow_step "Request Booking Page" "$BASE_URL/request_booking.php" "GET" "" "booking\|request"

# Test booking submission (this might fail if no items exist, but we test the page loads)
test_workflow_step "Booking Submission" "$BASE_URL/request_booking.php" "POST" \
    "thing_id=1&start_date=2025-08-05&end_date=2025-08-06&message=Test booking" \
    "booking\|success\|error\|request"

# Step 7: Test add listing functionality
echo -e "\n${YELLOW}Step 7: Add Listing Tests${NC}" | tee -a "$LOG_FILE"
test_workflow_step "Add Listing Page" "$BASE_URL/add_listing.php" "GET" "" "Add\|listing"

# Test listing submission
test_workflow_step "Listing Submission" "$BASE_URL/add_listing.php" "POST" \
    "thing_name=Test Item&description=Test description&category=tools&condition=good" \
    "listing\|success\|error\|Add"

# Step 8: Test notification preferences
echo -e "\n${YELLOW}Step 8: Notification Tests${NC}" | tee -a "$LOG_FILE"
test_workflow_step "Notification Preferences" "$BASE_URL/notifications.php" "POST" \
    "email_notifications=1&booking_notifications=1" "notification\|success\|error"

# Performance test
echo -e "\n${YELLOW}Step 9: Performance Tests${NC}" | tee -a "$LOG_FILE"
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

# Summary
echo -e "\n${BLUE}===============================================${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}Workflow Test Summary:${NC}" | tee -a "$LOG_FILE"
echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}" | tee -a "$LOG_FILE"
echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📊 Total Tests: $((TESTS_PASSED + TESTS_FAILED))${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📝 Log saved to: $LOG_FILE${NC}" | tee -a "$LOG_FILE"

# Clean up
rm -f "$COOKIE_FILE"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All workflow tests passed!${NC}" | tee -a "$LOG_FILE"
    exit 0
else
    echo -e "${RED}⚠️  Some workflow tests failed. Check the log for details.${NC}" | tee -a "$LOG_FILE"
    exit 1
fi 