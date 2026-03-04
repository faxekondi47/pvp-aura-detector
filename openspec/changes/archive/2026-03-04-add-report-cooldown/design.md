## Context

The addon currently uses event-driven detection with a 2-second debounce and a 10-second polling ticker as a safety net. When a mismatch is detected, it reports immediately if the state has changed from the last report. There is no minimum interval between reports — rapid flag changes can produce rapid chat messages.

## Goals / Non-Goals

**Goals:**
- Enforce a 60-second minimum interval between automatic report messages
- Continue tracking mismatch state changes during cooldown (no data loss)
- Keep `/pvpcheck` manual command unaffected by cooldown

**Non-Goals:**
- Changing the polling interval or debounce timing
- Adding user-configurable cooldown duration
- Rate-limiting the `/pvpcheck` slash command

## Decisions

### Timestamp comparison over C_Timer cooldown
Use `GetTime()` timestamp comparison (`reportCooldownExpiry`) rather than a separate `C_Timer` for cooldown tracking.

**Rationale**: A timer would need cancellation logic and callback management. A simple timestamp comparison in the existing `PerformCheck()` flow is simpler and stateless — just compare `GetTime() >= reportCooldownExpiry`.

**Alternative considered**: `C_Timer.NewTimer(60, ...)` with a boolean flag. Rejected — adds unnecessary timer lifecycle management for what is just a time comparison.

### Decouple state tracking from reporting
Rename `lastReportedState` to `lastKnownState`. Always update it when mismatch state changes, regardless of whether a report is sent. This prevents stale state from triggering a duplicate report after cooldown expires.

**Rationale**: If state is only updated on report, a change detected during cooldown would be re-reported when the cooldown expires — even though it's old news.

### Clear lastKnownState when mismatch resolves
Continue clearing state to `nil` when no mismatch is detected, preserving existing behavior for the resolve-then-reappear scenario.

## Risks / Trade-offs

- **Delayed awareness**: A genuine new mismatch occurring 5 seconds after a report won't be communicated for another 55 seconds. → Acceptable trade-off for reducing chat spam. The `/pvpcheck` command is available for immediate manual checks.
- **Silent state changes**: Multiple state transitions during cooldown are tracked but never reported. → By design. Only the state at cooldown expiry matters.
