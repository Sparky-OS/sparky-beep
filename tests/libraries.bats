#!/usr/bin/env bats
#
# Test suite for Sparky Beep Libraries
# Tests lib/config.sh, lib/discovery.sh, lib/tunes.sh, lib/scheduler.sh, locale/i18n.sh
#

setup() {
    # Set up test environment
    export SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export LIB_DIR="$SCRIPT_DIR/lib"
    export LOCALE_DIR="$SCRIPT_DIR/locale"
    export CONFIG_DIR="$SCRIPT_DIR/config"

    # Create temporary directories
    export TMP_DIR="$BATS_TMPDIR/sparky-beep-libs-$$"
    export TMP_CONFIG="$TMP_DIR/config"
    export TMP_BEEP_CONF="$TMP_CONFIG/beep.conf"

    mkdir -p "$TMP_CONFIG"
}

teardown() {
    # Clean up
    rm -rf "$TMP_DIR"
}

# ============================================================================
# lib/config.sh tests
# ============================================================================

@test "config.sh: file exists and is readable" {
    [ -f "$LIB_DIR/config.sh" ]
    [ -r "$LIB_DIR/config.sh" ]
}

@test "config.sh: can be sourced without errors" {
    run bash -c "source '$LIB_DIR/config.sh'"
    [ "$status" -eq 0 ]
}

@test "config.sh: init_config function exists" {
    source "$LIB_DIR/config.sh"
    type init_config >/dev/null 2>&1
}

@test "config.sh: create_default_config function exists" {
    source "$LIB_DIR/config.sh"
    type create_default_config >/dev/null 2>&1
}

@test "config.sh: load_config function exists" {
    source "$LIB_DIR/config.sh"
    type load_config >/dev/null 2>&1
}

@test "config.sh: save_config function exists" {
    source "$LIB_DIR/config.sh"
    type save_config >/dev/null 2>&1
}

@test "config.sh: get_config_value function exists" {
    source "$LIB_DIR/config.sh"
    type get_config_value >/dev/null 2>&1
}

@test "config.sh: set_config_value function exists" {
    source "$LIB_DIR/config.sh"
    type set_config_value >/dev/null 2>&1
}

# ============================================================================
# lib/discovery.sh tests
# ============================================================================

@test "discovery.sh: file exists and is readable" {
    [ -f "$LIB_DIR/discovery.sh" ]
    [ -r "$LIB_DIR/discovery.sh" ]
}

@test "discovery.sh: can be sourced without errors" {
    run bash -c "source '$LIB_DIR/discovery.sh'"
    [ "$status" -eq 0 ]
}

@test "discovery.sh: discover_services function exists" {
    source "$LIB_DIR/discovery.sh"
    type discover_services >/dev/null 2>&1
}

@test "discovery.sh: is_service_installed function exists" {
    source "$LIB_DIR/discovery.sh"
    type is_service_installed >/dev/null 2>&1
}

@test "discovery.sh: is_service_active function exists" {
    source "$LIB_DIR/discovery.sh"
    type is_service_active >/dev/null 2>&1
}

@test "discovery.sh: get_beep_service_name function exists" {
    source "$LIB_DIR/discovery.sh"
    type get_beep_service_name >/dev/null 2>&1
}

# ============================================================================
# lib/tunes.sh tests
# ============================================================================

@test "tunes.sh: file exists and is readable" {
    [ -f "$LIB_DIR/tunes.sh" ]
    [ -r "$LIB_DIR/tunes.sh" ]
}

@test "tunes.sh: can be sourced without errors" {
    run bash -c "source '$LIB_DIR/tunes.sh'"
    [ "$status" -eq 0 ]
}

# ============================================================================
# lib/scheduler.sh tests
# ============================================================================

@test "scheduler.sh: file exists and is readable" {
    [ -f "$LIB_DIR/scheduler.sh" ]
    [ -r "$LIB_DIR/scheduler.sh" ]
}

@test "scheduler.sh: can be sourced without errors" {
    run bash -c "source '$LIB_DIR/scheduler.sh'"
    [ "$status" -eq 0 ]
}

@test "scheduler.sh: is_in_quiet_hours function exists" {
    source "$LIB_DIR/scheduler.sh"
    type is_in_quiet_hours >/dev/null 2>&1
}

@test "scheduler.sh: time_to_minutes function exists" {
    source "$LIB_DIR/scheduler.sh"
    type time_to_minutes >/dev/null 2>&1
}

@test "scheduler.sh: should_play_beep function exists" {
    source "$LIB_DIR/scheduler.sh"
    type should_play_beep >/dev/null 2>&1
}

# ============================================================================
# lib/notes.sh tests (additional tests beyond composer.bats)
# ============================================================================

@test "notes.sh: file exists and is readable" {
    [ -f "$LIB_DIR/notes.sh" ]
    [ -r "$LIB_DIR/notes.sh" ]
}

@test "notes.sh: can be sourced without errors" {
    run bash -c "source '$LIB_DIR/notes.sh'"
    [ "$status" -eq 0 ]
}

@test "notes.sh: scale_tempo function exists" {
    source "$LIB_DIR/notes.sh"
    type scale_tempo >/dev/null 2>&1
}

@test "notes.sh: get_rest_duration function exists" {
    source "$LIB_DIR/notes.sh"
    type get_rest_duration >/dev/null 2>&1
}

# ============================================================================
# locale/i18n.sh tests
# ============================================================================

@test "i18n.sh: file exists and is readable" {
    [ -f "$LOCALE_DIR/i18n.sh" ]
    [ -r "$LOCALE_DIR/i18n.sh" ]
}

@test "i18n.sh: can be sourced without errors" {
    run bash -c "source '$LOCALE_DIR/i18n.sh'"
    [ "$status" -eq 0 ]
}

@test "i18n.sh: detect_language function exists" {
    source "$LOCALE_DIR/i18n.sh"
    type detect_language >/dev/null 2>&1
}

@test "i18n.sh: load_translations function exists" {
    source "$LOCALE_DIR/i18n.sh"
    type load_translations >/dev/null 2>&1
}

@test "i18n.sh: t (translate) function exists" {
    source "$LOCALE_DIR/i18n.sh"
    type t >/dev/null 2>&1
}

@test "i18n.sh: all 26 language files exist" {
    local lang_count=0
    for lang in ar ca cs da de el en es fi fr hu it ja ko nl pl pt pt_BR ro ru sk sv tr uk zh_CN zh_TW; do
        if [ -f "$LOCALE_DIR/${lang}.lang" ]; then
            ((lang_count++))
        fi
    done
    [ "$lang_count" -eq 26 ]
}

@test "i18n.sh: English language file exists" {
    [ -f "$LOCALE_DIR/en.lang" ]
}

@test "i18n.sh: German language file exists" {
    [ -f "$LOCALE_DIR/de.lang" ]
}

@test "i18n.sh: French language file exists" {
    [ -f "$LOCALE_DIR/fr.lang" ]
}

@test "i18n.sh: Spanish language file exists" {
    [ -f "$LOCALE_DIR/es.lang" ]
}

@test "i18n.sh: Japanese language file exists" {
    [ -f "$LOCALE_DIR/ja.lang" ]
}

@test "i18n.sh: Chinese (Simplified) language file exists" {
    [ -f "$LOCALE_DIR/zh_CN.lang" ]
}

# ============================================================================
# Integration tests
# ============================================================================

@test "all libraries can be sourced together" {
    run bash -c "
        source '$LIB_DIR/config.sh' &&
        source '$LIB_DIR/discovery.sh' &&
        source '$LIB_DIR/tunes.sh' &&
        source '$LIB_DIR/scheduler.sh' &&
        source '$LIB_DIR/notes.sh' &&
        source '$LOCALE_DIR/i18n.sh'
    "
    [ "$status" -eq 0 ]
}

@test "config file template exists" {
    [ -f "$CONFIG_DIR/beep.conf" ]
}

@test "config file has BEEP_MODE setting" {
    grep -q "BEEP_MODE=" "$CONFIG_DIR/beep.conf"
}

@test "config file has DEFAULT_TEMPO setting" {
    grep -q "DEFAULT_TEMPO=" "$CONFIG_DIR/beep.conf"
}

@test "config file has DEFAULT_OCTAVE setting" {
    grep -q "DEFAULT_OCTAVE=" "$CONFIG_DIR/beep.conf"
}
