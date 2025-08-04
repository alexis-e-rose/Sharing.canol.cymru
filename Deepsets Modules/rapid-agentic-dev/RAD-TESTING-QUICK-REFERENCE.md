# RAD Testing Quick Reference

**Purpose**: Quick reference for RAD protocol testing integration  
**Status**: Active - Agentic Browser Testing as Primary Method

---

## 🚀 **RAD Testing Commands**

### **PRE-TASK VERIFICATION**
```bash
cd Sharing/tests
./test_localhost.sh                    # Quick connectivity check
./test_browser_agentic.sh | grep "Navigation successful"  # Baseline check
```

### **DURING IMPLEMENTATION**
```bash
./test_browser_agentic.sh              # After major changes
./test_enhanced.sh                     # After authentication changes
./test_localhost.sh                    # After quick fixes
```

### **TRIPLE-CHECK VERIFICATION**
```bash
./test_browser_agentic.sh              # Primary validation
./test_enhanced.sh                     # Security/auth validation
./test_localhost.sh                    # Quick final check
```

### **POST-TASK COMPLETION**
```bash
./test_browser_agentic.sh && ./test_enhanced.sh  # Comprehensive validation
echo "Test results: $(date)" >> TEST-ANALYSIS-REPORT.md
```

---

## 🎯 **Testing Priority**

1. **🤖 Agentic Browser Testing** - Primary method for workflow validation
2. **🧪 Enhanced Testing** - Secondary method for authentication/security
3. **⚡ Basic Testing** - Quick checks for connectivity
4. **📊 Continuous Monitoring** - Ongoing system health

---

## 📊 **Success Criteria**

### **Agentic Browser Testing**
- ✅ **88%+ navigation success rate**
- ✅ **Session persistence working**
- ✅ **Form submissions successful**
- ✅ **User workflows functional**

### **Enhanced Testing**
- ✅ **73%+ test pass rate**
- ✅ **Authentication working**
- ✅ **Security validation passed**
- ✅ **Performance < 2 seconds**

---

## 🔧 **Troubleshooting**

### **HTTP 500 Errors**
```bash
curl -v http://localhost:8000/problematic_page.php
php -r "include 'includes/connect.inc'; echo 'DB OK';"
```

### **Authentication Issues**
```bash
./test_browser_agentic.sh | grep "Navigation failed"
php -r "session_start(); var_dump(session_status());"
```

### **Performance Issues**
```bash
./monitor_localhost.sh
top -p $(pgrep php)
```

---

## 📚 **Documentation**

- **RAD Testing Integration**: `Sharing/tests/RAD-TESTING-INTEGRATION.md`
- **Test Comparison**: `Sharing/tests/TEST-COMPARISON-REPORT.md`
- **Test Analysis**: `Sharing/tests/TEST-ANALYSIS-REPORT.md`
- **Main Test Suite**: `Sharing/tests/README.md`

---

**Status**: ✅ **ACTIVE - INTEGRATED WITH RAD PROTOCOL** 