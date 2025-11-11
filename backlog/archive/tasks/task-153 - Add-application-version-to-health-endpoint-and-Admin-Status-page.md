---
id: task-153
title: Add application version to /health endpoint and Admin Status page
status: Done
assignee: []
created_date: '2025-11-10 21:52'
updated_date: '2025-11-10 22:04'
labels:
  - enhancement
  - monitoring
  - ui
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Currently there's no way for users to see which version of the app they're running. Add version information to:

1. `/health` endpoint - Include app version in JSON response using `Application.spec(:mydia, :vsn)`
2. Admin Status page - Add app version to system info section in `AdminStatusLive.Index`

This will help with troubleshooting, monitoring, and ensuring users are running the correct version.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 GET /health returns JSON with version field
- [x] #2 Admin Status page displays app version in system info section
- [x] #3 Version is read from mix.exs via Application.spec(:mydia, :vsn)
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Summary

Added version information and dev mode indicator to both the `/health` endpoint and Admin Status page.

### Changes Made

1. **Created `Mydia.System` module** (`lib/mydia/system.ex`):
   - `app_version/0` - Gets application version from Application.spec(:mydia, :vsn)
   - `dev_mode?/0` - Checks if running in development mode using Mix.env()

2. **Updated HealthController** (`lib/mydia_web/controllers/health_controller.ex:9`):
   - Added `version` field to JSON response
   - Added `dev_mode` boolean field to indicate development environment
   - Uses `Mydia.System` module for version and environment info

3. **Updated AdminStatusLive.Index** (`lib/mydia_web/live/admin_status_live/index.ex:159`):
   - Added app_version and dev_mode to system info map
   - Uses `Mydia.System` module for version and environment info

4. **Updated Admin Status template** (`lib/mydia_web/live/admin_status_live/index.html.heex:20`):
   - Displays app version prominently
   - Shows warning "dev" badge next to version when in development mode
   - Maintains responsive grid layout for system info stats

5. **Updated test** (`test/mydia_web/live/admin_status_live_test.exs:49`):
   - Added assertion for "App Version" stat title

### Example Output

Health endpoint in dev mode:
```json
{
  "status": "ok",
  "service": "mydia",
  "version": "0.4.4",
  "dev_mode": true,
  "timestamp": "2025-11-10T22:04:03.358852Z"
}
```

Admin Status page shows version "0.4.4" with a yellow "dev" badge when running in development.
<!-- SECTION:NOTES:END -->
