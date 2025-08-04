# 🤖 AI Agent Documentation Guide

## Agent Responsibilities

### **MANDATORY Documentation Behaviors**
Every AI agent working on this project **MUST** follow these documentation protocols:

## 🔍 PRE-TASK: Documentation Discovery Phase

### 1. Check Existing Documentation (REQUIRED)
```bash
# Agent must check these locations FIRST:
1. active-projects/         # Look for related ongoing work
2. completed-projects/      # Review similar past implementations  
3. roadmaps/               # Understand strategic context
4. knowledge-base/         # Find established patterns and solutions
```

### 2. Documentation Gap Analysis
- **IF** related documentation exists → Reference and build upon it
- **IF** no documentation exists → Create new documentation using templates
- **IF** documentation is outdated → Update existing documentation

### 3. Template Selection Matrix
| Task Type | Primary Template | Secondary Templates |
|-----------|-----------------|-------------------|
| New Feature | `implementation-plan.md` | `feature-spec.md` |
| Security Issue | `security-analysis.md` | `implementation-plan.md` |
| Bug Fix | `implementation-plan.md` | N/A |
| Module Creation | `module-spec.md` | `implementation-plan.md` |
| Performance Issue | `implementation-plan.md` | N/A |
| Architecture Change | `module-spec.md` | `roadmap.md` |

## 🚀 IMPLEMENTATION: Real-Time Documentation Updates

### Progress Tracking (Update Every Major Step)
```markdown
## Progress Tracking
### Completed Tasks
- [x] [2025-08-04] Database schema analysis completed
- [x] [2025-08-04] Security vulnerabilities identified

### In Progress Tasks  
- [ ] [CURRENT] Implementing prepared statements for SQL injection fix
- [ ] [NEXT] Testing authentication security improvements

### Blockers/Issues
- **Issue**: Legacy code uses procedural approach, requires careful refactoring
  **Status**: INVESTIGATING
  **Resolution**: Creating secure wrapper functions to maintain compatibility
```

### Decision Documentation (Document Every Technical Choice)
```markdown
### [2025-08-04] - Prepared Statements Implementation
**Context**: 112 SQL injection vulnerabilities found in DPM report
**Options Considered**: 
  1. Complete rewrite to ORM
  2. Gradual migration to prepared statements  
  3. Input sanitization only
**Decision**: Gradual migration to prepared statements with secure wrapper functions
**Impact**: Maintains existing code structure while eliminating SQL injection risks
```

### Security Decision Logging (CRITICAL for Security Work)
```markdown
### [2025-08-04] - Password Hashing Strategy
**Security Issue**: Plain text password storage across authentication system
**Options Evaluated**: bcrypt, Argon2, PHP password_hash() with bcrypt
**Decision**: PHP password_hash() with PASSWORD_DEFAULT for future compatibility  
**Trade-offs**: Slight performance impact vs critical security improvement
**Implementation**: Created secure_password_hash() and secure_password_verify() functions
```

## 🔍 TRIPLE-CHECK: Documentation Verification

### Pre-Completion Checklist
- [ ] **Implementation Status**: All progress accurately reflected
- [ ] **Decision Rationale**: All technical choices documented with reasoning
- [ ] **Security Implications**: Security decisions and trade-offs documented
- [ ] **Testing Results**: Test outcomes and validation steps recorded
- [ ] **Knowledge Extraction**: Patterns and learnings identified for knowledge base

### Hallucination Prevention
- [ ] **File References**: All mentioned files actually exist
- [ ] **Function References**: All referenced functions are implemented
- [ ] **Database References**: All table/column references are accurate
- [ ] **Integration Points**: All system integrations are correctly described

## 📋 POST-TASK: Documentation Finalization

### Knowledge Base Updates (Add New Patterns)
```markdown
# Add to knowledge-base/security-patterns.md:
## SQL Injection Prevention Pattern
### Problem: Legacy procedural PHP with string concatenation
### Solution: Secure wrapper functions maintaining compatibility
### Implementation: 
- qq() function enhanced with PDO prepared statements
- Backward compatibility maintained
- Performance impact: <5ms per query
```

### Documentation Archival Rules
| Project Status | Action Required |
|---------------|-----------------|
| COMPLETE | Move to `completed-projects/[project-name]/` |
| ON-HOLD | Keep in `active-projects/` with status update |
| CANCELLED | Move to `completed-projects/cancelled/[project-name]/` |
| ONGOING | Keep in `active-projects/` with progress updates |

### Handoff Documentation (When Required)
```markdown
# Generate handoff-report.md when:
- Transferring work to another agent/developer
- Project reaches major milestone  
- Security remediation is complete
- Major architectural changes are finished
```

## 🔄 RAD Integration Protocols

### RAD Phase Documentation Requirements

#### Pre-Task ✅
- [ ] **Documentation Discovery**: Check active-projects/, roadmaps/, knowledge-base/
- [ ] **Template Creation**: Copy appropriate template to active-projects/[project-name]/
- [ ] **Context Integration**: Reference related documentation and dependencies
- [ ] **Success Criteria**: Define measurable outcomes in implementation plan

#### Implementation 🚀
- [ ] **Real-Time Updates**: Update progress tracking after each major step
- [ ] **Decision Documentation**: Log technical decisions immediately when made
- [ ] **Security Recording**: Document security implications and trade-offs
- [ ] **Testing Documentation**: Record testing approach and results

#### Triple-Check 🔍
- [ ] **Documentation Accuracy**: Verify all documentation reflects actual implementation
- [ ] **Reference Validation**: Confirm all file, function, and system references are correct
- [ ] **Security Verification**: Ensure security decisions and implementations are documented
- [ ] **Knowledge Extraction**: Identify patterns and lessons for knowledge base

#### Post-Task 📋
- [ ] **Status Finalization**: Update project status (complete/ongoing/on-hold)
- [ ] **Knowledge Base Update**: Add new patterns, solutions, and troubleshooting info
- [ ] **Archival Decision**: Move completed projects to appropriate archive location
- [ ] **Handoff Generation**: Create handoff documentation if transferring work

## 📂 Directory Usage Patterns

### active-projects/ Organization
```
active-projects/
├── security-emergency-patch/          # Current critical security work
│   ├── implementation-plan.md         # Main project plan
│   ├── security-analysis.md           # DPM findings and remediation
│   └── progress-tracking.md           # Real-time progress updates
├── phase-2-deployment/                # Ongoing deployment preparation
│   ├── implementation-plan.md
│   └── deployment-checklist.md
└── mobile-responsive-ui/              # Future enhancement planning
    └── feature-spec.md
```

### knowledge-base/ Contribution Requirements
```
knowledge-base/
├── security-patterns.md              # Add patterns from security work
├── deployment-patterns.md            # Add deployment lessons learned  
├── troubleshooting-guides.md         # Add problem-solution pairs
├── performance-optimization.md       # Add performance insights
└── php-best-practices.md             # Add coding patterns and standards
```

## 🎯 Quality Standards

### Documentation Quality Checklist
- [ ] **Clarity**: Technical decisions are clearly explained with reasoning
- [ ] **Completeness**: All aspects of implementation are documented
- [ ] **Accuracy**: Documentation matches actual implementation
- [ ] **Usefulness**: Future agents/developers can understand and build upon the work
- [ ] **Consistency**: Follows established templates and formatting standards

### Common Documentation Anti-Patterns (AVOID THESE)
❌ **Vague Progress Updates**: "Working on security fixes"
✅ **Specific Progress Updates**: "Implemented prepared statements for user registration (15/112 SQL injection vulnerabilities fixed)"

❌ **Missing Decision Context**: "Used bcrypt for passwords"  
✅ **Complete Decision Context**: "Chose PHP password_hash() over bcrypt directly for future algorithm flexibility, considering performance impact acceptable for security gain"

❌ **Implementation Without Documentation**: Code changes without updating docs
✅ **Documented Implementation**: Every code change reflected in documentation with reasoning

## 🚨 Emergency Documentation Protocol

### Critical/Security Issues
1. **IMMEDIATE**: Create `security-analysis.md` using template
2. **CONCURRENT**: Update `implementation-plan.md` with emergency timeline
3. **REAL-TIME**: Document each security fix with verification steps
4. **POST-FIX**: Update knowledge base with security patterns learned

### Blockers/Issues
1. **IMMEDIATE**: Document blocker in progress tracking with status
2. **INVESTIGATE**: Document investigation approach and findings
3. **RESOLVE**: Document resolution approach and implementation
4. **PREVENT**: Add prevention pattern to knowledge base

---
**Guide Version**: 1.0  
**Compatible with**: RAD Protocol, DPM Integration  
**Last Updated**: 2025-08-04 