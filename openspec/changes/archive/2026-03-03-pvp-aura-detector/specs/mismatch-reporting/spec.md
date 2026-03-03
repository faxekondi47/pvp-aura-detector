## ADDED Requirements

### Requirement: Report mismatch to party chat
When a PVP flag mismatch is detected, the addon SHALL send a message to party chat identifying which players do not have PVP enabled and instructing them to type /pvp. The message SHALL indicate that group-wide buffs may not work correctly.

#### Scenario: Mismatch with some players PVP-off
- **WHEN** a flag check finds players with PVP enabled and players without PVP enabled
- **THEN** the addon SHALL send a party chat message listing the names of players without PVP, stating that group-wide buffs may not work correctly, and instructing them to type /pvp

#### Scenario: All players have same flag state
- **WHEN** a flag check finds all party members have the same PVP flag state (all on or all off)
- **THEN** the addon SHALL NOT send any message

### Requirement: State-based report suppression
The addon SHALL track the last reported mismatch state as a snapshot of party member PVP flags. The addon SHALL only send a new report when the current mismatch state differs from the last reported state.

#### Scenario: Same mismatch persists across checks
- **WHEN** a flag check detects a mismatch identical to the previously reported mismatch
- **THEN** the addon SHALL NOT send a message

#### Scenario: Mismatch resolved then re-occurs
- **WHEN** a previously reported mismatch is resolved (all flags match), and then a new mismatch occurs with the same players
- **THEN** the addon SHALL report the mismatch again because the last reported state was cleared when the mismatch resolved

#### Scenario: New mismatch after previous mismatch
- **WHEN** a mismatch is reported, and then a different mismatch occurs (different set of players)
- **THEN** the addon SHALL report the new mismatch

#### Scenario: State cleared on dungeon exit
- **WHEN** the player leaves the dungeon
- **THEN** the last reported mismatch state SHALL be cleared

### Requirement: Message always suggests enabling PVP
The mismatch report SHALL always list the players who do NOT have PVP enabled and ask them to enable it. The addon SHALL NOT suggest disabling PVP for flagged players, regardless of majority.

#### Scenario: Majority has PVP off
- **WHEN** 4 players have PVP off and 1 has PVP on
- **THEN** the addon SHALL list the 4 PVP-off players and ask them to /pvp

#### Scenario: Majority has PVP on
- **WHEN** 4 players have PVP on and 1 has PVP off
- **THEN** the addon SHALL list the 1 PVP-off player and ask them to /pvp
