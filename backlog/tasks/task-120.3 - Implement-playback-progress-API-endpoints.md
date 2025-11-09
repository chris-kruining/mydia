---
id: task-120.3
title: Implement playback progress API endpoints
status: Done
assignee: []
created_date: '2025-11-08 20:23'
updated_date: '2025-11-08 22:28'
labels: []
dependencies: []
parent_task_id: task-120
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create API endpoints to save and retrieve playback progress. These endpoints enable the frontend to persist watch position and retrieve it when users return to watch content.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 GET endpoint retrieves playback progress for a specific media file and current user
- [x] #2 POST endpoint saves playback progress with position, duration, and percentage
- [x] #3 Endpoint automatically marks content as watched when progress exceeds 90%
- [x] #4 Endpoint updates last_watched_at timestamp on each save
- [x] #5 Endpoints validate media_file_id exists and user has access
- [x] #6 Progress data includes all fields needed for player resumption
- [x] #7 API returns proper error responses for invalid requests
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

**Updated to use media_item_id/episode_id instead of media_file_id**

### API Routes
Add to router in authenticated API scope:
- `GET /api/v1/playback/movie/:media_item_id` - Get movie progress
- `GET /api/v1/playback/episode/:episode_id` - Get episode progress
- `POST /api/v1/playback/movie/:media_item_id` - Save movie progress
- `POST /api/v1/playback/episode/:episode_id` - Save episode progress

### Controller Implementation
Create: `lib/mydia_web/controllers/api/playback_controller.ex`

**Action: `show_movie/2` (GET /playback/movie/:id)**
1. Extract current_user from conn (set by auth pipeline)
2. Extract media_item_id from params
3. Verify media_item exists and is a movie
4. Call `Playback.get_progress(user.id, media_item_id: media_item_id)`
5. Return JSON with progress or defaults

**Action: `show_episode/2` (GET /playback/episode/:id)**
1. Extract current_user from conn
2. Extract episode_id from params
3. Verify episode exists
4. Call `Playback.get_progress(user.id, episode_id: episode_id)`
5. Return JSON with progress or defaults

**Action: `update_movie/2` (POST /playback/movie/:id)**
1. Extract current_user from conn
2. Extract media_item_id from params
3. Parse request body: `{position_seconds, duration_seconds}`
4. Verify media_item exists and is a movie
5. Call `Playback.save_progress(user.id, [media_item_id: id], attrs)`
6. Return JSON with updated progress

**Action: `update_episode/2` (POST /playback/episode/:id)**
1. Extract current_user from conn
2. Extract episode_id from params
3. Parse request body: `{position_seconds, duration_seconds}`
4. Verify episode exists
5. Call `Playback.save_progress(user.id, [episode_id: id], attrs)`
6. Return JSON with updated progress

### Request/Response Schema
**GET response:**
```json
{
  "position_seconds": 1250,
  "duration_seconds": 5400,
  "completion_percentage": 23.15,
  "watched": false,
  "last_watched_at": "2025-11-08T22:00:00Z"
}
```

**If no progress exists:**
```json
{
  "position_seconds": 0,
  "duration_seconds": null,
  "completion_percentage": 0,
  "watched": false
}
```

**POST request:**
```json
{
  "position_seconds": 1250,
  "duration_seconds": 5400
}
```

**POST response:** Same as GET response (returns updated progress)

### Error Handling
- 404 if media_item/episode doesn't exist
- 403 if user doesn't have access
- 422 if invalid data (negative position, zero duration, etc.)

### Testing
- Test getting progress for movie when none exists
- Test getting progress for episode when none exists
- Test getting existing progress
- Test saving new progress for movie
- Test saving new progress for episode
- Test updating existing progress
- Test automatic watched flag at 90%+
- Test switching between quality versions maintains progress
- Test authorization (user can only access their own progress)
- Test invalid data handling
<!-- SECTION:PLAN:END -->
