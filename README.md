# Sharing.canol.cymru 🌍

A community-driven platform for sharing, lending, and trading items within local communities across Wales. This project facilitates sustainable living through peer-to-peer item sharing, local marketplaces, and community building.

## 🚀 **Quick Start for New Users**

> **📖 For detailed setup instructions, see [GETTING_STARTED.md](GETTING_STARTED.md)**

### **One-Command Setup** ⚡
```bash
# Clone and setup in one go
git clone https://github.com/your-username/Sharing.canol.cymru.git
cd Sharing.canol.cymru/Sharing && ./setup.sh
```

### **Prerequisites**
Before you start, ensure you have:
- **PHP 7.4+** with MySQL/MariaDB support (`php -v` to check)
- **MySQL/MariaDB** database server (`mysql --version` to check)
- **Git** for cloning the repository
- **curl** for testing (usually pre-installed)

### **Step 1: Clone and Setup**
```bash
# Clone the repository
git clone https://github.com/your-username/Sharing.canol.cymru.git
cd Sharing.canol.cymru

# Navigate to the application directory
cd Sharing
```

### **Step 2: Database Setup**
```bash
# 1. Create a database (login to MySQL first)
mysql -u root -p
CREATE DATABASE sharingcanol_stuff_dev;
CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpass';
GRANT ALL PRIVILEGES ON sharingcanol_stuff_dev.* TO 'testuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 2. Import the database schema
cd database
mysql -u testuser -p sharingcanol_stuff_dev < sharingcanol_stuff.sql
mysql -u testuser -p sharingcanol_stuff_dev < schema_updates_fixed.sql

# 2b. (Optional) Apply Phase 3 groundwork schema
mysql -u testuser -p sharingcanol_stuff_dev < schema_updates_phase3.sql

# 3. Return to Sharing directory
cd ..
```

### **Step 3: Start the Development Server**
```bash
# Make sure you're in the Sharing directory
pwd
# Should show: /your/path/Sharing.canol.cymru/Sharing

# Kill any existing PHP servers
pkill -f "php -S" 2>/dev/null || true

# Start the development server
php -S localhost:8000

# In another terminal, test the server
curl http://localhost:8000/
# Expected: "Welcome to Sharing.Canol.Cymru"
```

### **Step 4: Run Tests**
```bash
# Open a new terminal window/tab
cd /your/path/Sharing.canol.cymru/Sharing/tests

# Run the primary test suite
./test_browser_agentic.sh

# Expected: 100% success rate with all tests passing
```

### **Step 5: Access the Application**
Open your browser and visit:
- **Homepage**: http://localhost:8000/
- **Register**: http://localhost:8000/register.php
- **Search Items**: http://localhost:8000/search.php

## 🔧 **Troubleshooting**

### **Common Issues**

**Server won't start or 404 errors:**
```bash
# Ensure you're in the correct directory
cd Sharing.canol.cymru/Sharing
ls -la index.php  # Should exist

# Try alternative startup method
php -S localhost:8000 -t .
```

**Database connection errors:**
```bash
# Test database connection
mysql -u testuser -p sharingcanol_stuff_dev
# If this fails, repeat Step 2

# Check database credentials in includes/connect.inc
cat includes/connect.inc
```

**Permission issues:**
```bash
# Fix file permissions
chmod 755 *.php
chmod 755 includes/*.inc
chmod +x tests/*.sh
```

### **Development Tools**

**Security Analysis:**
```bash
# Run from project root
cd ..  # Go to project root
"Deepsets Modules/problem-matcher/analyze-code"
```

**Feature Flags (dev):**
```php
// Edit this file to toggle features during development:
// File: Sharing/includes/feature_flags.inc
$FEATURE_FLAGS = [
  'sales_flow' => false,
  'donation_ledger' => false,
  'donation_statements' => false,
  'community_freeze' => false,
  'enhanced_visibility' => false,
  'listing_enhancements' => false,
];
// Flags are loaded globally via includes/header.inc and includes/header2.inc
```

**Continuous Testing:**
```bash
cd Sharing/tests
./monitor_localhost.sh  # For continuous monitoring
```

## 🏗️ **Project Organization**

```
Sharing.canol.cymru/
├── Sharing/                    # Main application code
│   ├── index.php              # Application entry point
│   ├── *.php                  # Core application files
│   ├── includes/              # PHP includes and functions
│   ├── database/              # Database schema and migrations
│   ├── docs/                  # Project documentation
│   └── tests/                 # Automated testing suite
├── Deepsets Modules/          # Agentic development modules
│   ├── rapid-agentic-dev/     # RAD protocol and workflows
│   ├── problem-matcher/       # Security analysis and DPM
│   ├── documentation-framework/ # Documentation templates
│   ├── knowledge-base/        # Established patterns
│   ├── active-projects/       # Current work tracking
│   ├── completed-projects/    # Archived implementations
│   └── roadmaps/             # Strategic planning
├── logs/                      # Application logs
└── README.md                  # This file
```

## 🎯 **Current Status**

**Phase 2 Fully Deployed & Stable** ✅

### **What's Working**
- ✅ **Phase 1 Core Platform**: User registration, item management, search
- ✅ **Phase 2 Calendar Booking**: Complete booking workflow with notifications
- ✅ **Database Schema**: All tables properly migrated with constraints
- ✅ **Security Framework**: Enhanced security functions implemented
- ✅ **Automated Testing**: Comprehensive test suite with monitoring

### **In Progress**
- 🛠️ **Phase 3 Groundwork**: Feature flags wired; dev DB updated with causes/visibility/sales/donations schema; UI gating active for enhanced visibility and sales flow (flags default-off)

### **Recent Accomplishments**
- **Critical Hotfix Applied**: Resolved fatal database errors and runtime issues
- **Code Quality Improved**: Added defensive programming with `isset()` checks
- **Testing Integration**: Automated test suite with workflow validation
- **Documentation Updated**: Comprehensive project structure and guides

## 📊 **Technical Stack**

### **Backend**
- **Language**: PHP 7.4+
- **Database**: MySQL/MariaDB
- **Web Server**: Apache/Nginx (or PHP built-in server)

### **Features**
- **User Management**: Registration, authentication, profiles
- **Item Sharing**: Listing, search, categorization
- **Booking System**: Calendar-based booking with approval workflow
- **Notifications**: Email templates and user preferences
- **Security**: Enhanced security functions and validation

### **Development Tools**
- **RAD Protocol**: Rapid Agentic Development workflow
- **DPM Module**: Problem Matcher for security analysis
- **Test Suite**: Automated testing with curl-based scripts
- **Documentation Framework**: Structured documentation templates

## 📈 **Performance & Security**

### **Performance**
- **Response Times**: < 2 seconds for all endpoints
- **Database**: Optimized queries with proper indexing
- **Caching**: Session-based user data caching
- **Monitoring**: Continuous availability tracking

### **Security**
- **112 legacy security issues** maintained (deferred per user priority)
- **No new vulnerabilities** introduced in Phase 2
- **Enhanced security functions** in `includes/security_functions.inc`
- **Automated security analysis** via DPM module

## 🗄️ **Database Schema**

### **Core Tables**
  - `members` - User accounts and profiles
  - `things` - Items available for sharing
  - `groups` - Community groups and access control

### **Phase 2 Tables**
- `bookings` - Calendar booking system
- `booking_notifications` - Notification preferences
- `notification_logs` - Email notification tracking

### **Phase 3 Groundwork (feature-flagged)**
- `community_causes` - Admin-defined donation causes per community
- `thing_visibility` - Per-community item visibility mapping
- `sale_reservations` - Reservations for sale items
- `sales` - Sale confirmations and pricing
- `donation_pledges` - Ledger entries for pledges
- `donation_statements` - Threshold-based statements
- `donation_statement_items` - Statement line items
- `donation_payments` - Admin-recorded payments/reconciliation

## 📚 **Documentation**

### **Getting Started**
- **Quick Setup**: [GETTING_STARTED.md](GETTING_STARTED.md) - Comprehensive setup guide
- **Main README**: This file - Project overview and status
- **Application README**: `Sharing/README.md` - Application-specific documentation

### **Application Documentation**
- **Deployment**: `Sharing/docs/DEPLOYMENT_GUIDE.md` - Production deployment
- **Phase 2**: `Sharing/docs/PHASE-2-*.md` - Implementation details
- **Testing**: `Sharing/tests/README.md` - Test suite documentation

### **Development Documentation**
- **RAD Protocol**: `Deepsets Modules/rapid-agentic-dev/RAD-MODULE.md`
- **Problem Matcher**: `Deepsets Modules/problem-matcher/PROBLEM-MATCHER-MODULE.md`
- **Documentation Framework**: `Deepsets Modules/documentation-framework/DOC-FRAMEWORK.md`

## 🎯 **Next Steps**

### **For New Users**
1. **Follow Setup Guide**: Use [GETTING_STARTED.md](GETTING_STARTED.md) for detailed instructions
2. **Run Tests**: Verify everything works with `./test_browser_agentic.sh`
3. **Explore Features**: Register account, try booking system
4. **Check Security**: Run DPM analysis for code quality

### **For Developers**
1. **Development Workflow**: Follow RAD protocol for contributions
2. **Testing Integration**: Use agentic browser testing for all changes
3. **Security First**: Regular DPM analysis before commits
4. **Documentation**: Update docs with any significant changes
5. **Feature Flags**: Toggle flags in `Sharing/includes/feature_flags.inc` to demo Phase 3 features (default-off)

## 🔗 **Related Modules**

- **RAD Protocol**: `Deepsets Modules/rapid-agentic-dev/` - Rapid development workflow
- **Problem Matcher**: `Deepsets Modules/problem-matcher/` - Security and code analysis
- **Documentation Framework**: `Deepsets Modules/documentation-framework/` - Structured documentation
- **Knowledge Base**: `Deepsets Modules/knowledge-base/` - Established patterns and solutions

## 🚨 **Status Summary**

### **Current State**
- ✅ **Phase 2 Fully Deployed**: Calendar booking and notification systems stable
- ✅ **Automated Setup**: One-command setup script working perfectly
- ✅ **Comprehensive Testing**: 100% success rate with agentic browser testing
- ✅ **Documentation Updated**: Complete getting started guide available
- ✅ **Security Status**: 40 functions detected, no new vulnerabilities

### **Quality Metrics**
- **Testing**: 100% success rate (17/17 tests pass)
- **Performance**: < 1 second response times
- **Security**: Legacy issues maintained, no new vulnerabilities
- **Documentation**: Comprehensive setup and development guides

---

**Status**: ✅ **READY FOR NEW USERS**  
**Setup**: ✅ **One-Command Setup Available**  
**Testing**: ✅ **100% Success Rate**  
**Documentation**: ✅ **Comprehensive Guide Complete**