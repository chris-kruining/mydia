---
id: task-156.5
title: Cache HLS playlist file paths to reduce filesystem calls
status: Done
assignee: []
created_date: '2025-11-10 22:20'
updated_date: '2025-11-10 23:38'
labels:
  - performance
  - backend
dependencies: []
parent_task_id: task-156
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Current implementation checks multiple file paths on every playlist request, adding 5-10ms latency.

## Current Problem
```elixir
# lib/mydia_web/controllers/api/hls_controller.ex:22-26
file_path =
  cond do
    File.exists?(index_path) -> index_path      # Blocking I/O
    File.exists?(playlist_path) -> playlist_path # Blocking I/O
    true -> nil
  end
```

**Performance Impact:**
- 2 filesystem calls per playlist request
- HLS.js requests playlist every 6 seconds
- Adds 5-10ms latency per request
- Scales poorly with concurrent users

## Solution
Cache the successful playlist path in session state:

```elixir
# In HlsSession state
%State{
  ...,
  playlist_path: nil  # Cache after first successful read
}

# In HlsController
if cached_path = get_cached_playlist_path(session_id) do
  # Fast path - use cached path
  File.read(cached_path)
else
  # Slow path - check both locations, cache result
  discover_and_cache_playlist_path(session_id)
end
```

## Files to Modify
- `lib/mydia/streaming/hls_session.ex` - Add playlist_path to state
- `lib/mydia_web/controllers/api/hls_controller.ex` - Use cached path

## Expected Impact
- Reduce latency from 10ms to <1ms for subsequent requests
- First request still checks both paths (discovery)
- Better performance under concurrent load
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Playlist path cached after first successful read
- [x] #2 Cache invalidated when session terminates
- [x] #3 Fallback to filesystem checks if cached path invalid
- [x] #4 No increase in memory usage per session
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implementation completed:
- Added playlist_path field to HlsSession.State (line 69, type at 82)
- Created cache_playlist_path/2 client API method (line 131-133)
- Created get_playlist_path/1 client API method (line 138-140)
- Added handle_call :get_playlist_path callback (line 261-263)
- Added handle_cast {:cache_playlist_path, path} callback (line 271-273)
- Updated master_playlist action to try cached path first (line 19-63)
- Fallback to filesystem checks if cache miss or invalid path (line 20-39, 47-62)
- Cache automatically cleared when session terminates (state is destroyed)
- Memory overhead: single string path per session (~50-100 bytes)

Performance:
- First request: 2 File.exists? calls (discovery)
- Subsequent requests: 0 File.exists? calls if cached path still valid
- If cached path invalid: Re-discover and re-cache

Commit: 864d0cc
<!-- SECTION:NOTES:END -->
