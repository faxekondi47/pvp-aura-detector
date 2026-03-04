## Why

The addon can spam party chat when PVP flags change frequently (e.g., players toggling PVP on and off, or rapid zone transitions). A cooldown ensures a minimum of 60 seconds between report messages to avoid being disruptive.

## What Changes

- Add a 60-second cooldown after each report message is sent to party chat
- During cooldown, mismatch state is still tracked but no messages are sent
- After cooldown expires, the next detected change may trigger a new report
- Rename `lastReportedState` to `lastKnownState` to reflect that it now tracks detected state regardless of whether a report was sent
- The `/pvpcheck` manual command bypasses the cooldown entirely

## Capabilities

### New Capabilities
- `report-cooldown`: Rate-limiting of mismatch report messages with a 60-second minimum interval between reports

### Modified Capabilities
- `mismatch-reporting`: State tracking is decoupled from reporting — state is always updated, but reporting is gated by cooldown

## Impact

- `PVPAuraDetector.lua`: Modifications to `PerformCheck()` and variable renaming
- No new dependencies or API changes
- `/pvpcheck` slash command is unaffected
