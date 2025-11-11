---
id: task-162
title: Allow removing movies/TV shows from library without deleting files
status: Done
assignee:
  - Claude
created_date: '2025-11-11 15:26'
updated_date: '2025-11-11 15:36'
labels:
  - enhancement
  - ui
  - movies
  - tv-shows
  - user-experience
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add an option in the Delete dialog to give users a choice between removing items from the library database only, or deleting the files from disk as well. This provides flexibility to clean up the library without losing the actual media files.

Currently, deleting a movie or TV show removes both the database entry and the files from disk. Users may want to remove items from their library while preserving the files for other purposes (archival, re-import later, etc.).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Delete dialog displays a clear option (checkbox/radio buttons) to choose between 'Remove from library only' and 'Delete files from disk'
- [x] #2 When 'Remove from library only' is selected, the item is removed from the database but files remain untouched on disk
- [x] #3 When 'Delete files from disk' is selected, the item is removed from database AND files are permanently deleted
- [x] #4 Default behavior is clearly indicated in the UI (suggest keeping current delete behavior as default for safety)
- [x] #5 Feature works consistently for both movies and TV shows
- [x] #6 Confirmation message clearly states what will happen based on the user's selection
- [x] #7 For TV shows, consider whether to apply the choice to the entire series or allow per-season/episode granularity
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### Current State Analysis
- Two delete locations found:
  1. **MediaLive.Show** (lib/mydia_web/live/media_live/show.ex:334) - Single item deletion via `delete_media` event
  2. **MediaLive.Index** (lib/mydia_web/live/media_live/index.ex:254) - Batch deletion via `batch_delete_confirmed` event

- Backend functions:
  - `Media.delete_media_item/2` - Deletes single media item (line 115)
  - `Media.delete_media_items/1` - Deletes multiple media items (line 201)
  
- Current behavior: Both functions use `Repo.delete` which triggers database cascades, deleting associated media_files records. The actual file deletion on disk happens via database triggers or associations.

### Implementation Approach

1. **Backend Changes** (lib/mydia/media.ex):
   - Add new parameter `:delete_files` (boolean) to both delete functions
   - Default to `true` to maintain current behavior for safety
   - When `delete_files: false`, only delete database records without triggering file deletion
   - Need to investigate how files are currently deleted (check schema associations and on_delete behavior)

2. **Frontend Changes**:
   - **Show.html.heex**: Add radio buttons or checkbox in delete modal to select deletion mode
   - **Index.html.heex**: Add radio buttons or checkbox in batch delete modal to select deletion mode
   - Update event handlers to pass `delete_files` option

3. **UI Design**:
   - Use radio buttons (two mutually exclusive options)
   - Default: "Delete files from disk" (safer - keeps current destructive behavior as default)
   - Option 2: "Remove from library only (keep files)"
   - Clear warning messages for each option

4. **Acceptance Criteria Mapping**:
   - AC#1: Radio buttons in both dialogs ✓
   - AC#2-3: Backend logic to handle both modes ✓
   - AC#4: Default to "delete files" option ✓
   - AC#5: Works for movies and TV shows (single implementation) ✓
   - AC#6: Clear confirmation messages ✓
   - AC#7: For TV shows, the deletion applies to the entire series (existing behavior)
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Important Discovery

After analyzing the codebase, I discovered that:

1. **Current behavior**: When a media_item is deleted, the database CASCADE deletes associated media_files records, but the physical files on disk are **NOT** deleted. The system already preserves files!

2. **Evidence**:
   - `Library.delete_media_file/1` (line 91-92) only calls `Repo.delete`, no file system operations
   - No `File.rm` or `File.rm_rf` calls exist for media file deletion
   - The show.html.heex message (line 663) is misleading - it says 'including files' but actually means 'file records'

3. **Revised Implementation**:
   Since the current behavior is already 'library only', we need to:
   - **Add** the ability to delete physical files (opposite of original assumption!)
   - Update UI to clarify what 'delete' currently means
   - Add option to also delete physical files from disk
   - Update confirmation messages to be accurate

4. **New Implementation Plan**:
   - Add `Library.delete_media_files_from_disk/1` function to delete physical files
   - Modify `Media.delete_media_item/2` to accept `:delete_files` option
   - When `:delete_files` is `true`, load all media_files first, delete physical files, then delete DB records
   - When `:delete_files` is `false` (or default), use current behavior
   - Update UI to reflect this
<!-- SECTION:NOTES:END -->
