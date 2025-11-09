---
id: task-122
title: Build admin user management interface
status: Done
assignee: []
created_date: '2025-11-08 22:34'
updated_date: '2025-11-08 22:40'
labels:
  - ui
  - admin
  - authentication
  - user-management
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a comprehensive admin interface for managing users, including viewing all users, creating local auth users, managing roles, and handling user lifecycle operations.

Currently, there's no visibility into the user base for admins. While OIDC users are automatically created on first login, local auth users can only be created programmatically. Admins need a UI to:
- See all users in the system (both OIDC and local auth)
- Understand which users are guests vs admins
- Create local authentication users with generated invite links/passwords
- Manage user roles and permissions
- View user activity and statistics
- Delete or deactivate users

This interface is critical for deployments using local authentication, and provides important visibility for OIDC deployments as well.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Admin dashboard or dedicated page shows list of all users with role, auth type (OIDC/local), and last login
- [x] #2 Admins can create new local auth users with username, email, and auto-generated password
- [x] #3 System generates shareable invite link or displays initial password for new users
- [x] #4 Admins can change user roles (promote guest to admin, demote admin to guest, etc.)
- [x] #5 User list shows key statistics: total requests submitted, requests approved/rejected
- [x] #6 Admins can delete users (with confirmation prompt)
- [x] #7 Interface clearly distinguishes between OIDC users (cannot change password) and local users (can reset password)
- [x] #8 Admins can reset passwords for local auth users
- [x] #9 User list supports filtering by role and searching by username/email
- [x] #10 For OIDC deployments, interface explains that users auto-register on first login
<!-- AC:END -->
