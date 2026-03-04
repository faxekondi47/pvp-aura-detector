## Why

Publishing addon updates to CurseForge currently requires manual packaging and uploading. A CI/CD workflow triggered on tag pushes automates this, ensuring every tagged release is consistently packaged and published without manual intervention.

## What Changes

- Add a GitHub Actions workflow that triggers on tag pushes (`v*`)
- Workflow packages the addon into a correctly structured zip
- Workflow uploads the zip to CurseForge via their upload API using `curl`
- No 3rd party GitHub Actions dependencies beyond `actions/checkout@v4`
- CurseForge game version ID hardcoded to `14300` (BCC 2.5.5)
- CurseForge project ID hardcoded to `1477285`

## Capabilities

### New Capabilities
- `curseforge-release`: Automated packaging and upload of the addon to CurseForge on tag push via GitHub Actions

### Modified Capabilities
<!-- None -->

## Impact

- New file: `.github/workflows/release.yml`
- Requires `CF_API_KEY` GitHub secret configured in the repository
- No changes to existing addon code
