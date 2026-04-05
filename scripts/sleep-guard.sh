#!/bin/bash
# sleep-guard: Keeps sleep disabled while battery is above threshold.
# Re-enables sleep when: on battery and idle for 2+ hours OR battery < threshold.
# Also restores disablesleep if a monitor/display change wiped the setting,
# but only when ~/.sleep-guard-active exists (set by DontSleep.myscript).

IDLE_THRESHOLD=7200  # 2 hours in seconds
BATTERY_THRESHOLD=10 # percent — below this, allow sleep
SENTINEL="$HOME/.sleep-guard-active"

# Get battery percentage and charging status
battery_percent=$(pmset -g batt | grep -oE '[0-9]+%' | tr -d '%')
on_battery=$(pmset -g batt | grep -c "Battery Power")

# Check if sleep is currently disabled
sleep_disabled=$(pmset -g | awk '/SleepDisabled/ {print $2}')

# --- Restore path: re-disable sleep if it was cleared (e.g. by a display change) ---
# Only act if the user intentionally disabled sleep via DontSleep.myscript
if [[ "$sleep_disabled" -ne 1 && -f "$SENTINEL" ]]; then
    if [[ -n "$battery_percent" && "$battery_percent" -le "$BATTERY_THRESHOLD" ]]; then
        # Battery too low — honour the threshold, clean up sentinel
        logger -t sleep-guard "Battery at ${battery_percent}% — not restoring, removing sentinel"
        rm -f "$SENTINEL"
    else
        logger -t sleep-guard "SleepDisabled was cleared (battery: ${battery_percent}%) — restoring"
        sudo pmset -a disablesleep 1
    fi
    exit 0
fi

# --- Release path: allow sleep when on battery and a condition is met ---
# Nothing to release if on charger or sentinel is absent
if [[ "$on_battery" -eq 0 || ! -f "$SENTINEL" ]]; then
    exit 0
fi

# Get idle time in seconds (milliseconds from ioreg / 1000000000)
idle_ms=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF; exit}')
idle_seconds=$((idle_ms / 1000000000))

should_sleep=0

if [[ "$idle_seconds" -ge "$IDLE_THRESHOLD" ]]; then
    logger -t sleep-guard "Idle for ${idle_seconds}s (threshold: ${IDLE_THRESHOLD}s) on battery — enabling sleep"
    should_sleep=1
fi

if [[ -n "$battery_percent" && "$battery_percent" -le "$BATTERY_THRESHOLD" ]]; then
    logger -t sleep-guard "Battery at ${battery_percent}% (threshold: ${BATTERY_THRESHOLD}%) — enabling sleep"
    should_sleep=1
fi

if [[ "$should_sleep" -eq 1 ]]; then
    rm -f "$SENTINEL"
    sudo pmset -a disablesleep 0
    # Trigger sleep immediately if battery is critical
    if [[ -n "$battery_percent" && "$battery_percent" -le 5 ]]; then
        logger -t sleep-guard "Battery critical (${battery_percent}%) — sleeping now"
        sudo pmset sleepnow
    fi
fi
