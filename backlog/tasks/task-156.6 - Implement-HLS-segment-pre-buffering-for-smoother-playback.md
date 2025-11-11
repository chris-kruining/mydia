---
id: task-156.6
title: Implement HLS segment pre-buffering for smoother playback
status: To Do
assignee: []
created_date: '2025-11-10 22:20'
labels:
  - performance
  - frontend
dependencies: []
parent_task_id: task-156
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configure HLS.js to buffer more aggressively to handle network hiccups and provide smoother playback experience.

## Current Problem
- Default HLS.js buffer settings are conservative
- Network hiccups cause buffering/stuttering
- No resilience to temporary network issues
- Poor experience on slower connections

## Solution
Configure HLS.js with more aggressive buffering:

```javascript
this.hls = new Hls({
  maxBufferLength: 60,        // Buffer 60 seconds ahead (was: 30)
  maxMaxBufferLength: 600,    // Up to 10 minutes max
  maxBufferSize: 60 * 1000 * 1000,  // 60MB buffer
  maxBufferHole: 0.5,         // Jump over holes faster
  enableWorker: true,         // Already enabled
  lowLatencyMode: false       // Already disabled
})
```

**Trade-offs:**
- ✅ Smoother playback, better network resilience
- ✅ Better experience on mobile/slow connections
- ⚠️ Uses more memory (~60MB vs ~30MB)
- ⚠️ Longer initial load (but masked by retry logic)

## Files to Modify
- `assets/js/hooks/video_player.js` (line 239-242)

## Expected Impact
- Fewer rebuffering events during playback
- Better handling of network fluctuations
- Improved mobile playback experience
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 HLS buffer increased to 60 seconds
- [ ] #2 No memory issues on low-end devices
- [ ] #3 Reduced rebuffering events during playback
- [ ] #4 Seeking still responsive with larger buffer
<!-- AC:END -->
