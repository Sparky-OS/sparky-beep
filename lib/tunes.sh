#!/bin/bash
#
# Sparky Beep Tune Library Manager
# Manages available melodies and beep compositions
# last update 2025/11/20
#

# Tune directories
SYSTEM_TUNES_DIR="/usr/share/sparky-beep/compositions"
USER_TUNES_DIR="${HOME}/.local/share/sparky-beep/compositions"
LOCAL_TUNES_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")/compositions"

# Arrays to store tune information
declare -A TUNE_FILES
declare -A TUNE_DESCRIPTIONS
declare -A TUNE_CATEGORIES

#
# Function: init_tune_library
# Description: Initialize the tune library
# Usage: init_tune_library
#
init_tune_library() {
    # Clear existing data
    TUNE_FILES=()
    TUNE_DESCRIPTIONS=()
    TUNE_CATEGORIES=()

    # Scan for tunes in all directories
    scan_tune_directory "$SYSTEM_TUNES_DIR"
    scan_tune_directory "$USER_TUNES_DIR"
    scan_tune_directory "$LOCAL_TUNES_DIR"

    # Add built-in default tunes
    add_builtin_tunes
}

#
# Function: scan_tune_directory
# Description: Scan a directory for tune files
# Usage: scan_tune_directory <directory>
#
scan_tune_directory() {
    local dir="$1"

    [ ! -d "$dir" ] && return 0

    # Find all .beepmusic files
    while IFS= read -r -d '' tune_file; do
        local tune_name=$(basename "$tune_file" .beepmusic)

        # Store tune file path
        TUNE_FILES["$tune_name"]="$tune_file"

        # Try to extract description from file header
        local description=$(grep "^# Description:" "$tune_file" 2>/dev/null | sed 's/^# Description: //')
        TUNE_DESCRIPTIONS["$tune_name"]="${description:-$tune_name}"

        # Try to extract category from file header
        local category=$(grep "^# Category:" "$tune_file" 2>/dev/null | sed 's/^# Category: //')
        TUNE_CATEGORIES["$tune_name"]="${category:-general}"
    done < <(find "$dir" -name "*.beepmusic" -type f -print0 2>/dev/null)
}

#
# Function: add_builtin_tunes
# Description: Add built-in default tunes
# Usage: add_builtin_tunes
#
add_builtin_tunes() {
    # Default simple beep
    TUNE_FILES["default"]="BUILTIN"
    TUNE_DESCRIPTIONS["default"]="Default simple beep"
    TUNE_CATEGORIES["default"]="builtin"

    # Silent/none
    TUNE_FILES["none"]="BUILTIN"
    TUNE_DESCRIPTIONS["none"]="Silent - no beep"
    TUNE_CATEGORIES["none"]="builtin"

    # Short beep
    TUNE_FILES["short"]="BUILTIN"
    TUNE_DESCRIPTIONS["short"]="Quick short beep"
    TUNE_CATEGORIES["short"]="builtin"

    # Long beep
    TUNE_FILES["long"]="BUILTIN"
    TUNE_DESCRIPTIONS["long"]="Long sustained beep"
    TUNE_CATEGORIES["long"]="builtin"

    # Double beep
    TUNE_FILES["double"]="BUILTIN"
    TUNE_DESCRIPTIONS["double"]="Two quick beeps"
    TUNE_CATEGORIES["double"]="builtin"

    # Triple beep
    TUNE_FILES["triple"]="BUILTIN"
    TUNE_DESCRIPTIONS["triple"]="Three quick beeps"
    TUNE_CATEGORIES["triple"]="builtin"

    # Ascending
    TUNE_FILES["ascending"]="BUILTIN"
    TUNE_DESCRIPTIONS["ascending"]="Ascending frequency sweep"
    TUNE_CATEGORIES["ascending"]="builtin"

    # Descending
    TUNE_FILES["descending"]="BUILTIN"
    TUNE_DESCRIPTIONS["descending"]="Descending frequency sweep"
    TUNE_CATEGORIES["descending"]="builtin"
}

#
# Function: get_tune_list
# Description: Get a list of all available tunes
# Usage: get_tune_list [category]
#
get_tune_list() {
    local filter_category="$1"

    for tune in "${!TUNE_FILES[@]}"; do
        if [ -z "$filter_category" ] || [ "${TUNE_CATEGORIES[$tune]}" = "$filter_category" ]; then
            echo "$tune"
        fi
    done | sort
}

#
# Function: get_tune_description
# Description: Get the description of a tune
# Usage: get_tune_description <tune_name>
#
get_tune_description() {
    local tune="$1"
    echo "${TUNE_DESCRIPTIONS[$tune]:-Unknown tune}"
}

#
# Function: get_tune_file
# Description: Get the file path of a tune
# Usage: get_tune_file <tune_name>
#
get_tune_file() {
    local tune="$1"
    echo "${TUNE_FILES[$tune]}"
}

#
# Function: tune_exists
# Description: Check if a tune exists
# Usage: tune_exists <tune_name>
#
tune_exists() {
    local tune="$1"
    [ -n "${TUNE_FILES[$tune]}" ]
}

#
# Function: get_builtin_beep_command
# Description: Get the beep command for a built-in tune
# Usage: get_builtin_beep_command <tune_name>
#
get_builtin_beep_command() {
    local tune="$1"

    case "$tune" in
        default)
            echo "beep -f 1000 -l 200"
            ;;
        none)
            echo ""  # No beep
            ;;
        short)
            echo "beep -f 1200 -l 100"
            ;;
        long)
            echo "beep -f 800 -l 500"
            ;;
        double)
            echo "beep -f 1000 -l 150 -n -f 1000 -l 150"
            ;;
        triple)
            echo "beep -f 1000 -l 100 -n -f 1000 -l 100 -n -f 1000 -l 100"
            ;;
        ascending)
            echo "beep -f 500 -l 100 -n -f 800 -l 100 -n -f 1200 -l 100 -n -f 1600 -l 100"
            ;;
        descending)
            echo "beep -f 1600 -l 100 -n -f 1200 -l 100 -n -f 800 -l 100 -n -f 500 -l 100"
            ;;
        *)
            echo ""
            ;;
    esac
}

#
# Function: play_tune
# Description: Play a tune
# Usage: play_tune <tune_name> [beep_mode]
#
play_tune() {
    local tune="$1"
    local beep_mode="${2:-binary}"

    if ! tune_exists "$tune"; then
        echo "ERROR: Tune not found: $tune" >&2
        return 1
    fi

    local tune_file="${TUNE_FILES[$tune]}"

    if [ "$tune_file" = "BUILTIN" ]; then
        # Play built-in tune
        local beep_cmd=$(get_builtin_beep_command "$tune")
        if [ -n "$beep_cmd" ]; then
            eval "$beep_cmd" 2>/dev/null || return 1
        fi
    else
        # Play composition file
        if [ -f "$tune_file" ]; then
            # Check if sparky-beep-compose exists
            local composer=""
            if [ -x "/usr/bin/sparky-beep-compose" ]; then
                composer="/usr/bin/sparky-beep-compose"
            elif [ -x "$(dirname "$(dirname "$(readlink -f "$0")")")/bin/sparky-beep-compose" ]; then
                composer="$(dirname "$(dirname "$(readlink -f "$0")")")/bin/sparky-beep-compose"
            fi

            if [ -n "$composer" ]; then
                "$composer" "$tune_file" -p -m "$beep_mode" 2>/dev/null || return 1
            else
                echo "ERROR: sparky-beep-compose not found" >&2
                return 1
            fi
        else
            echo "ERROR: Tune file not found: $tune_file" >&2
            return 1
        fi
    fi

    return 0
}

#
# Function: list_tunes
# Description: List all tunes with their descriptions
# Usage: list_tunes [category]
#
list_tunes() {
    local filter_category="$1"

    echo "Available Tunes:"
    echo "================"

    for tune in $(get_tune_list "$filter_category"); do
        local description="${TUNE_DESCRIPTIONS[$tune]}"
        local category="${TUNE_CATEGORIES[$tune]}"
        printf "%-25s %-15s %s\n" "$tune" "[$category]" "$description"
    done
}

#
# Function: get_categories
# Description: Get a list of all tune categories
# Usage: get_categories
#
get_categories() {
    for category in "${TUNE_CATEGORIES[@]}"; do
        echo "$category"
    done | sort -u
}

#
# Function: create_user_tune
# Description: Create a new user tune file
# Usage: create_user_tune <tune_name> <tune_content>
#
create_user_tune() {
    local tune_name="$1"
    local tune_content="$2"

    # Create user tunes directory if it doesn't exist
    mkdir -p "$USER_TUNES_DIR" || return 1

    local tune_file="$USER_TUNES_DIR/${tune_name}.beepmusic"

    # Write tune content
    cat > "$tune_file" << EOF
# Description: User-created tune
# Category: custom
# Created: $(date '+%Y-%m-%d %H:%M:%S')

$tune_content
EOF

    # Add to library
    TUNE_FILES["$tune_name"]="$tune_file"
    TUNE_DESCRIPTIONS["$tune_name"]="User-created tune"
    TUNE_CATEGORIES["$tune_name"]="custom"

    echo "$tune_file"
}

#
# Function: delete_user_tune
# Description: Delete a user-created tune
# Usage: delete_user_tune <tune_name>
#
delete_user_tune() {
    local tune_name="$1"
    local tune_file="${TUNE_FILES[$tune_name]}"

    # Only allow deletion of user tunes
    if [[ "$tune_file" != "$USER_TUNES_DIR"* ]]; then
        echo "ERROR: Cannot delete system or built-in tune" >&2
        return 1
    fi

    if [ -f "$tune_file" ]; then
        rm -f "$tune_file" || return 1

        # Remove from library
        unset TUNE_FILES["$tune_name"]
        unset TUNE_DESCRIPTIONS["$tune_name"]
        unset TUNE_CATEGORIES["$tune_name"]

        return 0
    fi

    return 1
}

#
# Function: export_tune
# Description: Export a tune to a file
# Usage: export_tune <tune_name> <output_file>
#
export_tune() {
    local tune_name="$1"
    local output_file="$2"

    if ! tune_exists "$tune_name"; then
        echo "ERROR: Tune not found: $tune_name" >&2
        return 1
    fi

    local tune_file="${TUNE_FILES[$tune_name]}"

    if [ "$tune_file" = "BUILTIN" ]; then
        # Export built-in tune as beep command
        local beep_cmd=$(get_builtin_beep_command "$tune_name")
        cat > "$output_file" << EOF
# Built-in tune: $tune_name
# Description: ${TUNE_DESCRIPTIONS[$tune_name]}
# Beep command:
$beep_cmd
EOF
    else
        # Copy composition file
        cp "$tune_file" "$output_file" || return 1
    fi

    return 0
}

# Export functions
export -f init_tune_library
export -f scan_tune_directory
export -f add_builtin_tunes
export -f get_tune_list
export -f get_tune_description
export -f get_tune_file
export -f tune_exists
export -f get_builtin_beep_command
export -f play_tune
export -f list_tunes
export -f get_categories
export -f create_user_tune
export -f delete_user_tune
export -f export_tune
