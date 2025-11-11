---
id: task-156.7
title: Add HLS session pre-warming on media detail page
status: To Do
assignee: []
created_date: '2025-11-10 22:20'
labels:
  - performance
  - ux
  - optimization
dependencies: []
parent_task_id: task-156
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Start HLS transcoding session when user views the media detail page (before clicking play), so segments are ready when playback starts.

## Current Problem
- Transcoding starts only when user clicks play
- 4-8 second wait before playback begins
- Poor first-play experience

## Solution
Pre-warm transcoding session on page load:

**Frontend (media detail page):**
```javascript
// Preload transcoding session (don't start playback)
fetch(`/api/v1/hls/preload/${mediaItemId}`, { method: 'POST' })
```

**Backend (new endpoint):**
```elixir
def preload_session(conn, %{"media_item_id" => media_item_id}) do
  # Start session but don't redirect
  # Segments generate in background while user reads description
  HlsSessionSupervisor.start_session(media_file_id, user_id)
  json(conn, %{status: "warming"})
end
```

**Benefits:**
- Segments ready when user clicks play (instant playback)
- User spends 3-5 seconds reading description = transcoding time
- Only downside: wasted resources if user doesn't play (acceptable)

## Files to Create/Modify
- `lib/mydia_web/controllers/api/hls_controller.ex` - Add preload endpoint
- `lib/mydia_web/router.ex` - Add route
- `lib/mydia_web/live/media_live/show.ex` - Add preload hook
- `assets/js/hooks/video_preload.js` - New hook for preloading

## Expected Impact
- Time-to-playback reduced from 8s to <1s (perceived)
- Better user experience (instant play)
- Slight increase in server resource usage
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Preload endpoint starts session without blocking
- [ ] #2 Preload only happens if playback enabled
- [ ] #3 Session reused when user clicks play
- [ ] #4 No preload for direct-play files (optimization)
- [ ] #5 Preload cancelled if user navigates away
<!-- AC:END -->
