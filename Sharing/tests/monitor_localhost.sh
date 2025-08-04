#!/bin/bash

# Continuous Monitoring Script for localhost:8000
# Monitors application availability and performance

BASE_URL="http://localhost:8000"
LOG_FILE="monitor_$(date +%Y%m%d_%H%M%S).log"
CHECK_INTERVAL=30  # seconds

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🔍 Starting continuous monitoring of localhost:8000" | tee -a "$LOG_FILE"
echo "Check interval: ${CHECK_INTERVAL} seconds" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "Press Ctrl+C to stop monitoring" | tee -a "$LOG_FILE"
echo "===============================================" | tee -a "$LOG_FILE"

# Counter
CHECKS=0
FAILURES=0

# Function to check endpoint
check_endpoint() {
    local name="$1"
    local url="$2"
    
    start_time=$(date +%s.%N)
    response=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME:%{time_total}s" "$url")
    end_time=$(date +%s.%N)
    
    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    response_time=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    content=$(echo "$response" | sed '/HTTP_CODE:/d' | sed '/TIME:/d')
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ "$http_code" = "200" ] && [ -n "$content" ]; then
        echo -e "[$timestamp] ${GREEN}✅ $name: OK (${response_time}s)${NC}" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "[$timestamp] ${RED}❌ $name: FAILED (HTTP: $http_code, Time: ${response_time}s)${NC}" | tee -a "$LOG_FILE"
        ((FAILURES++))
        return 1
    fi
}

# Function to check multiple endpoints
check_all_endpoints() {
    local all_ok=true
    
    check_endpoint "Homepage" "$BASE_URL/" || all_ok=false
    check_endpoint "Search" "$BASE_URL/search.php" || all_ok=false
    check_endpoint "Add Listing" "$BASE_URL/add_listing.php" || all_ok=false
    check_endpoint "My Bookings" "$BASE_URL/my_bookings.php" || all_ok=false
    check_endpoint "Notifications" "$BASE_URL/notifications.php" || all_ok=false
    
    if [ "$all_ok" = true ]; then
        echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}🎉 All endpoints OK${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}⚠️  Some endpoints failed${NC}" | tee -a "$LOG_FILE"
    fi
    
    return $([ "$all_ok" = true ] && echo 0 || echo 1)
}

# Main monitoring loop
trap 'echo -e "\n${YELLOW}Monitoring stopped by user${NC}"; echo "Final stats: $CHECKS checks, $FAILURES failures" | tee -a "$LOG_FILE"; exit 0' INT

while true; do
    ((CHECKS++))
    echo -e "\n${BLUE}Check #$CHECKS - $(date '+%Y-%m-%d %H:%M:%S')${NC}" | tee -a "$LOG_FILE"
    
    check_all_endpoints
    
    echo -e "${BLUE}Stats: $CHECKS checks, $FAILURES failures${NC}" | tee -a "$LOG_FILE"
    echo "Waiting ${CHECK_INTERVAL} seconds..." | tee -a "$LOG_FILE"
    sleep $CHECK_INTERVAL
done 