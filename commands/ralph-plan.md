---
name: ralph-plan
description: Create a detailed plan.md for Ralph to execute
args:
  - name: feature
    description: The feature or task to plan
    required: true
  - name: stack
    description: Which stack (phoenix|react|full)
    default: "full"
---

# Create Ralph Execution Plan

## Feature Request

{{feature}}

## Instructions

Analyze the feature request and create a detailed `plan.md` file.

### 1. Understand the Scope
- What Phoenix changes are needed? (contexts, schemas, migrations, controllers)
- What React changes are needed? (components, hooks, API calls, types)
- What tests are needed?

### 2. Create plan.md

Use this template:

```markdown
# Plan: {{feature}}

## Overview
Brief description of what we're building.

## Stack: {{stack}}

## Tasks

### Phoenix Backend
- [ ] Create migration for X table
- [ ] Create X schema with changeset
- [ ] Create X context with CRUD functions
- [ ] Add API routes to router.ex
- [ ] Create XController with index/show/create/update/delete
- [ ] Write context tests
- [ ] Write controller tests

### React Frontend
- [ ] Create TypeScript types for X
- [ ] Create API client functions for X
- [ ] Create XList component
- [ ] Create XItem component
- [ ] Create XForm component (create/edit)
- [ ] Add routing for X pages
- [ ] Write component tests

### Integration
- [ ] Verify full flow works end-to-end
- [ ] Add error handling
- [ ] Add loading states

## Notes
- Any special considerations
- Dependencies between tasks
- Potential blockers

## Progress Log
<!-- Ralph will update this section -->
```

### 3. Guidelines for Tasks

- Each task should be completable in ONE iteration
- Tasks should be ordered by dependency (migrations before schemas, schemas before contexts)
- Include verification criteria in task if complex
- Group related tasks but keep them atomic

### 4. Output

Save the plan to `plan.md` in the project root.

Then output: `PLAN_CREATED`
