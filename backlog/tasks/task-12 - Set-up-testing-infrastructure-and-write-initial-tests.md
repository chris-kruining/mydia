---
id: task-12
title: Set up testing infrastructure and write initial tests
status: In Progress
assignee: []
created_date: '2025-11-04 01:52'
updated_date: '2025-11-05 02:16'
labels:
  - testing
  - quality
dependencies:
  - task-4
  - task-7
  - task-11
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configure test environment with SQLite in-memory database. Write tests for contexts, controllers, and LiveViews. Set up test helpers and factories.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Test database configured (SQLite in-memory)
- [x] #2 ExMachina or similar factory library set up
- [x] #3 Test helpers for common operations
- [ ] #4 Context tests for Media, Accounts, Downloads
- [ ] #5 Controller tests for API endpoints
- [ ] #6 LiveView tests for main pages
- [ ] #7 Test coverage > 70%
- [ ] #8 All tests passing with `mix test`
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Investigation Results

### Current Test Infrastructure
- 608 tests total
- 67 failures (mostly authentication and config-related)
- 11 skipped
- Test infrastructure exists:
  - DataCase for context tests
  - ConnCase for controller tests
  - Media and Downloads fixtures
  - No factory library (ExMachina or similar)

### Main Test Failures
1. **Authentication issues**: LiveView tests failing due to missing authentication setup
2. **Download client health tests**: Configuration/setup issues with client IDs
3. **Compiler warnings**: Several unused variables and inefficient patterns

### Next Steps
1. Add ExMachina for better test data generation
2. Create authentication helpers for LiveView tests
3. Fix download client health test setup
4. Address compiler warnings
5. Measure and improve test coverage
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Current Status

**Infrastructure fixes completed:**
- ✅ task-20: Fixed Oban/SQL Sandbox configuration issues
- ✅ Test database appears to be working (SQLite)

**Unclear/Needs verification:**
- Test helpers and factories setup?
- Current test coverage level?
- Which contexts/LiveViews have test coverage?

**Likely remaining work:**
- Set up ExMachina or similar factory library (AC #2)
- Create comprehensive test helpers (AC #3)
- Expand context test coverage (AC #4)
- Add controller/API tests (AC #5)
- Add LiveView tests beyond basics (AC #6)
- Achieve 70%+ coverage (AC #7)

This task needs investigation to determine actual current state vs. desired state.

## Progress Summary (2025-11-04)

### Completed
1. ✅ Added ExMachina 2.8 for better test data generation
2. ✅ Created comprehensive Factory module with factories for:
   - MediaItem (movie and tv_show variants)
   - Episode
   - MediaFile
   - Download
3. ✅ Created AuthHelpers for authentication in tests:
   - create_test_user/1
   - create_admin_user/1
   - log_in_user/2
   - create_user_and_token/1
   - Works with actual Guardian/Accounts modules
4. ✅ Created ConfigHelpers for download client/indexer configuration
5. ✅ Updated DataCase and ConnCase to auto-import helpers
6. ✅ Reduced test failures from 67 to 63

### Remaining Issues

#### Authentication Test Failures (~60 failures)
- LiveView tests using `guardian_default_token` session key
- Should use `guardian_token` to match UserAuth hook expectations
- Tests in: test/mydia_web/live/search_live/add_to_library_test.exs

#### Download Client Health Tests (6 failures)
- Settings.get_download_client_config!/2 doesn't handle binary_id properly
- Function expects integer IDs but schema uses :binary_id (UUIDs)
- Needs fix in lib/mydia/settings.ex:257-285
- ETS table :download_client_health not initialized in test env

#### Test Database Configuration
- `mix precommit` fails with DBConnection.ConnectionPool error
- Test config has correct Sandbox pool setting
- Issue with ./dev test wrapper vs native mix test

### Next Steps
1. Fix Settings module to handle binary IDs
2. Update failing LiveView tests to use correct session key
3. Ensure ETS tables are initialized for tests
4. Add more comprehensive tests for uncovered contexts
5. Measure test coverage with mix test --cover

## Session Progress (2025-11-04 continued)

### Fixes Implemented
1. ✅ Fixed AuthHelpers to use `password` instead of `password_hash`
   - Changed create_test_user to pass password field to Accounts.create_user
   - This allows the User.changeset to properly hash passwords

2. ✅ Fixed SearchLive tests to use correct session key
   - Updated add_to_library_test.exs to use AuthHelpers
   - Changed session key from `:guardian_default_token` to `:guardian_token`
   - This matches the UserAuth hook expectations

3. ✅ Fixed Settings module to handle UUID (binary_id) for download clients
   - Added UUID validation using Ecto.UUID.cast/1
   - Settings.get_download_client_config! now handles:
     - Runtime IDs (special format)
     - UUIDs (binary_id from database)
     - Integer IDs (backwards compatibility)
   - Fixed lib/mydia/settings.ex:277-293

### Test Results
- **Before fixes**: 608 tests, 80 failures, 11 skipped
- **After fixes**: 608 tests, 52 failures, 11 skipped
- **Improvement**: Reduced failures by 28 (35% reduction)

### Current Test Coverage
- Overall coverage: **28.05%** (below 90% threshold but above initial 0%)
- Many modules have 0% coverage (LiveViews, Controllers, some contexts)
- Some modules have 100% coverage (schemas, configs, some helpers)

### Remaining Test Failures (52 total)
Breakdown by category:
1. **Metadata Provider Relay tests** (~20 failures)
   - Need mock server or external service setup
   - Tests: search, fetch_by_id, fetch_images, fetch_season, etc.

2. **AdminConfigLiveTest** (~20 failures)
   - Authentication, navigation, CRUD operations
   - May need additional LiveView test setup

3. **Quality Parser/Indexer tests** (~5 failures)
   - quality_description, quality_score, parsing tests

4. **Misc tests** (~7 failures)
   - LibraryScanner, DownloadMonitor, SearchLive, etc.

### Files Modified
- test/support/auth_helpers.ex - Fixed password handling
- test/mydia_web/live/search_live/add_to_library_test.exs - Fixed session key
- lib/mydia/settings.ex - Added UUID support for download clients
<!-- SECTION:NOTES:END -->
