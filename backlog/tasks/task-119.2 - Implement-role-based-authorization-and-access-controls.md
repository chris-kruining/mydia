---
id: task-119.2
title: Implement role-based authorization and access controls
status: Done
assignee: []
created_date: '2025-11-08 20:23'
updated_date: '2025-11-08 21:42'
labels:
  - authentication
  - authorization
  - security
dependencies:
  - task-119.1
parent_task_id: task-119
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Build the authorization layer to enforce role-based permissions throughout the application, ensuring guests can only perform read operations and submit requests while admins retain full control.

This implements the security boundary between guest and admin functionality.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Authorization helpers check user role before sensitive operations
- [x] #2 Guest users can read media but cannot create/update/delete
- [x] #3 Admin users retain full CRUD permissions on media
- [x] #4 LiveView routes properly scope access based on role
- [x] #5 Unauthorized actions return appropriate error messages
- [x] #6 Authorization logic is tested for both roles
- [x] #7 Default new users are created as guests
<!-- AC:END -->
