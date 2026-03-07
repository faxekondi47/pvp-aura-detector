## ADDED Requirements

### Requirement: Verify party members are in the same instance via map ID
The addon SHALL use `C_Map.GetBestMapForUnit()` to obtain the map ID for each party member and compare it against the local player's map ID. A party member SHALL be considered "inside the instance" only if their map ID matches the local player's map ID.

#### Scenario: Party member is in the same dungeon
- **WHEN** `C_Map.GetBestMapForUnit("party1")` returns the same map ID as `C_Map.GetBestMapForUnit("player")`
- **THEN** that party member SHALL be considered inside the instance

#### Scenario: Party member is in a different zone
- **WHEN** `C_Map.GetBestMapForUnit("party2")` returns a different map ID than the player's
- **THEN** that party member SHALL NOT be included in PVP flag checks

#### Scenario: Map API returns nil for a party member
- **WHEN** `C_Map.GetBestMapForUnit()` returns nil for a party member
- **THEN** that party member SHALL be treated as not inside the instance

### Requirement: All party members must be verified inside before PVP flag checking
The addon SHALL NOT perform PVP flag mismatch checks until every party member (where `UnitExists()` returns true) has been verified as sharing the local player's map ID.

#### Scenario: 3 of 4 party members inside
- **WHEN** a check runs and 3 party members share the player's map ID but 1 does not
- **THEN** the addon SHALL NOT perform a PVP flag mismatch check

#### Scenario: All party members inside
- **WHEN** a check runs and all existing party members share the player's map ID
- **THEN** the addon SHALL proceed with a PVP flag mismatch check
