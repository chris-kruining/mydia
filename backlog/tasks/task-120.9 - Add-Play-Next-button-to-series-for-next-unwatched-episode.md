---
id: task-120.9
title: Add "Play Next" button to series for next unwatched episode
status: Done
assignee: []
created_date: '2025-11-09 04:30'
updated_date: '2025-11-09 04:37'
labels:
  - enhancement
  - ui
  - video-player
  - tv-shows
dependencies: []
parent_task_id: task-120
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a prominent "Play Next" or "Continue Watching" button on TV series detail pages that automatically plays the next unwatched episode. This provides a seamless watching experience similar to streaming services like Netflix and Plex.

The button should:
- Display on the series detail page (media show page for TV shows)
- Show "Continue Watching" if there's an in-progress episode
- Show "Play Next" if the last watched episode is completed
- Show "Start Watching" for series with no progress
- Navigate directly to the playback page for the appropriate episode
- Display episode information (S01E05, episode title, thumbnail)

This leverages the existing playback progress tracking (task-120) to determine which episode to play next.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Series detail page shows a prominent 'Play Next' button
- [x] #2 Button displays correct text based on watch state (Continue/Play Next/Start)
- [x] #3 Button shows next episode information (season, episode number, title, thumbnail)
- [x] #4 Clicking button navigates to playback page for the correct episode
- [x] #5 Logic correctly identifies next unwatched episode based on progress data
- [x] #6 Button is hidden if all episodes are watched
- [x] #7 Button works for series with multiple seasons
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### 1. Add Helper Function to Determine Next Episode

**Location**: `lib/mydia/playback.ex` or create new `lib/mydia/playback/next_episode.ex`

Add function to find the next unwatched episode for a series:

```elixir
def get_next_episode(media_item_id, user_id) do
  # Get all episodes for the series, ordered by season/episode number
  # Get all progress records for this user and series
  # Determine:
  #   - If there's an in-progress episode (< 90% watched), return that
  #   - Otherwise, find first unwatched episode
  #   - Return nil if all episodes watched
  # Return: {:continue, episode} | {:next, episode} | {:start, episode} | :all_watched
end
```

### 2. Update Media Show LiveView

**Location**: `lib/mydia_web/live/media_live/show.ex`

- Preload episodes with progress data when loading TV show
- Call `get_next_episode/2` to determine which episode to show
- Assign next episode data and button state to socket

### 3. Add "Play Next" Button Component

**Location**: `lib/mydia_web/live/media_live/show.html.heex`

Add prominent button near the top of the page (after poster/title):

```heex
<%= if @next_episode do %>
  <div class="card bg-gradient-to-r from-primary/20 to-secondary/20 shadow-lg mb-6">
    <div class="card-body">
      <div class="flex items-center gap-6">
        <!-- Episode thumbnail -->
        <figure class="w-40 h-24 rounded overflow-hidden bg-base-300 flex-shrink-0">
          <img src={get_episode_thumbnail(@next_episode)} />
        </figure>
        
        <!-- Episode info -->
        <div class="flex-1">
          <p class="text-sm text-base-content/70">
            {format_episode_number(@next_episode)}
          </p>
          <h3 class="text-lg font-semibold line-clamp-1">
            {@next_episode.title}
          </h3>
        </div>
        
        <!-- Play button -->
        <.link
          navigate={~p"/playback/episode/#{@next_episode.id}"}
          class="btn btn-primary btn-lg gap-2"
        >
          <.icon name="hero-play" class="w-6 h-6" />
          {@next_episode_button_text}
        </.link>
      </div>
    </div>
  </div>
<% end %>
```

### 4. Add Helper Functions

Add to the LiveView module:

```elixir
defp get_episode_thumbnail(episode) do
  # Extract from metadata or use placeholder
end

defp format_episode_number(episode) do
  "S#{String.pad_leading(to_string(episode.season_number), 2, "0")}E#{String.pad_leading(to_string(episode.episode_number), 2, "0")}"
end

defp next_episode_button_text(state) do
  case state do
    :continue -> "Continue Watching"
    :next -> "Play Next Episode"
    :start -> "Start Watching"
  end
end
```

### 5. Query Optimization

Ensure efficient loading:

```elixir
# In show.ex mount/3
import Ecto.Query

progress_query = from p in Playback.Progress, where: p.user_id == ^user_id

media_item = 
  Media.get_media_item!(id)
  |> Repo.preload([
    episodes: [:media_files, playback_progress: progress_query]
  ])
```

### 6. Edge Cases to Handle

- Series with no episodes yet
- Series with no available media files
- All episodes watched
- Episodes without air dates (order by season/episode number only)
- Episodes airing in the future

### Testing

- Test with series with no progress
- Test with partially watched episode
- Test with completed episodes
- Test with all episodes watched
- Test multi-season series
- Test episode ordering is correct
<!-- SECTION:PLAN:END -->
