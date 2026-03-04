## MODIFIED Requirements

### Requirement: State-based report suppression
The addon SHALL track the last known mismatch state as a snapshot of party member PVP flags. The addon SHALL always update this tracked state when a mismatch change is detected, regardless of whether a report is sent. The addon SHALL only send a new report when the current mismatch state differs from the last known state and the report cooldown has expired.

#### Scenario: Same mismatch persists across checks
- **WHEN** a flag check detects a mismatch identical to the last known mismatch state
- **THEN** the addon SHALL NOT send a message

#### Scenario: Mismatch resolved then re-occurs
- **WHEN** a previously known mismatch is resolved (all flags match), and then a new mismatch occurs with the same players
- **THEN** the addon SHALL report the mismatch again (if cooldown has expired) because the last known state was cleared when the mismatch resolved

#### Scenario: New mismatch after previous mismatch
- **WHEN** a mismatch is known, and then a different mismatch occurs (different set of players)
- **THEN** the addon SHALL update the last known state, and report the new mismatch only if the cooldown has expired

#### Scenario: State cleared on dungeon exit
- **WHEN** the player leaves the dungeon
- **THEN** the last known mismatch state SHALL be cleared
