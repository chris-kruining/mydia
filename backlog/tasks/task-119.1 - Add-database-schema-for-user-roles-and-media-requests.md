---
id: task-119.1
title: Add database schema for user roles and media requests
status: Done
assignee: []
created_date: '2025-11-08 20:23'
updated_date: '2025-11-08 21:39'
labels:
  - database
  - schema
  - migration
dependencies: []
parent_task_id: task-119
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create the database foundation for the guest request system by adding user roles and a media requests table to track request lifecycle.

This establishes the data model needed to distinguish between admin and guest users, and track all media requests from submission through approval/rejection.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 User schema includes role field (admin, guest)
- [x] #2 MediaRequest schema includes requester, media details, status, admin notes
- [x] #3 Migration creates media_requests table with proper indexes
- [x] #4 Request status enum supports pending, approved, rejected states
- [x] #5 Foreign key relationships properly established
- [x] #6 Database constraints prevent invalid state transitions
- [x] #7 Timestamps track creation and status change times
<!-- AC:END -->
