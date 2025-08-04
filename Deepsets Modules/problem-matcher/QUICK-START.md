# Problem Matcher - Quick Start Guide 🚀

> **Quick trigger reference**: `./analyze-code` from project root

## 🎯 **30-Second Usage**

```bash
# 1. Run analysis
./analyze-code

# 2. View latest report  
cat "Deepsets Modules/problem-matcher/reports/latest_report.txt"

# 3. Attach to AI conversation and ask for help with specific issues
```

## 📋 **Common Commands**

```bash
# Standard analysis run
./analyze-code

# List all current reports
./analyze-code --list-reports

# List archived reports  
./analyze-code --list-archived

# Force archive old reports
./analyze-code --archive-old

# Show help
./analyze-code --help
```

## 🔄 **Typical Workflow**

### **Before AI Conversations**
1. **Generate fresh analysis**: `./analyze-code`
2. **Note the report file**: `problems_report_YYYY-MM-DD_HH-MM-SS.txt`
3. **Attach to your AI chat** or reference specific issues

### **During Development**
1. **Make code changes**
2. **Re-run analysis**: `./analyze-code`  
3. **Compare results**: Check if issue count decreased
4. **Ask AI for specific help**: "Fix the SQL injection on line 32 of account.php"

### **Example AI Prompts**
```
"Based on the latest problem report, I have 112 security issues. 
Which SQL injection vulnerability should I fix first?"

"The analysis shows plain text passwords in register.php line 65. 
Help me implement proper password hashing."

"I fixed some issues in account.php. Can you help me verify the 
security improvements by comparing the before/after reports?"
```

## 📊 **Report Structure**

### **Header Information**
- **Timestamp**: Exact analysis time  
- **Total Issues**: Issue count by severity
- **File Statistics**: Total files and lines analyzed

### **Issue Details**  
- **File:Line**: Exact location of each issue
- **Severity**: SECURITY, ERROR_HANDLING, DEPRECATED, TODO
- **Message**: Description of the problem
- **Code**: The actual problematic line

### **Example Issue**
```
account.php:32 - Unescaped user input detected
  Code: $query = 'insert into communities ( member_ID , community_name , password ) 
         values ( '.$_SESSION['member_ID'].' , '.qq($_POST["groupname"]).' , '
         .qq($_POST["grouppassword"]).' )';
```

## 🗂️ **File Organization**

```
Deepsets Modules/problem-matcher/
├── reports/
│   ├── latest_report.txt                    # ← Always current
│   ├── problems_report_2025-08-04_13-31-12.txt  # ← Timestamped
│   └── problems_report_2025-08-04_13-31-12.json # ← Machine readable
└── reports/archive/
    └── 2025-08/                            # ← Monthly archives
        └── old_problems_report_*.txt
```

## ⚡ **Quick Tips**

### **For New Issues**
- Focus on **SECURITY** issues first (highest priority)
- **Plain text passwords** are critical vulnerabilities
- **SQL injection** risks need immediate attention

### **For Progress Tracking**
- Compare issue counts before/after changes
- Archive old reports when major fixes are complete
- Use timestamped reports to track improvement over time

### **For AI Integration**
- Always run fresh analysis before asking for help
- Reference specific file:line numbers in your prompts
- Attach the full report for comprehensive context

## 🚨 **Current Status Alert**

**Latest Analysis Results**:
- **112 Security Issues** detected
- **Primary concern**: Unescaped user input (SQL injection risk)  
- **Critical files**: account.php, register.php, add_listing.php
- **Immediate action needed**: Input validation and prepared statements

---

**Ready to improve your code?** Run `./analyze-code` and start fixing! 🔧 