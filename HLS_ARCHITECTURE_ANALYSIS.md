# Media Playback Architecture Analysis - HLS Transcoding System

## Executive Summary

The Mydia application implements a sophisticated HLS (HTTP Live Streaming) video transcoding system with:
- **Session-based architecture** with timeout management
- **Dual backend support** (FFmpeg as default, Membrane as experimental)
- **Registry-based session lookup** for O(1) performance
- **Client-side HLS.js player** with polling for playlist readiness
- **2-minute inactivity timeout** (configured to 30 minutes in config, but HLS session defaults to 2 minutes based on comment in code)
- **Heartbeat mechanism** to keep sessions alive during active playback

---

## 1. HLS Session Management

### Session Timeout Configuration

**File:** `/home/arosenfeld/Code/mydia/lib/mydia/streaming/hls_session.ex`

```elixir
@session_timeout Application.compile_env(
                   :mydia,
                   [:streaming, :session_timeout],
                   :timer.minutes(2)
                 )
```

**Key Points:**
- Default timeout: **2 minutes** (120 seconds)
- Configured in `/home/arosenfeld/Code/mydia/config/config.exs`: 30 minutes
- Actual code uses `timer.minutes(2)` as the compile-time default
- Timeout checks run every 30 seconds

### Session Storage & Lookup

**Location:** `/home/arosenfeld/Code/mydia/lib/mydia/streaming/hls_session_supervisor.ex`

**Lookup Method (O(1) complexity):**
```elixir
Registry.lookup(@registry_name, session_key)
```

**Session Key Structure:**
```elixir
{:hls_session, media_file_id, user_id}
```

**Storage Mechanism:**
- Uses Elixir's built-in `Registry` (not a database lookup)
- Registry key format: `{:hls_session, media_file_id, user_id}`
- Multiple users can stream the same file simultaneously (different sessions)
- Sessions are ephemeral (stored in memory, cleared on termination)

### Session Lifecycle

1. **Creation** (`start_session/2`):
   - Creates unique UUID-based session ID
   - Generates temporary directory: `/tmp/mydia-hls/{session_id}/`
   - Registers session in `HlsSessionRegistry`
   - Starts backend transcoding process

2. **Activity Tracking**:
   - `heartbeat/1` - Records activity (resets timeout timer)
   - `get_info/1` - Returns session metadata (counts as activity)
   - Activity timestamp updated whenever either function is called

3. **Inactivity Timeout**:
   - Check runs every 30 seconds
   - If inactive for 2 minutes (120 seconds), session terminates
   - Each playlist/segment request triggers a heartbeat

4. **Termination**:
   - Backend process is stopped gracefully
   - FFmpeg process receives SIGTERM (100ms grace period)
   - Force SIGKILL if process doesn't terminate
   - Temporary directory cleaned up (`File.rm_rf`)

### Session Registration Details

**File:** `/home/arosenfeld/Code/mydia/lib/mydia/streaming/hls_session.ex` (lines 146-154)

```elixir
Registry.register(
  Mydia.Streaming.HlsSessionRegistry,
  registry_key,
  %{
    media_file_id: media_file_id,
    user_id: user_id,
    started_at: DateTime.utc_now()
  }
)
```

---

## 2. HLS Playlist Generation & Serving

### Playlist Generation (FFmpeg)

**File:** `/home/arosenfeld/Code/mydia/lib/mydia/streaming/ffmpeg_hls_transcoder.ex`

**FFmpeg HLS Arguments:**
```elixir
hls_args = [
  "-f", "hls",
  "-hls_time", "6",              # 6-second segments
  "-hls_playlist_type", "event",  # Event playlist (live-like)
  "-hls_segment_filename", segment_pattern,
  "-progress", "pipe:1",          # Progress reporting
  "-loglevel", "info",
  playlist_path                   # Output: index.m3u8
]
```

**Output Structure:**
- Master playlist: `/tmp/mydia-hls/{session_id}/index.m3u8`
- Segments: `/tmp/mydia-hls/{session_id}/segment_001.ts`, etc.
- Fallback support for old format: `playlist.m3u8`

### Playlist Serving

**File:** `/home/arosenfeld/Code/mydia/lib/mydia_web/controllers/api/hls_controller.ex`

**Master Playlist Endpoint:**
```
GET /api/v1/hls/{session_id}/index.m3u8
```

**Process:**
1. Extract session_id from URL
2. Verify user authentication
3. Look up session in registry
4. Retrieve session temp directory
5. Check for `index.m3u8` (or fallback to `playlist.m3u8`)
6. Return file with cache headers:
   - `Content-Type`: `application/vnd.apple.mpegurl`
   - `Cache-Control`: `no-cache` (prevents stale manifests)
7. Trigger heartbeat to keep session alive

**Segment Serving Endpoints:**

```
GET /api/v1/hls/{session_id}/{track_id}/{segment}     # Membrane style (with subdirs)
GET /api/v1/hls/{session_id}/{segment}                # FFmpeg style (flat)
```

**Segment Caching:**
```elixir
put_resp_header("cache-control", "public, max-age=31536000, immutable")
```

---

## 3. Media Transcoding

### FFmpeg Integration

**File:** `/home/arosenfeld/Code/mydia/lib/mydia/streaming/ffmpeg_hls_transcoder.ex`

**Codec Detection & Stream Copy Optimization:**

The system intelligently decides whether to copy or transcode based on browser compatibility:

```elixir
# H.264 video codec → stream copy (10-100x faster, zero quality loss)
should_copy_video?("h264")      # true
should_copy_video?("avc")       # true
should_copy_video?("hevc")      # false (needs transcoding)

# AAC audio codec → stream copy
should_copy_audio?("aac")       # true
should_copy_audio?("mp4a")      # true
should_copy_audio?("eac3")      # false (needs transcoding)
```

**Transcode Policy Configuration:**
- Policy: `:copy_when_compatible` (default)
- Intelligently copies compatible streams
- Transcodes incompatible codecs to H.264/AAC

**FFmpeg Video Encoding Parameters (when transcoding):**
```elixir
[
  "-c:v", "libx264",
  "-preset", "medium",           # Quality/speed tradeoff
  "-crf", "23",                  # Quality (0-51, lower=better)
  "-pix_fmt", "yuv420p",         # 8-bit output (converts from 10-bit sources)
  "-profile:v", "high",          # H.264 profile
  "-s", "1280x720",              # Resolution
  "-g", "60",                    # GOP size (60 frames = ~2 seconds at 30fps)
  "-bf", "0"                     # No B-frames for streaming
]
```

**FFmpeg Audio Encoding Parameters (when transcoding):**
```elixir
[
  "-c:a", "aac",
  "-b:a", "128k",                # Audio bitrate
  "-ar", "48000",                # Sample rate
  "-ac", "2"                     # 2 channels (stereo)
]
```

**Process Management:**
- Spawned via `Port.open()` with `:binary`, `:exit_status`, `:stderr_to_stdout`
- Captures FFmpeg output via message passing
- Parses progress from `out_time_ms=` entries
- Graceful shutdown: SIGTERM → 100ms grace period → SIGKILL if needed

### FFmpeg Output Parsing

**Progress Detection:**
```regex
/out_time_ms=(\d+)/   # Time in microseconds
```

**Duration Detection:**
```regex
/Duration: (\d{2}):(\d{2}):(\d{2}\.\d{2})/
```

**Error Detection:**
```regex
/Error|Invalid|failed/i
```

---

## 4. Video Player UI Components

### Video Player Hook

**File:** `/home/arosenfeld/Code/mydia/assets/js/hooks/video_player.js`

**Responsibilities:**
1. Initialize video element and fetch playback progress
2. Detect HLS vs direct play
3. Setup HLS.js for adaptive streaming
4. Manage playback progress saving
5. Handle keyboard shortcuts and gestures
6. Coordinate with Alpine.js for UI state

### HLS.js Configuration

```javascript
if (Hls.isSupported()) {
  this.hls = new Hls({
    enableWorker: true,
    lowLatencyMode: false
  })
}
```

**HLS.js Event Handlers:**
- `MANIFEST_PARSED` - Playlist loaded, ready to play
- `LEVEL_SWITCHED` - Quality changed
- `ERROR` - Playback error with recovery attempts

**Error Recovery:**
```javascript
if (data.fatal) {
  switch (data.type) {
    case Hls.ErrorTypes.NETWORK_ERROR:
      this.hls.startLoad()  // Retry
      break
    case Hls.ErrorTypes.MEDIA_ERROR:
      this.hls.recoverMediaError()  // Recover
      break
  }
}
```

### Alpine.js Component

**File:** `/home/arosenfeld/Code/mydia/assets/js/alpine_components/video_player.js`

**State Management:**
- `playing`, `muted`, `volume`, `currentTime`, `duration`
- `buffering`, `hasMetadata`, `loading`, `error`
- HLS quality levels and current selection
- TV show features (skip intro, skip credits, next episode)

**UI Features:**
- Play/pause controls
- Volume slider with mute
- Progress bar
- Playback speed selection (0.5x - 2x)
- Quality selection (if multiple HLS levels)
- Fullscreen support
- TV show feature indicators

---

## 5. Retry & Polling Logic

### Client-Side Polling (Video Player Hook)

**Playlist Readiness Detection:**

```javascript
// 1. Detect if stream is HLS
const finalUrl = response.url
if (finalUrl && finalUrl.includes('.m3u8')) {
  this.setupHLS(finalUrl)
}
```

**Session Heartbeat (keeps session alive):**

```javascript
startHlsHeartbeat() {
  // Every 30 seconds send heartbeat
  this.heartbeatInterval = setInterval(() => {
    if (!this.video.paused && this.hlsSessionId) {
      // Heartbeat sent implicitly via HLS.js segment fetches
      // Each fetch request triggers HlsSession.heartbeat(pid)
    }
  }, 30000)
}
```

**Progress Saving:**

```javascript
startProgressTracking() {
  // Save progress every 10 seconds while playing
  this.progressInterval = setInterval(() => {
    if (this.video.duration && !this.video.paused) {
      if (Math.abs(position - this.lastSavedPosition) >= 1) {
        this.saveProgress(position, duration)
      }
    }
  }, 10000)
}
```

### Server-Side Heartbeat Response

**File:** `/home/arosenfeld/Code/mydia/lib/mydia_web/controllers/api/hls_controller.ex`

**Master Playlist Endpoint (heartbeat triggered):**
```elixir
def master_playlist(conn, %{"session_id" => session_id}) do
  # ... validate user and get session ...
  
  # Update session activity on every playlist request
  heartbeat_session(session_id, user_id)
  
  # Return playlist with no-cache header to prevent stale manifests
  put_resp_header("cache-control", "no-cache")
end
```

**Heartbeat Implementation:**
```elixir
defp heartbeat_session(session_id, user_id) do
  case find_session_by_id(session_id, user_id) do
    {:ok, pid} ->
      HlsSession.heartbeat(pid)
      :ok
    _ ->
      :ok
  end
end
```

**Heartbeat Cast Handler:**
```elixir
def handle_cast(:heartbeat, state) do
  state = update_activity(state)
  {:noreply, state}
end

defp update_activity(state) do
  # Cancel existing timeout check
  if state.timeout_ref do
    Process.cancel_timer(state.timeout_ref)
  end

  # Update last activity and schedule new timeout check
  state
  |> Map.put(:last_activity, DateTime.utc_now())
  |> schedule_timeout_check()
end
```

### Timeout Check Mechanism

**Periodic Timeout Check:**

```elixir
def handle_info(:check_timeout, state) do
  now = DateTime.utc_now()
  inactive_duration = DateTime.diff(now, state.last_activity, :millisecond)

  if inactive_duration >= @session_timeout do
    Logger.info("Session #{state.session_id} inactive for #{inactive_duration}ms, terminating")
    {:stop, :timeout, state}
  else
    # Still active, schedule next check
    state = schedule_timeout_check(state)
    {:noreply, state}
  end
end

defp schedule_timeout_check(state) do
  # Check every 30 seconds (more frequent than 2-minute timeout)
  check_interval = :timer.seconds(30)
  timeout_ref = Process.send_after(self(), :check_timeout, check_interval)
  Map.put(state, :timeout_ref, timeout_ref)
end
```

---

## 6. Current Implementation Issues

### Known Issues

1. **2-minute default vs 30-minute configured:**
   - Code default: 2 minutes
   - Config default: 30 minutes
   - Mismatch could cause confusion

2. **Playlist readiness without explicit polling:**
   - No explicit retry logic in controller
   - HLS.js handles retry with exponential backoff
   - If playlist not ready (transcoding still in progress), returns 404
   - Client-side HLS.js retries automatically

3. **No explicit session warmup:**
   - Session starts when first request arrives
   - Media detail page triggers session start implicitly
   - No pre-warming before user clicks play

4. **O(n) session lookup by session_id:**
   - HLS controller does enumeration to find session by ID:
   ```elixir
   Enum.find(HlsSessionSupervisor.list_sessions(), fn {_key, pid, _meta} ->
     case HlsSession.get_info(pid) do
       {:ok, info} -> info.session_id == session_id
       _ -> false
     end
   end)
   ```
   - Should use direct registry lookup instead

5. **Segment pre-buffering not implemented:**
   - HLS.js uses default buffering strategy
   - No explicit segment prefetch for smooth playback

---

## 7. Architecture Diagrams

### Session Lifecycle Flow

```
User Request (stream)
    ↓
StreamController.stream()
    ↓
Check Compatibility
    ├→ Direct Play (compatible)
    └→ Needs Transcoding (incompatible)
        ↓
    HlsSessionSupervisor.start_session()
        ↓
    Registry.lookup() - Check existing
        ├→ Found: Return existing PID
        └→ Not found: Create new
            ↓
        HlsSession.start_link()
            ├→ Load media file
            ├→ Register in registry
            ├→ Create temp directory
            ├→ Start FFmpeg/Membrane backend
            ├→ Schedule timeout check
            └→ Link to backend (crash if dies)
    ↓
Return master playlist URL
    ↓
Client HLS.js loads manifest
    ├→ Check cache
    └→ Fetch /api/v1/hls/{session_id}/index.m3u8
        ↓
    HlsController.master_playlist()
        ├→ Validate user
        ├→ Get session temp dir
        ├→ Read index.m3u8 from disk
        ├→ Call heartbeat_session()
        │   ├→ HlsSession.heartbeat()
        │   │   └→ update_activity()
        │   │       ├→ Cancel old timeout timer
        │   │       ├→ Update last_activity
        │   │       └→ Schedule new check in 30s
        └→ Return with cache-control: no-cache
```

### Session Timeout Flow

```
Activity Occurs
    ↓
heartbeat() or get_info()
    ├→ Cancel pending timeout_ref
    ├→ Update last_activity to now()
    └→ Schedule :check_timeout message in 30s
        ↓
        [... 30 seconds pass ...]
        ↓
    handle_info(:check_timeout)
        ├→ Calculate: inactive_duration = now() - last_activity
        ├→ If inactive_duration >= 2 minutes:
        │   ├→ Log termination
        │   └→ {:stop, :timeout}
        │       ├→ terminate() callback runs
        │       ├→ Stop FFmpeg (SIGTERM)
        │       ├→ Clean up /tmp/mydia-hls/{session_id}/
        │       └→ Remove registry entry
        └→ Else: Schedule next check in 30s
```

### Playlist Readiness Polling

```
Client calls HLS.js loadSource(url)
    ↓
HLS.js sends GET /api/v1/hls/{session_id}/index.m3u8
    ↓
HlsController.master_playlist()
    ├→ File exists? 
    │   ├→ Yes: Return it + heartbeat
    │   └→ No: Return 404
    ↓
HLS.js gets response
    ├→ 200: Parse manifest → MANIFEST_PARSED event
    │   └→ Ready to play
    └→ 404: Retry with exponential backoff
        └→ Eventually manifest becomes available
            (FFmpeg finishes transcoding first segment)
```

### Playlist & Segment Serving

```
Video Timeline Request
    ├→ Media Detail Page Load
    │   └→ (No explicit session start)
    │
    └→ User Clicks Play
        └→ StreamController detects incompatible codec
            ├→ Create HLS session
            ├→ Return redirect to master playlist
            └→ Redirect: 302 /api/v1/hls/{session_id}/index.m3u8
                ↓
            Client follows redirect
                ├→ GET /api/v1/hls/{session_id}/index.m3u8
                │   └→ (Playlist may not exist yet if transcoding hasn't started first segment)
                │
                ├→ HLS.js retries on 404
                │
                └→ Eventually FFmpeg outputs index.m3u8
                    ↓
                    Client gets manifest
                    ├→ Parse variant streams
                    └→ Start requesting segments
                        ├→ GET /api/v1/hls/{session_id}/segment_001.ts
                        ├→ GET /api/v1/hls/{session_id}/segment_002.ts
                        └→ (each triggers heartbeat)
```

---

## 8. Key Functions & Their Locations

| Function | File | Purpose |
|----------|------|---------|
| `HlsSessionSupervisor.start_session/2` | `hls_session_supervisor.ex:52-78` | Start or get existing session |
| `HlsSession.start_link/1` | `hls_session.ex:100-108` | Initialize GenServer for session |
| `HlsSession.get_info/1` | `hls_session.ex:115-117` | Get session metadata (triggers activity) |
| `HlsSession.heartbeat/1` | `hls_session.ex:122-124` | Record activity (cast) |
| `HlsSession.schedule_timeout_check/1` | `hls_session.ex:369-374` | Schedule next 30-second check |
| `HlsSession.update_activity/1` | `hls_session.ex:357-367` | Update last_activity timestamp |
| `FfmpegHlsTranscoder.start_transcoding/1` | `ffmpeg_hls_transcoder.ex:128-131` | Start FFmpeg process |
| `FfmpegHlsTranscoder.build_ffmpeg_args/3` | `ffmpeg_hls_transcoder.ex:352-499` | Construct FFmpeg command |
| `HlsController.master_playlist/2` | `hls_controller.ex:14-71` | Serve HLS master playlist |
| `HlsController.segment/3` | `hls_controller.ex:122-165` | Serve HLS segments |
| `HlsController.heartbeat_session/2` | `hls_controller.ex:336-345` | Trigger activity on session |
| `VideoPlayer.setupHLS()` | `video_player.js:228-290` | Initialize HLS.js |
| `VideoPlayer.startProgressTracking()` | `video_player.js:377-395` | Start saving progress + heartbeat |
| `VideoPlayer.startHlsHeartbeat()` | `video_player.js:407-420` | Send heartbeat every 30 seconds |

---

## 9. Configuration Values

**File:** `/home/arosenfeld/Code/mydia/config/config.exs`

```elixir
config :mydia, :streaming,
  session_timeout: :timer.minutes(30),    # Configured timeout
  temp_base_dir: "/tmp/mydia-hls"         # Session storage
```

**Code Defaults:**

```elixir
@session_timeout Application.compile_env(
                   :mydia,
                   [:streaming, :session_timeout],
                   :timer.minutes(2)       # Fallback: 2 minutes
                 )
@temp_base_dir Application.compile_env(:mydia, [:streaming, :temp_base_dir], "/tmp/mydia-hls")
```

---

## Summary for Task Implementation

### For HLS Playlist Readiness Polling with Retry Logic (Task 156.1)
- **Current approach:** No explicit polling in controller, relies on HLS.js built-in retry
- **Improvement:** Implement exponential backoff with max retries in controller
- **Location:** `HlsController.master_playlist/2`

### For HLS Session Timeout Increase (Task 156.2)
- **Current timeout:** 2 minutes (code default) vs 30 minutes (config)
- **Location:** `/home/arosenfeld/Code/mydia/config/config.exs` - update `:session_timeout`
- **Propagation:** HlsSession uses `Application.compile_env()` with fallback

### For Session Lookup Optimization (Task 156.4)
- **Current:** O(n) enumeration when finding session by ID
- **Improvement:** Add secondary registry index for session_id → pid mapping
- **Location:** `HlsController.find_session_by_id/2` (~line 316)

### For Segment Pre-buffering (Task 156.6)
- **Current:** Default HLS.js buffering
- **Improvement:** Configure HLS.js chunk size and buffer targets
- **Location:** `VideoPlayer.setupHLS()` in video_player.js

### For Session Pre-warming (Task 156.7)
- **Current:** Sessions created on first stream request
- **Improvement:** Add endpoint to start session proactively on media detail page load
- **Location:** New API endpoint or enhanced stream controller

### For Telemetry & Monitoring (Task 156.8)
- **Current:** Basic logging only
- **Improvement:** Add metrics collection (session count, transcoding time, error rates)
- **Location:** Add metrics middleware in HlsSession and FfmpegHlsTranscoder

