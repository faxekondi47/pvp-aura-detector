## MODIFIED Requirements

### Requirement: State-based report suppression
The addon SHALL track the last known mismatch state as a snapshot of party member PVP flags. The addon SHALL only send a new report when the current mismatch state differs from the last known state. When returning to Phase 1 due to a member leaving the instance, `lastKnownState` SHALL be preserved. When returning to Phase 1 due to group composition change, `lastKnownState` SHALL be cleared.

#### Scenario: Same mismatch persists across checks
- **WHEN** a flag check detects a mismatch identical to the last known mismatch state
- **THEN** the addon SHALL NOT send a message

#### Scenario: Mismatch resolved then re-occurs
- **WHEN** a previously known mismatch is resolved (all flags match), and then a new mismatch occurs
- **THEN** the addon SHALL report the mismatch because the last known state was cleared when the mismatch resolved

#### Scenario: New mismatch after previous mismatch
- **WHEN** a mismatch is known, and then a different mismatch occurs (different set of players)
- **THEN** the addon SHALL update the last known state and report the new mismatch

#### Scenario: State cleared on dungeon exit
- **WHEN** the player leaves the dungeon
- **THEN** the last known mismatch state SHALL be cleared

#### Scenario: State preserved when member zones out
- **WHEN** a party member leaves the instance (detected via map ID mismatch on UNIT_FLAGS)
- **THEN** the last known mismatch state SHALL be preserved during the return to Phase 1

#### Scenario: State cleared on group composition change
- **WHEN** GROUP_ROSTER_UPDATE fires in Phase 2
- **THEN** the last known mismatch state SHALL be cleared
