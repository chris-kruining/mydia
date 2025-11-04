---
id: task-12
title: Set up testing infrastructure and write initial tests
status: To Do
assignee: []
created_date: '2025-11-04 01:52'
labels:
  - testing
  - quality
dependencies:
  - task-4
  - task-7
  - task-11
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configure test environment with SQLite in-memory database. Write tests for contexts, controllers, and LiveViews. Set up test helpers and factories.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Test database configured (SQLite in-memory)
- [ ] #2 ExMachina or similar factory library set up
- [ ] #3 Test helpers for common operations
- [ ] #4 Context tests for Media, Accounts, Downloads
- [ ] #5 Controller tests for API endpoints
- [ ] #6 LiveView tests for main pages
- [ ] #7 Test coverage > 70%
- [ ] #8 All tests passing with `mix test`
<!-- AC:END -->
