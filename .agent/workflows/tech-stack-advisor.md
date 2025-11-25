---
description: Technology recommendation and architecture decision workflow
---

# Technology Stack Advisor

AI-assisted technology selection and architecture decision support for system architects.

## Overview

Get intelligent recommendations for technologies, frameworks, and architectural patterns based on your project requirements.

## Usage

```powershell
# Analyze current stack
.agent/scripts/Advise-TechStack.ps1 -Action "analyze"

# Get recommendations for new project
.agent/scripts/Advise-TechStack.ps1 -Action "recommend" -Requirements "requirements.json"

# Compare alternatives
.agent/scripts/Advise-TechStack.ps1 -Action "compare" -Technologies "React,Vue,Angular"

# Generate architecture decision record
.agent/scripts/Advise-TechStack.ps1 -Action "adr" -Decision "Use PostgreSQL"
```

## Features

### Technology Analysis
- **Current Stack Audit**: Analyze existing technologies
- **Compatibility Check**: Verify technology compatibility
- **Version Analysis**: Check for outdated or deprecated tech
- **License Review**: Identify licensing issues

### Recommendation Engine
- **Requirements-Based**: Match tech to your needs
- **Best Practices**: Industry-standard recommendations
- **Scalability Assessment**: Future-proof selections
- **Cost Analysis**: Consider licensing and operational costs

### Decision Documentation
- **Architecture Decision Records (ADRs)**: Document why choices were made
- **Trade-off Analysis**: Compare pros/cons
- **Risk Assessment**: Identify potential issues
- **Migration Paths**: Plan technology transitions

## Requirements File Format

Create `requirements.json`:

```json
{
  "project_type": "web_application",
  "scale": "medium",
  "team_size": 5,
  "requirements": {
    "performance": "high",
    "scalability": "horizontal",
    "security": "high",
    "budget": "moderate"
  },
  "constraints": {
    "existing_infrastructure": ["AWS"],
    "team_expertise": ["JavaScript", "Python"],
    "compliance": ["GDPR", "SOC2"]
  },
  "preferences": {
    "open_source": true,
    "cloud_native": true,
    "managed_services": true
  }
}
```

## Technology Categories

### Frontend
- **Frameworks**: React, Vue, Angular, Svelte
- **Build Tools**: Vite, Webpack, Rollup
- **State Management**: Redux, Zustand, Pinia
- **UI Libraries**: Material-UI, Tailwind, Bootstrap

### Backend
- **Languages**: Node.js, Python, Go, C#, Java
- **Frameworks**: Express, FastAPI, Gin, ASP.NET
- **API Styles**: REST, GraphQL, gRPC
- **Authentication**: OAuth2, JWT, SAML

### Database
- **Relational**: PostgreSQL, MySQL, SQL Server
- **NoSQL**: MongoDB, Redis, Cassandra
- **Time-Series**: InfluxDB, TimescaleDB
- **Graph**: Neo4j, ArangoDB

### Infrastructure
- **Cloud**: AWS, Azure, GCP
- **Containers**: Docker, Kubernetes
- **CI/CD**: GitHub Actions, GitLab CI, Jenkins
- **Monitoring**: Prometheus, Grafana, DataDog

## Architecture Decision Records (ADRs)

### ADR Template

```markdown
# ADR-001: Use PostgreSQL for Primary Database

## Status
Accepted

## Context
We need a reliable, scalable database for our application that supports:
- Complex queries with joins
- ACID transactions
- JSON data types
- Full-text search

## Decision
We will use PostgreSQL 15+ as our primary database.

## Consequences

### Positive
- Mature, battle-tested technology
- Excellent performance for complex queries
- Strong community and ecosystem
- Native JSON support
- Open source with permissive license

### Negative
- Requires operational expertise
- Vertical scaling limitations
- More complex than NoSQL for simple use cases

### Neutral
- Need to implement connection pooling
- Requires backup strategy
- May need read replicas for scale

## Alternatives Considered
- MySQL: Less feature-rich, weaker JSON support
- MongoDB: Better for document storage, weaker for relations
- DynamoDB: Vendor lock-in, different query model
```

## Recommendation Criteria

### Performance
- Throughput requirements
- Latency requirements
- Concurrent users
- Data volume

### Scalability
- Horizontal vs vertical
- Auto-scaling capabilities
- Geographic distribution
- Load balancing

### Security
- Authentication methods
- Encryption (at rest/in transit)
- Compliance requirements
- Audit logging

### Operational
- Deployment complexity
- Monitoring capabilities
- Backup/recovery
- Maintenance overhead

### Team
- Learning curve
- Available expertise
- Community support
- Documentation quality

### Cost
- Licensing fees
- Infrastructure costs
- Operational costs
- Training costs

## Best Practices

### Technology Selection
1. **Start with requirements** - Don't pick tech first
2. **Consider team skills** - Leverage existing expertise
3. **Evaluate maturity** - Avoid bleeding edge for critical systems
4. **Plan for scale** - Think 2-3 years ahead
5. **Document decisions** - Use ADRs for all major choices

### Stack Composition
- **Proven combinations** - Use well-tested stacks
- **Minimize complexity** - Fewer technologies = easier maintenance
- **Standardize** - Consistent tech across projects
- **Stay current** - Regular updates and migrations

## Example Recommendations

### Startup MVP
```
Frontend: React + Vite + Tailwind
Backend: Node.js + Express + PostgreSQL
Infrastructure: Vercel + Supabase
Monitoring: Sentry + Vercel Analytics
```

### Enterprise Application
```
Frontend: Angular + TypeScript + Material-UI
Backend: C# + ASP.NET Core + SQL Server
Infrastructure: Azure App Service + Azure SQL
Monitoring: Application Insights + Azure Monitor
```

### High-Scale SaaS
```
Frontend: Next.js + React + Tailwind
Backend: Go + gRPC + PostgreSQL
Infrastructure: Kubernetes + AWS + CloudFront
Monitoring: Prometheus + Grafana + DataDog
```

## Integration with Development

### Pre-Project
```powershell
# Define requirements
# Get recommendations
.agent/scripts/Advise-TechStack.ps1 -Action "recommend"

# Document decisions
.agent/scripts/Advise-TechStack.ps1 -Action "adr"
```

### During Development
```powershell
# Validate choices
.agent/scripts/Advise-TechStack.ps1 -Action "analyze"

# Compare alternatives
.agent/scripts/Advise-TechStack.ps1 -Action "compare"
```

### Maintenance
```powershell
# Check for updates
.agent/scripts/Manage-Dependencies.ps1 -Action "check"

# Review tech debt
.agent/scripts/Advise-TechStack.ps1 -Action "audit"
```
