## 1. Create Workflow File

- [x] 1.1 Create `.github/workflows/release.yml` with tag push trigger (`v*` pattern)
- [x] 1.2 Add checkout step with `actions/checkout@v4` and `fetch-depth: 0`
- [x] 1.3 Add version extraction step (strip `v` prefix from `GITHUB_REF_NAME`)
- [x] 1.4 Add changelog generation step (`git log` between previous and current tag)
- [x] 1.5 Add packaging step (create `PVPAuraDetector/` directory, copy `.toc` and `.lua`, zip)
- [x] 1.6 Add CurseForge upload step (`curl` POST to upload API with hardcoded project ID `1477285`, game version ID `14300`, `CF_API_KEY` secret, and error handling)
