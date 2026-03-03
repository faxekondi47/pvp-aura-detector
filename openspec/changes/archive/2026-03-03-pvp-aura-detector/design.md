## Context

WoW TBC Classic Anniversary (client 2.5.5) has a bug where group-wide buffs/auras only apply to party members sharing the same PVP flag state inside dungeons. There is no existing addon or in-game mechanism to detect this. The addon must use only the WoW Lua API available in BCC Anniversary.

Key APIs available:
- `UnitIsPVP(unit)` — returns 1/nil for PVP flag status
- `UnitExists(unit)` — validates a unit token
- `UnitName(unit)` — gets player name
- `IsInInstance()` — returns true inside dungeons/raids
- `IsInGroup()` — returns true if in a party
- `SendChatMessage(msg, "PARTY")` — sends to party chat
- `UNIT_FLAGS` event — fires with unitTarget when flags change
- `ZONE_CHANGED_NEW_AREA` event — fires on zone transitions
- `GROUP_ROSTER_UPDATE` event — fires on party composition changes
- `C_Timer.NewTicker()` — periodic callback timer

## Goals / Non-Goals

**Goals:**
- Detect PVP flag mismatches among party members inside dungeon instances
- Alert the party via chat with clear, actionable messaging
- Avoid spam — only report when the mismatch state actually changes
- Handle edge cases: stragglers zoning in, mid-dungeon flag changes from mind control
- Provide manual `/pvpcheck` command for on-demand checks

**Non-Goals:**
- Raid support (raid1-40) — party only for now
- Visual UI frames or minimap icons
- Automatic PVP flag toggling (not possible via addon API)
- Cross-addon communication or LibDataBroker integration
- Localization

## Decisions

### Single-file architecture
The entire addon fits in one `.lua` file plus the `.toc` manifest. No libraries, no dependencies. The logic is simple enough that splitting into modules would add complexity for no benefit.

**Alternative considered**: Multi-file with a lib for event handling. Rejected — overkill for this scope.

### Event-driven + periodic timer hybrid
Primary detection via `UNIT_FLAGS`, `ZONE_CHANGED_NEW_AREA`, and `GROUP_ROSTER_UPDATE` events. A 10-second periodic timer acts as a safety net to catch cases where events are missed or party members zone in without triggering observable events.

**Alternative considered**: Pure event-driven (no timer). Rejected — when a party member zones into the dungeon, the addon user may not receive a reliable event. The timer catches this within 10 seconds.

**Alternative considered**: Pure polling (no events). Rejected — wasteful and less responsive than events for the common cases.

### State-based report suppression
Track the last reported mismatch as a serialized snapshot of party PVP flags (e.g., `"PlayerA:1,PlayerB:1,PlayerC:0"`). Only report when: (a) there is a mismatch, AND (b) the snapshot differs from the last reported one. Clear the snapshot when no mismatch exists, so a re-occurring identical mismatch after resolution gets reported again.

**Alternative considered**: Simple cooldown timer. Rejected — doesn't distinguish between "same mismatch persisting" and "new mismatch after resolution."

**Alternative considered**: One-shot per dungeon. Rejected — misses mid-dungeon flag changes from mind control.

### Check all party members regardless of location
`UnitIsPVP("partyN")` is called for all existing party members, even if they haven't entered the dungeon yet. There is no reliable API to determine if a specific party member is in the same instance.

**Alternative considered**: Filter by `UnitIsVisible()`. Rejected — too strict, returns false for players in the dungeon but far away.

### Debounce rapid event bursts
Zone transitions can fire multiple events in quick succession. A short debounce (1-2 seconds) coalesces these into a single check to avoid redundant processing and potential duplicate messages.

## Risks / Trade-offs

- **`UnitIsPVP()` data staleness** — Party member flag data may be briefly stale after they zone in. → Mitigation: The 10-second timer will catch up within one tick.
- **False positives for outside players** — A player outside the dungeon with PVP off gets reported even though the bug doesn't affect them yet. → Mitigation: Acceptable — serves as a proactive warning before they enter.
- **Chat spam from multiple addon users** — If several party members run the addon, each sends a message. → Mitigation: Out of scope for v1. Could add addon-to-addon communication later.
- **SendChatMessage restrictions** — In some contexts WoW restricts addon chat messages. Inside dungeons in a party this should work fine, but worth noting.
