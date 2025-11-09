---
id: task-132
title: Fix video playback starting at wrong position and not autoplaying
status: Done
assignee: []
created_date: '2025-11-09 04:34'
updated_date: '2025-11-09 04:39'
labels:
  - bug
  - video-player
  - playback
  - high-priority
dependencies:
  - task-120
  - task-125
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
When opening an episode or movie, the video player:
1. Starts at a random/incorrect position instead of starting at the beginning (0:00) for new videos or the saved progress position for resumed videos
2. Does not automatically start playing - the user has to manually click play

**Expected Behavior:**
- New videos (no saved progress) should start at 0:00
- Resumed videos should start at the saved progress position
- Video should autoplay when the page loads (with appropriate browser autoplay policies)

**Current Behavior:**
- Video starts at some random position
- Video does not autoplay - remains paused until user clicks play

**Context:**
This is affecting the video streaming functionality implemented in task-120. The issue may be related to:
- Progress tracking initialization in the Alpine.js/Phoenix hook refactor (task-125)
- Initial video element state and currentTime setting
- Browser autoplay policies and muted state
- HLS vs direct play initialization timing

**Investigation Areas:**
1. Progress loading and video.currentTime initialization
2. Autoplay attribute and browser policies (may need muted autoplay)
3. Alpine.js component initialization timing
4. HLS.js ready state vs direct play ready state
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 New videos (no saved progress) start at 0:00 when page loads
- [x] #2 Resumed videos start at the saved progress position when page loads
- [x] #3 Video autoplays when page loads (respecting browser autoplay policies)
- [x] #4 Direct play videos initialize and start correctly
- [x] #5 HLS transcoded videos initialize and start correctly
- [x] #6 Progress tracking does not interfere with initial playback position
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Summary

Fixed video playback autoplay and starting position issues by making the following changes:

### 1. Enabled Autoplay (lib/mydia_web/live/playback_live/show.html.heex)
- Added `autoplay={true}` attribute to the video_player component call
- This ensures videos automatically start playing when the page loads

### 2. Browser Autoplay Policy Compliance (lib/mydia_web/components/core_components.ex)
- Added `muted={@autoplay}` to the video element
- Videos now start muted to comply with browser autoplay policies
- This allows autoplay to work across all modern browsers

### 3. Fixed Starting Position Timing (assets/js/hooks/video_player.js)
- Changed from using `loadedmetadata` event to `canplay` event for seeking
- The `canplay` event fires when the video is actually ready to play, avoiding race conditions
- Added explicit `currentTime = 0` for new videos (no saved progress)
- Added `hasSetInitialPosition` flag to ensure we only set the position once
- This fixes both HLS and direct play videos starting at the correct position

### 4. Unmute on First User Interaction (assets/js/alpine_components/video_player.js)
- Modified `togglePlay()` method to unmute the video on first user interaction
- When user clicks play/pause or the video element, it automatically unmutes
- Provides a smooth UX where the video autoplays muted, then unmutes when user interacts
- Users can still manually control mute/unmute via the mute button

### Technical Details

**Autoplay Flow:**
1. Video loads on page mount
2. Video autoplays muted (browser policy compliant)
3. User sees video playing
4. User clicks play/pause, video, or keyboard shortcut
5. Video unmutes automatically (if still muted)
6. Subsequent interactions work normally

**Starting Position Flow:**
1. Hook fetches saved progress from API
2. Video source is set (HLS or direct play)
3. Video emits `canplay` event when ready
4. Hook seeks to saved position (or 0:00 for new videos)
5. Video starts playing from correct position

**Browser Compatibility:**
- All modern browsers support muted autoplay
- HLS.js handles HLS streams in browsers without native support
- Safari uses native HLS support
- Direct play works for compatible codecs/containers
<!-- SECTION:NOTES:END -->
