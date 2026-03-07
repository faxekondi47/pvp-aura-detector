## 1. Remove old timing mechanisms

- [x] 1.1 Remove `reportCooldownExpiry` variable and all references to it
- [x] 1.2 Remove `debounceTimer` variable, `ScheduleDebouncedCheck()` function, and all references
- [x] 1.3 Remove cooldown check from `PerformCheck()` (the `GetTime() >= reportCooldownExpiry` guard)

## 2. Add instance presence verification

- [x] 2.1 Add `AreAllMembersInInstance()` function that uses `C_Map.GetBestMapForUnit()` to compare each party member's map ID against the player's map ID, returning true only if all existing members match

## 3. Implement two-phase monitoring lifecycle

- [x] 3.1 Add `monitoringPhase` state variable (nil, 1, or 2) replacing `isMonitoring` boolean
- [x] 3.2 Rewrite `EvaluateMonitoring()` to set `monitoringPhase = 1` and start polling on activation, and reset `monitoringPhase = nil` with full state clear on deactivation
- [x] 3.3 Rewrite polling ticker callback to call `AreAllMembersInInstance()` first — skip check if not all inside, otherwise check PVP flags, optionally report, and transition to Phase 2 (stop ticker)
- [x] 3.4 Add Phase 2 `UNIT_FLAGS` handler: guard-check all maps, if any member outside → Phase 1 (keep `lastKnownState`, restart ticker), else check PVP flags and report if state changed
- [x] 3.5 Add Phase 2 `GROUP_ROSTER_UPDATE` handler: return to Phase 1, clear `lastKnownState`, restart ticker

## 4. Update event dispatcher

- [x] 4.1 Rewrite `OnEvent` handler to route events based on `monitoringPhase` — Phase 1 only processes `ZONE_CHANGED_NEW_AREA` and `GROUP_ROSTER_UPDATE` for monitoring evaluation; Phase 2 processes `UNIT_FLAGS` with map guard and `GROUP_ROSTER_UPDATE` as phase transition

## 5. Update slash command

- [x] 5.1 Verify `/pvpcheck` still works as manual override regardless of phase — no changes expected but confirm it bypasses phase restrictions
