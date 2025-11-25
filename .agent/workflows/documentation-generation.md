---
description: Automated code documentation generation workflow
---

# Code Documentation Generator

Automatically generate comprehensive documentation from your codebase.

## Overview

Extract documentation from code comments, function signatures, and structure to create readable documentation.

## Usage

```powershell
# Generate documentation for entire project
.agent/scripts/Generate-Documentation.ps1

# Generate for specific directory
.agent/scripts/Generate-Documentation.ps1 -Path "src/core"

# Generate API reference
.agent/scripts/Generate-Documentation.ps1 -Type "api"

# Generate with examples
.agent/scripts/Generate-Documentation.ps1 -IncludeExamples
```

## What Gets Documented

### PowerShell Scripts
- Comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, etc.)
- Function signatures and parameters
- Examples and usage patterns
- Return types and error handling

### JavaScript/TypeScript
- JSDoc comments
- Function/class documentation
- Type definitions
- Module exports

### Python
- Docstrings (Google/NumPy/Sphinx style)
- Type hints
- Class and method documentation
- Module-level documentation

### C#
- XML documentation comments
- Method signatures
- Property documentation
- Namespace organization

## Output Formats

### Markdown (Default)
```powershell
.agent/scripts/Generate-Documentation.ps1 -Format "markdown"
```

Creates:
- `docs/README.md` - Overview
- `docs/api/` - API reference
- `docs/guides/` - Usage guides
- `docs/examples/` - Code examples

### HTML
```powershell
.agent/scripts/Generate-Documentation.ps1 -Format "html"
```

Generates static HTML site with:
- Navigation
- Search functionality
- Syntax highlighting
- Responsive design

### JSON
```powershell
.agent/scripts/Generate-Documentation.ps1 -Format "json"
```

Machine-readable format for:
- IDE integration
- Custom documentation tools
- API documentation sites

## Documentation Structure

```
docs/
├── README.md                 # Project overview
├── getting-started.md        # Quick start guide
├── api/
│   ├── functions.md         # Function reference
│   ├── classes.md           # Class documentation
│   └── modules.md           # Module documentation
├── guides/
│   ├── installation.md      # Setup instructions
│   ├── configuration.md     # Configuration guide
│   └── troubleshooting.md   # Common issues
└── examples/
    ├── basic-usage.md       # Simple examples
    └── advanced.md          # Advanced patterns
```

## Best Practices

### Writing Documentable Code

**PowerShell:**
```powershell
<#
.SYNOPSIS
    Brief description of what the function does

.DESCRIPTION
    Detailed explanation of functionality

.PARAMETER Name
    Description of the parameter

.EXAMPLE
    Example-Function -Name "test"
    
    Shows how to use the function

.NOTES
    Additional information
#>
function Example-Function {
    param([string]$Name)
    # Implementation
}
```

**JavaScript:**
```javascript
/**
 * Brief description
 * 
 * @param {string} name - Parameter description
 * @returns {Object} Return value description
 * @example
 * exampleFunction('test')
 */
function exampleFunction(name) {
    // Implementation
}
```

**Python:**
```python
def example_function(name: str) -> dict:
    """
    Brief description
    
    Args:
        name: Parameter description
        
    Returns:
        Return value description
        
    Example:
        >>> example_function('test')
        {'result': 'test'}
    """
    # Implementation
```

## Automation

### Pre-Commit Hook
```powershell
# Regenerate docs before commit
.agent/scripts/Generate-Documentation.ps1
git add docs/
```

### CI/CD Integration
```yaml
- name: Generate Documentation
  run: |
    pwsh .agent/scripts/Generate-Documentation.ps1
    
- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./docs
```

## Customization

### Configuration File
Create `.agent/docs-config.json`:

```json
{
  "title": "My Project Documentation",
  "version": "1.0.0",
  "exclude": ["tests/", "*.Tests.ps1"],
  "include_private": false,
  "theme": "default",
  "output_dir": "docs"
}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Missing documentation | Ensure code has proper comment blocks |
| Incorrect parsing | Check comment format matches language standards |
| Broken links | Verify file paths and references |
| Outdated docs | Set up automated regeneration |
