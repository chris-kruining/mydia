---
id: task-125.2
title: Fix video player UI layout and icon toggling issues
status: Done
assignee: []
created_date: '2025-11-09 04:33'
updated_date: '2025-11-09 04:38'
labels:
  - bug
  - frontend
  - ui
  - video-player
dependencies: []
parent_task_id: task-125
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The video player has several visual issues that make it look unprofessional:

## Issues

1. **White bar below video** - There's an unwanted white bar appearing below the video element
2. **Video not vertically centered** - The video is not properly centered in its container
3. **Icon toggling broken** - All toggle icons (play/pause, mute/unmute, fullscreen/exit-fullscreen) show at the same time instead of toggling between states

## Root Cause Investigation

The icon toggling issue is likely caused by:
- `x-show` directives not working properly on icon elements
- Icons need `style="display: none"` inline for proper hiding
- Alpine may not be controlling icon visibility correctly

The layout issues may be caused by:
- Incorrect flexbox/grid settings on video container
- Missing height constraints
- Incorrect aspect ratio handling

## Proposed Solutions

**For icon toggling:**
- Add inline `style="display: none"` to icons that should start hidden (pause, muted, exit-fullscreen)
- Verify Alpine is properly controlling these icon elements
- Consider restructuring icons to use conditional rendering instead of x-show

**For layout issues:**
- Review video container flex/grid properties
- Ensure proper centering with `items-center justify-center`
- Check for unwanted margins/padding creating white bars
- Verify video element has proper sizing constraints

## Files to Check

- `lib/mydia_web/components/core_components.ex` - video_player component (lines 526-914)
- `assets/js/alpine_components/video_player.js` - Alpine state management
- `assets/css/app.css` - Check for conflicting styles
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Video is properly vertically centered in its container
- [x] #2 No white bar or unwanted spacing below video
- [x] #3 Only one icon shows at a time for toggle pairs (play OR pause, mute OR unmute, fullscreen OR exit-fullscreen)
- [x] #4 Video maintains proper aspect ratio and fills available space
- [x] #5 All UI elements are visually polished and professional looking
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Summary

Fixed the video player UI layout and icon toggling issues:

### Changes Made

1. **Added global attributes support to icon component** (`core_components.ex:415`)
   - Added `attr :rest, :global` to allow Alpine.js directives on icons
   - Updated template to `<span {@rest} class={[@name, @class]} />`

2. **Fixed icon toggling** (`core_components.ex:598-778`)
   - Applied `x-show` directives to toggle icon visibility based on state
   - Added `x-cloak` to icons that start hidden (pause, muted, exit-fullscreen)
   - Removed conflicting inline `style="display: none"` that prevented Alpine from controlling visibility
   - Icons now properly toggle: only play OR pause shows, only mute OR unmute shows, etc.

3. **Fixed video layout** (`core_components.ex:538`)
   - Changed container background from `bg-base-300` to `bg-black` (eliminates white bar)
   - Added `flex items-center justify-center` to container for proper vertical centering
   - Added `object-contain` to video element for proper aspect ratio handling

### How It Works

- **Icon toggling**: Alpine's `x-show` directive controls visibility dynamically
- **FOUC prevention**: `x-cloak` + CSS (`[x-cloak] { display: none !important; }`) hides elements until Alpine initializes
- **Video centering**: Flexbox centers video vertically in its container
- **Background**: Black background matches video, no visible gaps

### Files Modified

- `lib/mydia_web/components/core_components.ex`
<!-- SECTION:NOTES:END -->
