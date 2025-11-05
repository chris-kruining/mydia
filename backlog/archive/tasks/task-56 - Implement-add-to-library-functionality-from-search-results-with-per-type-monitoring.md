---
id: task-56
title: >-
  Implement add to library functionality from search results with per-type
  monitoring
status: To Do
assignee: []
created_date: '2025-11-05 02:27'
labels:
  - library
  - liveview
  - ui
  - search
  - monitoring
  - media
dependencies:
  - task-22.8
  - task-22.10
  - task-32
  - task-23.6
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create UI actions and backend logic to add media items (movies, TV shows, seasons, episodes) to the library directly from search results. This enables the core workflow: discover media → add to library with monitoring → automatic acquisition.

This bridges the gap between search/discovery (task-22.8) and automatic monitoring (task-22.10). Users should be able to add different media types with appropriate monitoring options, which then triggers automatic background searches to acquire the content.

## Implementation Details

**UI Components:**

1. **Add Movie to Library**
   - Button on movie search results
   - Modal/form with options:
     - Quality profile selection
     - Root folder/path selection
     - Monitoring toggle (default: on)
     - Search immediately checkbox
   - Creates Movie record with monitored status
   - Optionally triggers immediate search

2. **Add TV Show to Library**
   - Button on TV show search results
   - Modal/form with options:
     - Season monitoring strategy (all, future, latest, specific)
     - Quality profile selection
     - Root folder/path selection
     - Search for missing episodes checkbox
   - Creates Series record with episode records
   - Fetches episode list from TMDB/TVDB

3. **Add Specific Season**
   - Available when browsing TV show details in search
   - Adds only selected season to existing or new series
   - Creates episode records for that season only

4. **Add Specific Episode**
   - Available when browsing season/episode details
   - Adds single episode to existing or new series
   - Useful for specials or specific episodes

**Backend Logic:**

- Title parsing to extract movie/show name, year, season/episode numbers
- TMDB/TVDB metadata lookup for enrichment
- Create MediaItem records with appropriate type
- Set monitoring flags based on user selection
- Associate with quality profile and root path
- Optionally trigger immediate search job

**Integration Points:**

- Uses metadata services (TMDB/TVDB) for enrichment (task-23.6)
- Integrates with quality profile system (task-32)
- Triggers automatic search jobs from task-22.10
- Works with existing monitoring controls from task-33
- Called from search results UI (task-22.8)

**Error Handling:**

- Media already exists in library
- Metadata lookup failures
- Invalid title parsing
- Missing configuration (no quality profiles, no root paths)

**Validation:**

- Prevent duplicate additions
- Validate quality profile exists
- Validate root path is writable
- Check storage space if configured
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Add movie to library button in search results with configuration modal
- [ ] #2 Add TV show to library button with season monitoring strategy options
- [ ] #3 Add specific season action when browsing TV show details
- [ ] #4 Add specific episode action when browsing episode details
- [ ] #5 Title parsing extracts movie/show name, year, season/episode numbers
- [ ] #6 TMDB/TVDB metadata lookup enriches media items on addition
- [ ] #7 Creates MediaItem records with correct type and monitoring flags
- [ ] #8 Associates media with selected quality profile and root path
- [ ] #9 Optional immediate search trigger after adding to library
- [ ] #10 Duplicate detection prevents adding same media twice
- [ ] #11 Error handling for metadata lookup failures and configuration issues
- [ ] #12 Success message shows media added with link to library item
- [ ] #13 Added media appears in library immediately
- [ ] #14 Monitored media is picked up by automatic search jobs (task-22.10)
<!-- AC:END -->
