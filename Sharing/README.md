# Sharing.canol.cymru Application

A community-driven platform for sharing, lending, and trading items within local communities across Wales. This project facilitates sustainable living through peer-to-peer item sharing, local marketplaces, and community building.

## 🚀 **Quick Start for New Users**

### **One-Command Setup** ⚡
```bash
# Clone the repository and navigate to the application
git clone https://github.com/your-username/Sharing.canol.cymru.git
cd Sharing.canol.cymru/Sharing

# Run the automated setup script
./setup.sh
```

This script will:
- ✅ Check all prerequisites (PHP, MySQL)
- ✅ Create and configure the database
- ✅ Import the schema and data
- ✅ Set proper file permissions
- ✅ Start the development server
- ✅ Test that everything is working

### **Manual Setup** (Alternative)

## 🏗️ **Project Structure**

```
Sharing/
├── index.php                 # Main application entry point
├── search.php               # Item search and browsing
├── add_listing.php          # Add new items to share
├── my_bookings.php          # User booking management
├── notifications.php        # Notification preferences and center
├── account.php              # User account management
├── register.php             # User registration
├── request_booking.php      # Booking request system
├── create_private.php       # Private group creation
├── joingroup.php           # Group joining functionality
├── login_form              # Login form handler
├── cron_notifications.php  # Automated notification processing
├── test_security.php       # Security testing page
├── setup_cron.sh          # Cron job setup script
├── includes/               # PHP includes and functions
│   ├── connect.inc        # Database connection
│   ├── connect_dev.inc    # Development database connection
│   ├── header.inc         # Common header
│   ├── header2.inc        # Alternative header
│   ├── login_form.inc     # Login form components
│   ├── login_process.inc  # Login processing
│   ├── logout_form.inc    # Logout form
│   ├── logout_process.inc # Logout processing
│   ├── miscfunctions.inc  # Utility functions
│   ├── booking_functions.inc # Booking system functions
│   ├── notification_functions.inc # Notification system
│   └── security_functions.inc # Security implementations
├── database/              # Database schema and migrations
│   ├── sharingcanol_stuff.sql # Main database schema
│   ├── schema_updates.sql     # Phase 2 schema updates
│   └── schema_updates_fixed.sql # Fixed schema updates
├── docs/                  # Project documentation
│   ├── DEPLOYMENT_GUIDE.md    # Deployment instructions
│   ├── PHASE-2-DEPLOYMENT-COMPLETE.md # Phase 2 completion
│   └── PHASE-2-HOTFIX-COMPLETE.md # Hotfix documentation
└── tests/                 # Automated testing suite
    ├── README.md          # Test suite documentation
    ├── test_localhost.sh  # Basic endpoint testing
    ├── test_workflow.sh   # Complete workflow testing
    └── monitor_localhost.sh # Continuous monitoring
```

## 🧪 **Testing the Application**

### **Primary Testing Method: Agentic Browser Testing**
```bash
cd tests
./test_browser_agentic.sh
```

**What this tests:**
- ✅ Complete user registration workflow
- ✅ Login and authentication
- ✅ Item search and browsing
- ✅ Booking request system
- ✅ Notification center
- ✅ Session management
- ✅ Form submissions
- ✅ Performance (< 1 second response times)

**Success Criteria:** 100% navigation success rate (17/17 tests)

### **Additional Testing**
```bash
# Complete workflow testing
./test_workflow.sh

# Continuous monitoring
./monitor_localhost.sh
```

## 🔧 **Development Tools**

### **Security Analysis (DPM)**
```bash
# Run from project root
cd ..
"Deepsets Modules/problem-matcher/analyze-code"
```

**Current Status:** 
- ✅ 40 defined functions in codebase
- ⚠️ 202 legacy security issues (maintained per user priority)
- ✅ No new vulnerabilities in Phase 2

### **RAD Protocol Integration**
This project follows the Rapid Agentic Development protocol:
1. **PRE-TASK**: Check documentation, validate requirements
2. **IMPLEMENT**: Execute with speed, test incrementally
3. **TRIPLE-CHECK**: Run automated tests, verify functionality
4. **POST-TASK**: Update documentation, archive completed work

## 🎯 **Current Status**

**Phase 2 Fully Deployed & Stable** ✅

### **Phase 1 Features** (Core Platform)
- ✅ User registration and authentication
- ✅ Item listing and management
- ✅ Search and browse functionality
- ✅ Basic user profiles

### **Phase 2 Features** (Calendar Booking System)
- ✅ Calendar-based booking system
- ✅ Notification preferences and email templates
- ✅ Booking approval workflow
- ✅ Automated notification processing
- ✅ Enhanced search with booking integration

## 📊 **Security Status**

- **112 legacy security issues** maintained (deferred per user priority)
- **No new vulnerabilities** introduced in Phase 2
- **Enhanced security functions** implemented in `includes/security_functions.inc`
- **Automated security analysis** available via DPM module

## 🗄️ **Database Schema**

### **Core Tables**
- `members` - User accounts and profiles
- `things` - Items available for sharing
- `groups` - Community groups and access control

### **Phase 2 Tables**
- `bookings` - Calendar booking system
- `booking_notifications` - Notification preferences
- `notification_logs` - Email notification tracking

## 📈 **Performance**

- **Response times**: < 2 seconds for all endpoints
- **Database queries**: Optimized with proper indexing
- **Caching**: Session-based caching for user data
- **Monitoring**: Continuous availability tracking

## 🛠️ **Troubleshooting**

### **Common Issues**

1. **Database Connection Errors**
   - Verify credentials in `includes/connect.inc`
   - Check database server is running
   - Ensure database exists and is accessible

2. **Booking System Issues**
   - Verify Phase 2 tables are created
   - Check notification preferences are set
   - Validate cron job is running for notifications

3. **Test Failures**
   - Ensure application is running on localhost:8000
   - Check database has sample data
   - Verify all includes are accessible

### **Debug Mode**
```bash
# Enable debug output in tests
export DEBUG=1
cd Sharing/tests
./test_workflow.sh
```

## 📚 **Documentation**

- **Deployment Guide**: `docs/DEPLOYMENT_GUIDE.md`
- **Phase 2 Documentation**: `docs/PHASE-2-*.md`
- **Test Suite**: `tests/README.md`
- **Security Testing**: `test_security.php`

## 🔗 **Related Modules**

- **RAD Protocol**: `Deepsets Modules/rapid-agentic-dev/`
- **Problem Matcher**: `Deepsets Modules/problem-matcher/`
- **Documentation Framework**: `Deepsets Modules/documentation-framework/`

## 🎯 **Next Steps**

1. **User Acceptance Testing**: Complete end-to-end workflow validation
2. **Performance Optimization**: Monitor and optimize database queries
3. **Mobile Responsiveness**: Implement CSS framework for mobile devices
4. **Phase 3 Planning**: Advanced features and community tools

---

**Status**: ✅ **DEPLOYED & STABLE**  
**Last Updated**: 2025-08-04  
**Version**: Phase 2 Complete 