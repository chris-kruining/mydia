---
id: task-123.5
title: 'Add TV show features (skip intro, skip credits, next episode)'
status: Done
assignee: []
created_date: '2025-11-09 01:50'
updated_date: '2025-11-09 02:50'
labels: []
dependencies: []
parent_task_id: '123'
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement TV show-specific player features that enhance binge-watching experience, similar to Netflix, Disney+, and Plex.

**Features:**
- Skip Intro button (appears during intro sequence)
- Skip Credits button (appears during end credits)
- Next Episode button (appears at end of episode)
- Auto-play next episode countdown (15 seconds)
- Episode navigation controls

**Skip Timing:**
- Intro timestamps stored in episode metadata (future: auto-detection)
- Credits start timestamp stored in episode metadata
- Skip buttons appear only during relevant time ranges
- Buttons positioned non-intrusively (top-right corner)

**Next Episode Flow:**
- Next episode button appears when &gt;90% watched or during credits
- Auto-play countdown starts when episode ends
- User can cancel auto-play
- Smooth transition to next episode playback page

**Technical:**
- Conditional rendering based on content_type (only for episodes)
- Check episode metadata for intro/credits timestamps
- TimeUpdate event monitoring for showing/hiding skip buttons
- Next episode detection via LiveView (fetch next episode ID)
- Countdown timer component
- Auto-navigate to next episode on countdown complete
- Phoenix navigation for episode switching
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Skip Intro button appears during intro sequence (based on metadata)
- [x] #2 Clicking Skip Intro seeks to end of intro timestamp
- [x] #3 Skip Credits button appears during end credits
- [x] #4 Clicking Skip Credits seeks to next episode or end
- [x] #5 Next Episode button appears when episode is &gt;90% complete
- [x] #6 Auto-play countdown (15 seconds) starts when episode ends
- [x] #7 Countdown displays time remaining until next episode
- [x] #8 User can cancel auto-play countdown
- [x] #9 Player auto-navigates to next episode when countdown reaches 0
- [x] #10 Skip buttons only appear for TV episodes (not movies)
- [x] #11 Skip buttons are positioned in top-right with smooth fade-in/out
- [x] #12 Next episode info displays thumbnail and title during countdown
<!-- AC:END -->
