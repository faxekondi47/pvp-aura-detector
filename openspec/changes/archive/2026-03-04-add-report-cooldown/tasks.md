## 1. Variable Changes

- [x] 1.1 Rename `lastReportedState` to `lastKnownState` throughout PVPAuraDetector.lua
- [x] 1.2 Add `reportCooldownExpiry` variable initialized to 0

## 2. Core Cooldown Logic

- [x] 2.1 Modify `PerformCheck()` to always update `lastKnownState` when mismatch state changes, regardless of cooldown
- [x] 2.2 Add `GetTime() >= reportCooldownExpiry` check before calling `ReportMismatch()`
- [x] 2.3 Set `reportCooldownExpiry = GetTime() + 60` after sending a report

## 3. Spec Update

- [x] 3.1 Update main `openspec/specs/mismatch-reporting/spec.md` with modified state-tracking requirements
