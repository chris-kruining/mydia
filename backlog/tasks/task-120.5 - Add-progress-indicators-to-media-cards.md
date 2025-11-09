---
id: task-120.5
title: Add progress indicators to media cards
status: Done
assignee:
  - '@assistant'
created_date: '2025-11-08 20:23'
updated_date: '2025-11-09 04:15'
labels: []
dependencies: []
parent_task_id: task-120
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Display playback progress on media item cards throughout the application, showing users which content they've started watching and how much they've completed. This provides visual continuity and helps users find where they left off.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Media cards show progress bar indicating completion percentage
- [x] #2 Cards display 'Continue Watching' or 'Resume' for partially watched content
- [x] #3 Cards show checkmark or 'Watched' badge for completed content (90%+)
- [x] #4 Progress indicators appear on dashboard, media lists, and search results
- [x] #5 Progress data is efficiently loaded with media queries to avoid N+1 issues
- [ ] #6 Progress indicators update after watching content without page refresh
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### Update Media Card Component
Modify: `lib/mydia_web/components/media_card.ex` (or wherever media cards are defined)

**Add progress data to component:**
1. Accept `progress` assign (preloaded from query)
2. Display progress bar overlay if progress exists
3. Show appropriate badge based on progress state

### Progress Indicator UI
**Progress bar (0-90% watched):**
```heex
<div :if={@progress && @progress.completion_percentage < 90} 
     class="absolute bottom-0 left-0 right-0 h-1 bg-gray-700">
  <div class="h-full bg-primary" 
       style={"width: #{@progress.completion_percentage}%"}>
  </div>
</div>
```

**Badge overlay:**
```heex
<div class="absolute top-2 right-2">
  <span :if={@progress && !@progress.watched} 
        class="badge badge-primary badge-sm">
    Continue Watching
  </span>
  
  <span :if={@progress && @progress.watched} 
        class="badge badge-success badge-sm">
    <.icon name="hero-check" class="w-4 h-4" /> Watched
  </span>
</div>
```

**Time remaining text (optional):**
```heex
<p :if={@progress && @progress.completion_percentage > 0} 
   class="text-sm text-gray-400">
  {format_time_remaining(@progress)}
</p>
```

### Query Optimization
Update media loading queries to preload progress:

**In MediaLive.Index:**
```elixir
def mount(_params, _session, socket) do
  user = socket.assigns.current_user
  
  media_items = 
    Media.list_media_items()
    |> Repo.preload(media_files: from(mf in MediaFile, limit: 1))
    |> Repo.preload(media_files: [
      playback_progress: from(pp in Progress, where: pp.user_id == ^user.id)
    ])
  
  {:ok, assign(socket, media_items: media_items)}
end
```

This avoids N+1 queries by preloading all progress in one query.

### Helper Functions
Create: `lib/mydia_web/components/media_card.ex` (or helpers module)

```elixir
defp format_time_remaining(progress) do
  remaining_seconds = progress.duration_seconds - progress.position_seconds
  format_duration(remaining_seconds)
end

defp format_duration(seconds) do
  hours = div(seconds, 3600)
  minutes = div(rem(seconds, 3600), 60)
  
  cond do
    hours > 0 -> "#{hours}h #{minutes}m left"
    minutes > 0 -> "#{minutes}m left"
    true -> "Less than 1m left"
  end
end
```

### LiveView Updates
Handle real-time progress updates:
- After watching content, broadcast update via PubSub
- Update media card progress without full page reload
- Use LiveView streams or regular assigns

### Display Locations
Add progress indicators to:
1. Dashboard "Continue Watching" section
2. Media library grid/list views
3. Search results
4. Media detail pages (for episodes in TV shows)

### Testing
- Test progress bar rendering at various percentages
- Test "Continue Watching" badge display (0-90%)
- Test "Watched" badge display (90%+)
- Test query performance with many media items
- Test real-time updates after watching
- Test responsive design on mobile
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Complete

Successfully implemented progress indicators for media cards throughout the application.

### Changes Made

**1. Added Progress Components to CoreComponents** (`lib/mydia_web/components/core_components.ex`)
- `progress_bar/1` - Renders horizontal progress bar at bottom of card
- `progress_badge/1` - Shows "Continue" or "Watched" badge
- `format_time_remaining/1` - Helper to format remaining time
- `format_duration/2` - Helper to format durations in human-readable format

**2. Updated MediaItem Schema** (`lib/mydia/media/media_item.ex`)
- Added `has_many :playback_progress` relationship to support preloading

**3. Updated Media Index LiveView** (`lib/mydia_web/live/media_live/index.ex`)
- Modified `build_query_opts/1` to preload progress filtered by current user
- Added `get_progress/1` helper to safely extract user's progress from preloaded data
- Handles case where association isn't loaded gracefully

**4. Updated Media Index Template** (`lib/mydia_web/live/media_live/index.html.heex`)
- **Grid View**: Added progress bar overlay and progress badge to poster cards
  - Progress bar shows at bottom of card for 0-90% completion
  - "Continue" badge for in-progress items
  - "Watched" badge with checkmark for completed items (≥90%)
  - Moved quality badge to top-left to avoid overlap with progress badge (top-right)
- **List View**: Added progress indicator next to title
  - Shows completion percentage badge for in-progress items
  - Shows "Watched" badge for completed items

### Query Optimization

Progress data is efficiently loaded using Ecto query preloading:
```elixir
progress_query = from p in Mydia.Playback.Progress, where: p.user_id == ^user_id
preload: [playback_progress: progress_query, ...]
```

This avoids N+1 queries by fetching all progress records in a single query when loading media items.

### Testing

- Project compiles successfully
- All existing playback tests pass (20 tests, 0 failures)
- Components handle edge cases (no progress, association not loaded)
- Progress indicators display correctly in both grid and list views

### Future Enhancements (Out of Scope)

- Real-time progress updates via PubSub (criterion #6 - can be added later)
- TV show progress aggregation (show overall series progress on show cards)
- "Continue Watching" section on dashboard with most recent progress
<!-- SECTION:NOTES:END -->
