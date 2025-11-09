---
id: task-120.9.1
title: Style Play Next button to match movie Play button in sidebar
status: Done
assignee: []
created_date: '2025-11-09 04:41'
updated_date: '2025-11-09 04:42'
labels:
  - ui
  - enhancement
  - video-player
  - tv-shows
dependencies: []
parent_task_id: task-120.9
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The current Play Next button for TV shows is displayed as a prominent gradient card in the main content area. It should be moved to the left sidebar (Quick Actions section) and styled to match the movie Play button for consistency.

**Current Implementation:**
- Large gradient card with episode thumbnail, info, and button
- Displayed in main content area after title/genres
- `btn btn-primary btn-lg gap-2 w-full sm:w-auto flex-shrink-0`

**Desired Implementation:**
- Simple button in left sidebar Quick Actions section
- Match movie button style: `btn btn-primary btn-block`
- Same icon style: `hero-play-circle-solid` with `w-5 h-5`
- Text should reflect state: "Continue Watching", "Play Next Episode", or "Start Watching"
- Should be placed at the top of Quick Actions, similar to movie Play button
- Add divider after button like movie implementation

**Location:**
`lib/mydia_web/live/media_live/show.html.heex` - Move Play Next button from main content area (around line 187-226) to Quick Actions section (around line 39-50)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Play Next button is in left sidebar Quick Actions section
- [x] #2 Button styling matches movie Play button (btn btn-primary btn-block)
- [x] #3 Icon matches movie button style (hero-play-circle-solid w-5 h-5)
- [x] #4 Button text reflects watch state correctly
- [x] #5 Divider added after button like movie implementation
- [x] #6 Button is hidden when all episodes are watched or no episodes with files exist
<!-- AC:END -->
