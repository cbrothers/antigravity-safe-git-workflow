---
description: Performance profiling and benchmarking workflow
---

# Performance Profiling Workflow

Measure and optimize script performance with automated benchmarking.

## Usage

```powershell
.agent/scripts/Profile-Performance.ps1 -TestScript ".\MyScript.ps1" -Iterations 10
```

## What It Measures

- **Execution time**: Average, min, max, standard deviation
- **Memory usage**: Peak memory consumption
- **Consistency**: Performance variance across runs

## Profiling Process

### 1. Baseline Measurement
```powershell
# Measure current performance
.agent/scripts/Profile-Performance.ps1 -TestScript ".\script.ps1" -Iterations 20
```

### 2. Optimize Code
Make your performance improvements

### 3. Compare Results
```powershell
# Re-measure after optimization
.agent/scripts/Profile-Performance.ps1 -TestScript ".\script.ps1" -Iterations 20
```

### 4. Validate Improvement
Compare the statistics to ensure optimization worked

## Best Practices

- Run at least 10 iterations for statistical significance
- Profile in a clean environment (close other apps)
- Test with realistic data sizes
- Profile both cold start and warm runs
- Document performance requirements

## Example Output

```
⚡ PERFORMANCE PROFILE

  Iterations: 20
  Average:    125.50ms
  Min:        118.20ms
  Max:        142.30ms
  Std Dev:    8.45ms
  
  ✅ Performance is consistent (low variance)
```
