---
id: task-22.10.1
title: Add UI trigger for automatic search and download of best matching release
status: To Do
assignee: []
created_date: '2025-11-05 02:31'
updated_date: '2025-11-05 02:39'
labels:
  - ui
  - liveview
  - automation
  - downloads
  - search
dependencies:
  - task-22.10
  - task-33
  - task-32
parent_task_id: task-22.10
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a button in the media detail page UI that triggers the same automatic search and download logic used by background jobs, allowing users to manually initiate automatic acquisition for any media item (monitored or not).

This provides an on-demand version of the background automation - users can click "Auto Search & Download" and the system will search indexers, evaluate results against quality profile settings, and automatically download the best matching release without requiring the user to manually select from search results.

## Implementation Details

**UI Location:**
Media detail page actions section, alongside existing manual search button

**Button Behavior:**
- "Auto Search & Download" or "Search & Auto-Grab" button
- Available for movies, TV shows (entire series), seasons, and individual episodes
- Shows loading state during search and evaluation
- Disabled if no quality profile assigned or no download clients configured

**Backend Logic:**
- Reuses the same search and evaluation logic from MovieSearchJob/TVShowSearchJob
- For movies: searches indexers, evaluates against quality profile, downloads best match
- For TV shows: searches for all missing/wanted episodes
- For seasons: searches for season pack or individual episodes in that season
- For episodes: searches for specific episode

**User Feedback:**
- Shows toast notification during search ("Searching indexers...")
- Success: "Downloaded [release name] - [quality] - [size]" with link to downloads queue
- No results: "No releases found matching quality profile requirements"
- Error: Specific error message (no quality profile, download client offline, etc.)

**Integration:**
- Uses same quality matching logic as task-22.10 background jobs
- Respects quality profile cutoff and preferred settings
- Integrates with download client management (task-21.1)
- Creates Download records for tracking (task-21.4)

**Difference from Manual Search (task-22.9):**
- Manual search shows results grid, user picks release
- Auto search automatically picks best match based on quality profile and downloads it
- Both buttons available - manual for control, auto for convenience
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Auto Search & Download button added to media detail page actions
- [ ] #2 Button triggers automatic search using same logic as background jobs
- [ ] #3 Evaluates results against quality profile and downloads best match
- [ ] #4 Works for movies, TV shows, seasons, and individual episodes
- [ ] #5 Shows loading state during search and evaluation process
- [ ] #6 Success notification shows downloaded release details and link to queue
- [ ] #7 No results notification when no matching releases found
- [ ] #8 Error handling for missing quality profile or offline download clients
- [ ] #9 Button disabled when prerequisites not met (no quality profile, no clients)
- [ ] #10 Downloaded release appears in downloads queue immediately
- [ ] #11 Respects quality profile cutoff and preferred settings
- [ ] #12 Available for both monitored and unmonitored media items
<!-- AC:END -->
