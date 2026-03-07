## REMOVED Requirements

### Requirement: 60-second report cooldown
**Reason**: The two-phase monitoring system eliminates the spam that the cooldown was designed to prevent. Phase 1 naturally gates reports until all members are inside, and Phase 2 uses state-based deduplication without time-based throttling.
**Migration**: No migration needed. Reports are now controlled by phase transitions and state comparison instead of time-based cooldown.
