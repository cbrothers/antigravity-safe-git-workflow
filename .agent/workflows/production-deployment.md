---
description: Automated workflow for deploying changes to Stage and Production
---

# Deployment Pipeline Workflow

This workflow automates the deployment pipeline: **Local -> Stage -> Production**.

## Pipeline Overview

1.  **Dev (Local)**: Run `npm run dev` to test locally.
2.  **Stage**: Deploy to `stage` branch (auto-deploys to `stage.thesilentwhistleband.com`).
3.  **Production**: Promote Stage to `production` branch (auto-deploys to `www.thesilentwhistleband.com`).

## Steps

### 1. Deploy to Stage
Use this when you have new changes on `main` and want to deploy them to the Stage environment.

```bash
# 1. Switch to stage branch
git checkout stage

# 2. Merge changes from main
git merge main

# 3. Push to trigger Cloudflare Pages build
git push origin stage

# 4. Switch back to main
git checkout main
```

### 2. Promote to Production
Use this ONLY after verifying the Stage site works perfectly.

```bash
# 1. Switch to production branch
git checkout production

# 2. Merge changes from stage
git merge stage

# 3. Push to trigger Cloudflare Pages build
git push origin production

# 4. Switch back to main
git checkout main
```

## Benefits
-   **Safety**: Enforces testing on Stage before touching Production.
-   **Consistency**: Production is always a direct merge from Stage.
-   **Automation**: Cloudflare Pages automatically builds and deploys when you push to these branches.
