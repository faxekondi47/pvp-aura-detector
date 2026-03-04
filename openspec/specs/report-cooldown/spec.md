## ADDED Requirements

### Requirement: 60-second report cooldown
After sending an automatic mismatch report to party chat, the addon SHALL enforce a 60-second cooldown before sending another automatic report. During cooldown, mismatch detection SHALL continue but no messages SHALL be sent.

#### Scenario: Report sent, new change within cooldown
- **WHEN** an automatic mismatch report is sent, and a different mismatch is detected 10 seconds later
- **THEN** the addon SHALL NOT send a message, and SHALL update the tracked mismatch state

#### Scenario: Report sent, change detected after cooldown
- **WHEN** an automatic mismatch report is sent, and a different mismatch is detected 65 seconds later
- **THEN** the addon SHALL send a new report to party chat

#### Scenario: Cooldown does not apply to manual check
- **WHEN** the player runs `/pvpcheck` during an active cooldown
- **THEN** the addon SHALL send the report to party chat regardless of cooldown state
