# Sharing.canol.cymru Test Suite

This directory contains automated testing scripts for the Sharing.canol.cymru application.

## 🧪 **Available Tests**

### **1. Basic Endpoint Testing (`test_localhost.sh`)**
Tests all main application endpoints and basic functionality.

**Usage:**
```bash
cd Sharing/tests
./test_localhost.sh
```

**Tests:**
- ✅ Homepage, search, add listing, my bookings, notifications
- ✅ Form submissions (login, registration)
- ✅ Search with parameters
- ✅ Response times and HTTP codes

### **2. Advanced Workflow Testing (`test_workflow.sh`)**
Tests complete user journey and booking workflow with session handling.

**Usage:**
```bash
cd Sharing/tests
./test_workflow.sh
```

**Tests:**
- ✅ Complete user journey: register → login → search → book → notify
- ✅ Session handling and authentication
- ✅ Booking workflow end-to-end
- ✅ Performance benchmarks

### **3. Continuous Monitoring (`monitor_localhost.sh`)**
Continuously monitors application availability and performance.

**Usage:**
```bash
cd Sharing/tests
./monitor_localhost.sh
```

**Features:**
- ✅ Continuous availability checking
- ✅ Response time tracking
- ✅ Failure detection and logging
- ✅ Real-time status updates

## 🚀 **Quick Start**

```bash
# Navigate to test directory
cd Sharing/tests

# Run basic tests
./test_localhost.sh

# Run complete workflow tests
./test_workflow.sh

# Start continuous monitoring
./monitor_localhost.sh

# Run monitoring in background
nohup ./monitor_localhost.sh > monitor.log 2>&1 &
```

## 📊 **Test Results**

Test results are automatically logged to timestamped files:
- `test_results_YYYYMMDD_HHMMSS.log` - Basic endpoint test results
- `workflow_test_YYYYMMDD_HHMMSS.log` - Workflow test results
- `monitor_YYYYMMDD_HHMMSS.log` - Continuous monitoring logs

## 🔧 **Configuration**

All tests are configured to work with `http://localhost:8000` by default. To change the target URL, edit the `BASE_URL` variable in each script.

## 📋 **Test Coverage**

### **Phase 1 Core Features**
- [x] Homepage functionality
- [x] User registration and login
- [x] Item search and browsing
- [x] Account management

### **Phase 2 New Features**
- [x] Calendar booking system
- [x] Notification preferences
- [x] Booking management
- [x] Email notification system

### **Performance & Reliability**
- [x] Response time monitoring
- [x] HTTP status code validation
- [x] Content verification
- [x] Session handling

## 🛠️ **Troubleshooting**

### **Common Issues**

1. **Tests fail with connection refused**
   - Ensure the application is running on localhost:8000
   - Check if the web server is started

2. **Authentication tests fail**
   - Verify database is properly configured
   - Check if test user exists in database

3. **Workflow tests fail**
   - Ensure database has sample data
   - Check if all Phase 2 tables are created

### **Debug Mode**

To see detailed output, run tests with verbose logging:
```bash
# Enable debug output
export DEBUG=1
./test_workflow.sh
```

## 📈 **Integration with RAD Protocol**

These tests are integrated into the Rapid Agentic Development (RAD) protocol:

1. **PRE-TASK**: Run basic tests to verify current state
2. **IMPLEMENT**: Use workflow tests to validate changes
3. **TRIPLE-CHECK**: Run comprehensive test suite
4. **POST-TASK**: Use monitoring to ensure stability

## 🔄 **Continuous Integration**

For automated testing in CI/CD pipelines:

```bash
# Run all tests and exit with failure if any test fails
cd Sharing/tests
./test_localhost.sh && ./test_workflow.sh
```

## 📝 **Adding New Tests**

To add new test cases:

1. Create a new script in this directory
2. Follow the naming convention: `test_[feature].sh`
3. Include proper error handling and logging
4. Update this README with documentation
5. Ensure the script is executable: `chmod +x test_[feature].sh`

## 🎯 **Success Criteria**

Tests are considered successful when:
- All endpoints return HTTP 200 status codes
- Response times are under 2 seconds
- Expected content patterns are found
- No fatal errors or exceptions occur
- Session handling works correctly
- Database operations complete successfully 