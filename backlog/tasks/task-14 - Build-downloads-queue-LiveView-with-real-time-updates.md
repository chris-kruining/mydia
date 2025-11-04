---
id: task-14
title: Build downloads queue LiveView with real-time updates
status: To Do
assignee: []
created_date: '2025-11-04 01:52'
labels:
  - liveview
  - ui
  - downloads
  - real-time
dependencies:
  - task-4
  - task-7
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create downloads queue page showing active, completed, and failed downloads. Use LiveView PubSub for real-time progress updates.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 DownloadsLive.Index LiveView created
- [ ] #2 Show downloads grouped by status
- [ ] #3 Real-time progress bars for active downloads
- [ ] #4 Display download stats (speed, ETA, seeds)
- [ ] #5 Actions: pause, resume, cancel downloads
- [ ] #6 PubSub broadcasts for progress updates
- [ ] #7 LiveView streams for download list
- [ ] #8 Empty state when no downloads
<!-- AC:END -->
