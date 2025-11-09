---
id: task-119
title: Implement guest request system for media approval workflow
status: Done
assignee: []
created_date: '2025-11-08 20:22'
updated_date: '2025-11-08 22:19'
labels:
  - feature
  - authentication
  - media-management
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Enable a guest user system where guests can browse TV shows and movies but cannot directly manipulate them. Instead, guests submit requests for media additions that require admin approval before being added to the system.

This provides a controlled way for non-admin users to suggest content while maintaining admin oversight of what gets added to the media library.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Guest users can browse existing TV shows and movies without ability to modify them
- [x] #2 Guest users can submit requests for new media items
- [x] #3 Requests include media details (title, type, TVDB/TMDB ID, etc.)
- [x] #4 Admin users can view pending requests in a dedicated interface
- [x] #5 Admin users can approve or reject requests with optional notes
- [x] #6 Approved requests automatically create the corresponding media items
- [x] #7 Rejected requests are marked with rejection reason visible to the requester
- [x] #8 Guest users can view the status of their submitted requests
- [x] #9 System prevents duplicate requests for the same media item
- [x] #10 Request history is preserved for audit purposes
<!-- AC:END -->
