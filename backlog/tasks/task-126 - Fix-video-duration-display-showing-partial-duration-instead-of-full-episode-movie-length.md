---
id: task-126
title: >-
  Fix video duration display showing partial duration instead of full
  episode/movie length
status: Done
assignee: []
created_date: '2025-11-09 04:02'
updated_date: '2025-11-09 04:10'
labels:
  - bug
  - video-player
  - ui
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Problem

The video player displays an incorrect duration - it shows only a partial number instead of the full movie or episode duration.

## Expected Behavior

The video player should display the complete duration of the media file (e.g., "01:23:45" for a 1 hour 23 minute movie).

## Current Behavior

The duration shows as a partial/truncated number, not reflecting the actual full length of the content.

## Potential Causes

1. Duration calculation issue in the video player
2. Incorrect metadata being passed from the backend
3. HLS transcoding providing incorrect duration information
4. Frontend formatting issue with the duration display

## Investigation Needed

- Check what duration value is being received from the media metadata
- Verify HLS playlist provides correct duration
- Check video element's `duration` property
- Review duration formatting logic in the video player component

## Related Components

- Video player hook (`assets/js/hooks/video_player.js`)
- Video player Alpine component (`assets/js/alpine_components/video_player.js`)
- MediaFile metadata
- HLS transcoding duration detection
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Solution

Fixed the video duration display issue by adding support for the `durationchange` event, which is essential for HLS streams where the duration isn't always available immediately when `loadedmetadata` fires.

## Changes Made

1. **Alpine.js Component** (`assets/js/alpine_components/video_player.js`):
   - Added `onDurationChange()` event handler that updates the duration when it changes
   - Includes validation to ensure duration is finite and greater than zero

2. **Video Element Template** (`lib/mydia_web/components/core_components.ex`):
   - Added `@durationchange="onDurationChange"` event listener to the video element

3. **Phoenix Hook** (`assets/js/hooks/video_player.js`):
   - Added console logging for duration changes to aid in debugging

## How It Works

- The `durationchange` event fires whenever the video's duration property changes
- For HLS streams, this often happens after `loadedmetadata` when the manifest is fully parsed
- For direct play, it provides a fallback in case duration isn't available on first load
- The event handler only updates the duration if it's a valid finite number > 0

## Testing

- Code compiles successfully
- No JavaScript syntax errors
- Changes are backwards compatible with direct play streams
<!-- SECTION:NOTES:END -->
