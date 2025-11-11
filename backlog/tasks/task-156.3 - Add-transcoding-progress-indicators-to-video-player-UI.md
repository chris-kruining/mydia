---
id: task-156.3
title: Add transcoding progress indicators to video player UI
status: Done
assignee: []
created_date: '2025-11-10 22:20'
updated_date: '2025-11-10 23:36'
labels:
  - ux
  - frontend
  - quick-win
dependencies: []
parent_task_id: task-156
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Users currently see a generic loading spinner for 4-8 seconds with no context during transcoding startup. Add specific feedback for transcoding preparation.

## Current Problem
- FFmpeg takes 4-8 seconds to start generating segments
- User sees generic "loading" spinner
- No indication of what's happening
- Users think it's broken and reload the page

## Solution
Add transcoding-specific UI states:

**Loading State Messages:**
- "Preparing video for playback..."
- "Preparing video... (attempt 2 of 10)" (during retries)
- "Starting transcoding..." (first 2 seconds)

**Implementation:**
1. Add Alpine.js method: `updateTranscodingProgress(attempt, maxAttempts)`
2. Update loading spinner to show transcoding-specific message
3. Show retry attempt counter during playlist polling

## Files to Modify
- `assets/js/hooks/video_player.js` - Add progress callback
- `assets/js/alpine_components/video_player.js` - Add UI state methods
- `lib/mydia_web/live/playback_live/show.html.heex` - Update loading UI

## Expected Impact
- Users understand what's happening during wait
- Reduced perceived load time (progress feedback makes waits feel shorter)
- Fewer page reloads due to confusion
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Loading message shows 'Preparing video...' for transcoding
- [x] #2 Retry attempts shown to user (e.g., '2 of 10')
- [x] #3 Different message for direct play vs transcoding
- [x] #4 Loading state clears immediately when playback starts
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implementation completed:
- Added loadingMessage, isTranscoding, retryAttempt, maxRetries state to Alpine component
- Created showTranscodingLoading() for transcoding-specific loading message
- Created showDirectPlayLoading() for direct play loading message
- Created updateTranscodingProgress(attempt, maxAttempts) to update retry counter
- Updated initializePlayer() to call appropriate loading method based on stream type
- Updated waitForPlaylist() to call updateTranscodingProgress() during retries
- Updated template to display dynamic loadingMessage using x-text
- Loading state clears automatically when video starts playing (via onLoadedMetadata/onPlaying)

Commit: 23584f7
<!-- SECTION:NOTES:END -->
