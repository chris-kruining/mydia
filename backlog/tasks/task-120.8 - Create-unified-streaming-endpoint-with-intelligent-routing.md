---
id: task-120.8
title: Create unified streaming endpoint with intelligent routing
status: Done
assignee: []
created_date: '2025-11-08 21:39'
updated_date: '2025-11-08 22:34'
labels: []
dependencies: []
parent_task_id: task-120
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Build the orchestration layer that ties together direct play and HLS streaming into a single, intelligent API endpoint. This endpoint analyzes each request and routes to the optimal streaming method based on codec compatibility and transcoding status.

This is the user-facing entry point for all video streaming - the "brain" of the hybrid architecture that makes the right decision for each playback request.

**Technical approach:**
- Create GET /api/v1/stream/:media_file_id endpoint
- Use codec compatibility checker (task-120.6) to determine streaming mode
- Route to direct play endpoint (task-120.2) for compatible files
- Redirect to HLS playlist for transcoded files (task-120.7)
- Trigger Oban transcoding job if file needs HLS but isn't transcoded yet
- Return appropriate response codes and headers for each scenario

**Decision flow:**
```elixir
case determine_streaming_mode(media_file) do
  {:direct_play, _} ->
    # Serve with range requests (206)
    serve_direct_play(conn, media_file)
    
  {:hls_available, hls_path} ->
    # Redirect to HLS master playlist
    redirect(conn, to: "/api/v1/hls/#{media_file.id}/master.m3u8")
    
  {:needs_transcoding, _} ->
    # Trigger job, return 202 Accepted
    queue_transcoding_job(media_file)
    json(conn, %{status: "transcoding", message: "Video is being prepared"})
end
```

**Additional endpoints:**
- GET /api/v1/hls/:id/master.m3u8 - Serve HLS master playlist
- GET /api/v1/hls/:id/:quality/playlist.m3u8 - Serve variant playlist  
- GET /api/v1/hls/:id/:quality/:segment - Serve HLS segments
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 GET /api/v1/stream/:media_file_id endpoint exists and requires authentication
- [ ] #2 Endpoint calls codec compatibility checker to determine streaming mode
- [ ] #3 Compatible files served via direct play with 206 responses
- [ ] #4 Transcoded files redirect to HLS master playlist
- [ ] #5 Non-transcoded incompatible files return 202 and queue Oban job
- [ ] #6 HLS playlist and segment endpoints serve files efficiently
- [ ] #7 Proper HTTP status codes and headers for each scenario
- [ ] #8 Error handling for missing files, unauthorized access, transcoding failures
- [ ] #9 Endpoint integrates with existing playback progress API
- [ ] #10 Frontend can call single endpoint and receive appropriate streaming method
- [ ] #11 Documentation explains routing logic and response codes
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
**Revised approach: On-demand transcoding integration**

Unified endpoint initiates transcoding sessions when needed instead of queueing background jobs:

**Decision logic flow:**
```elixir
case determine_streaming_mode(media_file) do
  {:direct_play, _} ->
    # Serve with HTTP range requests (206)
    serve_direct_play(conn, media_file)
    
  {:needs_transcoding, _} ->
    # Start or get existing HLS session for this user/file
    {:ok, session_id} = HLS.SessionManager.start_session(user.id, media_file.id)
    # Redirect to HLS master playlist (session will generate it)
    redirect(conn, to: "/api/v1/hls/#{session_id}/master.m3u8")
end
```

**Endpoints:**
- `GET /api/v1/stream/:media_file_id` - Unified entry point (checks compatibility, routes appropriately)
- `GET /api/v1/hls/:session_id/master.m3u8` - Master playlist (starts transcoding if needed)
- `GET /api/v1/hls/:session_id/:quality/playlist.m3u8` - Variant playlist
- `GET /api/v1/hls/:session_id/:quality/:segment` - HLS segments

**Session management:**
- Session ID identifies active transcoding session
- Multiple requests from same user/file reuse existing session
- Sessions auto-cleanup after inactivity timeout
- Handle session errors gracefully (restart, error messages)

**No background jobs needed** - everything happens in request/response cycle with streaming
<!-- SECTION:PLAN:END -->
