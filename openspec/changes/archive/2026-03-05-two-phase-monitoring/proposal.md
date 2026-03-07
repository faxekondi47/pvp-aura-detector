## Why

The addon currently checks PVP flags of all party members regardless of whether they're inside the dungeon. When players trickle into a dungeon over a couple of minutes, those still outside naturally have PVP enabled, causing false mismatch reports that spam party chat. Additionally, the addon re-reports the same mismatch situation repeatedly via cooldown cycling, when a single report per instance entry is sufficient.

## What Changes

- **Two-phase monitoring**: Replace the single polling loop with a gathering phase (Phase 1) that waits for all party members to be inside the dungeon before checking, and an event-driven phase (Phase 2) that reacts to flag changes without polling.
- **Map-based instance verification**: Use `C_Map.GetBestMapForUnit()` to verify each party member is on the same map as the player before including them in PVP flag checks.
- **Phase transitions**: `GROUP_ROSTER_UPDATE` returns to Phase 1 with cleared state; detecting an out-of-instance member on `UNIT_FLAGS` returns to Phase 1 with preserved state.
- **Remove report cooldown**: The 60-second cooldown timer is no longer needed. Phase 1 naturally handles the wait, and Phase 2 uses state-based deduplication only.
- **Remove debounce timer**: The 2-second debounce coalescing is no longer needed. Phase 1 uses a 10-second poll, and Phase 2 handles events directly.

## Capabilities

### New Capabilities
- `instance-presence-verification`: Verify party members are inside the same dungeon instance using map ID comparison before including them in PVP flag checks.
- `two-phase-monitoring`: Two-phase monitoring lifecycle — Phase 1 (gathering with polling) waits for all members, Phase 2 (event-driven) reacts to flag changes.

### Modified Capabilities
- `pvp-flag-monitoring`: Replace single polling loop with two-phase system. Remove debounce timer. Change event handling behavior per phase. Remove unconditional checking of all party members regardless of location.
- `mismatch-reporting`: State clearing now depends on transition trigger — preserved when members zone out, cleared when group composition changes.
- `report-cooldown`: **BREAKING** — Remove entirely. Replaced by phase-based flow control and state deduplication.

## Impact

- **PVPAuraDetector.lua**: Full rewrite of monitoring logic, event handling, and state management. Single file change.
- **WoW API dependency**: New dependency on `C_Map.GetBestMapForUnit()` — available in BCC but needs verification that it returns meaningful data for party members in different zones.
- **User-facing behavior**: Fewer chat messages (no more spam on dungeon entry), but still reports when a genuine mismatch exists after everyone is inside.
- **Slash command**: `/pvpcheck` unchanged — still works as manual override.
