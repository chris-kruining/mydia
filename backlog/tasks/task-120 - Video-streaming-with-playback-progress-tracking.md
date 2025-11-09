---
id: task-120
title: Video streaming with playback progress tracking
status: In Progress
assignee:
  - assistant
created_date: '2025-11-08 20:23'
updated_date: '2025-11-08 22:05'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Enable users to stream movies and TV shows directly from the application with persistent playback progress tracking using a hybrid streaming architecture. The system intelligently chooses between direct play (for browser-compatible files) and HLS adaptive streaming (for incompatible files or when quality adaptation is needed).

This unified approach provides the best user experience by:
- Instant playback for compatible files (direct play via HTTP range requests)
- Automatic transcoding for incompatible files (HLS via Membrane Framework)
- Adaptive quality for varying network conditions (HLS multi-bitrate)
- Cross-device progress synchronization

**Architecture:**
- Single streaming endpoint intelligently routes to direct play or HLS
- Phoenix/Plug handles HTTP serving for both modes
- Membrane Framework generates HLS segments in background when needed
- Frontend player supports both direct playback and HLS

This matches the architecture used by professional media servers like Plex and Jellyfin.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Users can play movies and TV episodes in the browser using a video player
- [ ] #2 Video streaming supports seek/scrubbing with HTTP range requests
- [ ] #3 Playback position is automatically saved every 10 seconds while watching
- [ ] #4 Users can resume watching from their last position when returning to a video
- [ ] #5 Playback progress is displayed on media item cards (e.g., 45% watched)
- [ ] #6 Videos marked as watched when user reaches 90% or higher of total duration
- [ ] #7 Playback progress syncs across devices for the same user
- [ ] #8 Player shows loading states and handles errors gracefully
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Overall Implementation Plan

This feature will be implemented in 7 phases across 8 sub-tasks:

### Phase 1: Foundation
- **Task 120.1** - Create playback_progress table and Ecto schema
- **Task 120.3** - Build API endpoints for saving/retrieving progress

### Phase 2: Simple Streaming  
- **Task 120.2** - Implement direct play with HTTP range requests (206 responses)

### Phase 3: Intelligent Routing
- **Task 120.6** - Build codec compatibility checker to determine streaming mode

### Phase 4: On-Demand HLS Transcoding
- **Task 120.7** - Implement ephemeral HLS transcoding with Membrane Framework
  - GenServer sessions manage active transcodes
  - Segments generated to /tmp/ and cleaned up after use
  - No disk storage or background jobs

### Phase 5: Unified Endpoint
- **Task 120.8** - Create unified streaming endpoint with intelligent routing
  - Routes to direct play or starts HLS session based on compatibility
  - Simple redirect flow, no polling needed

### Phase 6: Frontend Player
- **Task 120.4** - Build video player component with hls.js
  - Handles both direct play and HLS automatically
  - Integrates progress tracking

### Phase 7: UI Enhancements  
- **Task 120.5** - Add progress indicators to media cards

### Key Architecture Decisions
- **On-demand transcoding**: HLS segments generated only when needed, discarded after streaming
- **No persistent storage**: Temporary files in /tmp/ only
- **Session-based**: GenServer manages each active transcode session
- **Unified endpoint**: Single entry point determines optimal streaming method
- **Progressive enhancement**: Start with direct play, add HLS for incompatible files
<!-- SECTION:PLAN:END -->
