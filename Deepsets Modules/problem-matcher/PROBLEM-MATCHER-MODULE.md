# Problem Matcher Module - Sharing.canol.cymru

> **⚠️ CRITICAL**: This module requires timestamped execution. Use: `date +"%Y-%m-%d %H:%M:%S"`

## 🎯 **Module Purpose**

Automated code analysis system that provides comprehensive context for AI-assisted development. Creates timestamped problem reports with automatic archiving of previous analyses.

**Trigger Command**: `./analyze-code`  
**Output Location**: `reports/` directory with timestamped files  
**Archive Location**: `reports/archive/` directory

---

## 🚀 **Quick Start**

### **Single Analysis Run**
```bash
# Navigate to project root
cd /home/alexisrose/Documents/Repos/Sharing.canol.cymru

# Run analysis (creates timestamped report)
./analyze-code
```

### **View Latest Report**
```bash
# View the most recent analysis
cat "Deepsets Modules/problem-matcher/reports/problems_report_$(date +%Y-%m-%d)_*.txt"

# Or use the convenience link
cat "Deepsets Modules/problem-matcher/reports/latest_report.txt"
```

### **Use with AI Assistant**
1. Run `./analyze-code` before AI conversations
2. Attach the latest report file from `reports/` directory
3. Reference specific line numbers and issues in your prompts

---

## 📁 **Module Structure**

```
Deepsets Modules/problem-matcher/
├── PROBLEM-MATCHER-MODULE.md        # This documentation
├── problem_matcher.php              # Core analysis engine
├── analyze-code.sh                  # Main trigger script
├── reports/                         # Current analysis reports
│   ├── latest_report.txt            # Symlink to most recent
│   ├── problems_report_YYYY-MM-DD_HH-MM-SS.txt
│   └── problems_report_YYYY-MM-DD_HH-MM-SS.json
└── reports/archive/                 # Archived historical reports
    ├── YYYY-MM/                     # Monthly organization
    └── old_problems_report_*.txt
```

---

## 🔄 **Archiving System**

### **Automatic Archiving Triggers**
- **After 5 reports** in main directory
- **Reports older than 7 days** are auto-archived
- **When running analysis** if main directory is cluttered

### **Archive Organization**
```
reports/archive/
├── 2025-08/                        # Monthly folders
│   ├── problems_report_2025-08-01_09-15-30.txt
│   └── problems_report_2025-08-02_14-22-17.txt
└── 2025-07/
    └── problems_report_2025-07-28_16-45-12.txt
```

### **Manual Archive Command**
```bash
# Archive reports older than 7 days
"Deepsets Modules/problem-matcher/analyze-code.sh" --archive-old

# Archive all but latest 3 reports
"Deepsets Modules/problem-matcher/analyze-code.sh" --archive-all
```

---

## 📊 **Report Format**

### **Timestamped Filename Convention**
- **Format**: `problems_report_YYYY-MM-DD_HH-MM-SS.txt`
- **Example**: `problems_report_2025-08-04_13-25-18.txt`
- **JSON Version**: Same name with `.json` extension

### **Report Contents**
1. **Header Section**: Timestamp, total issues, analysis scope
2. **Security Issues**: SQL injection, unescaped input, authentication
3. **Code Quality**: Error handling, deprecated functions
4. **Development Notes**: TODO/FIXME comments
5. **File Statistics**: Lines of code, file counts

### **Sample Report Header**
```
=== PROBLEM MATCHER REPORT ===
Generated: 2025-08-04 13:25:18
Analysis Scope: ./Sharing (recursive)
Total Issues: 112
Total Files Analyzed: 15
Total Lines of Code: 2,847

## SECURITY ISSUES (112)
## ERROR_HANDLING ISSUES (0) 
## DEPRECATED ISSUES (0)
## TODO ISSUES (0)
```

---

## 🔧 **Configuration**

### **Analysis Scope**
Edit `problem_matcher.php` to change analysis directory:
```php
public function __construct($basePath = './Sharing') {
    $this->basePath = realpath($basePath);
}
```

### **Issue Detection Rules**
Add custom checks in `analyzeFile()` method:
```php
// Example: Check for missing CSRF protection
if (preg_match('/form.*method.*post/i', $line) && !preg_match('/csrf|token/', $line)) {
    $this->addProblem($relativePath, $lineNum, 'SECURITY', 'Missing CSRF protection', $line);
}
```

### **Archive Retention**
Modify retention settings in `analyze-code.sh`:
```bash
# Keep reports for 30 days instead of 7
ARCHIVE_DAYS=30

# Keep 10 recent reports instead of 5
MAX_REPORTS=10
```

---

## 🎯 **Integration with AI Development**

### **Before Coding Sessions**
```bash
# Get current state
./analyze-code

# Note the report filename for AI context
ls -la "Deepsets Modules/problem-matcher/reports/" | tail -1
```

### **During Problem Solving**
Reference specific issues:
```
"Based on the analysis from problems_report_2025-08-04_13-25-18.txt, 
I need help fixing the SQL injection on line 32 of account.php"
```

### **After Implementing Fixes**
```bash
# Re-analyze to verify improvements
./analyze-code

# Compare before/after
diff "Deepsets Modules/problem-matcher/reports/archive/2025-08/old_report.txt" \
     "Deepsets Modules/problem-matcher/reports/latest_report.txt"
```

---

## 🚨 **Critical Usage Notes**

### **Timestamp Accuracy** ⚠️
- **NEVER manually type dates** in filenames
- **ALWAYS use system commands**: `date +"%Y-%m-%d %H:%M:%S"`
- **VALIDATE timestamps** before sharing reports

### **Report Freshness** 📅
- **Check report age** before using with AI
- **Run fresh analysis** if reports are >24 hours old
- **Archive old reports** to avoid confusion

### **File Locations** 📁
- **Main reports**: `Deepsets Modules/problem-matcher/reports/`
- **Archived reports**: `Deepsets Modules/problem-matcher/reports/archive/`
- **Latest symlink**: Always points to most recent analysis

---

## 📋 **Troubleshooting**

### **Permission Issues**
```bash
chmod +x analyze-code
chmod +x "Deepsets Modules/problem-matcher/analyze-code.sh"
```

### **PHP Path Problems**
```bash
which php
# Update shebang in problem_matcher.php if needed
```

### **Archive Directory Issues**
```bash
# Manually create archive structure
mkdir -p "Deepsets Modules/problem-matcher/reports/archive/$(date +%Y-%m)"
```

---

## 🔄 **Module Maintenance**

### **Weekly Tasks**
- Review archive directory for disk space
- Validate that latest analysis reflects current code
- Check for new issue types to add to detection rules

### **Monthly Tasks**
- Analyze trends in issue counts
- Update detection patterns based on new vulnerabilities
- Review and optimize archive retention policies

---

**Last Updated**: Use `date +"%Y-%m-%d %H:%M:%S"` when modifying this file  
**Module Version**: 1.0  
**Compatible With**: PHP 8.0+, Linux/Unix systems 