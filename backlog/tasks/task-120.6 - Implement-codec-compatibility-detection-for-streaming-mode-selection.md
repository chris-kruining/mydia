---
id: task-120.6
title: Implement codec compatibility detection for streaming mode selection
status: Done
assignee: []
created_date: '2025-11-08 21:38'
updated_date: '2025-11-08 22:32'
labels: []
dependencies: []
parent_task_id: task-120
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add logic to analyze media files and determine the optimal streaming mode: direct play (browser can handle natively) or HLS transcoding (requires processing). This decision engine is the core of the hybrid streaming architecture.

The system should detect video codec, audio codec, and container format, then determine browser compatibility based on modern web standards (Chrome, Firefox, Safari, Edge).

**Technical approach:**
- Analyze media file metadata using FFprobe or similar
- Store codec information in media_files table during library scanning
- Create compatibility checker module with browser compatibility matrix
- Return streaming decision: :direct_play, :needs_hls, or :hls_available

**Browser Compatibility Rules:**
- **Direct Play**: MP4/WebM container + (H.264/VP9/AV1 video) + (AAC/Opus audio)
- **Needs HLS**: MKV, AVI, or incompatible codecs (HEVC, VP8, DivX, etc.)
- **Consider**: HDR formats may need transcoding for tone mapping

**Integration point:** Called by unified streaming endpoint (task-120.5) to route requests.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Module analyzes video codec, audio codec, and container format
- [ ] #2 Compatibility checker correctly identifies browser-playable formats (H.264/AAC in MP4)
- [ ] #3 Checker correctly identifies formats needing transcoding (HEVC, MKV, AVI, etc.)
- [ ] #4 Media file metadata includes codec info populated during library scan
- [ ] #5 Function returns clear decision: direct_play, needs_hls, or hls_available
- [ ] #6 Compatibility matrix covers Chrome, Firefox, Safari, and Edge
- [ ] #7 System handles unknown codecs gracefully (defaults to needs transcoding)
- [ ] #8 Documentation explains browser compatibility decisions
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### Codec Information Storage
Media files table already has `codec` and `audio_codec` fields. Verify these are populated during library scanning. May need to add:
- `container_format` field (mp4, mkv, avi, webm)
- `video_codec_profile` field (baseline, main, high for H.264)

Update library scanning to extract this metadata using FFprobe.

### Compatibility Checker Module
Create: `lib/mydia/streaming/compatibility.ex`

**Main function:**
```elixir
@spec check_compatibility(MediaFile.t()) :: 
  :direct_play | :needs_transcoding

def check_compatibility(media_file) do
  container = get_container_format(media_file)
  video_codec = media_file.codec
  audio_codec = media_file.audio_codec
  
  if browser_compatible?(container, video_codec, audio_codec) do
    :direct_play
  else
    :needs_transcoding
  end
end
```

**Browser Compatibility Matrix:**

Direct play compatible:
- **Containers:** MP4, WebM
- **Video codecs:** H.264 (all profiles), VP9, AV1
- **Audio codecs:** AAC, MP3, Opus, Vorbis

Needs transcoding:
- **Containers:** MKV, AVI, MOV, M4V, FLV, WMV
- **Video codecs:** HEVC/H.265, VP8, DivX, Xvid, MPEG-2, VC-1
- **Audio codecs:** AC3, DTS, FLAC, TrueHD

**Implementation:**
```elixir
defp browser_compatible?(container, video_codec, audio_codec) do
  compatible_containers = ~w(mp4 webm)
  compatible_video = ~w(h264 vp9 av1)
  compatible_audio = ~w(aac mp3 opus vorbis)
  
  String.downcase(container || "") in compatible_containers and
  String.downcase(video_codec || "") in compatible_video and
  String.downcase(audio_codec || "") in compatible_audio
end

defp get_container_format(media_file) do
  # If stored in metadata
  media_file.metadata["container"] ||
  # Or extract from file extension
  Path.extname(media_file.path) |> String.trim_leading(".")
end
```

### FFprobe Integration
Create: `lib/mydia/media_inspector.ex` (or update existing)

**Extract codec information:**
```elixir
def inspect_file(path) do
  case System.cmd("ffprobe", [
    "-v", "quiet",
    "-print_format", "json",
    "-show_format",
    "-show_streams",
    path
  ]) do
    {output, 0} ->
      json = Jason.decode!(output)
      extract_codec_info(json)
    
    _ ->
      {:error, :ffprobe_failed}
  end
end

defp extract_codec_info(json) do
  video_stream = find_stream(json, "video")
  audio_stream = find_stream(json, "audio")
  
  %{
    container: json["format"]["format_name"],
    video_codec: video_stream["codec_name"],
    video_codec_profile: video_stream["profile"],
    audio_codec: audio_stream["codec_name"],
    audio_channels: audio_stream["channels"],
    duration: json["format"]["duration"],
    bitrate: json["format"]["bit_rate"]
  }
end
```

### Library Scanning Integration
Update media file creation to populate codec metadata:
- Run FFprobe during library scan
- Store results in media_files table
- Update existing media files with missing codec info (migration or background job)

### Testing
- Test detection of compatible formats (H.264 + AAC in MP4)
- Test detection of incompatible containers (MKV)
- Test detection of incompatible codecs (HEVC, DTS)
- Test edge cases (missing codec info, unknown codecs)
- Test with real video files of various formats
- Verify FFprobe integration works correctly
- Default to :needs_transcoding for unknown/missing info (safe fallback)
<!-- SECTION:PLAN:END -->
