---
description: Dependency tracking and build automation workflow
---

# Build and Dependency Tracking

Automated build process with comprehensive dependency tracking and caching.

## Overview

Track dependencies, optimize builds, and maintain a clean build pipeline.

## Usage

```powershell
# Full build
.agent/scripts/Build-Project.ps1

# Clean build (no cache)
.agent/scripts/Build-Project.ps1 -Clean

# Track dependencies only
.agent/scripts/Build-Project.ps1 -TrackOnly

# Generate dependency graph
.agent/scripts/Build-Project.ps1 -GenerateGraph
```

## Features

### Dependency Tracking
- **File Dependencies**: Track which files depend on others
- **Module Dependencies**: Map module relationships
- **External Dependencies**: Monitor third-party packages
- **Circular Detection**: Identify circular dependencies

### Build Optimization
- **Incremental Builds**: Only rebuild changed files
- **Dependency Caching**: Cache dependency resolution
- **Parallel Builds**: Build independent modules in parallel
- **Build Artifacts**: Track and reuse build outputs

### Dependency Graph
```powershell
# Generate visual dependency graph
.agent/scripts/Build-Project.ps1 -GenerateGraph
```

Creates:
- `build/dependencies.json` - Machine-readable graph
- `build/dependencies.md` - Human-readable documentation
- `build/dependencies.dot` - GraphViz format (if installed)

## Build Process

### 1. Dependency Analysis
```powershell
# Analyze dependencies
.agent/scripts/Build-Project.ps1 -TrackOnly
```

Analyzes:
- Import/require statements
- Module references
- File inclusions
- External packages

### 2. Build Order Calculation
Determines optimal build order based on:
- Dependency graph
- File modification times
- Previous build results

### 3. Incremental Build
```powershell
# Build only changed files
.agent/scripts/Build-Project.ps1
```

Rebuilds:
- Modified files
- Files depending on modified files
- Files with outdated artifacts

### 4. Validation
- Verify all dependencies resolved
- Check for circular dependencies
- Validate build artifacts
- Run post-build tests

## Configuration

Create `.agent/build-config.json`:

```json
{
  "entry_points": ["src/main.ps1"],
  "output_dir": "build",
  "cache_dir": ".build-cache",
  "exclude_patterns": ["*.Tests.ps1", "test/**"],
  "parallel_builds": true,
  "max_parallel": 4,
  "track_external": true
}
```

## Dependency Graph Example

```
main.ps1
├── utils/logger.ps1
├── core/config.ps1
│   └── utils/validator.ps1
└── services/api.ps1
    ├── core/config.ps1
    └── utils/logger.ps1
```

## CI/CD Integration

```yaml
- name: Build Project
  run: |
    pwsh .agent/scripts/Build-Project.ps1
    
- name: Upload Build Artifacts
  uses: actions/upload-artifact@v3
  with:
    name: build-output
    path: build/
    
- name: Cache Dependencies
  uses: actions/cache@v3
  with:
    path: .build-cache
    key: deps-${{ hashFiles('**/*.ps1') }}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Circular dependencies | Review dependency graph, refactor to break cycles |
| Slow builds | Enable caching, use parallel builds |
| Missing dependencies | Check import statements, verify file paths |
| Stale cache | Run clean build with `-Clean` flag |

## Advanced Features

### Custom Build Steps

Add custom build steps in `.agent/build-steps.ps1`:

```powershell
# Pre-build
function Invoke-PreBuild {
    Write-Host "Running pre-build tasks..."
    # Custom logic
}

# Post-build
function Invoke-PostBuild {
    Write-Host "Running post-build tasks..."
    # Custom logic
}
```

### Dependency Hooks

Monitor specific dependencies:

```powershell
# Watch for changes
.agent/scripts/Build-Project.ps1 -Watch
```

Automatically rebuilds when dependencies change.
