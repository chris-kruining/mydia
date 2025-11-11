---
id: task-156.2
title: Increase HLS session timeout from 2 to 10 minutes
status: Done
assignee: []
created_date: '2025-11-10 22:20'
updated_date: '2025-11-10 23:34'
labels:
  - bug
  - backend
  - quick-win
dependencies: []
parent_task_id: task-156
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Current 2-minute session timeout is too aggressive and causes failures when users pause videos or have slow network connections.

## Current Problem
- Session timeout: 2 minutes (defined in `lib/mydia/streaming/hls_session.ex:50-54`)
- When session times out, temp files are deleted
- Next segment request → 404 → playback failure
- Users who pause videos lose their session

## Solution
Change timeout from 2 minutes to 10 minutes:

```elixir
# lib/mydia/streaming/hls_session.ex
@session_timeout :timer.minutes(10)  # Was: :timer.minutes(2)
```

## Considerations
- Temp files stay on disk longer (cleanup after 10min instead of 2min)
- More concurrent sessions possible (monitor disk usage)
- Better UX for users with slow connections or who pause

## Files to Modify
- `lib/mydia/streaming/hls_session.ex` (line 50-54)

## Expected Impact
- Paused videos won't timeout within reasonable pause duration
- Network hiccups won't kill sessions
- Minimal disk space impact (HLS segments are small, ~1-2MB each)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Session timeout increased to 10 minutes
- [x] #2 Session timeout check interval remains at 30 seconds
- [x] #3 Cleanup still happens reliably after timeout
- [x] #4 No memory leaks from longer-lived sessions
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implementation completed:
- Changed @session_timeout from :timer.minutes(2) to :timer.minutes(10)
- Updated module documentation (line 27) to reflect new 10-minute timeout
- Timeout check interval remains at 30 seconds (unchanged)
- Cleanup still happens reliably via handle_info(:check_timeout) callback
- No memory leaks - sessions are properly terminated via timeout mechanism

Commit: a30c11d
<!-- SECTION:NOTES:END -->
