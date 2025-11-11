---
id: task-165
title: Fix TMDB matching for "Black Phone 2 (2025)" file
status: In Progress
assignee: []
created_date: '2025-11-11 16:33'
updated_date: '2025-11-11 16:34'
labels:
  - bug
  - tmdb
  - file-matching
  - metadata
  - audio-codec
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The file "Black Phone 2. 2025 1080P WEB-DL DDP5.1 Atmos. X265. POOLTED.mkv" located at `/media/movies/Black Phone 2 (2025)/` is not being matched with TMDB metadata. The file matcher is returning "No Match" despite the movie existing in TMDB as "Black Phone 2 (2025)" [ID: 1197137].

**Root Cause:**
The FileParser extracts the title as "Black Phone 2 Ddp5 1 Poolted" instead of "Black Phone 2" because:
1. "DDP5.1" audio codec is not recognized - dots are normalized to spaces ("DDP5 1"), and "DDP5.1" is not in the @audio_codecs list (only "DD5.1" and "DD+" are listed)
2. "POOLTED" appears to be a release group but lacks the standard hyphen prefix (should be "-POOLTED"), so it's not removed from the title

**Expected Behavior:**
- FileParser should extract: "Black Phone 2"
- MetadataMatcher should find: "Black Phone 2 (2025)" [TMDB ID: 1197137]

This impacts user experience as the movie won't have proper metadata, artwork, or details displayed in the library.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The file 'Black Phone 2. 2025 1080P WEB-DL DDP5.1 Atmos. X265. POOLTED.mkv' successfully matches with TMDB metadata for 'Black Phone 2 (2025)'
- [ ] #2 The FileParser correctly recognizes and removes DDP5.1 audio codec patterns from filenames
- [ ] #3 The FileParser handles release groups without hyphen prefixes (or documents that this is intentional behavior)
- [ ] #4 The movie displays correct metadata, poster, and details in the library after import
- [ ] #5 Existing tests pass and new test case added for DDP5.1 audio codec pattern
<!-- AC:END -->
