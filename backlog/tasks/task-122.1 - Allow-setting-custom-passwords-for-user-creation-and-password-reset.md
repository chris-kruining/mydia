---
id: task-122.1
title: Allow setting custom passwords for user creation and password reset
status: Done
assignee: []
created_date: '2025-11-09 02:20'
updated_date: '2025-11-09 02:46'
labels:
  - ui
  - admin
  - authentication
  - user-management
  - enhancement
dependencies: []
parent_task_id: task-122
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Currently, when creating local auth users or resetting passwords, the system auto-generates a random password. This should be enhanced to allow administrators (and eventually users themselves) to set their own passwords.

**Current Behavior:**
- Create Local User: Auto-generates a random password, displays it once
- Reset Password: Auto-generates a random password, displays it once

**Desired Behavior:**
- Provide an option to either auto-generate OR manually set a password
- For user creation: Add a password input field with confirmation
- For password reset: Add a password input field with confirmation
- Maintain password validation (minimum length, complexity if desired)
- Still show the auto-generate option as a convenience feature

**Future Enhancement:**
- Allow users to change their own passwords from a profile/settings page
- Require current password verification when users change their own password
- Consider password strength indicators
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Create User modal has option to either auto-generate or manually set password
- [x] #2 Manual password input includes confirmation field to prevent typos
- [x] #3 Password validation enforces minimum security requirements (e.g., min 8 characters)
- [x] #4 Reset Password modal has option to either auto-generate or manually set password
- [x] #5 Both modals clearly indicate which mode is selected (auto-gen vs manual)
- [x] #6 Manual password input shows/hides password with toggle button
- [x] #7 Generated passwords still displayed in a copyable format when auto-generate is used
- [x] #8 Form validation prevents submission if password and confirmation don't match
<!-- AC:END -->
