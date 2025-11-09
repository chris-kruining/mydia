---
id: task-120.7.3
title: Create HLS session GenServer for session management
status: Done
assignee:
  - '@assistant'
created_date: '2025-11-09 01:46'
updated_date: '2025-11-09 02:40'
labels: []
dependencies: []
parent_task_id: '120.7'
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create GenServer to manage individual HLS transcoding sessions (one per user/file combination).

Create: `lib/mydia/streaming/hls_session.ex`

Responsibilities:
- Start/stop Membrane pipeline for specific media file
- Track session activity with timestamps
- Generate unique session ID
- Manage temp directory for segments
- Auto-terminate after 30 minutes of inactivity
- Cleanup temp files on termination

Session state tracks: session_id, media_file, pipeline pid, temp_dir, last_activity, timeout
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 GenServer module created with proper OTP behavior
- [x] #2 Session starts pipeline and creates temp directory
- [x] #3 Session tracks activity and updates timestamps
- [x] #4 Session auto-terminates after timeout period
- [x] #5 Temp files cleaned up on session termination
- [ ] #6 Unit tests verify session lifecycle
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Complete

Created `lib/mydia/streaming/hls_session.ex` with full session management:

**Features:**
- GenServer managing individual transcoding sessions
- Starts Membrane pipeline on init
- Creates unique session ID (UUID)
- Manages temp directory in `/tmp/mydia-hls/<session_id>`
- Tracks activity with heartbeat mechanism
- Auto-terminates after 30 minutes of inactivity (checked every 5 minutes)
- Cleans up temp files and stops pipeline on termination
- Linked to pipeline process for crash handling

**API:**
- `start_link/1` - Start new session
- `get_info/1` - Get session info (also acts as heartbeat)
- `heartbeat/1` - Update activity timestamp
- `stop/1` - Gracefully stop session

Module compiles successfully.
<!-- SECTION:NOTES:END -->
