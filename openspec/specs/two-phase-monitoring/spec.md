## ADDED Requirements

### Requirement: Phase 1 gathering mode with polling
When monitoring activates, the addon SHALL enter Phase 1 (gathering). In Phase 1, the addon SHALL poll every 10 seconds. Each poll SHALL verify whether all party members are inside the instance. Once all members are verified inside, the addon SHALL check PVP flags, report any mismatch, and transition to Phase 2.

#### Scenario: Polling tick with members still outside
- **WHEN** the 10-second polling tick fires and one or more party members are not on the player's map
- **THEN** the addon SHALL skip the PVP flag check and continue polling

#### Scenario: Polling tick with all members inside and mismatch
- **WHEN** the 10-second polling tick fires, all party members are on the player's map, and a PVP flag mismatch exists
- **THEN** the addon SHALL report the mismatch to party chat and transition to Phase 2

#### Scenario: Polling tick with all members inside and no mismatch
- **WHEN** the 10-second polling tick fires and all party members are on the player's map with no PVP flag mismatch
- **THEN** the addon SHALL transition to Phase 2 without sending a message

### Requirement: Phase 2 event-driven mode without polling
In Phase 2, the addon SHALL stop the polling ticker. The addon SHALL only react to `UNIT_FLAGS` and `GROUP_ROSTER_UPDATE` events.

#### Scenario: Phase 2 entered
- **WHEN** the addon transitions from Phase 1 to Phase 2
- **THEN** the polling ticker SHALL be cancelled

### Requirement: UNIT_FLAGS handling in Phase 2 with map guard
In Phase 2, when `UNIT_FLAGS` fires, the addon SHALL first verify all party members are on the player's map. If any member is not on the player's map, the addon SHALL return to Phase 1 while preserving `lastKnownState`. If all members are verified inside, the addon SHALL check PVP flags and report only if the mismatch state has changed.

#### Scenario: UNIT_FLAGS with all members inside and new mismatch state
- **WHEN** `UNIT_FLAGS` fires in Phase 2, all party members share the player's map ID, and the PVP flag state differs from `lastKnownState`
- **THEN** the addon SHALL report the mismatch to party chat and update `lastKnownState`

#### Scenario: UNIT_FLAGS with all members inside and same state
- **WHEN** `UNIT_FLAGS` fires in Phase 2, all party members share the player's map ID, and the PVP flag state matches `lastKnownState`
- **THEN** the addon SHALL NOT send a message

#### Scenario: UNIT_FLAGS with a member outside the instance
- **WHEN** `UNIT_FLAGS` fires in Phase 2 and any party member's map ID does not match the player's
- **THEN** the addon SHALL return to Phase 1 with `lastKnownState` preserved and restart the polling ticker

### Requirement: GROUP_ROSTER_UPDATE returns to Phase 1 with cleared state
In Phase 2, when `GROUP_ROSTER_UPDATE` fires, the addon SHALL return to Phase 1 and clear `lastKnownState`.

#### Scenario: Group composition changes in Phase 2
- **WHEN** `GROUP_ROSTER_UPDATE` fires while in Phase 2
- **THEN** the addon SHALL return to Phase 1, clear `lastKnownState`, and restart the polling ticker

### Requirement: Monitoring exit clears all state
When the player leaves the instance or leaves the group, the addon SHALL stop all monitoring, cancel any polling ticker, clear `lastKnownState`, and reset the phase to inactive.

#### Scenario: Player leaves dungeon during Phase 1
- **WHEN** the player zones out of a dungeon while in Phase 1
- **THEN** all monitoring SHALL stop, the polling ticker SHALL be cancelled, and all state SHALL be cleared

#### Scenario: Player leaves dungeon during Phase 2
- **WHEN** the player zones out of a dungeon while in Phase 2
- **THEN** all monitoring SHALL stop and all state SHALL be cleared

#### Scenario: Player leaves group during monitoring
- **WHEN** the player leaves their party while monitoring is active in either phase
- **THEN** all monitoring SHALL stop and all state SHALL be cleared
