---
id: task-53
title: Add Playwright E2E browser tests for critical user workflows
status: To Do
assignee: []
created_date: '2025-11-05 01:51'
labels:
  - testing
  - e2e
  - quality
dependencies:
  - task-12
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement end-to-end browser testing using Playwright to complement existing unit/integration tests and LiveView tests. Playwright will validate actual browser behavior, JavaScript hooks, real user interactions, and complete workflows that are difficult to test with Phoenix.LiveViewTest alone.

This provides a third testing layer:
1. Unit/integration tests (task-12) - context logic, business rules
2. Testcontainers tests (task-51) - database operations, transactions
3. Playwright E2E tests - real browser interactions, complete user journeys

Focus on critical user paths:
- Authentication flows (login, logout, session management)
- Media search and add-to-library workflow
- Admin configuration UI (clients, indexers, quality profiles)
- Downloads queue monitoring with real-time updates
- Library browsing and media detail views
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Playwright installed and configured for Elixir/Phoenix project
- [ ] #2 Test infrastructure set up with authentication helpers and fixtures
- [ ] #3 E2E tests written for authentication flows (login, logout, protected routes)
- [ ] #4 E2E tests written for search and add-to-library workflow
- [ ] #5 E2E tests written for admin configuration UI interactions
- [ ] #6 E2E tests written for downloads queue real-time updates
- [ ] #7 E2E tests written for media library browsing
- [ ] #8 All Playwright tests passing in CI pipeline
- [ ] #9 Documentation for running and writing E2E tests
<!-- AC:END -->
