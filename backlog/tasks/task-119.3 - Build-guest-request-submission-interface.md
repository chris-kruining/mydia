---
id: task-119.3
title: Build guest request submission interface
status: Done
assignee: []
created_date: '2025-11-08 20:23'
updated_date: '2025-11-08 22:19'
labels:
  - ui
  - liveview
  - forms
dependencies:
  - task-119.2
  - task-119.5
parent_task_id: task-119
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create the user interface for guests to browse media and submit new requests, including media search integration and request form.

This provides the guest-facing workflow for discovering and requesting content.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Guest users see 'Request' button instead of 'Add' in media search
- [x] #2 Request form captures media type, title, TVDB/TMDB ID, and optional notes
- [x] #3 Form validates required fields before submission
- [x] #4 Duplicate detection warns if media already exists or is requested
- [x] #5 Success message confirms request submission
- [x] #6 Guest users can view their own request history
- [x] #7 Request cards show status (pending, approved, rejected) with appropriate styling
<!-- AC:END -->
