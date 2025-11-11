---
id: task-156.1
title: Implement HLS playlist readiness polling with retry logic
status: Done
assignee: []
created_date: '2025-11-10 22:20'
updated_date: '2025-11-10 23:32'
labels:
  - bug
  - frontend
  - quick-win
dependencies: []
parent_task_id: task-156
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add retry logic in the frontend video player to handle the race condition where FFmpeg hasn't generated the HLS playlist yet.

## Current Problem
When user clicks play on a video requiring transcoding:
1. Browser fetches stream URL (HEAD request)
2. Server redirects to HLS playlist URL
3. Browser immediately follows redirect
4. FFmpeg hasn't started yet → 404 error
5. No retry → playback fails

## Solution
Implement exponential backoff retry logic in `assets/js/hooks/video_player.js`:

```javascript
async waitForPlaylist(playlistUrl, { maxRetries: 10, retryDelay: 500, maxDelay: 3000 }) {
  for (let i = 0; i < maxRetries; i++) {
    const response = await fetch(playlistUrl, { method: 'HEAD' })
    if (response.ok) return  // Playlist ready
    
    this.alpine.updateTranscodingProgress(i + 1, maxRetries)
    const delay = Math.min(retryDelay * Math.pow(1.5, i), maxDelay)
    await new Promise(resolve => setTimeout(resolve, delay))
  }
  throw new Error('Playlist not ready')
}
```

## Files to Modify
- `assets/js/hooks/video_player.js` (lines 141-188)

## Expected Impact
- Reduce failure rate from 50% to ~5%
- Max wait time: ~15 seconds with exponential backoff
- Better user experience with retry attempts
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Retry logic implements exponential backoff (500ms to 3s)
- [x] #2 Maximum 10 retry attempts before showing error
- [x] #3 Successful retry logged for debugging
- [x] #4 Works for both direct HLS URLs and redirected URLs
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implementation completed:
- Added waitForPlaylist() method with exponential backoff (500ms base, 1.5x multiplier, 3s max)
- Configured for 10 max retries before error
- Logs successful retries with attempt count
- Handles both direct and redirected HLS URLs
- Integrated into initializePlayer() flow before setupHLS()

Commit: 2bd48ae
<!-- SECTION:NOTES:END -->
