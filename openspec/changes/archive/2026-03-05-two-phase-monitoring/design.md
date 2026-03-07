## Context

The addon currently uses a single monitoring loop: when the player enters a dungeon instance in a group, it starts a 10-second polling ticker and listens for events. Every check queries `UnitIsPVP()` for all party members regardless of their location. This means party members still running to the dungeon entrance show up in checks, causing false mismatch reports.

The addon also uses a 60-second cooldown and 2-second debounce timer to reduce spam, but these are band-aids — the root cause is checking members who aren't in the instance yet.

All logic lives in a single file: `PVPAuraDetector.lua`.

## Goals / Non-Goals

**Goals:**
- Eliminate false positives from party members outside the dungeon
- Report mismatch only once all members are verified inside the instance
- React to mid-dungeon flag changes (mind control, manual /pvp) without polling
- Simplify the timer/cooldown logic by replacing it with phase-based flow control

**Non-Goals:**
- Detecting which specific dungeon the party is in
- Handling raid groups (addon is party-only)
- Cross-realm or battleground scenarios
- Proactively detecting when members leave the instance (only checked as a guard on events)

## Decisions

### Decision 1: Use `C_Map.GetBestMapForUnit()` for instance presence verification

**Choice**: Compare mapIDs between the local player and each party member to determine if they're in the same instance.

**Alternatives considered**:
- `CheckInteractDistance()` — max 28yd range, useless for dungeon-wide check
- `UnitIsVisible()` — ~100yd range, fails in large dungeons
- `UnitInRange()` — similar range limitation
- Subzone text comparison — `GetRealZoneText()` only works for local player

**Rationale**: `C_Map.GetBestMapForUnit()` works for any party member regardless of distance and returns their actual map ID. If the member is in a different zone, the mapID will differ. If the API returns `nil` for an out-of-range member, we treat that as "not verified inside."

**Risk**: This API's behavior for cross-zone party members in BCC Anniversary specifically is not 100% confirmed. See Risks section.

### Decision 2: Two-phase monitoring lifecycle

**Choice**: Split monitoring into Phase 1 (gathering) and Phase 2 (event-driven).

**Rationale**: Phase 1's polling is only needed while waiting for members to arrive — once everyone is verified inside, polling is wasteful. Phase 2 relies on `UNIT_FLAGS` which fires reliably for PVP flag changes within the instance. This eliminates unnecessary timer overhead for the majority of the dungeon run.

### Decision 3: Phase transition triggers

**Choice**:
- `GROUP_ROSTER_UPDATE` in Phase 2 → back to Phase 1, clear `lastKnownState`
- Out-of-instance member detected on `UNIT_FLAGS` in Phase 2 → back to Phase 1, keep `lastKnownState`

**Rationale**: Group composition change means a new player who hasn't been checked — fresh state needed. A member temporarily leaving (hearthing, dying) doesn't change who they are — preserve state to avoid re-reporting the same situation.

### Decision 4: Remove cooldown and debounce timers

**Choice**: Remove the 60-second `reportCooldownExpiry` and 2-second `debounceTimer` entirely.

**Rationale**: The cooldown existed to prevent spam, but the two-phase system eliminates the spam source. Phase 1 naturally debounces by polling every 10 seconds. Phase 2 only fires on actual flag change events, and state deduplication prevents duplicate reports. The debounce timer coalesced rapid events, but Phase 1 doesn't react to individual events (it polls), and Phase 2 checks are cheap and guarded by state comparison.

## Risks / Trade-offs

**`C_Map.GetBestMapForUnit()` may not work as expected in BCC Anniversary** → Mitigation: Treat `nil` return as "not in instance" (safe default — stays in Phase 1 until it can verify). If the API doesn't differentiate zones at all, the addon falls back to current behavior (checks everyone). Test in-game before release.

**No proactive detection of members leaving the instance in Phase 2** → Acceptable: The addon only needs to guard against checking out-of-instance members. If nobody's flags change, there's nothing to check. The guard runs on every `UNIT_FLAGS` event.

**`GROUP_ROSTER_UPDATE` fires frequently (role changes, leader changes)** → Trade-off: Returning to Phase 1 on every roster update may cause brief re-gathering periods. Acceptable because Phase 1 transitions quickly when everyone is already inside (next 10s tick verifies all maps match).
