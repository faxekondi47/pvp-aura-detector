## MODIFIED Requirements

### Requirement: Event-driven PVP flag detection
The addon SHALL listen for ZONE_CHANGED_NEW_AREA, GROUP_ROSTER_UPDATE, and UNIT_FLAGS events. Event handling behavior SHALL depend on the current monitoring phase. In Phase 1, events SHALL trigger monitoring evaluation but PVP flag checks are performed only by the polling ticker. In Phase 2, UNIT_FLAGS SHALL trigger a guarded PVP flag check and GROUP_ROSTER_UPDATE SHALL return to Phase 1.

#### Scenario: UNIT_FLAGS fires in Phase 1
- **WHEN** the UNIT_FLAGS event fires while in Phase 1
- **THEN** the addon SHALL NOT perform an immediate PVP flag check (the polling ticker handles checks)

#### Scenario: UNIT_FLAGS fires in Phase 2
- **WHEN** the UNIT_FLAGS event fires while in Phase 2
- **THEN** the addon SHALL verify all party members are on the player's map and perform a PVP flag check if verified

#### Scenario: GROUP_ROSTER_UPDATE fires in Phase 2
- **WHEN** the GROUP_ROSTER_UPDATE event fires while in Phase 2
- **THEN** the addon SHALL return to Phase 1 with cleared lastKnownState

#### Scenario: ZONE_CHANGED_NEW_AREA fires
- **WHEN** the ZONE_CHANGED_NEW_AREA event fires
- **THEN** the addon SHALL evaluate whether monitoring should activate or deactivate based on IsInInstance() and IsInGroup()

### Requirement: Periodic polling as safety net
The addon SHALL run a periodic timer (every 10 seconds) only during Phase 1 to check whether all party members have arrived in the instance. The polling ticker SHALL be stopped upon transition to Phase 2.

#### Scenario: Timer tick during Phase 1
- **WHEN** the 10-second timer fires while in Phase 1
- **THEN** the addon SHALL verify all party member map IDs and perform a PVP flag check only if all members are inside

#### Scenario: Timer stopped on Phase 2 transition
- **WHEN** the addon transitions from Phase 1 to Phase 2
- **THEN** the periodic timer SHALL be cancelled

#### Scenario: Timer stopped when monitoring stops
- **WHEN** monitoring becomes inactive (left dungeon or left party)
- **THEN** the periodic timer SHALL be cancelled

### Requirement: Check all party members regardless of location
**This requirement is removed. See report-cooldown specs for removal notice.**

## REMOVED Requirements

### Requirement: Check all party members regardless of location
**Reason**: Replaced by instance-presence-verification capability. Party members are now filtered by map ID before PVP flag checking.
**Migration**: PVP flag checks now only include party members verified to be on the same map as the local player.
