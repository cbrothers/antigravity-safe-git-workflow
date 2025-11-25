#!/usr/bin/env bash
# --------------------------------------------------------------
# Antigravity Redis Monitor
# --------------------------------------------------------------
# Shows:
#   • Total keys
#   • Memory usage
#   • Eviction policy stats
#   • Top‑N most‑accessed keys (via the Redis keyspace notifications)
#   • Simple health check (PING)
# --------------------------------------------------------------
# Prerequisites:
#   • redis-cli must be in $PATH (installed with Redis)
#   • The Redis server must have `notify-keyspace-events` enabled
# --------------------------------------------------------------

# ==== Configuration ==================================================
REDIS_HOST="10.10.1.53"
REDIS_PORT=6379
INTERVAL=5          # seconds between refreshes
TOP_N=10            # how many hot keys to show
# =====================================================================

# Helper to run a redis-cli command with auth
redis_cmd() {
    redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" "$@"
}

# Enable keyspace notifications (run once; harmless if already set)
redis_cmd config set notify-keyspace-events "K$"

# Function to print a section header
header() {
    printf "\n\033[1;34m=== %s ===\033[0m\n" "$1"
}

# Main monitoring loop
while true; do
    clear

    # ---- Health ----------------------------------------------------
    header "Health"
    if [[ "$(redis_cmd ping)" == "PONG" ]]; then
        echo -e "\033[1;32m✔ Redis is reachable\033[0m"
    else
        echo -e "\033[1;31m✖ Redis not reachable\033[0m"
    fi

    # ---- General Stats ---------------------------------------------
    header "General Stats"
    redis_cmd info server | grep -E 'redis_version|tcp_port|uptime_in_seconds'
    redis_cmd info memory | grep -E 'used_memory_human|used_memory_peak_human|maxmemory_human|mem_fragmentation_ratio'
    redis_cmd info stats | grep -E 'total_commands_processed|total_connections_received|expired_keys|evicted_keys'

    # ---- Keyspace -------------------------------------------------
    header "Keyspace"
    redis_cmd info keyspace | grep -E '^db'
    # Total keys (sum of keys across all DBs)
    total_keys=$(redis_cmd info keyspace | grep -E '^db' | awk -F',' '{sum+=$1} END{print sum}' | cut -d'=' -f2)
    echo "Total keys across all DBs: $total_keys"

    # ---- Hot Keys (most accessed) ---------------------------------
    header "Top $TOP_N Hot Keys (by idle time)"
    # Use OBJECT IDLETIME: keys with low idle time are hot (approximation)
    hot_keys=$(redis_cmd --scan | while read -r key; do
        idle=$(redis_cmd object idletime "$key" 2>/dev/null || echo 999999)
        echo "$idle $key"
    done | sort -n | head -n "$TOP_N")
    if [[ -z "$hot_keys" ]]; then
        echo "(no keys or idle‑time data unavailable)"
    else
        printf "%-8s %s\n" "Idle(s)" "Key"
        echo "$hot_keys" | while read -r idle key; do
            printf "%-8s %s\n" "$idle" "$key"
        done
    fi

    # ---- Eviction Policy -------------------------------------------
    header "Eviction Policy"
    redis_cmd config get maxmemory-policy | tail -n1

    # ---- Wait -------------------------------------------------------
    sleep "$INTERVAL"

done
