---
id: task-124
title: Fix HLS pipeline configuration based on Membrane best practices
status: Done
assignee: []
created_date: '2025-11-09 03:01'
updated_date: '2025-11-09 03:05'
labels:
  - enhancement
  - streaming
  - hls
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
After researching Membrane Framework documentation and examples, several improvements were identified for the HLS transcoding pipeline:

1. **Mode Configuration**: Change from `:vod` to `:live` mode for on-demand transcoding
2. **Track Naming**: Add explicit track names ("video", "audio") for better debugging and manifest clarity
3. **Audio Decoding**: Add missing AAC decoder between parser and resampler (currently Parser → SWResample which will fail if audio isn't already decoded)
4. **Optional**: Consider `:muxed_av` vs `:separate_av` mode for different streaming scenarios

The current implementation is fundamentally correct (using SinkBin with FileStorage is the proper approach), but these tweaks will make it more robust and aligned with official Membrane examples (rtmp_to_hls, camera_to_hls, etc.).

Files affected:
- `lib/mydia/streaming/hls_pipeline.ex`
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 HLS SinkBin configured with mode: :live instead of default :vod
- [x] #2 Video and audio pads include track_name option for debugging
- [x] #3 Audio pipeline includes AAC.FDK.Decoder between parser and resampler
- [x] #4 Transcoding still works correctly for test media files
- [x] #5 Consider documenting when to use :muxed_av vs :separate_av hls_mode
<!-- AC:END -->
