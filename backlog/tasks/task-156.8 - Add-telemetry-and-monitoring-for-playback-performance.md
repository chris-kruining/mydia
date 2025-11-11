---
id: task-156.8
title: Add telemetry and monitoring for playback performance
status: To Do
assignee: []
created_date: '2025-11-10 22:20'
labels:
  - monitoring
  - observability
dependencies: []
parent_task_id: task-156
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement comprehensive telemetry to track playback performance metrics and identify issues in production.

## Metrics to Track

**Backend (Telemetry Events):**
- HLS session start time
- Time to first segment generation
- FFmpeg startup duration
- Session timeout rate
- Transcoding failure rate by codec/container
- Average segment generation time
- Concurrent session count

**Frontend (Analytics):**
- Time to first byte (TTFB) for playlists
- Playlist 404 retry count before success
- Time from click to playback start
- Rebuffering events during playback
- HLS errors by type
- Browser/device info for failures

## Implementation

**Backend:**
```elixir
# Add to lib/mydia/streaming/hls_session.ex
:telemetry.execute(
  [:mydia, :hls, :session, :start],
  %{duration: duration},
  %{media_file_id: media_file_id, codec: codec}
)

# Add to lib/mydia/streaming/ffmpeg_hls_transcoder.ex
:telemetry.execute(
  [:mydia, :hls, :transcode, :segment],
  %{duration: duration},
  %{segment_number: n}
)
```

**Frontend:**
```javascript
// Track playback metrics
window.analyticsTrack('video_playback_start', {
  timeToPlay: Date.now() - clickTime,
  retryCount: retries,
  transcodingRequired: isHls
})
```

## Dashboards to Create
- Playback success rate (by codec, container, browser)
- Average time-to-playback histogram
- Session timeout rate over time
- FFmpeg performance metrics

## Files to Modify
- `lib/mydia/streaming/hls_session.ex` - Add telemetry events
- `lib/mydia/streaming/ffmpeg_hls_transcoder.ex` - Track transcoding performance
- `assets/js/hooks/video_player.js` - Track frontend metrics
- Add telemetry handler module for logging/aggregation

## Expected Impact
- Data-driven optimization decisions
- Early detection of performance regressions
- Better understanding of user experience in production
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Telemetry events for HLS session lifecycle
- [ ] #2 Frontend tracks time-to-playback metric
- [ ] #3 Failure rate tracked by codec/container/browser
- [ ] #4 Dashboard shows key playback metrics
- [ ] #5 No performance impact from telemetry collection
<!-- AC:END -->
