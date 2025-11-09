---
id: task-120.1
title: Create playback progress database schema
status: Done
assignee:
  - assistant
created_date: '2025-11-08 20:23'
updated_date: '2025-11-08 22:14'
labels: []
dependencies: []
parent_task_id: task-120
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create database schema to track user watch progress for movies and TV episodes. The schema should store the current playback position, completion status, and metadata needed to resume playback.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Playback progress table tracks user_id, media_file_id, and current position in seconds
- [x] #2 Table stores total duration, completion percentage, and watched status
- [x] #3 Table includes last_watched_at timestamp for sorting recently watched content
- [x] #4 Unique constraint ensures one progress record per user per media file
- [x] #5 Migration includes proper indexes on user_id and media_file_id for query performance
- [x] #6 Schema supports both movies and TV episodes through media_file relationship
- [x] #7 Ecto schema and changeset validation functions are implemented
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### Database Migration
Create migration: `priv/repo/migrations/TIMESTAMP_create_playback_progress.exs`

**Table: playback_progress**
- id (binary_id, primary key)
- user_id (binary_id, foreign key to users, NOT NULL)
- media_file_id (binary_id, foreign key to media_files, NOT NULL)
- position_seconds (integer, NOT NULL) - Current playback position
- duration_seconds (integer, NOT NULL) - Total video duration
- completion_percentage (float, NOT NULL) - Calculated: position/duration * 100
- watched (boolean, default false) - Auto-set true when >= 90%
- last_watched_at (utc_datetime, NOT NULL) - For "Continue Watching" sorting
- inserted_at, updated_at (utc_datetime)

**Constraints & Indexes:**
- UNIQUE constraint on (user_id, media_file_id)
- Index on user_id for querying user's progress
- Index on media_file_id for querying file's watchers
- Index on last_watched_at for "Recently Watched" queries
- Foreign key cascades on delete

### Ecto Schema
Create: `lib/mydia/playback/progress.ex`
- Define schema with belongs_to associations
- Changeset with validation: position >= 0, duration > 0, percentage 0-100
- Auto-calculate completion_percentage from position/duration
- Auto-set watched to true when percentage >= 90

### Context Module
Create: `lib/mydia/playback.ex`
- `get_progress(user_id, media_file_id)` - Returns progress or nil
- `save_progress(user_id, media_file_id, attrs)` - Upsert progress record
- `list_user_progress(user_id, opts)` - Get all progress for user (with filters)
- `mark_watched(user_id, media_file_id)` - Set watched = true
- `delete_progress(user_id, media_file_id)` - Remove progress (for "Mark as Unwatched")

### Testing
- Test progress creation and updates
- Test unique constraint enforcement
- Test automatic percentage calculation
- Test automatic watched flag at 90%
- Test queries and associations
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
**IMPORTANT DESIGN DECISION**: Changed schema to track progress at content level (media_item_id OR episode_id) instead of file level (media_file_id). This ensures that switching between different quality versions of the same movie/episode maintains the same playback position.
<!-- SECTION:NOTES:END -->
