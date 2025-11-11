# HLS Architecture - Quick Reference Guide

## File Locations (Absolute Paths)

### Backend Components
- **HLS Session Manager**: `/home/arosenfeld/Code/mydia/lib/mydia/streaming/hls_session.ex`
- **Session Supervisor**: `/home/arosenfeld/Code/mydia/lib/mydia/streaming/hls_session_supervisor.ex`
- **FFmpeg Transcoder**: `/home/arosenfeld/Code/mydia/lib/mydia/streaming/ffmpeg_hls_transcoder.ex`
- **HLS Controller**: `/home/arosenfeld/Code/mydia/lib/mydia_web/controllers/api/hls_controller.ex`
- **Stream Controller**: `/home/arosenfeld/Code/mydia/lib/mydia_web/controllers/api/stream_controller.ex`

### Frontend Components
- **Video Player Hook**: `/home/arosenfeld/Code/mydia/assets/js/hooks/video_player.js`
- **Alpine Component**: `/home/arosenfeld/Code/mydia/assets/js/alpine_components/video_player.js`
- **Media Show Page**: `/home/arosenfeld/Code/mydia/lib/mydia_web/live/media_live/show.html.heex`

### Configuration
- **Streaming Config**: `/home/arosenfeld/Code/mydia/config/config.exs`

---

## Session Timeout - Key Facts

### Current Configuration
- **Code default timeout**: 2 minutes (120 seconds)
- **Config file timeout**: 30 minutes
- **Actual setting used**: Compile-time value from config/config.exs
- **Timeout check interval**: Every 30 seconds
- **Inactivity metric**: Time since last `heartbeat()` or `get_info()`

### Session Timeout Flow
```
Session activity occurs → heartbeat() called
    ↓
Update last_activity to current time
    ↓
Cancel existing timeout timer
    ↓
Schedule :check_timeout message in 30 seconds
    ↓
[30 seconds pass]
    ↓
Check: inactive_duration = now() - last_activity
    ├─ If >= 2 minutes: Terminate session + cleanup
    └─ If < 2 minutes: Schedule next check
```

---

## Session Storage & Lookup

### Where Sessions Are Stored
- **Storage**: Elixir Registry (in-memory process registry)
- **Registry name**: `Mydia.Streaming.HlsSessionRegistry`
- **Key format**: `{:hls_session, media_file_id, user_id}`
- **Temp files**: `/tmp/mydia-hls/{session_id}/`

### How Lookups Work
```elixir
# Primary lookup (O(1)):
Registry.lookup(HlsSessionRegistry, {:hls_session, media_file_id, user_id})
  → Returns [{pid, metadata}] or []

# Secondary lookup (O(n) - inefficient):
Enum.find(HlsSessionSupervisor.list_sessions(), fn {key, pid, meta} ->
  HlsSession.get_info(pid) |> elem(1) |> Map.get(:session_id) == session_id
end)
```

---

## Playlist Generation & Serving

### FFmpeg Output
- **Master playlist**: `/tmp/mydia-hls/{session_id}/index.m3u8`
- **Segments**: `/tmp/mydia-hls/{session_id}/segment_001.ts`, `segment_002.ts`, etc.
- **Segment duration**: 6 seconds per segment
- **Playlist type**: Event (live-like, not VOD)

### API Endpoints
```
GET  /api/v1/hls/{session_id}/index.m3u8              → Master playlist
GET  /api/v1/hls/{session_id}/{segment}               → FFmpeg segment
GET  /api/v1/hls/{session_id}/{track_id}/{segment}    → Membrane segment
POST /api/v1/hls/start                                 → Start session
DELETE /api/v1/hls/{session_id}                        → Terminate session
```

### Cache Control Headers
- Master playlist: `no-cache` (prevents stale manifests)
- Segments: `public, max-age=31536000, immutable` (1-year cache)

---

## FFmpeg Codec Handling

### Stream Copy (No Re-encoding)
- **H.264 video**: Copied as-is (10-100x faster)
- **AAC audio**: Copied as-is (10-100x faster)
- **Result**: Zero quality loss, fastest transcoding

### Codec Transcoding (Re-encoding)
- **Video codec**: Transcoded to H.264 (`libx264` preset: medium)
- **Audio codec**: Transcoded to AAC (128 kbps, 48 kHz)
- **Output resolution**: 1280x720 (when transcoding)
- **Quality**: CRF 23 (good balance of quality/speed)

---

## Video Playback Flow

### Detection Phase
1. Client requests stream via `/api/v1/stream/{type}/{id}`
2. Server checks file codec compatibility
3. If compatible: Direct play (no HLS)
4. If incompatible: Start HLS session → 302 redirect to playlist

### Loading Phase
1. Client follows redirect to `/api/v1/hls/{session_id}/index.m3u8`
2. HLS.js sends GET request for manifest
3. Server calls `heartbeat_session()` to keep session alive
4. If playlist not ready (404): HLS.js retries with exponential backoff
5. Once manifest available: MANIFEST_PARSED event fires

### Playback Phase
1. Client requests segments: `/api/v1/hls/{session_id}/segment_NNN.ts`
2. Each request triggers heartbeat (resets 2-minute timeout)
3. Progress saved every 10 seconds during playback
4. When idle: Session times out after 2 minutes of inactivity

---

## Heartbeat Mechanism

### Client-Side Heartbeat
```javascript
// Every 30 seconds during playback:
setInterval(() => {
  // Implicit heartbeat via HLS.js segment fetches
  // No explicit heartbeat call needed
}, 30000)
```

### Server-Side Heartbeat
```elixir
# Called when any playlist/segment is requested:
defp heartbeat_session(session_id, user_id) do
  case find_session_by_id(session_id, user_id) do
    {:ok, pid} -> HlsSession.heartbeat(pid)
    _ -> :ok
  end
end
```

### Result
- Session stays alive during active playback
- Session terminates after 2 minutes of no segment requests
- Each segment fetch automatically extends session lifetime

---

## Retry & Polling Logic

### Playlist Readiness Polling
**How it works**: HLS.js built-in retry (no explicit server-side polling)
- Client requests manifest
- If 404 (not ready): HLS.js retries with exponential backoff
- Eventually FFmpeg outputs first segment + manifest
- Client gets 200 + manifest

### FFmpeg Output Parsing
- **Duration**: Detected from FFmpeg output (regex: `/Duration: HH:MM:SS.ss/`)
- **Progress**: Tracked via `out_time_ms=` entries (microseconds)
- **Errors**: Caught via regex `/Error|Invalid|failed/i`

### Error Recovery
```javascript
hls.on(Hls.Events.ERROR, (event, data) => {
  if (data.fatal) {
    if (data.type === Hls.ErrorTypes.NETWORK_ERROR) {
      hls.startLoad()  // Retry network request
    } else if (data.type === Hls.ErrorTypes.MEDIA_ERROR) {
      hls.recoverMediaError()  // Try to recover media error
    }
  }
})
```

---

## Performance Characteristics

### Session Lookup Performance
- **By media_file_id + user_id**: O(1) - Direct registry lookup
- **By session_id**: O(n) - Must enumerate all sessions (NEEDS OPTIMIZATION)

### Transcoding Performance
- **Stream copy** (compatible codec): 10-100x real-time speed
- **Full transcode** (H.264/AAC): 0.5-2x real-time speed (depends on CPU)
- **Segment duration**: 6 seconds (chosen for balance of latency vs rebuffering)

### Memory Usage
- **Per session**: ~50 MB (transcoding process) + temp files
- **Temp file cleanup**: Automatic on session termination
- **Registry overhead**: Minimal (just PID + metadata tuple)

---

## Configuration to Update

### To Increase Session Timeout
**File**: `/home/arosenfeld/Code/mydia/config/config.exs`

Current:
```elixir
config :mydia, :streaming,
  session_timeout: :timer.minutes(30),
```

This is already 30 minutes. However, code default is 2 minutes (defined in hls_session.ex).
To align: Update hls_session.ex line 50-54 to use the config value.

### To Change Temp Directory
**File**: `/home/arosenfeld/Code/mydia/config/config.exs`

Current:
```elixir
config :mydia, :streaming,
  temp_base_dir: "/tmp/mydia-hls"
```

---

## Known Issues & Limitations

1. **Session lookup by session_id is O(n)** 
   - Affects playlist serving when client provides session_id
   - Should add secondary registry index

2. **No explicit session pre-warming**
   - Sessions only created when user clicks play
   - Could add media detail page endpoint to start session early

3. **No segment pre-buffering**
   - HLS.js uses default buffering
   - Could configure larger buffer targets for smoother playback

4. **Limited telemetry**
   - Only basic logging
   - No metrics for session count, transcoding duration, error rates

5. **Playlist readiness has no explicit timeout**
   - Relies on HLS.js exponential backoff
   - If FFmpeg crashes, client retries indefinitely

---

## For Task Development

### Task 156.1: HLS Playlist Readiness Polling
- Location: `HlsController.master_playlist/2`
- Add: Exponential backoff with max retries
- Return: 503 (Service Unavailable) if transcoding too slow

### Task 156.2: Increase Session Timeout to 10 Minutes
- Change: `/home/arosenfeld/Code/mydia/config/config.exs`
- From: `session_timeout: :timer.minutes(30)` (or check hls_session.ex)
- To: `session_timeout: :timer.minutes(10)`

### Task 156.4: Optimize Session Lookup O(n) to O(1)
- Location: `HlsController.find_session_by_id/2`
- Solution: Add `:session_id` registry key alongside `{:hls_session, media_file_id, user_id}`
- Lookup: `Registry.lookup(HlsSessionRegistry, {:hls_session_id, session_id})`

### Task 156.6: Implement Segment Pre-buffering
- Location: `VideoPlayer.setupHLS()` in video_player.js
- Configure: `bufferTimeDefault`, `bufferTimeMax` in HLS.js config
- Test: Monitor network requests to verify pre-buffering

### Task 156.7: Add Session Pre-warming
- Create: New endpoint `/api/v1/hls/warmup/{media_file_id}`
- Call: From media detail page when component mounts
- Return: Session ID for use when user clicks play

### Task 156.8: Add Telemetry & Monitoring
- Track: Session count, active sessions, transcoding duration
- Use: `:telemetry` module (already available in Phoenix)
- Expose: Via `/api/v1/admin/streaming-stats` endpoint

