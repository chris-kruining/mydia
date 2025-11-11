---
id: task-156.4
title: Optimize HLS session lookup from O(n) to O(1)
status: Done
assignee: []
created_date: '2025-11-10 22:20'
updated_date: '2025-11-10 23:37'
labels:
  - performance
  - backend
dependencies: []
parent_task_id: task-156
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Current session lookup iterates through all active sessions with GenServer calls, causing performance degradation with multiple concurrent users.

## Current Problem
```elixir
# lib/mydia_web/controllers/api/hls_controller.ex:316-327
defp find_session_by_id(session_id, _user_id) do
  # Linear search through ALL sessions
  Enum.find(HlsSessionSupervisor.list_sessions(), fn {_key, pid, _meta} ->
    case HlsSession.get_info(pid) do  # GenServer call PER session
      {:ok, info} -> info.session_id == session_id
      _ -> false
    end
  end)
end
```

**Performance Impact:**
- O(n) lookup on every segment/playlist request
- GenServer call for EACH active session until match found
- With 10 concurrent users: 10 GenServer calls per request
- Called every 6 seconds (HLS playlist refresh)

## Solution
Use Registry for O(1) lookups:

```elixir
# Register session with session_id as key
Registry.register(
  Mydia.Streaming.HlsSessionRegistry,
  {:session, session_id},
  %{temp_dir: temp_dir, media_file_id: media_file_id}
)

# O(1) lookup
defp find_session_by_id(session_id, _user_id) do
  case Registry.lookup(Mydia.Streaming.HlsSessionRegistry, {:session, session_id}) do
    [{pid, _meta}] -> {:ok, pid}
    [] -> {:error, :session_not_found}
  end
end
```

## Files to Modify
- `lib/mydia/streaming/hls_session.ex` - Add session_id to registry
- `lib/mydia_web/controllers/api/hls_controller.ex` - Use Registry lookup

## Expected Impact
- Constant-time lookups regardless of concurrent users
- Eliminate cascading GenServer calls
- Better scalability (100+ concurrent users)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Session lookup uses Registry with O(1) complexity
- [x] #2 No Enum.find calls for session lookup
- [x] #3 Registry stores session_id as key with metadata
- [x] #4 Backwards compatible with existing session management
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implementation completed:
- Added second Registry.register call with {:session, session_id} as key in hls_session.ex:160-169
- Stored media_file_id, user_id, temp_dir in registry metadata for future use
- Replaced Enum.find with Registry.lookup in find_session_by_id (hls_controller.ex:316-322)
- Eliminated cascading GenServer calls across all active sessions
- Backwards compatible - existing {:hls_session, media_file_id, user_id} registration unchanged

Performance improvement:
- Before: O(n) where n = number of active sessions, with n GenServer calls
- After: O(1) constant-time lookup using Registry
- Scales linearly to 100+ concurrent users

Commit: 63f4361
<!-- SECTION:NOTES:END -->
