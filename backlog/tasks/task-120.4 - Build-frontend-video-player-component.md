---
id: task-120.4
title: Build frontend video player component
status: Done
assignee: []
created_date: '2025-11-08 20:23'
updated_date: '2025-11-08 22:43'
labels: []
dependencies: []
parent_task_id: task-120
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a video player component that seamlessly handles both direct play (progressive download) and HLS adaptive streaming. The player automatically detects the streaming mode from the server response and uses the appropriate playback method.

For direct play, use native HTML5 video. For HLS, use hls.js library (Safari has native HLS support). The player integrates with the progress API to save/resume playback position for both streaming modes.

**Technical approach:**
- Use HTML5 video element as foundation
- Detect streaming mode from unified endpoint response (task-120.8)
- Direct play: Set video src to streaming endpoint, browser handles range requests
- HLS mode: Use hls.js to load master playlist, enable adaptive bitrate
- Integrate JavaScript hooks for progress tracking (timeupdate event)
- Send progress updates to backend every 10 seconds (both modes)
- Handle player events (play, pause, ended, error, waiting)
- Show appropriate loading/error states for each mode

**HLS.js integration:**
```javascript
if (Hls.isSupported()) {
  const hls = new Hls();
  hls.loadSource(hlsUrl);
  hls.attachMedia(video);
} else if (video.canPlayType('application/vnd.apple.mpegurl')) {
  video.src = hlsUrl; // Safari native HLS
}
```

**Fallback handling:**
- Try direct play first (immediate playback)
- If server returns 202 (transcoding), show progress message
- Poll for transcoding completion, switch to HLS when ready
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Player component displays video using HTML5 video element
- [ ] #2 Player detects streaming mode from unified endpoint response
- [ ] #3 Direct play mode: Video src points to streaming endpoint, range requests work
- [ ] #4 HLS mode: Player uses hls.js for adaptive streaming (non-Safari browsers)
- [ ] #5 HLS mode: Safari uses native HLS support
- [ ] #6 Player fetches saved playback progress on mount via API
- [ ] #7 Player automatically seeks to saved position when video loads (both modes)
- [ ] #8 Player tracks playback position using timeupdate event

- [ ] #9 Player sends progress updates to API every 10 seconds during playback
- [ ] #10 Player includes standard controls (play/pause, volume, seek, fullscreen)
- [ ] #11 Player shows loading spinner during buffering and transcoding

- [ ] #12 Player displays user-friendly messages for transcoding status (202 response)
- [ ] #13 Player polls for transcoding completion and switches to HLS when ready
- [ ] #14 Player displays error message on playback failures with appropriate details
- [ ] #15 Player integrates into movie and TV episode detail pages
- [ ] #16 Player stops progress tracking when video ends or user navigates away
- [ ] #17 Player handles network errors gracefully with retry options
- [ ] #18 hls.js library added to assets/js and properly integrated
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### Dependencies
Add to `assets/package.json`:
- `hls.js` - For HLS streaming in non-Safari browsers

Run: `cd assets && npm install`

### Phoenix Hook
Create: `assets/js/hooks/video_player_hook.js`

**Hook lifecycle:**
1. **mounted()** - Initialize player
   - Get media_file_id from element data attribute
   - Fetch playback progress via GET /api/v1/playback/:id
   - Set video src to unified endpoint: /api/v1/stream/:id
   - Detect response (direct play vs HLS redirect)
   - If HLS URL detected, initialize hls.js or native HLS
   - Seek to saved position when metadata loads
   - Setup event listeners

2. **Video event handlers:**
   - `loadedmetadata` - Seek to saved position
   - `timeupdate` - Track current position, throttle to every 10 seconds
   - `play` - Start progress tracking
   - `pause` - Save current progress
   - `ended` - Mark as watched (send final progress)
   - `waiting` - Show loading indicator
   - `error` - Display error message

3. **Progress tracking:**
   - Store last saved position
   - Every 10 seconds during playback: POST to /api/v1/playback/:id
   - Include position_seconds and duration_seconds
   - Handle network errors gracefully (retry, queue updates)

4. **HLS.js integration:**
```javascript
if (video.src.includes('/hls/')) {
  if (Hls.isSupported()) {
    const hls = new Hls();
    hls.loadSource(video.src);
    hls.attachMedia(video);
    hls.on(Hls.Events.ERROR, handleHlsError);
  } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
    // Safari native HLS
    video.src = hlsUrl;
  }
}
```

5. **destroyed()** - Cleanup
   - Save final progress
   - Destroy hls.js instance
   - Remove event listeners

### LiveView Component
Create: `lib/mydia_web/components/video_player.ex`

**Component props:**
- media_file_id (required)
- autoplay (optional, default false)
- controls (optional, default true)

**Template:**
```heex
<div phx-hook="VideoPlayer" 
     id={"video-player-#{@media_file_id}"}
     data-media-file-id={@media_file_id}
     class="relative">
  <video 
    id={"video-#{@media_file_id}"}
    class="w-full h-auto"
    controls={@controls}
    autoplay={@autoplay}
    preload="metadata">
    Your browser does not support video playback.
  </video>
  
  <div class="loading hidden">
    <div class="loading-spinner"></div>
    <p>Loading video...</p>
  </div>
  
  <div class="error hidden">
    <p>Error loading video. Please try again.</p>
  </div>
</div>
```

### Integration
Update media detail pages:
- `lib/mydia_web/live/media_live/show.ex` (movies)
- Add video player component to template
- Pass media_file_id of selected quality/version

### App.js Integration
Update: `assets/js/app.js`
```javascript
import VideoPlayer from "./hooks/video_player_hook"

let Hooks = {}
Hooks.VideoPlayer = VideoPlayer

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  // ... existing config
})
```

### Testing
- Test direct play mode
- Test HLS mode (with mock HLS URLs)
- Test progress saving every 10 seconds
- Test resume from saved position
- Test watched marking at end
- Test error handling
- Test across browsers (Chrome, Firefox, Safari)
- Test seeking and scrubbing
<!-- SECTION:PLAN:END -->
