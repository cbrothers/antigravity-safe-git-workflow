---
description: Logging strategy and centralized logging setup
---

# Logging Strategy & Setup

Comprehensive logging implementation guide for structured, centralized, and actionable logs.

## Overview

Implement effective logging practices that enable debugging, monitoring, and compliance while managing costs.

## Usage

```powershell
# Analyze current logging
.agent/scripts/Setup-Logging.ps1 -Action "analyze"

# Get logging recommendations
.agent/scripts/Setup-Logging.ps1 -Action "recommend"

# Generate logging configuration
.agent/scripts/Setup-Logging.ps1 -Action "configure" -Framework "serilog"

# Setup log aggregation
.agent/scripts/Setup-Logging.ps1 -Action "aggregate" -Stack "elk"
```

## Logging Levels

### Standard Levels (RFC 5424)
```
TRACE   - Very detailed, typically only in development
DEBUG   - Detailed information for diagnosing issues
INFO    - General informational messages
WARN    - Warning messages, potential issues
ERROR   - Error messages, handled exceptions
FATAL   - Critical errors, application crash
```

### When to Use Each Level

**TRACE/DEBUG** - Development only
```csharp
logger.Debug("Processing user {UserId} with {ItemCount} items", userId, items.Count);
```

**INFO** - Important business events
```csharp
logger.Info("User {UserId} completed checkout for ${Amount}", userId, total);
```

**WARN** - Recoverable issues
```csharp
logger.Warn("API rate limit approaching: {Current}/{Limit}", current, limit);
```

**ERROR** - Handled errors
```csharp
logger.Error(ex, "Failed to process payment for order {OrderId}", orderId);
```

**FATAL** - Unrecoverable errors
```csharp
logger.Fatal(ex, "Database connection lost, shutting down");
```

## Structured Logging

### Bad (Unstructured)
```csharp
logger.Info("User john@example.com logged in from 192.168.1.1");
```

### Good (Structured)
```csharp
logger.Info("User login", new {
    Email = "john@example.com",
    IpAddress = "192.168.1.1",
    UserAgent = userAgent,
    Timestamp = DateTime.UtcNow
});
```

### Benefits
- Easy to search and filter
- Machine-readable
- Enables analytics
- Consistent format

## What to Log

### DO Log
✅ User actions (login, logout, purchases)
✅ API calls (endpoint, duration, status)
✅ Errors and exceptions (with context)
✅ Performance metrics (slow queries, timeouts)
✅ Security events (failed logins, permission denials)
✅ Business events (orders, payments, signups)

### DON'T Log
❌ Passwords or secrets
❌ Credit card numbers
❌ Personal identifiable information (PII)
❌ Session tokens
❌ API keys
❌ Excessive debug info in production

## Logging Frameworks

### .NET - Serilog
```csharp
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .WriteTo.Console()
    .WriteTo.File("logs/app-.txt", rollingInterval: RollingInterval.Day)
    .WriteTo.Elasticsearch(new ElasticsearchSinkOptions(new Uri("http://localhost:9200")))
    .CreateLogger();

Log.Information("Application starting");
```

### Node.js - Winston
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

### Python - structlog
```python
import structlog

logger = structlog.get_logger()
logger.info("user.login", user_id=123, ip="192.168.1.1")
```

### PowerShell - Custom
```powershell
function Write-StructuredLog {
    param(
        [string]$Level,
        [string]$Message,
        [hashtable]$Properties
    )
    
    $logEntry = @{
        Timestamp = (Get-Date).ToUniversalTime().ToString("o")
        Level = $Level
        Message = $Message
        Properties = $Properties
    } | ConvertTo-Json -Compress
    
    Add-Content -Path "app.log" -Value $logEntry
}

Write-StructuredLog -Level "INFO" -Message "User login" -Properties @{
    UserId = 123
    IpAddress = "192.168.1.1"
}
```

## Log Aggregation Stacks

### ELK Stack (Elasticsearch, Logstash, Kibana)
**Best for:** Large-scale, complex queries

```yaml
# Logstash configuration
input {
  file {
    path => "/var/log/app/*.log"
    type => "application"
  }
}

filter {
  json {
    source => "message"
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "app-logs-%{+YYYY.MM.dd}"
  }
}
```

### Loki + Grafana
**Best for:** Cost-effective, Prometheus users

```yaml
# Promtail configuration
server:
  http_listen_port: 9080

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: application
    static_configs:
      - targets:
          - localhost
        labels:
          job: app
          __path__: /var/log/app/*.log
```

### Splunk
**Best for:** Enterprise, compliance

```
# inputs.conf
[monitor:///var/log/app]
disabled = false
index = application
sourcetype = json
```

## Log Retention Policies

### Recommended Retention
```
Hot Storage (SSD):
  - ERROR/FATAL: 30 days
  - WARN: 14 days
  - INFO: 7 days
  - DEBUG: 1 day

Warm Storage (HDD):
  - ERROR/FATAL: 1 year
  - WARN: 90 days
  - INFO: 30 days

Cold Storage (Archive):
  - ERROR/FATAL: 7 years (compliance)
  - WARN: 1 year
```

### Cost Optimization
- Compress old logs
- Sample high-volume logs
- Filter noisy logs
- Use tiered storage
- Set automatic deletion

## Log Correlation

### Request ID Pattern
```csharp
// Generate request ID
var requestId = Guid.NewGuid().ToString();
HttpContext.Items["RequestId"] = requestId;

// Include in all logs
logger.Info("Processing request", new { RequestId = requestId });

// Return in response headers
response.Headers.Add("X-Request-Id", requestId);
```

### Trace Context
```csharp
// Distributed tracing
var traceId = Activity.Current?.TraceId.ToString();
var spanId = Activity.Current?.SpanId.ToString();

logger.Info("API call", new {
    TraceId = traceId,
    SpanId = spanId,
    Service = "payment-service"
});
```

## Security & Compliance

### PII Redaction
```csharp
public class PiiRedactor
{
    public static string Redact(string input)
    {
        // Redact email
        input = Regex.Replace(input, @"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b", "[EMAIL]");
        
        // Redact credit card
        input = Regex.Replace(input, @"\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b", "[CARD]");
        
        // Redact SSN
        input = Regex.Replace(input, @"\b\d{3}-\d{2}-\d{4}\b", "[SSN]");
        
        return input;
    }
}
```

### Audit Logging
```csharp
logger.Info("Audit.DataAccess", new {
    UserId = currentUser.Id,
    Action = "READ",
    Resource = "customer-data",
    CustomerId = customerId,
    Timestamp = DateTime.UtcNow,
    IpAddress = request.IpAddress
});
```

## Performance Considerations

### Async Logging
```csharp
// Don't block application
logger.InfoAsync("High volume event", data);
```

### Sampling
```csharp
// Log only 10% of requests
if (Random.Shared.Next(100) < 10)
{
    logger.Debug("Request details", details);
}
```

### Buffering
```csharp
// Batch writes
var bufferConfig = new BufferingSinkOptions
{
    BufferSize = 100,
    FlushInterval = TimeSpan.FromSeconds(5)
};
```

## Monitoring Logs

### Key Metrics to Track
- Error rate by service
- Log volume by level
- Response time for log queries
- Storage usage and growth
- Failed log deliveries

### Alerts on Logs
```
Alert: High error rate
Condition: ERROR count > 100 in 5 minutes
Action: Page on-call

Alert: New fatal error
Condition: FATAL level log appears
Action: Immediate notification

Alert: Disk space for logs
Condition: Log storage > 80%
Action: Cleanup or expand storage
```

## Best Practices Checklist

- [ ] Use structured logging (JSON)
- [ ] Include correlation IDs
- [ ] Set appropriate log levels
- [ ] Redact sensitive data
- [ ] Implement log rotation
- [ ] Set retention policies
- [ ] Monitor log volume
- [ ] Test log queries
- [ ] Document log schema
- [ ] Regular log reviews
