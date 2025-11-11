---
id: task-171.3
title: Add filesystem path autocomplete for custom path input
status: Done
assignee: []
created_date: '2025-11-11 18:44'
updated_date: '2025-11-11 19:27'
labels:
  - ui-ux
  - import-media
  - enhancement
dependencies: []
parent_task_id: '171'
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Enhance the custom path input field with intelligent filesystem path autocomplete that suggests actual directories as the user types.

## Current State
Currently the custom path input has a basic HTML5 datalist that only shows configured library paths. This is helpful but limited.

## Goal
Implement real-time filesystem path autocomplete that:
- Suggests actual directories from the filesystem as the user types
- Shows parent directory contents when typing a path like `/mnt/`
- Handles common path patterns intelligently
- Provides a smooth, responsive autocomplete experience

## Technical Approach
- Add a phx-change event handler that triggers on input
- Use Elixir's File.ls/1 or Path module to list directories
- Return suggestions via socket assigns
- Display suggestions in a custom dropdown (not HTML5 datalist for better control)
- Debounce the input to avoid excessive filesystem calls
- Handle edge cases: permissions errors, non-existent paths, etc.

## Security Considerations
- Limit path traversal to prevent security issues
- Consider restricting to certain root paths if needed
- Handle permission errors gracefully

## UI/UX Notes
- Keep the interface compact and non-intrusive
- Show suggestions in a dropdown below the input
- Allow arrow key navigation and Enter to select
- Maintain the streamlined, compact design from task-171
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Typing a partial path shows real filesystem directory suggestions
- [x] #2 Suggestions update as user types with appropriate debouncing
- [x] #3 User can select a suggestion with mouse click or keyboard
- [x] #4 Permission errors and invalid paths are handled gracefully
- [x] #5 Autocomplete UI is compact and matches the streamlined design
- [x] #6 Performance is acceptable even for directories with many subdirectories
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Complete

### Backend Changes (lib/mydia_web/live/import_media_live/index.ex)

1. **Added Socket Assigns**: Added `path_suggestions` and `show_path_suggestions` to track autocomplete state

2. **Event Handlers**:
   - `autocomplete_path`: Handles input changes, calls `suggest_directories/1`, and updates suggestions
   - `select_path_suggestion`: Handles selecting a suggestion from the dropdown
   - `hide_path_suggestions`: Hides the suggestions dropdown

3. **Helper Functions**:
   - `suggest_directories/1`: Main logic to generate directory suggestions based on partial path
   - `parse_path_for_suggestions/1`: Parses input to determine which directory to list and what prefix to filter by
   - `list_directories_safe/1`: Safely lists directories with error handling for permissions and invalid paths

### Frontend Changes

#### Template (lib/mydia_web/live/import_media_live/index.html.heex)
- Replaced simple input with autocomplete-enabled input using:
  - `phx-change="autocomplete_path"` with 300ms debounce
  - `phx-blur="hide_path_suggestions"` to hide on focus loss
  - `phx-hook="PathAutocomplete"` for keyboard navigation
  - Conditional dropdown showing suggestions with folder icons
  - `phx-click-away` for hiding dropdown when clicking outside

#### JavaScript Hook (assets/js/app.js)
- Added `PathAutocomplete` hook with:
  - Arrow key navigation (Up/Down)
  - Enter key to select highlighted suggestion
  - Escape key to close dropdown
  - Visual highlighting of selected item
  - Auto-scroll selected item into view

### Features Implemented
1. Real-time filesystem path autocomplete
2. 300ms debouncing to prevent excessive filesystem calls
3. Keyboard navigation (arrow keys, Enter, Escape)
4. Mouse click selection
5. Graceful error handling for permissions and invalid paths
6. Limit to 10 suggestions for performance
7. Only shows directories (filters out files)
8. Compact UI matching streamlined design from task-171

### Security Considerations
- Uses Elixir's `File.ls/1` with error handling
- Filters results to only show directories
- Gracefully handles permission errors
- No path restrictions applied (assumes server filesystem access is controlled)

### Performance
- Debounced at 300ms to reduce filesystem calls
- Limits results to 10 suggestions
- Efficient path parsing and filtering
<!-- SECTION:NOTES:END -->
