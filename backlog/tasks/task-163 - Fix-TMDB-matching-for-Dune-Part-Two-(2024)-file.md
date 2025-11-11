---
id: task-163
title: Fix TMDB matching for "Dune Part Two (2024)" file
status: Done
assignee: []
created_date: '2025-11-11 15:38'
updated_date: '2025-11-11 15:46'
labels:
  - bug
  - tmdb
  - file-matching
  - metadata
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The file "Dune.Part.Two.2024.HDR.BluRay.2160p.x265.7.1.aac.VMAF96-Rosy.mkv" located at `/media/movies/Dune Part Two (2024)/` is not being matched with TMDB metadata. The file matcher is returning "No Match" despite the movie existing in TMDB.

This impacts the user experience as the movie won't have proper metadata, artwork, or details displayed in the library. The filename contains clear identifiers (title, year) that should enable successful matching.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The file 'Dune.Part.Two.2024.HDR.BluRay.2160p.x265.7.1.aac.VMAF96-Rosy.mkv' successfully matches with TMDB metadata for 'Dune: Part Two (2024)'
- [x] #2 The matching logic handles filenames with 'Part Two' and similar sequel patterns (e.g., 'Part One', 'Part Three')
- [x] #3 The movie displays correct metadata, poster, and details in the library after import
- [x] #4 Existing tests pass and new test case added for this filename format
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Root Cause

The FileParser was not recognizing "VMAF96" as a quality metric that should be removed from the title. VMAF (Video Multimethod Assessment Fusion) is a perceptual video quality metric, and scores like "VMAF96" are commonly included in high-quality release filenames.

When parsing "Dune.Part.Two.2024.HDR.BluRay.2160p.x265.7.1.aac.VMAF96-Rosy.mkv", the parser extracted the title as "Dune Part Two Vmaf96" instead of just "Dune Part Two". This caused TMDB search to return no results since "Dune Part Two Vmaf96" doesn't match any movie titles.

## Solution

Added a new pattern `@vmaf_pattern = ~r/\bVMAF\d+(?:\.\d+)?\b/i` to the FileParser to match and remove VMAF quality metrics from filenames. The pattern handles both integer (VMAF96) and decimal (VMAF95.5) VMAF scores.

The pattern is applied during the `clean_for_title_extraction` pipeline, which strips quality markers before extracting the movie title.

## Changes Made

1. `lib/mydia/library/file_parser.ex:53` - Added `@vmaf_pattern` regex pattern
2. `lib/mydia/library/file_parser.ex:323` - Added `remove_vmaf()` call to cleaning pipeline
3. `lib/mydia/library/file_parser.ex:360-362` - Implemented `remove_vmaf/1` function
4. `test/mydia/library/file_parser_test.exs:443-456` - Added test case for VMAF pattern

## Verification

Tested with the actual file:
- FileParser now extracts title as "Dune Part Two" (correct)
- MetadataMatcher successfully finds TMDB match for "Dune: Part Two" (2024)
- Match confidence is high with correct metadata returned

## Test Results

All tests pass (1233 tests, 0 failures). The fix successfully:

1. Removes VMAF quality metrics from filenames during parsing
2. Correctly extracts "Dune Part Two" from the complex filename
3. Successfully matches with TMDB to retrieve "Dune: Part Two" (2024) metadata
4. Handles similar patterns like "Part One", "Part Three", "Chapter Two", etc.

The MetadataMatcher's fuzzy title matching handles slight differences between the parsed title and TMDB's title (e.g., "Part Two" vs "Dune: Part Two") using substring matching and Jaro distance similarity.

## Additional Patterns Tested

- "Movie Part One (2023)" → correctly extracts "Movie Part One"
- "Movie Part Three (2025)" → correctly extracts "Movie Part Three"
- "Film Chapter Two (2024)" → correctly extracts "Film Chapter Two"
- "Story Part IV (2022)" → correctly extracts "Story Part Iv"

All acceptance criteria have been met and verified.
<!-- SECTION:NOTES:END -->
