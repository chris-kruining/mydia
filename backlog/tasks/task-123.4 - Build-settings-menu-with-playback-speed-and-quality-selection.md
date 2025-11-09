---
id: task-123.4
title: Build settings menu with playback speed and quality selection
status: Done
assignee: []
created_date: '2025-11-09 01:50'
updated_date: '2025-11-09 02:24'
labels: []
dependencies: []
parent_task_id: '123'
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add an advanced settings menu to the video player with playback speed control and quality/stream selection options, similar to YouTube and Netflix.

**Settings Menu Features:**
- Playback speed control (0.25x, 0.5x, 0.75x, Normal, 1.25x, 1.5x, 1.75x, 2x)
- Quality/stream selection (when multiple streams available)
- Subtitle/caption selection (future-ready)
- Auto quality toggle (for HLS adaptive streaming)

**UI/UX:**
- Settings icon (gear) button in control bar
- Popup menu appears above settings button
- Nested menus for each setting category
- Current selection indicated with checkmark
- Click outside to close
- Smooth animations for menu open/close

**Technical:**
- Settings button in control bar triggers menu
- Playback rate API: `video.playbackRate = 1.5`
- Quality selection switches between available streams/renditions
- HLS quality level selection via hls.js API
- Menu state management in hook
- Persist playback speed preference to localStorage
- DaisyUI dropdown/modal components
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Settings button (gear icon) appears in control bar
- [x] #2 Clicking settings opens menu with smooth animation
- [x] #3 Playback speed menu shows all speed options (0.25x to 2x)
- [x] #4 Selecting speed changes video playback rate immediately
- [x] #5 Current speed is indicated with checkmark in menu
- [x] #6 Playback speed preference persists across sessions
- [x] #7 Quality menu shows available stream options when applicable
- [x] #8 HLS quality selection works with adaptive streaming
- [x] #9 Auto quality option toggles HLS automatic level selection
- [x] #10 Clicking outside settings menu closes it
- [x] #11 Menu appears positioned above settings button
- [x] #12 Menu uses DaisyUI styling for consistency
<!-- AC:END -->
