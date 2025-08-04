# Getting Started with Sharing.canol.cymru 🚀

**Quick setup guide for developers pulling from GitHub**

## Prerequisites ✅

Before you begin, make sure you have:

1. **PHP 7.4+** with MySQL support
   ```bash
   php -v  # Check version
   php -m | grep mysql  # Verify MySQL support
   ```

2. **MySQL or MariaDB**
   ```bash
   mysql --version  # Check if installed
   ```

3. **Git** (to clone the repository)
   ```bash
   git --version
   ```

4. **curl** (for testing - usually pre-installed)
   ```bash
   curl --version
   ```

## Option 1: Automated Setup (Recommended) ⚡

```bash
# 1. Clone the repository
git clone https://github.com/your-username/Sharing.canol.cymru.git
cd Sharing.canol.cymru/Sharing

# 2. Run the setup script
./setup.sh
```

**That's it!** The script will handle everything automatically:
- Database creation and setup
- Schema import
- Server startup
- Testing

## Option 2: Manual Setup 🔧

If you prefer to set up manually or the automated script fails:

### Step 1: Clone and Navigate
```bash
git clone https://github.com/your-username/Sharing.canol.cymru.git
cd Sharing.canol.cymru/Sharing
```

### Step 2: Database Setup
```bash
# Login to MySQL as root
mysql -u root -p

# Create database and user
CREATE DATABASE sharingcanol_stuff_dev;
CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpass';
GRANT ALL PRIVILEGES ON sharingcanol_stuff_dev.* TO 'testuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Import the schema
cd database
mysql -u testuser -p sharingcanol_stuff_dev < sharingcanol_stuff.sql
mysql -u testuser -p sharingcanol_stuff_dev < schema_updates_fixed.sql
cd ..
```

### Step 3: Start the Server
```bash
# Kill any existing PHP servers
pkill -f "php -S" 2>/dev/null || true

# Start the development server
php -S localhost:8000
```

### Step 4: Test the Setup
```bash
# In another terminal
curl http://localhost:8000/
# Expected: HTML containing "Welcome to Sharing.Canol.Cymru"
```

## Verification & Testing 🧪

### 1. Access the Application
Open your browser and visit:
- **Homepage**: http://localhost:8000/
- **Register**: http://localhost:8000/register.php
- **Search**: http://localhost:8000/search.php

### 2. Run the Test Suite
```bash
cd tests
./test_browser_agentic.sh
```

**Expected Output:**
- ✅ 100% success rate (17/17 tests pass)
- ✅ All navigation working
- ✅ Registration and login working
- ✅ Booking system functional

### 3. Check the Application Status
```bash
# Security analysis
cd ..
"Deepsets Modules/problem-matcher/analyze-code"

# Should show: 40 defined functions, system working properly
```

## Common Issues & Solutions 🛠️

### Issue: "Command not found: ./setup.sh"
```bash
# Fix permissions
chmod +x setup.sh
./setup.sh
```

### Issue: Database connection errors
```bash
# Check if MySQL is running
sudo systemctl status mysql
# or
sudo systemctl status mariadb

# Test connection manually
mysql -u testuser -p sharingcanol_stuff_dev
```

### Issue: Server returns 404 for all pages
```bash
# Ensure you're in the correct directory
pwd
# Should end with: Sharing.canol.cymru/Sharing

# Check if index.php exists
ls -la index.php

# Try starting server with explicit document root
php -S localhost:8000 -t .
```

### Issue: Permission denied errors
```bash
# Fix file permissions
chmod 755 *.php
chmod 755 includes/*.inc
chmod +x tests/*.sh
```

## Development Workflow 🔄

### Making Changes
1. Always run tests after changes:
   ```bash
   cd tests
   ./test_browser_agentic.sh
   ```

2. Check for security issues:
   ```bash
   cd ..
   "Deepsets Modules/problem-matcher/analyze-code"
   ```

3. Follow the RAD protocol:
   - **PRE-TASK**: Check documentation
   - **IMPLEMENT**: Make changes with testing
   - **TRIPLE-CHECK**: Verify everything works
   - **POST-TASK**: Update documentation

### Key Features to Test
- ✅ User registration and login
- ✅ Item listing and search
- ✅ Calendar booking system
- ✅ Notification center
- ✅ User account management

## Project Structure 📁

```
Sharing.canol.cymru/
├── Sharing/                    # Main application
│   ├── setup.sh               # Automated setup script
│   ├── index.php              # Homepage
│   ├── includes/              # PHP functions
│   ├── database/              # Schema files
│   └── tests/                 # Test suite
└── Deepsets Modules/          # Development tools
    ├── problem-matcher/       # Security analysis
    └── rapid-agentic-dev/     # Development workflow
```

## Next Steps 🎯

1. **Explore the Application**: Register an account and try the booking system
2. **Read the Documentation**: Check `README.md` and `Sharing/docs/`
3. **Join Development**: Follow the RAD protocol for contributions
4. **Run Security Analysis**: Use the DPM tools for code quality

## Support 💬

- **Documentation**: Check `README.md` and `Sharing/README.md`
- **Issues**: Review troubleshooting sections above
- **Testing**: Use `test_browser_agentic.sh` for comprehensive testing
- **Security**: Run DPM analysis for code quality checks

---

**Status**: ✅ **Phase 2 Complete & Stable**  
**Testing**: ✅ **100% Success Rate Achieved**  
**Security**: ✅ **No New Vulnerabilities** 