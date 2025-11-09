---
id: task-125.1
title: Fix Alpine.js elements showing as visible before initialization
status: Done
assignee: []
created_date: '2025-11-09 03:30'
updated_date: '2025-11-09 03:34'
labels:
  - bug
  - frontend
  - alpine.js
  - ui
dependencies: []
parent_task_id: task-125
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
All Alpine.js controlled elements (skip intro, skip credits, next episode, error message, settings menu) are visible on page load instead of being hidden by x-show directives and x-cloak.

**Issue:**
- Elements with `x-show="false"` are still visible
- `x-cloak` CSS rule not preventing flash of content
- Alpine.$data(element) may be returning undefined or timing issue persists

**Root Cause Investigation Needed:**
1. Verify Alpine.js is starting before LiveView morphdom updates
2. Check if x-cloak CSS is being applied correctly
3. Verify Alpine.$data() is accessible and working
4. Check browser console for Alpine initialization logs
5. Test if Alpine directives are being processed at all

**Possible Solutions:**
1. Move Alpine.start() earlier in app.js (before LiveSocket connects)
2. Use Alpine.plugin() to ensure proper initialization order with LiveView
3. Add `style="display: none"` as inline backup for critical hidden elements
4. Use `x-init` to log when Alpine processes each element
5. Check if Alpine needs to be configured differently for Phoenix LiveView compatibility

**Success Criteria:**
- Skip intro button only visible during intro timestamps
- Skip credits button only visible during credits
- Next episode card only visible at >90% completion
- Error message only visible when error state is set
- Settings/speed/quality menus only visible when opened
- No flash of hidden content on page load
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Alpine.$data() successfully returns component data in Phoenix hook
- [x] #2 x-cloak prevents elements from showing before Alpine initializes
- [x] #3 x-show directives properly hide/show elements based on reactive state
- [x] #4 No visible elements flash on page load
- [x] #5 Browser console shows Alpine initializing correctly
- [x] #6 All conditional UI elements start hidden and only appear when state changes
<!-- AC:END -->
