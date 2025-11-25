---
description: Deploy web applications to Cloudflare Pages
---

# Cloudflare Pages Deployment Workflow

This workflow provides a complete guide for deploying web applications to Cloudflare Pages using a three-branch strategy for development, staging, and production environments.

## Overview

Cloudflare Pages offers two deployment methods:
1. **Git Integration** (Recommended): Automatic deployments triggered by Git pushes
2. **Direct Upload**: Manual deployments via `wrangler` CLI

## Prerequisites

- Cloudflare account with Pages enabled
- Node.js and npm installed
- Wrangler CLI installed: `npm install -g wrangler`
- Authenticated with Cloudflare: `wrangler login`

## Three-Branch Deployment Strategy

### Branch Structure

```
main        → Development branch (local testing)
stage       → Staging environment (pre-production testing)
production  → Production environment (live site)
```

### Branch Setup

```powershell
# Create and push all branches
git checkout -b stage
git push -u origin stage

git checkout -b production  
git push -u origin production

git checkout main
```

## Deployment Methods

### Method 1: Git Integration (Recommended)

**Setup Steps:**

1. **Connect Repository to Cloudflare**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
   - Navigate to **Workers & Pages** > **Create application** > **Pages** > **Connect to Git**
   - Authorize Cloudflare GitHub App
   - Select your repository

2. **Configure Build Settings**
   - **Project name**: `your-project-name`
   - **Production branch**: `production`
   - **Framework preset**: Select your framework (Vite, Next.js, etc.)
   - **Build command**: `npm run build`
   - **Build output directory**: `dist` (or your framework's output dir)

3. **Configure Branch Deployments**
   - Production: `production` branch → `www.yourdomain.com`
   - Preview: `stage` branch → `stage.yourdomain.com`

**Deployment Workflow:**

```powershell
# Deploy to Stage
git checkout stage
git merge main
git push origin stage
# Cloudflare automatically builds and deploys

# Verify on stage.yourdomain.com

# Promote to Production
git checkout production
git merge stage
git push origin production
# Cloudflare automatically builds and deploys

# Return to main
git checkout main
```

### Method 2: Direct Upload via Wrangler

**Initial Setup:**

```powershell
# Build your project
npm run build

# Deploy to Cloudflare Pages
wrangler pages deploy dist --project-name your-project-name --branch production
```

**Automated Deployment Script:**

Use the provided `Deploy-CloudflarePages.ps1` script:

```powershell
# Deploy to production
.\scripts\Deploy-CloudflarePages.ps1 -Environment production

# Deploy to stage
.\scripts\Deploy-CloudflarePages.ps1 -Environment stage
```

## Common Issues and Solutions

### Issue 1: Git Submodule Error

**Error:**
```
fatal: No url found for submodule path 'folder' in .gitmodules
```

**Solution:**
```powershell
# Remove the submodule reference
git rm --cached folder

# Remove the .git folder inside the directory
Remove-Item -Recurse -Force folder/.git

# Add as regular directory
git add folder/*
git commit -m "fix: Convert submodule to regular directory"
git push
```

### Issue 2: Build Fails on Cloudflare

**Common Causes:**
- Missing dependencies in `package.json`
- Incorrect build command
- Environment variables not set

**Solution:**
1. Test build locally: `npm run build`
2. Check Cloudflare build logs
3. Add environment variables in Cloudflare Dashboard: **Settings** > **Environment variables**

### Issue 3: Deployment Not Updating

**Solutions:**
1. **Hard refresh browser**: `Ctrl + F5` (Windows) or `Cmd + Shift + R` (Mac)
2. **Check deployment status**: Cloudflare Dashboard > Workers & Pages > Your Project > Deployments
3. **Force new deployment**: Make a minor change and commit
4. **Clear Cloudflare cache**: Dashboard > Caching > Purge Everything

### Issue 4: Custom Domain Not Working

**Solution:**
1. Go to Cloudflare Dashboard > Workers & Pages > Your Project > **Custom domains**
2. Click **Set up a custom domain**
3. Enter your domain (e.g., `www.yourdomain.com`)
4. Cloudflare will automatically configure DNS

## Version Injection

To display build version information in your application:

1. **Configure Vite** (or your build tool):

```javascript
// vite.config.js
import { execSync } from 'child_process';

const commitHash = execSync('git rev-parse --short HEAD').toString().trim();
const branch = execSync('git rev-parse --abbrev-ref HEAD').toString().trim();
const date = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14);
const versionString = `Version: ${commitHash}-${date}-${branch}`;

export default defineConfig({
  define: {
    '__APP_VERSION__': JSON.stringify(versionString)
  }
});
```

2. **Display in Your App**:

```javascript
// In your main.js or app initialization
const versionEl = document.getElementById('version');
if (versionEl && typeof __APP_VERSION__ !== 'undefined') {
    versionEl.textContent = __APP_VERSION__;
}
```

3. **HTML Element**:

```html
<!-- Footer or debug area -->
<p id="version" style="font-size: 0.65rem; opacity: 0.2;"></p>
```

## Environment-Specific Configuration

### Using Environment Variables

**In Cloudflare Dashboard:**
1. Go to **Settings** > **Environment variables**
2. Add variables for each environment (Production, Preview)

**In Your Code:**
```javascript
const apiUrl = import.meta.env.VITE_API_URL || 'https://api.production.com';
```

**In `.env` files:**
```
# .env.production
VITE_API_URL=https://api.production.com

# .env.staging  
VITE_API_URL=https://api.staging.com
```

## Monitoring and Rollback

### View Deployment History

1. Go to Cloudflare Dashboard > Workers & Pages > Your Project
2. Click **Deployments** tab
3. View all past deployments with timestamps and commit info

### Rollback to Previous Version

1. Find the working deployment in the history
2. Click **...** menu > **Rollback to this deployment**
3. Confirm rollback

### Alternative: Git-Based Rollback

```powershell
# Find the commit hash of the working version
git log --oneline

# Reset production branch to that commit
git checkout production
git reset --hard <commit-hash>
git push --force origin production
```

## Performance Optimization

### Enable Caching

Cloudflare Pages automatically caches static assets. For additional control:

1. Add `_headers` file to your `public` directory:

```
/*
  Cache-Control: public, max-age=31536000, immutable

/*.html
  Cache-Control: public, max-age=0, must-revalidate

/*.json
  Cache-Control: public, max-age=3600
```

### Enable Compression

Add to `_headers`:

```
/*
  Content-Encoding: gzip
```

## Security Best Practices

### Add Security Headers

Create `public/_headers`:

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  X-XSS-Protection: 1; mode=block
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: geolocation=(), microphone=(), camera=()
```

### Enable HTTPS

Cloudflare Pages automatically provides free SSL certificates. Ensure:
1. **Always Use HTTPS** is enabled in Cloudflare Dashboard
2. **Automatic HTTPS Rewrites** is enabled

## Useful Commands

```powershell
# Check wrangler authentication
wrangler whoami

# List all Pages projects
wrangler pages project list

# View deployment logs
wrangler pages deployment list --project-name your-project-name

# Delete a project
wrangler pages project delete your-project-name
```

## Related Scripts

- `Deploy-CloudflarePages.ps1` - Automated deployment script
- `Get-DeploymentStatus.ps1` - Check deployment status across environments
- `Inject-Version.ps1` - Generate and inject version strings

## Additional Resources

- [Cloudflare Pages Documentation](https://developers.cloudflare.com/pages/)
- [Wrangler CLI Documentation](https://developers.cloudflare.com/workers/wrangler/)
- [Framework Guides](https://developers.cloudflare.com/pages/framework-guides/)
