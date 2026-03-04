## Context

The addon is a two-file WoW BCC Anniversary addon (`PVPAuraDetector.toc` + `PVPAuraDetector.lua`). There is no build step, no external dependencies, and no library bundling. Publishing to CurseForge is currently manual.

CurseForge exposes an upload API at `https://wow.curseforge.com/api/projects/{id}/upload-file` accepting multipart form data with a metadata JSON field and a zip file field, authenticated via `X-Api-Token` header.

## Goals / Non-Goals

**Goals:**
- Automatically package and upload the addon to CurseForge on every tag push
- Zero 3rd party action dependencies (only `actions/checkout@v4`)
- Self-contained workflow using standard CLI tools (`zip`, `curl`, `git log`, `jq`)

**Non-Goals:**
- GitHub Releases creation
- WoWInterface or Wago uploads
- Dynamic game version resolution from the API
- `.pkgmeta` support or keyword substitution in source files
- Multi-TOC / multi-flavor packaging

## Decisions

### Workflow trigger: tag push with `v*` pattern
Tags like `v1.0.0` trigger the workflow. The `v` prefix is stripped to derive the version string. This is the standard convention for release tags.

### Hardcoded game version ID
The CurseForge game version ID `14300` (BCC 2.5.5) is hardcoded directly in the workflow. This avoids an API call and removes a runtime dependency. When Blizzard updates the interface version, the workflow file must be updated — this is acceptable since the `.toc` file also needs updating.

### Hardcoded project ID
Project ID `1477285` is hardcoded in the workflow rather than stored as a secret. It's not sensitive information and hardcoding makes the workflow self-documenting.

### Changelog from git log
The changelog sent to CurseForge is generated from `git log` between the previous tag and the current tag. Format: one line per commit. This is simple and requires no manual changelog maintenance.

### Zip structure
The zip contains a single top-level directory `PVPAuraDetector/` with the `.toc` and `.lua` files inside. This matches the WoW addon installation convention where users extract directly into `Interface/AddOns/`.

### Upload via curl
A single `curl` POST with multipart form data. The metadata JSON is constructed inline. Response status code is checked for success (200).

## Risks / Trade-offs

- **Hardcoded version ID becomes stale** → Acceptable: interface version changes are rare and require `.toc` edits anyway, at which point the workflow ID is updated in the same commit.
- **CurseForge API changes or goes down** → Workflow fails visibly in GitHub Actions. No mitigation needed beyond checking the run status.
- **No retry logic** → Single attempt. CurseForge outages are rare and re-running the workflow is trivial.
