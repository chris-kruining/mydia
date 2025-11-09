---
id: task-127
title: Fix N+1 query issues in layouts and navigation
status: Done
assignee: []
created_date: '2025-11-09 04:03'
updated_date: '2025-11-09 04:13'
labels:
  - performance
  - database
  - n+1-queries
  - optimization
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Problem

The application is making redundant database queries on every page load, particularly in the layout component. These N+1 queries are causing unnecessary database load and slowing down page renders.

## Evidence from Logs

On every page render, the following queries are repeated:
```
[debug] QUERY OK source="media_items" db=0.2ms idle=16.0ms
SELECT count(*) FROM "media_items" AS m0 WHERE (m0."type" = 'tv_show') []
↳ MydiaWeb.Layouts."app (overridable 1)"/1, at: lib/mydia_web/components/layouts.ex:41

[debug] QUERY OK source="downloads" db=0.1ms idle=15.3ms
SELECT d0."id", ... FROM "downloads" AS d0 ORDER BY d0."inserted_at" DESC []
↳ Mydia.Downloads.list_downloads_with_status/1

[debug] QUERY OK source="download_client_configs" db=0.1ms idle=14.8ms
SELECT d0."id", ... FROM "download_client_configs" AS d0 ORDER BY d0."enabled" DESC
↳ Mydia.Settings.list_download_client_configs/1
```

## Impact

- **Performance**: Multiple redundant queries on every page load
- **Database load**: Unnecessary database connections and queries
- **Scalability**: Will get worse as data grows
- **User experience**: Slower page loads

## Root Cause

The layout component (`lib/mydia_web/components/layouts.ex:41`) is making database queries directly instead of:
1. Receiving data from assigns
2. Using caching
3. Loading data once per session

## Solution Approaches

1. **Pass data through assigns**: Load data in the LiveView mount and pass to layout
2. **Use ETS caching**: Cache counts and configurations that don't change often
3. **Use LiveView assign_async**: For data that can load asynchronously
4. **Optimize queries**: Use database-level caching or materialized views for counts

## Files to Investigate

- `lib/mydia_web/components/layouts.ex` (line 41)
- `lib/mydia/downloads.ex` (list_downloads_with_status/1)
- `lib/mydia/settings.ex` (list_download_client_configs/1)
- Layout rendering pipeline

## Recommended Fix

1. Remove queries from layout component
2. Load necessary data in root LiveView or plug
3. Cache static/semi-static data (download client configs)
4. Use counters or aggregates for counts instead of full SELECT COUNT(*)
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Solution Implemented

Fixed the N+1 query issues in layouts and navigation by implementing a centralized data loading approach using LiveView on_mount hooks.

### Changes Made

1. **Created `load_navigation_data` on_mount hook** (`lib/mydia_web/live/user_auth.ex`)
   - Loads navigation counts (movies, TV shows, downloads) once per LiveView mount
   - Assigns the data to the LiveView socket

2. **Updated router** (`lib/mydia_web/router.ex`)
   - Added `:load_navigation_data` hook to both `:authenticated` and `:admin` live_sessions
   - Ensures navigation data is loaded for all authenticated routes

3. **Updated layout component** (`lib/mydia_web/components/layouts.ex`)
   - Added `movie_count`, `tv_show_count`, and `downloads_count` as attributes
   - Removed fallback database queries from the layout component
   - Now receives navigation counts as explicit parameters

4. **Updated all LiveView templates**
   - Modified all `<Layouts.app>` calls to pass navigation counts from socket assigns
   - Ensures data flows from on_mount → LiveView socket → layout component

### How It Works

**Before (N+1 queries):**
- Layout component made database queries on every render
- Queries ran multiple times per page load
- No caching or optimization

**After (optimized):**
1. User navigates to any authenticated page
2. `on_mount :load_navigation_data` runs once, loading counts from database
3. Counts are stored in LiveView socket assigns
4. LiveView template passes counts to layout component
5. Layout uses the provided counts without making additional queries

### Benefits

- **Performance**: Database queries reduced from multiple per page to once per mount
- **Scalability**: Eliminates redundant queries as data grows
- **Maintainability**: Centralized data loading logic
- **Consistency**: All pages use the same data loading pattern

### Testing

- Compilation successful with no errors
- Code formatted according to project standards
- All LiveView templates updated consistently
<!-- SECTION:NOTES:END -->
