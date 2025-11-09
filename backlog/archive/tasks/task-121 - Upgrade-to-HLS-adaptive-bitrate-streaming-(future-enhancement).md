---
id: task-121
title: Upgrade to HLS adaptive bitrate streaming (future enhancement)
status: To Do
assignee: []
created_date: '2025-11-08 20:28'
labels:
  - enhancement
  - future
  - streaming
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upgrade the video streaming system from progressive download to HLS (HTTP Live Streaming) with adaptive bitrate support. This provides better user experience by automatically adjusting video quality based on network conditions and device capabilities.

This is a future enhancement to be implemented after the MVP is stable and being used.

Technical approach:
- Use Membrane Framework (Elixir-native) or FFmpeg for video transcoding
- Generate HLS segments (.ts files) and playlists (.m3u8)
- Create multiple quality variants (360p, 720p, 1080p, 4K where applicable)
- Store transcoded segments alongside original files
- Update streaming endpoint to serve HLS playlists and segments
- Use hls.js library for browser playback (Safari has native support)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Research and select between Membrane Framework and FFmpeg for transcoding
- [ ] #2 Implement background job to transcode videos into HLS format on media file import
- [ ] #3 Generate multiple quality levels based on source resolution
- [ ] #4 Create master playlist referencing all quality variants
- [ ] #5 Store HLS segments efficiently (consider cleanup strategy for disk space)
- [ ] #6 Update streaming endpoint to serve HLS playlists and segments
- [ ] #7 Frontend player uses hls.js for HLS playback in non-Safari browsers
- [ ] #8 Player automatically switches quality based on network conditions
- [ ] #9 Existing playback progress system continues working with HLS
- [ ] #10 Performance benchmarks show improved buffering and quality adaptation
- [ ] #11 Documentation covers HLS transcoding configuration and storage requirements
<!-- AC:END -->
