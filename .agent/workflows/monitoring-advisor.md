---
description: Monitoring strategy and observability setup advisor
---

# Monitoring & Observability Advisor

Comprehensive monitoring strategy and implementation guidance for production systems.

## Overview

Design and implement effective monitoring, alerting, and observability solutions tailored to your infrastructure and application needs.

## Usage

```powershell
# Analyze monitoring needs
.agent/scripts/Setup-Monitoring.ps1 -Action "analyze"

# Get monitoring recommendations
.agent/scripts/Setup-Monitoring.ps1 -Action "recommend"

# Generate monitoring configuration
.agent/scripts/Setup-Monitoring.ps1 -Action "configure" -Stack "prometheus"

# Setup alerts
.agent/scripts/Setup-Monitoring.ps1 -Action "alerts"
```

## The Three Pillars of Observability

### 1. Metrics
**What to measure:**
- **Infrastructure**: CPU, memory, disk, network
- **Application**: Request rate, error rate, duration
- **Business**: User signups, transactions, revenue

**Tools:**
- Prometheus + Grafana (open source)
- DataDog (SaaS)
- New Relic (SaaS)
- CloudWatch (AWS)
- Azure Monitor (Azure)

### 2. Logs
**What to log:**
- **Application logs**: Errors, warnings, info
- **Access logs**: HTTP requests, API calls
- **Audit logs**: Security events, data changes
- **System logs**: OS events, service status

**Tools:**
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Loki + Grafana
- Splunk
- CloudWatch Logs
- Azure Log Analytics

### 3. Traces
**What to trace:**
- **Request flows**: End-to-end request paths
- **Service dependencies**: Call graphs
- **Performance bottlenecks**: Slow operations
- **Error propagation**: Failure chains

**Tools:**
- Jaeger (open source)
- Zipkin (open source)
- DataDog APM
- New Relic APM
- AWS X-Ray

## Monitoring Strategy by Scale

### Small Team/Startup
```
Metrics: Prometheus + Grafana
Logs: Loki + Grafana
Traces: Jaeger (if needed)
Alerts: Grafana Alerting
Cost: ~$0-100/month
```

### Medium Business
```
Metrics: DataDog or New Relic
Logs: DataDog or Splunk Cloud
Traces: DataDog APM
Alerts: Integrated alerting
Cost: ~$500-2000/month
```

### Enterprise
```
Metrics: Prometheus + Thanos (multi-cluster)
Logs: ELK Stack or Splunk Enterprise
Traces: Jaeger or custom solution
Alerts: PagerDuty + custom rules
Cost: ~$5000+/month
```

## Key Metrics to Monitor

### Golden Signals (SRE)
1. **Latency**: How long requests take
2. **Traffic**: How many requests
3. **Errors**: How many requests fail
4. **Saturation**: How full your resources are

### RED Method (Services)
- **Rate**: Requests per second
- **Errors**: Failed requests per second
- **Duration**: Request latency distribution

### USE Method (Resources)
- **Utilization**: % time resource is busy
- **Saturation**: Amount of queued work
- **Errors**: Error count

## Alert Design

### Alert Levels

**Critical (Page)**
- Service completely down
- Data loss occurring
- Security breach detected
- Payment processing failed

**High (Notify)**
- High error rate (>5%)
- Slow response times (>2s p95)
- Disk space critical (>90%)
- Memory pressure

**Medium (Ticket)**
- Elevated error rate (>1%)
- Moderate slowness
- Disk space warning (>80%)
- Certificate expiring soon

**Low (Log)**
- Minor issues
- Informational events
- Trend warnings

### Alert Best Practices

**DO:**
- Alert on symptoms, not causes
- Include runbook links
- Set appropriate thresholds
- Use time windows (5m, 15m)
- Test alerts regularly

**DON'T:**
- Alert on everything
- Create noisy alerts
- Alert without action items
- Use static thresholds for dynamic systems
- Forget to document

## Dashboard Design

### Executive Dashboard
- System uptime
- Active users
- Revenue metrics
- Critical alerts

### Operations Dashboard
- Service health
- Resource utilization
- Error rates
- Deployment status

### Developer Dashboard
- API performance
- Database queries
- Cache hit rates
- Background jobs

### Business Dashboard
- User signups
- Conversion rates
- Feature usage
- Customer metrics

## Monitoring Configuration Examples

### Prometheus Configuration
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'application'
    static_configs:
      - targets: ['localhost:9090']
    
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']

rule_files:
  - 'alerts.yml'
```

### Alert Rules
```yaml
groups:
  - name: application
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors/sec"
          
      - alert: HighLatency
        expr: histogram_quantile(0.95, http_request_duration_seconds) > 2
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "P95 latency is {{ $value }}s"
```

## SLO/SLA Monitoring

### Service Level Objectives
```
Availability SLO: 99.9% uptime
  = 43.2 minutes downtime/month allowed

Latency SLO: 95% of requests < 200ms
  = 5% can be slower

Error Rate SLO: < 0.1% errors
  = 999 successful requests per 1000
```

### Error Budget
```
Monthly error budget = (1 - SLO) × Total requests
Example: (1 - 0.999) × 10M = 10,000 errors allowed
```

## Cost Optimization

### Reduce Monitoring Costs
- Sample high-volume metrics
- Aggregate before storing
- Set retention policies
- Use tiered storage
- Filter noisy logs

### Free/Open Source Stack
```
Prometheus: Metrics collection
Grafana: Visualization
Loki: Log aggregation
Jaeger: Distributed tracing
AlertManager: Alert routing

Total cost: Infrastructure only (~$50-200/month)
```

## Implementation Checklist

### Phase 1: Foundation
- [ ] Choose monitoring stack
- [ ] Deploy metrics collection
- [ ] Create basic dashboards
- [ ] Set up log aggregation
- [ ] Configure basic alerts

### Phase 2: Enhancement
- [ ] Add custom metrics
- [ ] Create service dashboards
- [ ] Implement SLO tracking
- [ ] Set up distributed tracing
- [ ] Document runbooks

### Phase 3: Optimization
- [ ] Tune alert thresholds
- [ ] Add anomaly detection
- [ ] Implement auto-remediation
- [ ] Create executive dashboards
- [ ] Regular review process

## Monitoring as Code

### Terraform Example
```hcl
resource "datadog_monitor" "high_error_rate" {
  name    = "High Error Rate"
  type    = "metric alert"
  message = "Error rate is above threshold @pagerduty"
  
  query = "avg(last_5m):sum:http.errors{*} > 100"
  
  thresholds = {
    critical = 100
    warning  = 50
  }
}
```

### Grafana Dashboard as Code
```json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      }
    ]
  }
}
```

## Troubleshooting Monitoring

| Issue | Solution |
|-------|----------|
| Too many alerts | Increase thresholds, add time windows |
| Missing data | Check scrape configs, verify exporters |
| High costs | Reduce retention, sample metrics |
| Slow dashboards | Optimize queries, add caching |
| Alert fatigue | Consolidate alerts, improve thresholds |
