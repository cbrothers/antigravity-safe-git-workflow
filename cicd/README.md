# CI/CD Pipelines - Quick Reference

## 🚀 Quick Setup

### GitHub Actions
```powershell
# Initialize pipeline
.agent\scripts\Setup-Pipeline.ps1 -Action "init" -Provider "github-actions"

# Validate configuration
.agent\scripts\Setup-Pipeline.ps1 -Action "validate" -Provider "github-actions"
```

### GitLab CI
```powershell
# Initialize pipeline
.agent\scripts\Setup-Pipeline.ps1 -Action "init" -Provider "gitlab-ci"

# Validate configuration
.agent\scripts\Setup-Pipeline.ps1 -Action "validate" -Provider "gitlab-ci"
```

### Azure DevOps
```powershell
# Initialize pipeline
.agent\scripts\Setup-Pipeline.ps1 -Action "init" -Provider "azure-devops"
```

## 📋 Pipeline Templates

### Available Templates
- `github-actions-complete.yml` - Full GitHub Actions pipeline
- `gitlab-ci-complete.yml` - Full GitLab CI pipeline
- `azure-pipelines-complete.yml` - Full Azure DevOps pipeline

### Template Features
- ✅ Build and test
- ✅ Security scanning (Trivy, npm audit)
- ✅ Code quality (SonarCloud)
- ✅ Docker image building
- ✅ Multi-environment deployment
- ✅ Smoke tests
- ✅ Notifications (Slack)

## 🔧 Common Customizations

### Add Environment Variables
```yaml
# GitHub Actions
env:
  NODE_VERSION: '18'
  API_URL: ${{ secrets.API_URL }}

# GitLab CI
variables:
  NODE_VERSION: "18"
  API_URL: $API_URL
```

### Add Secrets
```powershell
# GitHub: Settings → Secrets and variables → Actions
# GitLab: Settings → CI/CD → Variables
# Azure: Pipelines → Library → Variable groups
```

### Matrix Testing
```yaml
# Test multiple versions
strategy:
  matrix:
    node-version: [16, 18, 20]
    os: [ubuntu-latest, windows-latest]
```

## 🎯 Deployment Strategies

### Blue-Green
```yaml
- name: Deploy to green
  run: ./deploy.sh green
- name: Switch traffic
  run: ./switch.sh green
```

### Canary
```yaml
- name: Deploy 10%
  run: ./deploy-canary.sh 10
- name: Monitor
  run: sleep 300
- name: Deploy 100%
  run: ./deploy-canary.sh 100
```

## 🔒 Security Best Practices

- [ ] Use secrets management
- [ ] Scan dependencies (npm audit)
- [ ] Scan containers (Trivy)
- [ ] Run SAST tools
- [ ] Require code review
- [ ] Use signed commits
- [ ] Implement branch protection

## 📊 Monitoring

### Key Metrics
- Build success rate
- Build duration
- Test coverage
- Deployment frequency
- Mean time to recovery (MTTR)

### Notifications
- Slack for build status
- Email for failures
- GitHub/GitLab comments on PRs

## 📚 Learn More

- [CI/CD Pipelines Workflow](../workflows/cicd-pipelines.md)
- [GitHub Actions Docs](https://docs.github.com/actions)
- [GitLab CI Docs](https://docs.gitlab.com/ee/ci/)
- [Azure Pipelines Docs](https://docs.microsoft.com/azure/devops/pipelines/)
