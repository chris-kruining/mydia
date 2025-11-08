---
id: task-114.7
title: Update deployment documentation for hardlink requirements
status: Done
assignee: []
created_date: '2025-11-08 01:39'
updated_date: '2025-11-08 01:42'
labels:
  - documentation
  - deployment
  - hardlinks
dependencies: []
parent_task_id: '114'
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update deployment documentation to explain hardlink requirements and provide recommended volume mount configurations that enable hardlinks between download and library directories.

## Background

With the implementation of hardlink support (task 114.1), the deployment documentation needs to be updated to help users configure their volumes correctly to take advantage of hardlinks.

## Key Points to Document

1. **Hardlink Requirement**: Downloads and library directories must be on the same filesystem
2. **Recommended Configuration**: Use a single parent mount point that contains both downloads and media libraries
3. **Benefits**: Zero storage overhead, instant file operations
4. **Fallback Behavior**: Mydia will automatically fall back to copying if hardlinks aren't possible

## Documentation Updates Needed

### README.md - Production Deployment Section

Update the Docker Compose and Docker CLI examples to show the recommended configuration:

**Before (current - separate mounts):**
```yaml
volumes:
  - /path/to/mydia/config:/config
  - /path/to/your/movies:/media/movies
  - /path/to/your/tv:/media/tv  
  - /path/to/your/downloads:/media/downloads
```

**After (recommended - single parent mount):**
```yaml
volumes:
  - /path/to/mydia/config:/config
  - /path/to/your/media:/media  # Single mount for downloads AND libraries
```

Then set paths like:
- `MOVIES_PATH=/media/library/movies`
- `TV_PATH=/media/library/tv`
- Download client configured to save to `/media/downloads`

### Add New Section: "Volume Configuration for Hardlinks"

Add explanation of:
- Why hardlinks require same filesystem
- How to verify volumes are on same filesystem
- Example directory structures
- What happens if volumes are on different filesystems (automatic fallback to copy)

### docs/deployment/DEPLOYMENT.md

Add "Hardlink Configuration" section under "Advanced Configuration" with:
- Detailed explanation of hardlink requirements
- Multiple configuration examples (NAS, local storage, etc.)
- Troubleshooting guide for checking if hardlinks are working
- Performance implications

## Example Documentation Content

```markdown
## Hardlink Support for Efficient Storage

Mydia uses hardlinks by default when importing media, which provides instant file operations with zero storage overhead. Hardlinks allow the same file data to appear in both your download folder and library folder without duplicating the file.

### Requirements

For hardlinks to work, your downloads and library directories must be on the same filesystem. This is automatically handled when you use a single volume mount that contains both directories.

### Recommended Configuration

Mount a single parent directory that contains both your downloads and libraries:

```yaml
volumes:
  - /path/to/your/media:/media
```

Then organize your directories like:
```
/path/to/your/media/
  ├── downloads/          # Download client output
  ├── library/
  │   ├── movies/         # Movies library  
  │   └── tv/             # TV library
```

Configure environment variables:
```yaml
environment:
  - MOVIES_PATH=/media/library/movies
  - TV_PATH=/media/library/tv
```

Configure your download client to save to `/media/downloads`.

### What if I can't use a single mount?

If your downloads and libraries are on different filesystems, Mydia will automatically fall back to copying files. This works fine but uses more storage space and takes longer.
```

## Files to Update

1. `README.md` - Update production deployment examples (lines 119-186)
2. `docs/deployment/DEPLOYMENT.md` - Add new "Hardlink Configuration" section
3. Consider adding to `docs/guides/SETUP_COMPLETE.md` if relevant

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 README production deployment examples show recommended single-mount configuration
- [ ] #2 README includes note about hardlink requirements
- [ ] #3 New "Volume Configuration for Hardlinks" section added with clear examples
- [ ] #4 DEPLOYMENT.md includes detailed hardlink configuration guide
- [ ] #5 Documentation explains automatic fallback behavior
- [ ] #6 Examples show proper directory structure for hardlinks
<!-- SECTION:DESCRIPTION:END -->
<!-- AC:END -->
