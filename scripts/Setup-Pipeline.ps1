# Setup-Pipeline.ps1
# CI/CD pipeline configuration and management

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("init", "validate", "test-local", "generate-template")]
    [string]$Action,
    
    [ValidateSet("github-actions", "gitlab-ci", "azure-devops")]
    [string]$Provider = "github-actions",
    
    [ValidateSet("nodejs", "python", "dotnet", "go")]
    [string]$ProjectType = "nodejs",
    
    [string]$OutputPath = "."
)

$ErrorActionPreference = "Stop"

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              CI/CD PIPELINE SETUP                             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n🚀 Provider: $Provider | Project: $ProjectType`n" -ForegroundColor Yellow

# ---------------------------------------------------------
# Initialize Pipeline
# ---------------------------------------------------------

if ($Action -eq "init") {
    Write-Host "📝 Initializing $Provider pipeline...`n" -ForegroundColor Cyan
    
    switch ($Provider) {
        "github-actions" {
            $workflowDir = Join-Path $OutputPath ".github/workflows"
            
            if (-not (Test-Path $workflowDir)) {
                New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
                Write-Host "  ✅ Created $workflowDir" -ForegroundColor Green
            }
            
            # Generate CI workflow
            $ciWorkflow = @"
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup environment
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
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
"@
            
            $ciPath = Join-Path $workflowDir "ci.yml"
            $ciWorkflow | Set-Content $ciPath
            Write-Host "  ✅ Created $ciPath" -ForegroundColor Green
            
            # Generate CD workflow
            $cdWorkflow = @"
name: CD

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to staging
        run: |
          echo "Deploying to staging..."
          # Add your deployment script here
      
      - name: Run smoke tests
        run: |
          echo "Running smoke tests..."
          # Add your smoke tests here
  
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
          # Add your deployment script here
"@
            
            $cdPath = Join-Path $workflowDir "cd.yml"
            $cdWorkflow | Set-Content $cdPath
            Write-Host "  ✅ Created $cdPath" -ForegroundColor Green
            
            Write-Host "`n  📝 Next steps:" -ForegroundColor Cyan
            Write-Host "     1. Review and customize workflows in .github/workflows/" -ForegroundColor Gray
            Write-Host "     2. Add secrets in GitHub Settings → Secrets" -ForegroundColor Gray
            Write-Host "     3. Configure environments (staging, production)" -ForegroundColor Gray
            Write-Host "     4. Push to trigger first build" -ForegroundColor Gray
        }
        
        "gitlab-ci" {
            $ciPath = Join-Path $OutputPath ".gitlab-ci.yml"
            
            $gitlabCI = @"
stages:
  - build
  - test
  - deploy

variables:
  NODE_VERSION: "18"

build:
  stage: build
  image: node:`${NODE_VERSION}
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

test:
  stage: test
  image: node:`${NODE_VERSION}
  script:
    - npm ci
    - npm test
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'

deploy-staging:
  stage: deploy
  image: node:`${NODE_VERSION}
  script:
    - echo "Deploying to staging..."
    # Add your deployment script
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy-production:
  stage: deploy
  image: node:`${NODE_VERSION}
  script:
    - echo "Deploying to production..."
    # Add your deployment script
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual
"@
            
            $gitlabCI | Set-Content $ciPath
            Write-Host "  ✅ Created $ciPath" -ForegroundColor Green
            
            Write-Host "`n  📝 Next steps:" -ForegroundColor Cyan
            Write-Host "     1. Review and customize .gitlab-ci.yml" -ForegroundColor Gray
            Write-Host "     2. Add CI/CD variables in GitLab Settings" -ForegroundColor Gray
            Write-Host "     3. Configure environments" -ForegroundColor Gray
            Write-Host "     4. Push to trigger first pipeline" -ForegroundColor Gray
        }
        
        "azure-devops" {
            $pipelinePath = Join-Path $OutputPath "azure-pipelines.yml"
            
            $azurePipeline = @"
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
              versionSpec: `$(nodeVersion)
          
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
              versionSpec: `$(nodeVersion)
          
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
"@
            
            $azurePipeline | Set-Content $pipelinePath
            Write-Host "  ✅ Created $pipelinePath" -ForegroundColor Green
            
            Write-Host "`n  📝 Next steps:" -ForegroundColor Cyan
            Write-Host "     1. Review and customize azure-pipelines.yml" -ForegroundColor Gray
            Write-Host "     2. Create pipeline in Azure DevOps" -ForegroundColor Gray
            Write-Host "     3. Configure service connections" -ForegroundColor Gray
            Write-Host "     4. Set up environments" -ForegroundColor Gray
        }
    }
}

# ---------------------------------------------------------
# Validate Pipeline
# ---------------------------------------------------------

if ($Action -eq "validate") {
    Write-Host "🔍 Validating pipeline configuration...`n" -ForegroundColor Cyan
    
    switch ($Provider) {
        "github-actions" {
            $workflowDir = ".github/workflows"
            
            if (-not (Test-Path $workflowDir)) {
                Write-Host "  ❌ No workflows found in $workflowDir" -ForegroundColor Red
                exit 1
            }
            
            $workflows = Get-ChildItem -Path $workflowDir -Filter "*.yml" -File
            
            if ($workflows.Count -eq 0) {
                Write-Host "  ❌ No workflow files found" -ForegroundColor Red
                exit 1
            }
            
            Write-Host "  Found $($workflows.Count) workflow(s):" -ForegroundColor Gray
            foreach ($workflow in $workflows) {
                Write-Host "    - $($workflow.Name)" -ForegroundColor White
                
                # Basic YAML validation
                try {
                    $content = Get-Content $workflow.FullName -Raw
                    if ($content -match 'on:' -and $content -match 'jobs:') {
                        Write-Host "      ✅ Valid structure" -ForegroundColor Green
                    }
                    else {
                        Write-Host "      ⚠️  Missing required sections" -ForegroundColor Yellow
                    }
                }
                catch {
                    Write-Host "      ❌ Invalid YAML" -ForegroundColor Red
                }
            }
        }
        
        "gitlab-ci" {
            $ciFile = ".gitlab-ci.yml"
            
            if (-not (Test-Path $ciFile)) {
                Write-Host "  ❌ $ciFile not found" -ForegroundColor Red
                exit 1
            }
            
            Write-Host "  ✅ Found $ciFile" -ForegroundColor Green
            
            # Check for required sections
            $content = Get-Content $ciFile -Raw
            $requiredSections = @("stages:", "script:")
            
            foreach ($section in $requiredSections) {
                if ($content -match $section) {
                    Write-Host "    ✅ Contains $section" -ForegroundColor Green
                }
                else {
                    Write-Host "    ⚠️  Missing $section" -ForegroundColor Yellow
                }
            }
        }
    }
}

# ---------------------------------------------------------
# Test Pipeline Locally
# ---------------------------------------------------------

if ($Action -eq "test-local") {
    Write-Host "🧪 Testing pipeline locally...`n" -ForegroundColor Cyan
    
    switch ($Provider) {
        "github-actions" {
            Write-Host "  💡 To test GitHub Actions locally, use 'act':" -ForegroundColor Yellow
            Write-Host "     1. Install: https://github.com/nektos/act" -ForegroundColor Gray
            Write-Host "     2. Run: act -l (list workflows)" -ForegroundColor Gray
            Write-Host "     3. Run: act push (simulate push event)" -ForegroundColor Gray
            Write-Host "     4. Run: act -j build-and-test (run specific job)" -ForegroundColor Gray
        }
        
        "gitlab-ci" {
            Write-Host "  💡 To test GitLab CI locally, use gitlab-runner:" -ForegroundColor Yellow
            Write-Host "     1. Install: https://docs.gitlab.com/runner/install/" -ForegroundColor Gray
            Write-Host "     2. Run: gitlab-runner exec docker build" -ForegroundColor Gray
        }
    }
}

Write-Host ""
