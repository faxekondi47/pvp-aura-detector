## ADDED Requirements

### Requirement: Addon activates only inside dungeon instances while in a party
The addon SHALL only perform PVP flag monitoring when the player is inside a dungeon instance AND is in a party group. The addon SHALL stop monitoring when leaving the dungeon or leaving the party.

#### Scenario: Player enters dungeon while in party
- **WHEN** the player zones into a dungeon instance while in a party
- **THEN** the addon SHALL begin monitoring PVP flag status of all party members

#### Scenario: Player leaves dungeon
- **WHEN** the player zones out of a dungeon instance
- **THEN** the addon SHALL stop monitoring and clear all tracked state

#### Scenario: Player leaves party while in dungeon
- **WHEN** the player leaves their party while inside a dungeon
- **THEN** the addon SHALL stop monitoring and clear all tracked state

#### Scenario: Player is in dungeon but not in a party
- **WHEN** the player is inside a dungeon instance but not in a party
- **THEN** the addon SHALL NOT perform any monitoring

### Requirement: Event-driven PVP flag detection
The addon SHALL listen for ZONE_CHANGED_NEW_AREA, GROUP_ROSTER_UPDATE, and UNIT_FLAGS events to trigger PVP flag checks. When any of these events fire while monitoring is active, the addon SHALL check PVP flags of all party members.

#### Scenario: UNIT_FLAGS fires for a party member
- **WHEN** the UNIT_FLAGS event fires with a unitTarget matching a party unit token while monitoring is active
- **THEN** the addon SHALL perform a PVP flag check on all party members

#### Scenario: GROUP_ROSTER_UPDATE fires
- **WHEN** the GROUP_ROSTER_UPDATE event fires while monitoring is active
- **THEN** the addon SHALL perform a PVP flag check on all party members

#### Scenario: Events fire in rapid succession
- **WHEN** multiple events fire within a short window (1-2 seconds)
- **THEN** the addon SHALL coalesce them into a single PVP flag check

### Requirement: Periodic polling as safety net
The addon SHALL run a periodic timer (every 10 seconds) while monitoring is active to check PVP flags. This catches cases where events are not reliably fired, such as party members zoning in.

#### Scenario: Timer tick while monitoring
- **WHEN** the 10-second timer fires while monitoring is active
- **THEN** the addon SHALL perform a PVP flag check on all party members

#### Scenario: Timer stops when monitoring stops
- **WHEN** monitoring becomes inactive (left dungeon or left party)
- **THEN** the periodic timer SHALL be cancelled

### Requirement: Check all party members regardless of location
The addon SHALL check UnitIsPVP() on "player" and "party1" through "party4" for all unit tokens where UnitExists() returns true. The addon SHALL NOT attempt to filter by whether a party member is inside the dungeon.

#### Scenario: Party of 5 with all present
- **WHEN** a PVP flag check runs and all 5 party members exist
- **THEN** the addon SHALL query UnitIsPVP() for "player", "party1", "party2", "party3", and "party4"

#### Scenario: Party of 3
- **WHEN** a PVP flag check runs and only 3 party members exist
- **THEN** the addon SHALL query UnitIsPVP() only for unit tokens where UnitExists() returns true

### Requirement: Manual check via slash command
The addon SHALL register a `/pvpcheck` slash command that performs an immediate PVP flag check and reports results regardless of monitoring state or previous report history.

#### Scenario: Manual check inside dungeon with mismatch
- **WHEN** the player types `/pvpcheck` while inside a dungeon with a PVP flag mismatch
- **THEN** the addon SHALL report the mismatch to party chat even if it was previously reported

#### Scenario: Manual check outside dungeon
- **WHEN** the player types `/pvpcheck` while not inside a dungeon
- **THEN** the addon SHALL print a local message indicating the command only works in dungeons
