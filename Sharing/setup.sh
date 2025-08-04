#!/bin/bash

# Sharing.canol.cymru Setup Script
# Automates the setup process for new users

set -e  # Exit on any error

echo "🚀 Setting up Sharing.canol.cymru development environment..."
echo "============================================================="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if we're in the right directory
if [ ! -f "index.php" ]; then
    echo -e "${RED}❌ Error: Must run from the Sharing/ directory${NC}"
    echo "Usage: cd Sharing.canol.cymru/Sharing && ./setup.sh"
    exit 1
fi

echo -e "${BLUE}📋 Checking prerequisites...${NC}"

# Check PHP
if ! command -v php &> /dev/null; then
    echo -e "${RED}❌ PHP is not installed${NC}"
    echo "Please install PHP 7.4+ and try again"
    exit 1
fi

PHP_VERSION=$(php -v | head -n 1 | cut -d ' ' -f 2 | cut -c 1-3)
echo -e "${GREEN}✅ PHP ${PHP_VERSION} found${NC}"

# Check MySQL
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL/MariaDB is not installed${NC}"
    echo "Please install MySQL or MariaDB and try again"
    exit 1
fi

echo -e "${GREEN}✅ MySQL/MariaDB found${NC}"

# Check if database exists
echo -e "${BLUE}📊 Checking database configuration...${NC}"

DB_EXISTS=$(mysql -u testuser -ptestpass -e "USE sharingcanol_stuff_dev;" 2>&1 | grep -c "Unknown database" || true)

if [ "$DB_EXISTS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Database doesn't exist. Setting up...${NC}"
    
    read -p "Enter MySQL root password: " -s ROOT_PASS
    echo
    
    mysql -u root -p$ROOT_PASS -e "
        CREATE DATABASE IF NOT EXISTS sharingcanol_stuff_dev;
        CREATE USER IF NOT EXISTS 'testuser'@'localhost' IDENTIFIED BY 'testpass';
        GRANT ALL PRIVILEGES ON sharingcanol_stuff_dev.* TO 'testuser'@'localhost';
        FLUSH PRIVILEGES;
    "
    
    echo -e "${GREEN}✅ Database created${NC}"
    
    # Import schema
    echo -e "${BLUE}📥 Importing database schema...${NC}"
    mysql -u testuser -ptestpass sharingcanol_stuff_dev < database/sharingcanol_stuff.sql
    mysql -u testuser -ptestpass sharingcanol_stuff_dev < database/schema_updates_fixed.sql
    
    echo -e "${GREEN}✅ Database schema imported${NC}"
else
    echo -e "${GREEN}✅ Database already exists${NC}"
fi

# Set file permissions
echo -e "${BLUE}🔒 Setting file permissions...${NC}"
chmod 755 *.php
chmod 755 includes/*.inc
chmod +x tests/*.sh 2>/dev/null || true
chmod +x setup.sh

echo -e "${GREEN}✅ File permissions set${NC}"

# Kill existing PHP servers
echo -e "${BLUE}🔄 Stopping any existing PHP servers...${NC}"
pkill -f "php -S" 2>/dev/null || true
sleep 2

# Start the server
echo -e "${BLUE}🚀 Starting development server...${NC}"
echo "Starting server on http://localhost:8000"
echo "Press Ctrl+C to stop the server"
echo

# Start server in background initially to test it
php -S localhost:8000 &
SERVER_PID=$!
sleep 3

# Test the server
echo -e "${BLUE}🧪 Testing server...${NC}"
if curl -s http://localhost:8000/ | grep -q "Welcome to Sharing.Canol.Cymru"; then
    echo -e "${GREEN}✅ Server is running successfully!${NC}"
    echo
    echo -e "${GREEN}🎉 Setup complete!${NC}"
    echo
    echo "Next steps:"
    echo "1. Visit http://localhost:8000/ in your browser"
    echo "2. Register a new account"
    echo "3. Run tests: cd tests && ./test_browser_agentic.sh"
    echo
    echo "Development tools:"
    echo "• Security analysis: cd .. && \"Deepsets Modules/problem-matcher/analyze-code\""
    echo "• Continuous testing: cd tests && ./monitor_localhost.sh"
    echo
    echo "Server is running. Press Ctrl+C to stop."
    
    # Stop background server and start in foreground
    kill $SERVER_PID
    wait $SERVER_PID 2>/dev/null || true
    
    # Start server in foreground
    exec php -S localhost:8000
else
    echo -e "${RED}❌ Server test failed${NC}"
    kill $SERVER_PID 2>/dev/null || true
    exit 1
fi 