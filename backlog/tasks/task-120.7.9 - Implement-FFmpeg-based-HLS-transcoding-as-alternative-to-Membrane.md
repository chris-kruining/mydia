---
id: task-120.7.9
title: Implement FFmpeg-based HLS transcoding as alternative to Membrane
status: Done
assignee: []
created_date: '2025-11-09 03:40'
updated_date: '2025-11-09 03:47'
labels:
  - enhancement
  - hls
  - transcoding
  - ffmpeg
dependencies: []
parent_task_id: task-120.7
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Problem

The Membrane Framework implementation (task-120.7.x) has proven to have significant limitations:

1. **Limited codec support**: `membrane_matroska_plugin` only supports H264/HEVC/VP8/VP9 video and AAC/Opus audio. Rejects common codecs like EAC3, DTS, TrueHD, AC3, etc.
2. **Parser bugs**: Crashes on date parsing and other metadata issues in real-world MKV files
3. **Immature ecosystem**: Matroska plugin is not production-ready for diverse media files
4. **Complexity**: Requires managing complex pipeline state and dynamic pad linking

## Solution

Implement an alternative HLS transcoding backend using FFmpeg directly, which:

- Supports virtually all codecs out of the box
- Is battle-tested and production-ready
- Simpler implementation (single FFmpeg command vs complex pipeline)
- Already used in the project for other media operations

## Technical Approach

Use System.cmd/3 or Rambo to execute FFmpeg with HLS output:

```elixir
defmodule Mydia.Streaming.FfmpegHlsTranscoder do
  def transcode(input_path, output_dir, opts \\ []) do
    args = [
      "-i", input_path,
      # Video transcoding
      "-c:v", "libx264",
      "-preset", "medium",
      "-profile:v", "high",
      "-s", "1280x720",
      "-g", "60",
      "-bf", "0",
      # Audio transcoding
      "-c:a", "aac",
      "-b:a", "128k",
      "-ar", "48000",
      "-ac", "2",
      # HLS output
      "-f", "hls",
      "-hls_time", "6",
      "-hls_playlist_type", "event",
      "-hls_segment_filename", Path.join(output_dir, "segment_%03d.ts"),
      "-master_pl_name", "master.m3u8",
      Path.join(output_dir, "playlist.m3u8")
    ]
    
    System.cmd("ffmpeg", args, stderr_to_stdout: true)
  end
end
```

## Implementation Tasks

1. Create `Mydia.Streaming.FfmpegHlsTranscoder` module
2. Add configuration option to choose between Membrane and FFmpeg backends
3. Update `HlsSession` to support both backends
4. Handle FFmpeg process monitoring and progress tracking
5. Add graceful degradation: try Membrane first, fall back to FFmpeg on error
6. Test with diverse media files (various codecs, containers, etc.)

## Benefits

- **Universal codec support**: Works with any format FFmpeg supports
- **Proven reliability**: FFmpeg is industry standard
- **Simpler codebase**: No complex pipeline management
- **Better error handling**: FFmpeg provides clear error messages
- **Progress tracking**: Can parse FFmpeg output for progress updates

## Tradeoffs

- **Less granular control**: Can't customize each pipeline element
- **External dependency**: Requires FFmpeg binary installed
- **Process overhead**: Spawning external process vs in-process pipeline
- **Less "Elixir-native"**: Not using OTP/BEAM features as much

## Recommendation

Implement both backends and make FFmpeg the **default** with Membrane as an **experimental option**. This provides the best user experience while keeping the door open for future Membrane improvements.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 FFmpeg-based HLS transcoder module implemented
- [x] #2 Supports all common video/audio codecs (H264, HEVC, VP9, AAC, EAC3, DTS, etc.)
- [x] #3 Generates compatible HLS output with segments and playlists
- [x] #4 Handles transcoding errors gracefully with clear messages
- [x] #5 Progress tracking implemented (optional but nice)
- [x] #6 Configuration option to choose Membrane vs FFmpeg backend
- [x] #7 Tests verify transcoding works with diverse media files
- [x] #8 Documentation explains when to use each backend
<!-- AC:END -->
