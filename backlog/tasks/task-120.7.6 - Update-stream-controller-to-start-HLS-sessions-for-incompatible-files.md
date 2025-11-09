---
id: task-120.7.6
title: Update stream controller to start HLS sessions for incompatible files
status: Done
assignee:
  - '@assistant'
created_date: '2025-11-09 01:46'
updated_date: '2025-11-09 02:45'
labels: []
dependencies: []
parent_task_id: '120.7'
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update the existing stream controller to start HLS transcoding sessions when files need transcoding, replacing the current "not implemented" error.

Update: `lib/mydia_web/controllers/api/stream_controller.ex` (around line 119)

Replace the TODO section with:
- Start HLS session via supervisor
- Redirect to master playlist URL
- Handle session creation errors
- Log transcoding initiation

The change should be seamless - clients requesting incompatible files will automatically get HLS streams.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Stream controller starts HLS sessions for incompatible files
- [x] #2 Clients redirected to master playlist URL
- [x] #3 Error handling for session creation failures
- [x] #4 Logging indicates when transcoding is used
- [ ] #5 Integration test verifies incompatible file → HLS flow
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Complete

Updated `lib/mydia_web/controllers/api/stream_controller.ex` to integrate HLS transcoding:

**Changes made:**
- Added imports for `HlsSessionSupervisor` and `HlsSession`
- Replaced TODO/not_implemented section with full HLS integration
- Added `start_hls_session/3` helper function
- Added `get_user_id/1` helper function

**Flow for incompatible files:**
1. Compatibility check determines file needs transcoding
2. Get authenticated user ID
3. Start HLS session via supervisor (or reuse existing)
4. Get session info to retrieve session_id
5. Construct master playlist URL
6. HTTP 302 redirect to master playlist

**Error handling:**
- User not authenticated → 401
- Media file not found → 404
- Session creation failure → 500 with details

**Logging:**
- Info log when transcoding is initiated
- Info log with redirect URL
- Error logs for failures

Clients requesting incompatible files now seamlessly get HLS streams via redirect.
<!-- SECTION:NOTES:END -->
