---
id: task-124
title: Automate metadata-relay build and publish on version releases
status: Done
assignee: []
created_date: '2025-11-09 02:37'
updated_date: '2025-11-09 02:44'
labels:
  - metadata-relay
  - devops
  - automation
  - ci-cd
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Set up automated CI/CD pipeline to build and publish the metadata-relay package whenever a new version is released.

This should include:
- GitHub Actions workflow (or similar CI/CD) triggered on version tags/releases
- Docker image build and push to container registry (Docker Hub, GHCR, etc.)
- Automated deployment to fly.io on new releases
- Version tagging strategy aligned with the package version
- Build verification and testing before publish
- Release notes generation from changelog/commits

Current state: Manual deployment using `fly deploy`
Goal: Fully automated release pipeline triggered by git tags (e.g., `v0.2.0`)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 GitHub Actions workflow triggers on metadata-relay version tags (metadata-relay-v*)
- [ ] #2 Docker image builds successfully from metadata-relay directory
- [ ] #3 Image is pushed to GitHub Container Registry (GHCR) with proper tags
- [ ] #4 Automatic deployment to fly.io occurs on release
- [ ] #5 Health check verification runs after deployment
- [ ] #6 GitHub release is created with deployment notes
- [ ] #7 CI workflow runs tests and build verification on all changes
- [ ] #8 Documentation includes setup instructions for FLY_API_TOKEN secret
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Summary

Created a complete automated CI/CD pipeline for the metadata-relay service:

### Files Created

1. **.github/workflows/metadata-relay-ci.yml**
   - Runs on push/PR to metadata-relay directory
   - Executes tests, formatting checks, dependency checks
   - Builds Docker image to verify build succeeds
   - Uses proper working directory and caching for metadata-relay

2. **.github/workflows/metadata-relay-release.yml**
   - Triggers on tags matching `metadata-relay-v*` pattern
   - Builds multi-platform Docker images (amd64, arm64)
   - Pushes to GHCR with semantic version tags
   - Deploys to fly.io automatically
   - Verifies deployment with health check
   - Creates GitHub release with detailed notes

3. **metadata-relay/RELEASE_SETUP.md**
   - Complete setup guide for first-time configuration
   - Instructions for obtaining and adding FLY_API_TOKEN
   - Troubleshooting guide
   - Release checklist

### Updated Files

1. **metadata-relay/README.md**
   - Added "Automated Releases" section with step-by-step guide
   - Added "Continuous Integration" section explaining workflows
   - Documented versioning strategy and tag format
   - Added prerequisites section for automated releases

### Key Features

- **Tag-based releases**: Use `metadata-relay-vX.Y.Z` format
- **Multi-platform builds**: Supports both amd64 and arm64
- **Container registry**: Images pushed to GHCR
- **Automatic deployment**: Deploys to fly.io without manual intervention
- **Health verification**: Checks /health endpoint after deployment
- **GitHub releases**: Auto-creates releases with deployment details

### Usage

To create a release:
```bash
git tag metadata-relay-v0.2.0
git push origin metadata-relay-v0.2.0
```

The workflow handles everything else automatically.

### Prerequisites

One-time setup required:
1. Get fly.io API token: `fly auth token`
2. Add to GitHub Secrets as `FLY_API_TOKEN`

See RELEASE_SETUP.md for detailed instructions.
<!-- SECTION:NOTES:END -->
