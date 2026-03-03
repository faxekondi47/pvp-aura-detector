## Why

In WoW TBC Classic Anniversary, a persistent bug causes group-wide buffs and auras (paladin auras, shaman totems, prayer of fortitude, tranquility, etc.) to not apply correctly when party members have mismatched PVP flag states inside a dungeon. This happens organically — mind control effects auto-flag players, portals/summons/BG exits can unexpectedly unflag them — and there is no in-game indication of the mismatch. Players lose significant throughput without knowing why.

## What Changes

- New WoW addon that monitors PVP flag status of all party members while inside a dungeon instance
- Detects mismatches between flagged and unflagged players using event-driven checks + periodic polling
- Reports mismatches to party chat with a clear message identifying who needs to `/pvp`
- Tracks mismatch state to avoid spam — only re-reports when the mismatch changes
- Provides `/pvpcheck` slash command for manual on-demand checks

## Capabilities

### New Capabilities
- `pvp-flag-monitoring`: Detect and track PVP flag status of all party members using WoW API events and periodic polling
- `mismatch-reporting`: Report PVP flag mismatches to party chat with debounce and state-aware suppression

### Modified Capabilities

None — this is a new addon with no existing codebase.

## Impact

- New addon files: `PVPAuraDetector.toc` and `PVPAuraDetector.lua`
- No external dependencies — uses only WoW Lua API
- Sends messages to party chat channel when mismatches are detected
- Registers `/pvpcheck` slash command in the global namespace
