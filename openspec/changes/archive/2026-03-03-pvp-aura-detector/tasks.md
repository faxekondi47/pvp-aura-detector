## 1. Addon Scaffold

- [x] 1.1 Create PVPAuraDetector.toc with metadata, Interface version for BCC Anniversary (20505), and reference to PVPAuraDetector.lua
- [x] 1.2 Create PVPAuraDetector.lua with addon namespace, saved variables table, and frame for event registration

## 2. Core State and Event Framework

- [x] 2.1 Implement state variables: isMonitoring, lastReportedState, debounceTimer, pollingTicker
- [x] 2.2 Register for ZONE_CHANGED_NEW_AREA, GROUP_ROSTER_UPDATE, and UNIT_FLAGS events
- [x] 2.3 Implement event dispatcher that routes events to handler functions
- [x] 2.4 Implement activation logic: start monitoring when IsInInstance() and IsInGroup() are both true, stop otherwise
- [x] 2.5 Implement cleanup on deactivation: cancel polling ticker, clear lastReportedState

## 3. PVP Flag Checking

- [x] 3.1 Implement CheckPartyPVPFlags() — iterate "player" + "party1" through "party4", call UnitExists() and UnitIsPVP() for each, return table of {name, isPVP} pairs
- [x] 3.2 Implement BuildStateSnapshot() — serialize flag check results into a comparable string (sorted by name)
- [x] 3.3 Implement DetectMismatch() — return true if the flag table contains both PVP-on and PVP-off players, plus list of PVP-off player names

## 4. Reporting

- [x] 4.1 Implement ReportMismatch() — send party chat message listing PVP-off players with wording: group-wide buffs may not work correctly, type /pvp to enable
- [x] 4.2 Implement state-based suppression: compare current snapshot to lastReportedState, skip if identical, clear lastReportedState when no mismatch

## 5. Debounce and Polling

- [x] 5.1 Implement debounced check — on event, schedule a check after 1-2 seconds, cancel any pending scheduled check
- [x] 5.2 Implement 10-second polling ticker using C_Timer.NewTicker, started/stopped with monitoring activation/deactivation

## 6. Slash Command

- [x] 6.1 Register /pvpcheck slash command that performs an immediate flag check and reports to party chat regardless of lastReportedState
- [x] 6.2 If not in a dungeon instance, print a local message indicating the command only works in dungeons
