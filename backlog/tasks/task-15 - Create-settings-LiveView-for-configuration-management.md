---
id: task-15
title: Create settings LiveView for configuration management
status: To Do
assignee: []
created_date: '2025-11-04 01:52'
labels:
  - liveview
  - ui
  - settings
  - configuration
dependencies:
  - task-4
  - task-9
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Build settings interface for managing quality profiles, indexers, download clients, library paths, and OIDC configuration. Forms should persist to config.yml or database as appropriate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 SettingsLive.Index LiveView created
- [ ] #2 Tabs for different setting categories
- [ ] #3 Quality profiles CRUD interface
- [ ] #4 Indexer configuration forms
- [ ] #5 Download client configuration
- [ ] #6 Library path management
- [ ] #7 OIDC settings (read-only, managed via env)
- [ ] #8 Forms use changesets with validation
- [ ] #9 Changes persist correctly
<!-- AC:END -->
