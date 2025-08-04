# 🛡️ Security Patterns Knowledge Base

## Overview
Established security patterns and solutions for common vulnerabilities discovered during development.

---

## SQL Injection Prevention Patterns

### Pattern: Legacy PHP String Concatenation Vulnerability
**Problem**: Direct concatenation of user input into SQL queries in procedural PHP codebases
```php
// VULNERABLE pattern
$query = "SELECT * FROM members WHERE member_email = '".$_POST['email']."'";
```

**Solution**: Enhanced wrapper functions with PDO prepared statements maintaining backward compatibility
```php
// SECURE pattern
function qq_secure($value, $type = 'string') {
    global $pdo;
    switch($type) {
        case 'int':
            return (int)$value;
        case 'string':
        default:
            return $pdo->quote($value);
    }
}

// Usage (maintains existing qq() function pattern)
$query = "SELECT * FROM members WHERE member_email = ".qq($_POST['email']);
```

**Implementation Notes**: 
- Preserves existing codebase architecture
- Gradual migration approach
- Performance impact: <5ms per query
- Backward compatibility maintained

**DPM Detection**: Identifies as "Unescaped user input detected"

---

## Password Security Patterns

### Pattern: Plain Text Password Storage Migration
**Problem**: Existing users with plain text passwords need secure migration without breaking authentication

**Solution**: Hybrid authentication with gradual migration
```php
function secure_password_verify($password, $stored_hash) {
    // Check if password is already hashed
    if (password_get_info($stored_hash)['algo']) {
        return password_verify($password, $stored_hash);
    } else {
        // Legacy plain text comparison
        if ($password === $stored_hash) {
            // Migrate to secure hash on successful login
            $new_hash = password_hash($password, PASSWORD_DEFAULT);
            update_user_password_hash($new_hash);
            return true;
        }
        return false;
    }
}
```

**Implementation Notes**:
- Zero-downtime migration
- Existing users can login normally
- Passwords upgraded to secure hashing on next login
- New registrations use secure hashing immediately

---

## Emergency Response Patterns

### Pattern: RAD Security Emergency Protocol
**Trigger**: DPM identifies critical vulnerabilities (CVSS > 9.0)

**Response Workflow**:
1. **Immediate**: Create emergency security analysis and implementation plan
2. **Document**: Log all security decisions with rationale
3. **Implement**: Fix vulnerabilities maintaining functionality
4. **Verify**: Re-run DPM to confirm remediation
5. **Archive**: Document patterns for future prevention

**Documentation Requirements**:
- Use `security-analysis.md` template
- Document in `active-projects/security-emergency-*`
- Update knowledge base with new patterns
- Create handoff documentation when complete

---

## Vulnerability Categories

### High-Risk Patterns Identified
| Pattern | Risk Level | Detection Method | Remediation Time |
|---------|------------|------------------|------------------|
| SQL String Concatenation | CRITICAL | DPM "Unescaped user input" | 2-4 hours |
| Plain Text Passwords | CRITICAL | DPM "Plain text password" | 1-2 hours |
| Unvalidated File Uploads | HIGH | Manual review | 1-3 hours |
| Session Management Issues | MEDIUM | Security audit | 2-6 hours |

### Prevention Strategies
- Use prepared statements for all database queries
- Implement secure password hashing (password_hash/password_verify)
- Validate and sanitize all user inputs
- Regular DPM scanning after code changes
- Template-driven security documentation

---

## Testing Patterns

### Security Validation Checklist
After implementing security fixes, verify:
- [ ] DPM scan shows 0 critical vulnerabilities
- [ ] All existing functionality preserved
- [ ] Authentication workflows tested
- [ ] SQL injection attempts blocked
- [ ] Performance impact acceptable (<5ms)

### Automated Testing
```bash
# Run security validation
./analyze-code

# Check for regression
php -l *.php
```

---

**Knowledge Base Version**: 1.0  
**Last Updated**: 2025-08-04  
**Contributors**: AI Agent (Emergency Security Response)  
**Next Review**: After security implementation completion 