#!/usr/bin/env bats
#
# Test suite for Sparky Beep UI Tools
# Tests composer-tui, composer-gui, player-tui, player-gui
#

setup() {
    # Set up test environment
    export SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export BIN_DIR="$SCRIPT_DIR/bin"

    # Tool paths
    export COMPOSER_TUI="$BIN_DIR/sparky-beep-composer-tui"
    export COMPOSER_GUI="$BIN_DIR/sparky-beep-composer-gui"
    export PLAYER_TUI="$BIN_DIR/sparky-beep-player-tui"
    export PLAYER_GUI="$BIN_DIR/sparky-beep-player-gui"
}

# ============================================================================
# sparky-beep-composer-tui tests
# ============================================================================

@test "composer-tui: file exists" {
    [ -f "$COMPOSER_TUI" ]
}

@test "composer-tui: file is executable" {
    [ -x "$COMPOSER_TUI" ]
}

@test "composer-tui: file is a bash script" {
    head -n1 "$COMPOSER_TUI" | grep -q "bash"
}

@test "composer-tui: uses dialog or whiptail" {
    grep -q "dialog\|whiptail" "$COMPOSER_TUI"
}

@test "composer-tui: has menu functionality" {
    grep -q "menu\|inputbox\|textbox" "$COMPOSER_TUI"
}

@test "composer-tui: sources lib/notes.sh" {
    grep -q "source.*lib/notes.sh\|\\. .*lib/notes.sh" "$COMPOSER_TUI"
}

@test "composer-tui: sources locale/i18n.sh for translations" {
    grep -q "source.*i18n.sh\|\\. .*i18n.sh" "$COMPOSER_TUI"
}

@test "composer-tui: references sparky-beep-compose" {
    grep -q "sparky-beep-compose" "$COMPOSER_TUI"
}

# ============================================================================
# sparky-beep-composer-gui tests
# ============================================================================

@test "composer-gui: file exists" {
    [ -f "$COMPOSER_GUI" ]
}

@test "composer-gui: file is executable" {
    [ -x "$COMPOSER_GUI" ]
}

@test "composer-gui: file is a bash script" {
    head -n1 "$COMPOSER_GUI" | grep -q "bash"
}

@test "composer-gui: uses zenity or yad" {
    grep -q "zenity\|yad" "$COMPOSER_GUI"
}

@test "composer-gui: has GUI elements" {
    grep -q "entry\|text-info\|file-selection\|--forms" "$COMPOSER_GUI"
}

@test "composer-gui: sources lib/notes.sh" {
    grep -q "source.*lib/notes.sh\|\\. .*lib/notes.sh" "$COMPOSER_GUI"
}

@test "composer-gui: sources locale/i18n.sh for translations" {
    grep -q "source.*i18n.sh\|\\. .*i18n.sh" "$COMPOSER_GUI"
}

@test "composer-gui: references sparky-beep-compose" {
    grep -q "sparky-beep-compose" "$COMPOSER_GUI"
}

# ============================================================================
# sparky-beep-player-tui tests
# ============================================================================

@test "player-tui: file exists" {
    [ -f "$PLAYER_TUI" ]
}

@test "player-tui: file is executable" {
    [ -x "$PLAYER_TUI" ]
}

@test "player-tui: file is a bash script" {
    head -n1 "$PLAYER_TUI" | grep -q "bash"
}

@test "player-tui: uses dialog or whiptail" {
    grep -q "dialog\|whiptail" "$PLAYER_TUI"
}

@test "player-tui: has menu/radiolist functionality" {
    grep -q "menu\|radiolist\|fselect" "$PLAYER_TUI"
}

@test "player-tui: sources locale/i18n.sh for translations" {
    grep -q "source.*i18n.sh\|\\. .*i18n.sh" "$PLAYER_TUI"
}

@test "player-tui: references compositions directory" {
    grep -q "compositions\|beepmusic" "$PLAYER_TUI"
}

@test "player-tui: references sparky-beep-compose for playback" {
    grep -q "sparky-beep-compose" "$PLAYER_TUI"
}

# ============================================================================
# sparky-beep-player-gui tests
# ============================================================================

@test "player-gui: file exists" {
    [ -f "$PLAYER_GUI" ]
}

@test "player-gui: file is executable" {
    [ -x "$PLAYER_GUI" ]
}

@test "player-gui: file is a bash script" {
    head -n1 "$PLAYER_GUI" | grep -q "bash"
}

@test "player-gui: uses zenity or yad" {
    grep -q "zenity\|yad" "$PLAYER_GUI"
}

@test "player-gui: has file selection functionality" {
    grep -q "file-selection\|file-filter\|list" "$PLAYER_GUI"
}

@test "player-gui: sources locale/i18n.sh for translations" {
    grep -q "source.*i18n.sh\|\\. .*i18n.sh" "$PLAYER_GUI"
}

@test "player-gui: references compositions directory" {
    grep -q "compositions\|beepmusic" "$PLAYER_GUI"
}

@test "player-gui: references sparky-beep-compose for playback" {
    grep -q "sparky-beep-compose" "$PLAYER_GUI"
}

# ============================================================================
# Integration tests
# ============================================================================

@test "all UI tools are present" {
    [ -f "$COMPOSER_TUI" ] && [ -f "$COMPOSER_GUI" ] &&
    [ -f "$PLAYER_TUI" ] && [ -f "$PLAYER_GUI" ]
}

@test "all UI tools are executable" {
    [ -x "$COMPOSER_TUI" ] && [ -x "$COMPOSER_GUI" ] &&
    [ -x "$PLAYER_TUI" ] && [ -x "$PLAYER_GUI" ]
}

@test "all UI tools have shebang lines" {
    head -n1 "$COMPOSER_TUI" | grep -q "^#!"
    head -n1 "$COMPOSER_GUI" | grep -q "^#!"
    head -n1 "$PLAYER_TUI" | grep -q "^#!"
    head -n1 "$PLAYER_GUI" | grep -q "^#!"
}

@test "all UI tools support internationalization" {
    grep -q "i18n" "$COMPOSER_TUI"
    grep -q "i18n" "$COMPOSER_GUI"
    grep -q "i18n" "$PLAYER_TUI"
    grep -q "i18n" "$PLAYER_GUI"
}

@test "TUI tools are designed for terminal use" {
    # TUI tools should reference dialog/whiptail
    grep -q "dialog\|whiptail" "$COMPOSER_TUI"
    grep -q "dialog\|whiptail" "$PLAYER_TUI"
}

@test "GUI tools are designed for graphical use" {
    # GUI tools should reference zenity/yad
    grep -q "zenity\|yad" "$COMPOSER_GUI"
    grep -q "zenity\|yad" "$PLAYER_GUI"
}
