#!/usr/bin/env bats
#
# Test suite for Sparky Beep Configuration Tools
# Tests sparky-beep-config, sparky-beep-config-tui, sparky-beep-config-gui
#

setup() {
    # Set up test environment
    export SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export BIN_DIR="$SCRIPT_DIR/bin"

    # Check if tools exist
    export CONFIG_TOOL="$BIN_DIR/sparky-beep-config"
    export CONFIG_TUI="$BIN_DIR/sparky-beep-config-tui"
    export CONFIG_GUI="$BIN_DIR/sparky-beep-config-gui"
}

# ============================================================================
# sparky-beep-config tests
# ============================================================================

@test "config: file exists" {
    [ -f "$CONFIG_TOOL" ]
}

@test "config: file is executable" {
    [ -x "$CONFIG_TOOL" ]
}

@test "config: file is a bash script" {
    head -n1 "$CONFIG_TOOL" | grep -q "bash"
}

@test "config: shows help with -h flag" {
    skip "Requires mock environment or non-interactive mode"
    run "$CONFIG_TOOL" -h
    [ "$status" -eq 0 ]
}

@test "config: shows help with --help flag" {
    skip "Requires mock environment or non-interactive mode"
    run "$CONFIG_TOOL" --help
    [ "$status" -eq 0 ]
}

@test "config: has --list option" {
    grep -q "\-\-list" "$CONFIG_TOOL" || grep -q "list)" "$CONFIG_TOOL"
}

@test "config: has --enable option" {
    grep -q "\-\-enable" "$CONFIG_TOOL" || grep -q "enable)" "$CONFIG_TOOL"
}

@test "config: has --disable option" {
    grep -q "\-\-disable" "$CONFIG_TOOL" || grep -q "disable)" "$CONFIG_TOOL"
}

@test "config: has --test option" {
    grep -q "\-\-test" "$CONFIG_TOOL" || grep -q "test)" "$CONFIG_TOOL"
}

@test "config: sources lib/config.sh" {
    grep -q "source.*lib/config.sh\|\\. .*lib/config.sh" "$CONFIG_TOOL"
}

@test "config: sources lib/discovery.sh" {
    grep -q "source.*lib/discovery.sh\|\\. .*lib/discovery.sh" "$CONFIG_TOOL"
}

# ============================================================================
# sparky-beep-config-tui tests
# ============================================================================

@test "config-tui: file exists" {
    [ -f "$CONFIG_TUI" ]
}

@test "config-tui: file is executable" {
    [ -x "$CONFIG_TUI" ]
}

@test "config-tui: file is a bash script" {
    head -n1 "$CONFIG_TUI" | grep -q "bash"
}

@test "config-tui: uses dialog or whiptail" {
    grep -q "dialog\|whiptail" "$CONFIG_TUI"
}

@test "config-tui: has menu/checklist functionality" {
    grep -q "menu\|checklist\|radiolist" "$CONFIG_TUI"
}

@test "config-tui: sources lib/config.sh" {
    grep -q "source.*lib/config.sh\|\\. .*lib/config.sh" "$CONFIG_TUI"
}

@test "config-tui: sources lib/discovery.sh" {
    grep -q "source.*lib/discovery.sh\|\\. .*lib/discovery.sh" "$CONFIG_TUI"
}

@test "config-tui: sources locale/i18n.sh for translations" {
    grep -q "source.*i18n.sh\|\\. .*i18n.sh" "$CONFIG_TUI"
}

# ============================================================================
# sparky-beep-config-gui tests
# ============================================================================

@test "config-gui: file exists" {
    [ -f "$CONFIG_GUI" ]
}

@test "config-gui: file is executable" {
    [ -x "$CONFIG_GUI" ]
}

@test "config-gui: file is a bash script" {
    head -n1 "$CONFIG_GUI" | grep -q "bash"
}

@test "config-gui: uses zenity or yad" {
    grep -q "zenity\|yad" "$CONFIG_GUI"
}

@test "config-gui: has list/checklist functionality" {
    grep -q "list\|checklist\|--forms" "$CONFIG_GUI"
}

@test "config-gui: sources lib/config.sh" {
    grep -q "source.*lib/config.sh\|\\. .*lib/config.sh" "$CONFIG_GUI"
}

@test "config-gui: sources lib/discovery.sh" {
    grep -q "source.*lib/discovery.sh\|\\. .*lib/discovery.sh" "$CONFIG_GUI"
}

@test "config-gui: sources locale/i18n.sh for translations" {
    grep -q "source.*i18n.sh\|\\. .*i18n.sh" "$CONFIG_GUI"
}

# ============================================================================
# Integration tests
# ============================================================================

@test "all config tools are present" {
    [ -f "$CONFIG_TOOL" ] && [ -f "$CONFIG_TUI" ] && [ -f "$CONFIG_GUI" ]
}

@test "all config tools are executable" {
    [ -x "$CONFIG_TOOL" ] && [ -x "$CONFIG_TUI" ] && [ -x "$CONFIG_GUI" ]
}

@test "config tools have shebang lines" {
    head -n1 "$CONFIG_TOOL" | grep -q "^#!"
    head -n1 "$CONFIG_TUI" | grep -q "^#!"
    head -n1 "$CONFIG_GUI" | grep -q "^#!"
}
