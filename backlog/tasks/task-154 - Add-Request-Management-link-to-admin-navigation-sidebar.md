---
id: task-154
title: Add Request Management link to admin navigation sidebar
status: Done
assignee: []
created_date: '2025-11-10 21:58'
updated_date: '2025-11-10 22:06'
labels:
  - ui
  - navigation
  - admin
  - ux
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The request approval/management UI exists at `/admin/requests` but is not accessible from the sidebar navigation. Admin users currently need to either click a dashboard card (only visible when pending requests exist) or manually type the URL.

Add a permanent navigation link in the Administration section of the sidebar (lib/mydia_web/components/layouts.ex) to make the request management page easily discoverable.

**Current behavior:**
- Request management page exists with full approve/reject functionality
- No sidebar link - users don't know where to go to approve requests

**Desired behavior:**
- Admin sidebar includes "Requests" link with pending count badge
- Always visible to admin users regardless of pending request count
- Easy access to request management from any page
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Admin navigation sidebar includes 'Requests' link under Administration section
- [x] #2 Link navigates to /admin/requests route
- [x] #3 Badge displays count of pending requests (similar to downloads counter)
- [x] #4 Link is only visible to admin users
- [x] #5 Badge styling is consistent with other navigation badges
- [x] #6 Pending count updates when requests are approved/rejected
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Summary

Successfully added "Requests" navigation link to the admin sidebar with pending request count badge.

### Changes Made:

1. **Updated `lib/mydia_web/components/layouts.ex`:**
   - Added `pending_requests_count` attribute to the `app/1` function (line 43)
   - Updated documentation to include the new parameter
   - Added "Requests" navigation link in Administration section (lines 164-171) with conditional badge display

2. **Updated `lib/mydia_web/live/user_auth.ex`:**
   - Added `Authorization` and `MediaRequests` aliases
   - Modified `load_navigation_data` on_mount hook to load pending requests count for admin users
   - The count is loaded using `MediaRequests.count_pending_requests()` only for users who can manage requests

3. **Updated all 17 LiveView templates:**
   - Added `pending_requests_count={@pending_requests_count}` to all `<Layouts.app>` tags
   - Ensures the sidebar always has access to the current count

### How It Works:

- When a LiveView mounts, the `:load_navigation_data` on_mount hook runs
- For admin users, it queries the database for pending request count
- The count is passed to the layout component via the `@pending_requests_count` assign
- The layout component displays the "Requests" link with a badge showing the count (only if > 0)
- Badge styling matches other navigation badges (badge-primary badge-sm)
- Link is only visible to admin users (within the Administration section)

### Files Modified:
- lib/mydia_web/components/layouts.ex
- lib/mydia_web/live/user_auth.ex
- 17 LiveView template files (.html.heex)

The implementation is complete and follows the existing patterns in the codebase. The pending count updates on every LiveView mount, ensuring the badge stays current as users navigate the app.
<!-- SECTION:NOTES:END -->
