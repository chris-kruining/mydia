---
id: task-119.4
title: Build admin request management interface
status: Done
assignee: []
created_date: '2025-11-08 20:23'
updated_date: '2025-11-08 22:19'
labels:
  - ui
  - liveview
  - admin
dependencies:
  - task-119.2
  - task-119.5
parent_task_id: task-119
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create the admin interface for viewing, filtering, and acting on pending media requests with approve/reject actions.

This provides admins with the tools to review and process guest requests efficiently.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Admin dashboard shows pending requests count
- [x] #2 Dedicated requests page lists all requests with filters (pending, approved, rejected)
- [x] #3 Request cards display media details, requester info, and submission date
- [x] #4 Approve button triggers media creation workflow
- [x] #5 Reject button prompts for optional rejection reason
- [x] #6 Admin notes are saved with request status changes
- [x] #7 Real-time updates when requests are processed
- [x] #8 Request list supports pagination for large volumes
<!-- AC:END -->
