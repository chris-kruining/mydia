---
id: task-120.2
title: Implement direct play streaming with HTTP range requests
status: Done
assignee: []
created_date: '2025-11-08 20:23'
updated_date: '2025-11-08 22:17'
labels: []
dependencies: []
parent_task_id: task-120
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create Phoenix API endpoint to stream browser-compatible video files using progressive download with HTTP 206 Partial Content support. This enables instant playback and seeking for files that don't require transcoding (e.g., MP4 with H.264 video and AAC audio).

This is the "direct play" path in the hybrid streaming architecture - when the browser can natively play the file format, we serve it directly without any processing.

**Technical approach:**
- Use Plug.Conn.send_file/4 for efficient file streaming
- Parse Range header from browser requests
- Return 206 Partial Content responses with proper headers
- Support Accept-Ranges, Content-Range, Content-Length headers
- Stream file chunks without loading entire file into memory
- Validate user authentication and file access permissions

**Note:** This endpoint is used when codec compatibility check determines direct play is possible. For incompatible files, the unified streaming endpoint will use HLS instead (task-120.5).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 GET /api/v1/stream/:media_file_id endpoint streams video files
- [x] #2 Endpoint supports HTTP Range requests and returns 206 Partial Content responses
- [x] #3 Endpoint validates user authentication and media file access permissions
- [x] #4 Endpoint returns appropriate Content-Type based on file extension (video/mp4, video/mkv, etc.)
- [x] #5 Endpoint handles missing or inaccessible files with 404 or 403 errors
- [x] #6 Endpoint includes Accept-Ranges: bytes header in responses
- [x] #7 Endpoint includes Content-Range and Content-Length headers for range requests
- [x] #8 Endpoint streams file efficiently without loading entire file into memory

- [x] #9 Endpoint handles malformed Range headers gracefully
- [x] #10 Browser video players can seek through videos using range requests
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### API Endpoint
Add route to router: `GET /api/v1/stream/:media_file_id`
- Place in authenticated API scope (requires JWT or API key)
- Create controller: `lib/mydia_web/controllers/api/stream_controller.ex`

### Controller Implementation
**Action: `stream/2`**
1. Load media_file from database with authentication check
2. Verify user has access (admin or appropriate role)
3. Verify file exists on disk
4. Parse Range header from request
5. Calculate byte ranges (start, end, content_length)
6. Set response headers:
   - Status: 206 Partial Content (or 200 for full file)
   - Accept-Ranges: bytes
   - Content-Type: video/mp4 (or appropriate MIME type)
   - Content-Range: bytes START-END/TOTAL
   - Content-Length: RANGE_SIZE
7. Stream file using `Plug.Conn.send_file/5` with offset and length
8. Handle edge cases:
   - No Range header → send full file (200)
   - Invalid Range → return 416 Range Not Satisfiable
   - Missing file → return 404
   - Unauthorized → return 403

### Range Request Handling
Create helper module: `lib/mydia_web/controllers/api/range_helper.ex`
- `parse_range_header(header, file_size)` - Parse "bytes=START-END"
- `calculate_ranges(start, end, file_size)` - Validate and normalize ranges
- `format_content_range(start, end, total)` - Create Content-Range header
- Handle multi-range requests (optional: initially support single range only)

### MIME Type Detection
- Determine Content-Type from file extension
- Support: .mp4, .mkv, .avi, .webm, .mov, .m4v
- Default to "video/mp4" if unknown

### Testing
- Test full file download (no Range header)
- Test single range request
- Test seek operations (multiple range requests)
- Test invalid ranges (416 response)
- Test missing files (404)
- Test unauthorized access (403)
- Test with real video files and browser video player
<!-- SECTION:PLAN:END -->
