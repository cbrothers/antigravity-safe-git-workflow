#!/usr/bin/env bash
# --------------------------------------------------------------
# Antigravity Redis Monitor Wrapper
# --------------------------------------------------------------
# This script sets the REDISCLI_AUTH environment variable so that
# redis-cli does NOT emit the "Using a password with '-a'" warning.
# It then invokes the monitor-redis.sh script.
# --------------------------------------------------------------

# ---- Configuration ------------------------------------------------
REDIS_HOST="10.10.1.53"
REDIS_PORT=6379
# Keep the password out of the command line – you can also read it from a
# file (e.g. ~/.redispass) for extra security.
REDIS_PASS="AntigravityCache2024!"
# ------------------------------------------------------------------

# Export the password for redis-cli (suppresses the warning)
export REDISCLI_AUTH="$REDIS_PASS"

# Run the monitor script (assumes it lives in the same directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/monitor-redis.sh" -h "$REDIS_HOST" -p "$REDIS_PORT"
