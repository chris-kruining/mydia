---
id: task-8
title: Set up Oban for background job processing
status: To Do
assignee: []
created_date: '2025-11-04 01:52'
labels:
  - background-jobs
  - oban
  - automation
dependencies:
  - task-4
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configure Oban with SQLite-compatible engine for background jobs. Create job modules for library scanning, automated search, download monitoring, and scheduled tasks.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Oban dependency added and configured
- [ ] #2 Oban.Engines.Basic set up for SQLite
- [ ] #3 Queue configuration (critical, default, media, search, notifications)
- [ ] #4 LibraryScanner job created
- [ ] #5 DownloadMonitor job created
- [ ] #6 Cron plugins configured for scheduled jobs
- [ ] #7 Oban migrations run successfully
- [ ] #8 Jobs can be enqueued and processed
<!-- AC:END -->
