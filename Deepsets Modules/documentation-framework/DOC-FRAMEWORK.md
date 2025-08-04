# 📚 Deepsets Documentation Framework

## Overview
The Documentation Framework provides structured templates and guidelines for maintaining organized, agent-friendly project documentation that supports rapid agentic development (RAD) workflows.

## 🎯 Core Principles
- **Agent-First**: Documentation that AI agents can easily reference and update
- **RAD Compatible**: Supports "Deploy Fast, Deploy Right" methodology  
- **Template-Driven**: Consistent structure across all documentation types
- **Version Controlled**: Git-friendly markdown documentation
- **Living Documents**: Automatically updated during development cycles

## 📁 Framework Structure

```
Deepsets Modules/
├── documentation-framework/
│   ├── DOC-FRAMEWORK.md           # This file - framework overview
│   ├── templates/                 # Reusable documentation templates
│   │   ├── implementation-plan.md # Project implementation planning
│   │   ├── module-spec.md         # Module/component specifications  
│   │   ├── roadmap.md            # Feature and technical roadmaps
│   │   ├── security-analysis.md   # Security assessment templates
│   │   ├── feature-spec.md        # Feature requirement specifications
│   │   └── handoff-report.md      # Project handoff documentation
│   ├── guidelines/               # Agent and developer guidelines
│   │   ├── agent-documentation-guide.md  # AI agent documentation rules
│   │   ├── project-organization.md       # Project structure standards
│   │   └── version-control.md            # Documentation versioning
│   └── examples/                 # Example implementations
│       ├── sample-implementation-plan.md
│       └── sample-module-spec.md
├── active-projects/              # Current development projects
│   ├── [project-name]/
│   │   ├── implementation-plan.md
│   │   ├── progress-tracking.md
│   │   └── [project-specific-docs]
├── completed-projects/           # Archived completed projects  
│   └── [archived-projects]/
├── roadmaps/                    # Strategic planning documents
│   ├── security-roadmap.md
│   ├── feature-roadmap.md
│   └── technical-debt-roadmap.md
└── knowledge-base/              # Persistent knowledge and patterns
    ├── security-patterns.md
    ├── deployment-patterns.md
    └── troubleshooting-guides.md
```

## 🤖 Agent Integration Rules

### **MANDATORY Agent Behaviors**
1. **Reference Before Starting**: Always check `active-projects/` for existing documentation
2. **Update During Work**: Update progress and findings in real-time  
3. **Document Decisions**: Record technical decisions and rationale
4. **Create When Missing**: Generate missing documentation using templates
5. **Archive When Complete**: Move completed projects to `completed-projects/`

### **Documentation Triggers**
- **New Feature**: Create implementation plan and feature spec
- **Security Issue**: Create security analysis and remediation plan
- **Major Bug**: Document in troubleshooting guides
- **Architecture Change**: Update module specs and roadmaps
- **Project Handoff**: Generate comprehensive handoff report

## 📋 Template Usage Guide

### Implementation Plan (`implementation-plan.md`)
**When to Use**: Starting any new feature, fix, or enhancement
**Agent Responsibility**: Create before coding, update during implementation

### Module Specification (`module-spec.md`)  
**When to Use**: Creating new modules or major refactoring
**Agent Responsibility**: Document architecture, APIs, dependencies

### Security Analysis (`security-analysis.md`)
**When to Use**: Security vulnerabilities, audits, or hardening
**Agent Responsibility**: Document findings, remediation, verification

### Roadmap (`roadmap.md`)
**When to Use**: Strategic planning, feature prioritization
**Agent Responsibility**: Update based on discoveries and user feedback

## 🔄 RAD Integration

### Pre-Task Documentation Check
```bash
# Agent must check existing documentation
1. Check active-projects/ for related work
2. Review roadmaps/ for strategic context  
3. Reference knowledge-base/ for patterns
4. Identify documentation gaps
```

### Implementation Documentation
```bash
# During implementation
1. Update progress-tracking.md in real-time
2. Document technical decisions inline
3. Record security findings immediately
4. Update feature specs with discoveries
```

### Triple-Check Documentation Verification
```bash
# Verification phase
1. Ensure all decisions are documented
2. Verify implementation matches specs
3. Update progress tracking to completion
4. Generate handoff report if needed
```

### Post-Task Documentation Update
```bash
# After completion
1. Archive to completed-projects/ if finished
2. Update roadmaps based on learnings
3. Add patterns to knowledge-base/
4. Notify about documentation updates
```

## 🎯 Success Metrics
- All projects have implementation plans
- Security issues have analysis documentation  
- Agents reference existing docs before starting
- Documentation is updated during work
- Knowledge base grows with each project

## 🚀 Quick Start for Agents

1. **Starting Work**: `cp templates/implementation-plan.md active-projects/[project-name]/`
2. **Security Issue**: `cp templates/security-analysis.md active-projects/[project-name]/`  
3. **Feature Development**: `cp templates/feature-spec.md active-projects/[project-name]/`
4. **Check Context**: Review `roadmaps/` and `knowledge-base/` first
5. **Update Progress**: Edit docs in real-time during implementation

---
*Framework Version: 1.0*  
*Compatible with: RAD Protocol, Problem Matcher (DPM)*  
*Created: 2025-08-04* 