#!/bin/bash
#
# Sparky Beep Configuration Management Library
# Handles configuration file reading, writing, and validation
# last update 2025/11/20
#

# Configuration file paths
CONFIG_DIR="/etc/sparky-beep"
CONFIG_FILE="${CONFIG_DIR}/beep.conf"
USER_CONFIG_DIR="${HOME}/.config/sparky-beep"
USER_CONFIG_FILE="${USER_CONFIG_DIR}/beep.conf"
BACKUP_DIR="${CONFIG_DIR}/backups"

# Default configuration values
DEFAULT_BEEP_MODE="binary"
DEFAULT_LANGUAGE="en"
DEFAULT_AUTO_ENABLE="true"
DEFAULT_LOG_EVENTS="false"
DEFAULT_SCHEDULE_ENABLED="false"
DEFAULT_QUIET_START="22:00"
DEFAULT_QUIET_END="07:00"

# Global configuration variables
BEEP_MODE=""
LANGUAGE_CODE=""
AUTO_ENABLE_SERVICES=""
LOG_BEEP_EVENTS=""
SCHEDULE_ENABLED=""
QUIET_HOURS_START=""
QUIET_HOURS_END=""

# Service configuration arrays
declare -A SERVICE_ENABLED
declare -A SERVICE_TUNE_START
declare -A SERVICE_TUNE_STOP
declare -A SERVICE_TUNE_RESTART
declare -A SCHEDULE_RULES

#
# Function: init_config
# Description: Initialize configuration system
# Usage: init_config
#
init_config() {
    # Determine which config file to use
    if [ -w "$CONFIG_DIR" ] 2>/dev/null || [ "$(id -u)" -eq 0 ]; then
        # Use system config if we have write access or are root
        CONFIG_PATH="$CONFIG_FILE"
    else
        # Use user config
        CONFIG_PATH="$USER_CONFIG_FILE"
        CONFIG_DIR="$USER_CONFIG_DIR"
    fi

    # Create config directory if it doesn't exist
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR" 2>/dev/null || return 1
    fi

    # Create backup directory
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR" 2>/dev/null
    fi

    # Create default config if it doesn't exist
    if [ ! -f "$CONFIG_PATH" ]; then
        create_default_config
    fi

    return 0
}

#
# Function: create_default_config
# Description: Create a default configuration file
# Usage: create_default_config
#
create_default_config() {
    cat > "$CONFIG_PATH" << EOF
# Sparky Beep Configuration File
# Generated: $(date '+%Y-%m-%d %H:%M:%S')

[general]
beep_mode=$DEFAULT_BEEP_MODE
language=$DEFAULT_LANGUAGE
auto_enable=$DEFAULT_AUTO_ENABLE
log_events=$DEFAULT_LOG_EVENTS

[schedule]
enabled=$DEFAULT_SCHEDULE_ENABLED
quiet_hours_start=$DEFAULT_QUIET_START
quiet_hours_end=$DEFAULT_QUIET_END
# Format for weekdays: 1=Monday, 7=Sunday
active_weekdays=1,2,3,4,5,6,7

[services]
# Service format: service_name=enabled|tune_start|tune_stop|tune_restart
# Default services (will be auto-detected)
beep_sys=true|default|default|default
beep_netdata=true|default|default|default
beep_samba=true|imperial-march|default|default
beep_webmin=true|default|default|default

[schedule_rules]
# Custom schedule rules
# Format: rule_name=service|event|weekdays|start_time|end_time|action
# Example: quiet_night=*|*|1,2,3,4,5|22:00|07:00|disable
EOF

    return $?
}

#
# Function: load_config
# Description: Load configuration from file
# Usage: load_config [config_file]
#
load_config() {
    local config_file="${1:-$CONFIG_PATH}"

    if [ ! -f "$config_file" ]; then
        echo "ERROR: Configuration file not found: $config_file" >&2
        return 1
    fi

    local section=""

    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Detect section headers
        if [[ "$line" =~ ^\[([[:alnum:]_]+)\] ]]; then
            section="${BASH_REMATCH[1]}"
            continue
        fi

        # Parse key=value pairs
        if [[ "$line" =~ ^([[:alnum:]_]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"

            case "$section" in
                general)
                    case "$key" in
                        beep_mode) BEEP_MODE="$value" ;;
                        language) LANGUAGE_CODE="$value" ;;
                        auto_enable) AUTO_ENABLE_SERVICES="$value" ;;
                        log_events) LOG_BEEP_EVENTS="$value" ;;
                    esac
                    ;;
                schedule)
                    case "$key" in
                        enabled) SCHEDULE_ENABLED="$value" ;;
                        quiet_hours_start) QUIET_HOURS_START="$value" ;;
                        quiet_hours_end) QUIET_HOURS_END="$value" ;;
                        active_weekdays) ACTIVE_WEEKDAYS="$value" ;;
                    esac
                    ;;
                services)
                    # Parse service configuration
                    IFS='|' read -r enabled tune_start tune_stop tune_restart <<< "$value"
                    SERVICE_ENABLED["$key"]="${enabled:-true}"
                    SERVICE_TUNE_START["$key"]="${tune_start:-default}"
                    SERVICE_TUNE_STOP["$key"]="${tune_stop:-default}"
                    SERVICE_TUNE_RESTART["$key"]="${tune_restart:-default}"
                    ;;
                schedule_rules)
                    SCHEDULE_RULES["$key"]="$value"
                    ;;
            esac
        fi
    done < "$config_file"

    return 0
}

#
# Function: save_config
# Description: Save current configuration to file
# Usage: save_config [config_file]
#
save_config() {
    local config_file="${1:-$CONFIG_PATH}"

    # Create backup of existing config
    if [ -f "$config_file" ]; then
        local backup_file="$BACKUP_DIR/beep.conf.$(date +%Y%m%d_%H%M%S)"
        cp "$config_file" "$backup_file" 2>/dev/null
    fi

    # Write configuration
    cat > "$config_file" << EOF
# Sparky Beep Configuration File
# Last updated: $(date '+%Y-%m-%d %H:%M:%S')

[general]
beep_mode=${BEEP_MODE:-$DEFAULT_BEEP_MODE}
language=${LANGUAGE_CODE:-$DEFAULT_LANGUAGE}
auto_enable=${AUTO_ENABLE_SERVICES:-$DEFAULT_AUTO_ENABLE}
log_events=${LOG_BEEP_EVENTS:-$DEFAULT_LOG_EVENTS}

[schedule]
enabled=${SCHEDULE_ENABLED:-$DEFAULT_SCHEDULE_ENABLED}
quiet_hours_start=${QUIET_HOURS_START:-$DEFAULT_QUIET_START}
quiet_hours_end=${QUIET_HOURS_END:-$DEFAULT_QUIET_END}
active_weekdays=${ACTIVE_WEEKDAYS:-1,2,3,4,5,6,7}

[services]
EOF

    # Write service configurations
    for service in "${!SERVICE_ENABLED[@]}"; do
        local enabled="${SERVICE_ENABLED[$service]}"
        local tune_start="${SERVICE_TUNE_START[$service]:-default}"
        local tune_stop="${SERVICE_TUNE_STOP[$service]:-default}"
        local tune_restart="${SERVICE_TUNE_RESTART[$service]:-default}"
        echo "$service=$enabled|$tune_start|$tune_stop|$tune_restart" >> "$config_file"
    done

    # Write schedule rules
    echo "" >> "$config_file"
    echo "[schedule_rules]" >> "$config_file"
    for rule_name in "${!SCHEDULE_RULES[@]}"; do
        echo "$rule_name=${SCHEDULE_RULES[$rule_name]}" >> "$config_file"
    done

    return $?
}

#
# Function: get_config_value
# Description: Get a configuration value
# Usage: get_config_value <section> <key>
#
get_config_value() {
    local section="$1"
    local key="$2"

    case "$section" in
        general)
            case "$key" in
                beep_mode) echo "$BEEP_MODE" ;;
                language) echo "$LANGUAGE_CODE" ;;
                auto_enable) echo "$AUTO_ENABLE_SERVICES" ;;
                log_events) echo "$LOG_BEEP_EVENTS" ;;
            esac
            ;;
        schedule)
            case "$key" in
                enabled) echo "$SCHEDULE_ENABLED" ;;
                quiet_hours_start) echo "$QUIET_HOURS_START" ;;
                quiet_hours_end) echo "$QUIET_HOURS_END" ;;
            esac
            ;;
    esac
}

#
# Function: set_config_value
# Description: Set a configuration value
# Usage: set_config_value <section> <key> <value>
#
set_config_value() {
    local section="$1"
    local key="$2"
    local value="$3"

    case "$section" in
        general)
            case "$key" in
                beep_mode) BEEP_MODE="$value" ;;
                language) LANGUAGE_CODE="$value" ;;
                auto_enable) AUTO_ENABLE_SERVICES="$value" ;;
                log_events) LOG_BEEP_EVENTS="$value" ;;
            esac
            ;;
        schedule)
            case "$key" in
                enabled) SCHEDULE_ENABLED="$value" ;;
                quiet_hours_start) QUIET_HOURS_START="$value" ;;
                quiet_hours_end) QUIET_HOURS_END="$value" ;;
            esac
            ;;
    esac
}

#
# Function: validate_config
# Description: Validate configuration values
# Usage: validate_config
#
validate_config() {
    local errors=0

    # Validate beep mode
    if [ "$BEEP_MODE" != "binary" ] && [ "$BEEP_MODE" != "ternary" ]; then
        echo "ERROR: Invalid beep_mode: $BEEP_MODE (must be 'binary' or 'ternary')" >&2
        ((errors++))
    fi

    # Validate time format
    if ! [[ "$QUIET_HOURS_START" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        echo "ERROR: Invalid quiet_hours_start format: $QUIET_HOURS_START (use HH:MM)" >&2
        ((errors++))
    fi

    if ! [[ "$QUIET_HOURS_END" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        echo "ERROR: Invalid quiet_hours_end format: $QUIET_HOURS_END (use HH:MM)" >&2
        ((errors++))
    fi

    return $errors
}

#
# Function: is_service_enabled
# Description: Check if a service is enabled for beep notifications
# Usage: is_service_enabled <service_name>
#
is_service_enabled() {
    local service="$1"
    local enabled="${SERVICE_ENABLED[$service]}"

    [ "$enabled" = "true" ]
}

#
# Function: enable_service
# Description: Enable beep notifications for a service
# Usage: enable_service <service_name>
#
enable_service() {
    local service="$1"
    SERVICE_ENABLED["$service"]="true"

    # Set defaults if not already set
    [ -z "${SERVICE_TUNE_START[$service]}" ] && SERVICE_TUNE_START["$service"]="default"
    [ -z "${SERVICE_TUNE_STOP[$service]}" ] && SERVICE_TUNE_STOP["$service"]="default"
    [ -z "${SERVICE_TUNE_RESTART[$service]}" ] && SERVICE_TUNE_RESTART["$service"]="default"
}

#
# Function: disable_service
# Description: Disable beep notifications for a service
# Usage: disable_service <service_name>
#
disable_service() {
    local service="$1"
    SERVICE_ENABLED["$service"]="false"
}

#
# Function: get_service_tune
# Description: Get the tune for a service event
# Usage: get_service_tune <service_name> <event_type>
#
get_service_tune() {
    local service="$1"
    local event="$2"

    case "$event" in
        start) echo "${SERVICE_TUNE_START[$service]:-default}" ;;
        stop) echo "${SERVICE_TUNE_STOP[$service]:-default}" ;;
        restart) echo "${SERVICE_TUNE_RESTART[$service]:-default}" ;;
    esac
}

#
# Function: set_service_tune
# Description: Set the tune for a service event
# Usage: set_service_tune <service_name> <event_type> <tune_name>
#
set_service_tune() {
    local service="$1"
    local event="$2"
    local tune="$3"

    case "$event" in
        start) SERVICE_TUNE_START["$service"]="$tune" ;;
        stop) SERVICE_TUNE_STOP["$service"]="$tune" ;;
        restart) SERVICE_TUNE_RESTART["$service"]="$tune" ;;
    esac
}

# Export functions
export -f init_config
export -f create_default_config
export -f load_config
export -f save_config
export -f get_config_value
export -f set_config_value
export -f validate_config
export -f is_service_enabled
export -f enable_service
export -f disable_service
export -f get_service_tune
export -f set_service_tune
