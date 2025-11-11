---
id: task-166
title: Improve import process transparency with detailed results and retry capability
status: In Progress
assignee:
  - Claude
created_date: '2025-11-11 16:33'
updated_date: '2025-11-11 16:35'
labels:
  - enhancement
  - import
  - ux
  - transparency
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The import process currently provides minimal feedback to users. When imports complete, users only see a simple summary ("Successfully Imported: 0, Failed: 2") without any details about what succeeded, what failed, why failures occurred, or how to fix them.

**Current behavior:**
```
Import Complete!
Successfully Imported
0
Failed
2
```

No additional information is provided:
- Which specific files or items failed
- Why each failure occurred (metadata not found, file already exists, permission issues, etc.)
- Which items succeeded (if any)
- No option to retry failed imports
- No way to see detailed logs or error messages
- No actionable guidance on how to resolve failures

**Problems:**
1. **No visibility**: Users can't see which files failed
2. **No diagnostics**: No error messages or reasons for failures
3. **No retry**: Can't retry failed imports without re-running entire process
4. **No guidance**: Users don't know how to fix issues
5. **Poor UX**: Generic success/failure counts aren't helpful

**Expected behavior:**
The import process should provide detailed, actionable feedback:

1. **Detailed results list showing:**
   - File path or media title for each item
   - Status (success, failed, skipped)
   - Reason for failure (e.g., "File already in library", "Metadata not found", "Permission denied")
   - Action taken (e.g., "Created movie 'Dune'", "Skipped - already exists")

2. **Categorized results:**
   - Successfully imported items (with what was created)
   - Failed items (with specific error messages)
   - Skipped items (with reason for skipping)

3. **Retry capability:**
   - Option to retry all failed items
   - Option to retry individual failed items
   - Option to force re-import (ignore "already exists" checks)

4. **Actionable guidance:**
   - Suggestions for fixing common errors
   - Links to relevant settings or actions
   - Export failure details for debugging

5. **Progress tracking:**
   - Real-time progress during import
   - Show current item being processed
   - Allow cancellation mid-process

**Example improved UI:**
```
Import Complete - 2 items processed

✓ Successfully Imported (0 items)
  (none)

✗ Failed (2 items)
  📁 /media/movies/Dune.Part.One.2021.mkv
     Error: File already in library as orphaned record
     Action: [Remove Orphan] [Force Re-import]
  
  📁 /media/movies/Dune.Part.Two.2024.mkv
     Error: File already in library as orphaned record
     Action: [Remove Orphan] [Force Re-import]

[Retry All Failed] [Export Details] [Close]
```

**User impact:**
- Users waste time debugging import failures
- Cannot easily fix or retry failed imports
- Must resort to manual database cleanup
- Poor user experience discourages using the import feature
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Import results show detailed list of all processed items with file paths/titles
- [ ] #2 Each failed item displays specific error message explaining why it failed
- [ ] #3 Each failed item shows actionable buttons (Retry, Force Re-import, Remove, etc.)
- [ ] #4 Successfully imported items show what was created (movie title, metadata matched, etc.)
- [ ] #5 Skipped items explain why they were skipped
- [ ] #6 Users can retry individual failed items or all failed items at once
- [ ] #7 Import progress shows real-time status during processing
- [ ] #8 Users can export detailed results for debugging or support
<!-- AC:END -->
