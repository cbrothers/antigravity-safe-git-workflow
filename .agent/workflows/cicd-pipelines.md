---
description: CI/CD pipeline automation for continuous integration and deployment
---

# CI/CD Pipelines

Automate build, test, security scanning, and deployment processes with continuous integration and delivery pipelines.

## Overview

CI/CD pipelines automatically build, test, and deploy code changes, ensuring quality and enabling rapid delivery.

## Usage

```powershell
# Generate pipeline configuration
.agent\scripts\Setup-Pipeline.ps1 -Action "init" -Provider "github-actions"

# Validate pipeline
.agent\scripts\Setup-Pipeline.ps1 -Action "validate"

# Test pipeline locally
.agent\scripts\Setup-Pipeline.ps1 -Action "test-local"
```

## Supported Platforms

### GitHub Actions (Recommended for GitHub)
- **Native integration** - Built into GitHub
- **Marketplace** - 10,000+ pre-built actions
- **Matrix builds** - Test multiple versions
- **Secrets management** - Encrypted secrets
- **Free tier** - 2,000 minutes/month for private repos

### GitLab CI/CD
- **Built-in** - Included with GitLab
- **Auto DevOps** - Automatic pipelines
- **Container Registry** - Built-in Docker registry
- **Review apps** - Temporary environments
- **Free tier** - 400 minutes/month

### Azure DevOps Pipelines
- **Multi-platform** - Windows, Linux, macOS
- **YAML pipelines** - Infrastructure as code
- **Artifacts** - Package management
- **Release gates** - Approval workflows
- **Free tier** - 1,800 minutes/month

## Pipeline Stages

### 1. Build
- Compile code
- Install dependencies
- Create artifacts
- Version tagging

### 2. Test
- Unit tests
- Integration tests
- Code coverage
- Performance tests

### 3. Security
- Dependency scanning
- SAST (Static Application Security Testing)
- Secret scanning
- Container scanning

### 4. Deploy
- Staging deployment
- Production deployment
- Rollback capability
- Health checks

## GitHub Actions Examples

### Basic CI Pipeline

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run tests
        run: npm test
      
      - name: Build
        run: npm run build
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-output
          path: dist/
```

### Full CD Pipeline

```yaml
# .github/workflows/cd.yml
name: CD

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
      - run: npm run test:integration
  
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run security scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
      
      - name: Dependency check
        run: npm audit
  
  deploy-staging:
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to staging
        run: |
          echo "Deploying to staging..."
          # Your deployment script
      
      - name: Run smoke tests
        run: npm run test:smoke
  
  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to production
        run: |
          echo "Deploying to production..."
          # Your deployment script
```

### Matrix Testing

```yaml
# .github/workflows/matrix.yml
name: Matrix Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [16, 18, 20]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      
      - run: npm ci
      - run: npm test
```

## GitLab CI/CD Examples

### Basic Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

variables:
  NODE_VERSION: "18"

build:
  stage: build
  image: node:${NODE_VERSION}
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

test:
  stage: test
  image: node:${NODE_VERSION}
  script:
    - npm ci
    - npm test
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'

deploy-staging:
  stage: deploy
  image: node:${NODE_VERSION}
  script:
    - echo "Deploying to staging..."
    # Your deployment script
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy-production:
  stage: deploy
  image: node:${NODE_VERSION}
  script:
    - echo "Deploying to production..."
    # Your deployment script
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual
```

## Azure DevOps Examples

### Basic Pipeline

```yaml
# azure-pipelines.yml
trigger:
  - main
  - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  nodeVersion: '18.x'

stages:
  - stage: Build
    jobs:
      - job: BuildJob
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
          
          - script: npm ci
            displayName: 'Install dependencies'
          
          - script: npm run build
            displayName: 'Build'
          
          - task: PublishBuildArtifacts@1
            inputs:
              pathToPublish: 'dist'
              artifactName: 'drop'

  - stage: Test
    jobs:
      - job: TestJob
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
          
          - script: npm ci
            displayName: 'Install dependencies'
          
          - script: npm test
            displayName: 'Run tests'

  - stage: Deploy
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployProduction
        environment: production
        strategy:
          runOnce:
            deploy:
              steps:
                - script: echo "Deploying to production"
```

## Best Practices

### Pipeline Security

**1. Use Secrets Management**
```yaml
# GitHub Actions
- name: Deploy
  env:
    API_KEY: ${{ secrets.API_KEY }}
  run: ./deploy.sh
```

**2. Scan for Vulnerabilities**
```yaml
- name: Security scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
```

**3. Sign Commits**
```yaml
- name: Verify signatures
  run: git verify-commit HEAD
```

### Performance Optimization

**1. Cache Dependencies**
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

**2. Parallel Jobs**
```yaml
jobs:
  test-unit:
    runs-on: ubuntu-latest
  test-integration:
    runs-on: ubuntu-latest
  # Both run in parallel
```

**3. Conditional Execution**
```yaml
- name: Deploy
  if: github.ref == 'refs/heads/main'
  run: ./deploy.sh
```

### Quality Gates

**1. Required Checks**
```yaml
- name: Code coverage
  run: |
    npm run test:coverage
    if [ $(cat coverage/coverage-summary.json | jq '.total.lines.pct') -lt 80 ]; then
      echo "Coverage below 80%"
      exit 1
    fi
```

**2. Manual Approval**
```yaml
deploy-production:
  environment: production
  # Requires manual approval in GitHub
```

**3. Deployment Windows**
```yaml
- name: Check deployment window
  run: |
    hour=$(date +%H)
    if [ $hour -lt 9 ] || [ $hour -gt 17 ]; then
      echo "Outside deployment window"
      exit 1
    fi
```

## Deployment Strategies

### Blue-Green Deployment

```yaml
- name: Deploy to green
  run: ./deploy.sh green

- name: Run smoke tests
  run: ./smoke-tests.sh green

- name: Switch traffic
  run: ./switch-traffic.sh green

- name: Keep blue for rollback
  run: echo "Blue environment ready for rollback"
```

### Canary Deployment

```yaml
- name: Deploy 10% traffic
  run: ./deploy-canary.sh 10

- name: Monitor metrics
  run: ./monitor.sh --duration 5m

- name: Increase to 50%
  run: ./deploy-canary.sh 50

- name: Full deployment
  run: ./deploy-canary.sh 100
```

## Monitoring & Notifications

### Slack Notifications

```yaml
- name: Notify Slack
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "Build failed: ${{ github.repository }}"
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Email Notifications

```yaml
- name: Send email
  if: failure()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Build Failed
    to: team@example.com
    from: ci@example.com
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Slow builds | Use caching, parallel jobs |
| Flaky tests | Retry failed tests, fix root cause |
| Failed deployments | Implement rollback, improve testing |
| Secret leaks | Use secret scanning, rotate secrets |
| High costs | Optimize build time, use self-hosted runners |
