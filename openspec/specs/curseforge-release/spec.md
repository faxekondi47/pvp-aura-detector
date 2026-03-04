## ADDED Requirements

### Requirement: Workflow triggers on tag push
The workflow SHALL trigger only when a tag matching the `v*` pattern is pushed to the repository.

#### Scenario: Tag push triggers workflow
- **WHEN** a tag `v1.2.0` is pushed
- **THEN** the release workflow runs

#### Scenario: Regular commit does not trigger workflow
- **WHEN** a commit is pushed to any branch without a tag
- **THEN** the release workflow does not run

### Requirement: Addon is packaged into a zip
The workflow SHALL create a zip file containing a `PVPAuraDetector/` directory with all addon files (`.toc`, `.lua`).

#### Scenario: Zip has correct structure
- **WHEN** the workflow packages the addon
- **THEN** the zip contains `PVPAuraDetector/PVPAuraDetector.toc` and `PVPAuraDetector/PVPAuraDetector.lua`

### Requirement: Version is derived from tag
The workflow SHALL extract the version string by stripping the `v` prefix from the git tag name.

#### Scenario: Version extraction
- **WHEN** the tag is `v1.2.0`
- **THEN** the version used for the upload display name is `1.2.0`

### Requirement: Changelog is generated from git history
The workflow SHALL generate a changelog from commit messages between the previous tag and the current tag.

#### Scenario: Changelog from commits
- **WHEN** there are 3 commits between the previous tag and the current tag
- **THEN** the changelog contains those 3 commit messages

#### Scenario: First tag has no previous tag
- **WHEN** the current tag is the first tag in the repository
- **THEN** the changelog contains all commits up to the tag

### Requirement: Upload to CurseForge via API
The workflow SHALL upload the zip to CurseForge project `1477285` using the upload API at `https://wow.curseforge.com/api/projects/1477285/upload-file` with hardcoded game version ID `14300`.

#### Scenario: Successful upload
- **WHEN** the CurseForge API returns HTTP 200
- **THEN** the workflow succeeds

#### Scenario: Upload failure
- **WHEN** the CurseForge API returns a non-200 status
- **THEN** the workflow fails with an error message including the HTTP status and response body

### Requirement: Authentication via secret
The workflow SHALL authenticate to the CurseForge API using the `CF_API_KEY` repository secret passed in the `X-Api-Token` header.

#### Scenario: Secret is configured
- **WHEN** `CF_API_KEY` secret is set in the repository
- **THEN** the upload authenticates successfully

### Requirement: No 3rd party action dependencies
The workflow SHALL only use `actions/checkout@v4` as an external action. All other logic SHALL use shell commands.

#### Scenario: Workflow dependencies
- **WHEN** the workflow is examined
- **THEN** the only `uses:` reference is `actions/checkout@v4`
