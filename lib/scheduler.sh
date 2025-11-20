#!/bin/bash
#
# Sparky Beep Scheduler Library
# Manages time-based scheduling and quiet hours
# last update 2025/11/20
#

# Source configuration library
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. "${SCRIPT_DIR}/config.sh" 2>/dev/null || true

#
# Function: is_in_quiet_hours
# Description: Check if current time is within quiet hours
# Usage: is_in_quiet_hours
#
is_in_quiet_hours() {
    # Check if scheduling is enabled
    if [ "$SCHEDULE_ENABLED" != "true" ]; then
        return 1  # Not in quiet hours (scheduling disabled)
    fi

    local current_time=$(date '+%H:%M')
    local current_day=$(date '+%u')  # 1=Monday, 7=Sunday

    # Check if today is in active weekdays
    if [ -n "$ACTIVE_WEEKDAYS" ]; then
        if ! echo "$ACTIVE_WEEKDAYS" | grep -q "$current_day"; then
            return 1  # Today not in active days
        fi
    fi

    # Convert times to minutes since midnight
    local current_minutes=$(time_to_minutes "$current_time")
    local start_minutes=$(time_to_minutes "$QUIET_HOURS_START")
    local end_minutes=$(time_to_minutes "$QUIET_HOURS_END")

    # Handle cases where quiet hours span midnight
    if [ "$start_minutes" -le "$end_minutes" ]; then
        # Normal case: e.g., 22:00 to 23:00
        if [ "$current_minutes" -ge "$start_minutes" ] && [ "$current_minutes" -lt "$end_minutes" ]; then
            return 0  # In quiet hours
        fi
    else
        # Spans midnight: e.g., 22:00 to 07:00
        if [ "$current_minutes" -ge "$start_minutes" ] || [ "$current_minutes" -lt "$end_minutes" ]; then
            return 0  # In quiet hours
        fi
    fi

    return 1  # Not in quiet hours
}

#
# Function: time_to_minutes
# Description: Convert HH:MM time to minutes since midnight
# Usage: time_to_minutes <time>
#
time_to_minutes() {
    local time="$1"
    local hours="${time%%:*}"
    local minutes="${time##*:}"

    # Remove leading zeros
    hours=$((10#$hours))
    minutes=$((10#$minutes))

    echo $((hours * 60 + minutes))
}

#
# Function: minutes_to_time
# Description: Convert minutes since midnight to HH:MM
# Usage: minutes_to_time <minutes>
#
minutes_to_time() {
    local total_minutes="$1"
    local hours=$((total_minutes / 60))
    local minutes=$((total_minutes % 60))

    printf "%02d:%02d" "$hours" "$minutes"
}

#
# Function: should_play_beep
# Description: Determine if a beep should be played based on schedule
# Usage: should_play_beep <service> <event>
#
should_play_beep() {
    local service="$1"
    local event="$2"

    # Check if in quiet hours
    if is_in_quiet_hours; then
        return 1  # Don't play beep
    fi

    # Check custom schedule rules
    for rule_name in "${!SCHEDULE_RULES[@]}"; do
        local rule="${SCHEDULE_RULES[$rule_name]}"

        if apply_schedule_rule "$rule" "$service" "$event"; then
            # Rule matched and returned action
            return $?
        fi
    done

    # Default: play beep
    return 0
}

#
# Function: apply_schedule_rule
# Description: Apply a schedule rule and determine action
# Usage: apply_schedule_rule <rule> <service> <event>
#
apply_schedule_rule() {
    local rule="$1"
    local service="$2"
    local event="$3"

    # Parse rule: service|event|weekdays|start_time|end_time|action
    IFS='|' read -r rule_service rule_event rule_weekdays rule_start rule_end rule_action <<< "$rule"

    # Check if rule applies to this service
    if [ "$rule_service" != "*" ] && [ "$rule_service" != "$service" ]; then
        return 2  # Rule doesn't apply
    fi

    # Check if rule applies to this event
    if [ "$rule_event" != "*" ] && [ "$rule_event" != "$event" ]; then
        return 2  # Rule doesn't apply
    fi

    # Check if rule applies to today
    local current_day=$(date '+%u')
    if [ "$rule_weekdays" != "*" ]; then
        if ! echo "$rule_weekdays" | grep -q "$current_day"; then
            return 2  # Rule doesn't apply to today
        fi
    fi

    # Check if current time is within rule time range
    local current_time=$(date '+%H:%M')
    local current_minutes=$(time_to_minutes "$current_time")
    local start_minutes=$(time_to_minutes "$rule_start")
    local end_minutes=$(time_to_minutes "$rule_end")

    local in_time_range=0

    if [ "$start_minutes" -le "$end_minutes" ]; then
        if [ "$current_minutes" -ge "$start_minutes" ] && [ "$current_minutes" -lt "$end_minutes" ]; then
            in_time_range=1
        fi
    else
        # Spans midnight
        if [ "$current_minutes" -ge "$start_minutes" ] || [ "$current_minutes" -lt "$end_minutes" ]; then
            in_time_range=1
        fi
    fi

    if [ "$in_time_range" -eq 0 ]; then
        return 2  # Not in time range
    fi

    # Apply action
    case "$rule_action" in
        disable|quiet|silent)
            return 1  # Don't play beep
            ;;
        enable|allow|play)
            return 0  # Play beep
            ;;
        *)
            return 2  # Unknown action, continue to next rule
            ;;
    esac
}

#
# Function: add_schedule_rule
# Description: Add a new schedule rule
# Usage: add_schedule_rule <name> <service> <event> <weekdays> <start> <end> <action>
#
add_schedule_rule() {
    local name="$1"
    local service="$2"
    local event="$3"
    local weekdays="$4"
    local start="$5"
    local end="$6"
    local action="$7"

    # Validate time format
    if ! [[ "$start" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        echo "ERROR: Invalid start time format: $start" >&2
        return 1
    fi

    if ! [[ "$end" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        echo "ERROR: Invalid end time format: $end" >&2
        return 1
    fi

    # Create rule
    local rule="${service}|${event}|${weekdays}|${start}|${end}|${action}"
    SCHEDULE_RULES["$name"]="$rule"

    return 0
}

#
# Function: remove_schedule_rule
# Description: Remove a schedule rule
# Usage: remove_schedule_rule <name>
#
remove_schedule_rule() {
    local name="$1"

    if [ -z "${SCHEDULE_RULES[$name]}" ]; then
        echo "ERROR: Schedule rule not found: $name" >&2
        return 1
    fi

    unset SCHEDULE_RULES["$name"]
    return 0
}

#
# Function: list_schedule_rules
# Description: List all schedule rules
# Usage: list_schedule_rules
#
list_schedule_rules() {
    echo "Schedule Rules:"
    echo "==============="

    if [ ${#SCHEDULE_RULES[@]} -eq 0 ]; then
        echo "  (No rules defined)"
        return 0
    fi

    for rule_name in "${!SCHEDULE_RULES[@]}"; do
        local rule="${SCHEDULE_RULES[$rule_name]}"
        IFS='|' read -r service event weekdays start end action <<< "$rule"

        printf "%-20s %-15s %-10s %s-%s  %s  %s\n" \
            "$rule_name" \
            "$service" \
            "$event" \
            "$start" \
            "$end" \
            "$weekdays" \
            "$action"
    done | sort
}

#
# Function: get_next_quiet_period
# Description: Get information about the next quiet period
# Usage: get_next_quiet_period
#
get_next_quiet_period() {
    if [ "$SCHEDULE_ENABLED" != "true" ]; then
        echo "Scheduling is disabled"
        return 1
    fi

    local current_time=$(date '+%H:%M')
    local start_time="$QUIET_HOURS_START"
    local end_time="$QUIET_HOURS_END"

    if is_in_quiet_hours; then
        echo "Currently in quiet hours (until $end_time)"
    else
        echo "Next quiet period: $start_time - $end_time"
    fi
}

#
# Function: validate_time_format
# Description: Validate HH:MM time format
# Usage: validate_time_format <time>
#
validate_time_format() {
    local time="$1"

    if [[ "$time" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        return 0
    else
        return 1
    fi
}

#
# Function: get_weekday_name
# Description: Get weekday name from number
# Usage: get_weekday_name <day_number>
#
get_weekday_name() {
    local day="$1"

    case "$day" in
        1) echo "Monday" ;;
        2) echo "Tuesday" ;;
        3) echo "Wednesday" ;;
        4) echo "Thursday" ;;
        5) echo "Friday" ;;
        6) echo "Saturday" ;;
        7) echo "Sunday" ;;
        *) echo "Invalid" ;;
    esac
}

#
# Function: get_weekday_names
# Description: Get comma-separated weekday names from numbers
# Usage: get_weekday_names <day_numbers>
#
get_weekday_names() {
    local days="$1"
    local names=()

    IFS=',' read -ra day_array <<< "$days"
    for day in "${day_array[@]}"; do
        names+=("$(get_weekday_name "$day")")
    done

    # Join array with commas
    local IFS=','
    echo "${names[*]}"
}

#
# Function: enable_scheduling
# Description: Enable time-based scheduling
# Usage: enable_scheduling
#
enable_scheduling() {
    SCHEDULE_ENABLED="true"
    set_config_value "schedule" "enabled" "true"
}

#
# Function: disable_scheduling
# Description: Disable time-based scheduling
# Usage: disable_scheduling
#
disable_scheduling() {
    SCHEDULE_ENABLED="false"
    set_config_value "schedule" "enabled" "false"
}

#
# Function: set_quiet_hours
# Description: Set quiet hours start and end times
# Usage: set_quiet_hours <start_time> <end_time>
#
set_quiet_hours() {
    local start="$1"
    local end="$2"

    if ! validate_time_format "$start"; then
        echo "ERROR: Invalid start time format: $start" >&2
        return 1
    fi

    if ! validate_time_format "$end"; then
        echo "ERROR: Invalid end time format: $end" >&2
        return 1
    fi

    QUIET_HOURS_START="$start"
    QUIET_HOURS_END="$end"

    set_config_value "schedule" "quiet_hours_start" "$start"
    set_config_value "schedule" "quiet_hours_end" "$end"

    return 0
}

# Export functions
export -f is_in_quiet_hours
export -f time_to_minutes
export -f minutes_to_time
export -f should_play_beep
export -f apply_schedule_rule
export -f add_schedule_rule
export -f remove_schedule_rule
export -f list_schedule_rules
export -f get_next_quiet_period
export -f validate_time_format
export -f get_weekday_name
export -f get_weekday_names
export -f enable_scheduling
export -f disable_scheduling
export -f set_quiet_hours
