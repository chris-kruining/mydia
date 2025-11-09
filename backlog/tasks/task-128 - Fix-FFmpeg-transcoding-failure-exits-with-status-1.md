---
id: task-128
title: Fix FFmpeg transcoding failure - exits with status 1
status: To Do
assignee: []
created_date: '2025-11-09 04:04'
labels:
  - bug
  - critical
  - ffmpeg
  - transcoding
  - hls
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Problem

FFmpeg HLS transcoding is failing with exit status 1, preventing videos from being transcoded and played.

## Evidence from Logs

```
[info] Starting FFmpeg HLS transcoding: /media/movies/The Matrix (1999)/The Matrix 1999 1080p Bluray OPUS 7 1 AV1-WhiskeyJack.mkv
[debug] FFmpeg args: ["-i", "/media/movies/The Matrix (1999)/The Matrix 1999 1080p Bluray OPUS 7 1 AV1-WhiskeyJack.mkv", "-c:v", "libx264", "-preset", "medium", "-crf", "23", "-profile:v", "high", "-s", "1280x720", "-g", "60", "-bf", "0", "-c:a", "aac", "-b:a", "128k", "-ar", "48000", "-ac", "2", "-f", "hls", "-hls_time", "6", "-hls_playlist_type", "event", "-hls_segment_filename", "/tmp/mydia-hls/bee85dc2-19bc-4457-8790-4e660d03592b/segment_.ts", "-progress", "pipe:1", "-loglevel", "info", "/tmp/mydia-hls/bee85dc2-19bc-4457-8790-4e660d03592b/index.m3u8"]
[error] FFmpeg exited with status 1
[error] FFmpeg transcoding error for /media/movies/The Matrix (1999)/The Matrix 1999 1080p Bluray OPUS 7 1 AV1-WhiskeyJack.mkv: FFmpeg exited with status 1
```

## Impact

- **Critical**: Videos cannot be transcoded for playback
- **User experience**: Users see 404 errors when trying to play incompatible video formats
- **Feature broken**: HLS transcoding completely non-functional

## Potential Causes

1. **Incorrect segment filename pattern**: The pattern `segment_.ts` is invalid - should be `segment_%03d.ts`
2. **FFmpeg command syntax error**: Malformed arguments being passed to FFmpeg
3. **Missing FFmpeg binary**: FFmpeg might not be installed in the container
4. **Codec compatibility**: FFmpeg might not support the input codecs (AV1, Opus 7.1)
5. **File path issues**: Spaces or special characters in file path not properly escaped

## Investigation Steps

1. Check the segment filename pattern in `lib/mydia/streaming/ffmpeg_hls_transcoder.ex`
2. Run FFmpeg command manually in container to see actual error message
3. Verify FFmpeg is installed and has required codec support
4. Check FFmpeg error output (currently not being captured properly)
5. Test with different video files to isolate the issue

## Files Involved

- `lib/mydia/streaming/ffmpeg_hls_transcoder.ex` - FFmpeg command builder
- `lib/mydia/streaming/hls_session.ex` - Backend initialization

## Expected Behavior

FFmpeg should:
1. Successfully transcode the video to H.264/AAC
2. Generate HLS segments (segment_000.ts, segment_001.ts, etc.)
3. Create index.m3u8 playlist
4. Allow video playback through HLS.js

## Additional Notes

The segment filename pattern appears suspicious: `segment_.ts` instead of `segment_%03d.ts`
<!-- SECTION:DESCRIPTION:END -->
