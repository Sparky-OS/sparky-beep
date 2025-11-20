#!/usr/bin/env bats
#
# Test suite for Ternary Beep Engine
# Tests bin/tbeep.c compilation and functionality
#

setup() {
    # Set up test environment
    export SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TBEEP_SOURCE="$SCRIPT_DIR/bin/tbeep.c"
    export TBEEP_BIN="$SCRIPT_DIR/bin/tbeep"
    export MAKEFILE="$SCRIPT_DIR/Makefile"
}

# ============================================================================
# Source code tests
# ============================================================================

@test "tbeep.c: source file exists" {
    [ -f "$TBEEP_SOURCE" ]
}

@test "tbeep.c: source file is readable" {
    [ -r "$TBEEP_SOURCE" ]
}

@test "tbeep.c: has standard C headers" {
    grep -q "#include <stdio.h>" "$TBEEP_SOURCE"
}

@test "tbeep.c: has main function" {
    grep -q "int main(" "$TBEEP_SOURCE"
}

@test "tbeep.c: has ternary mode support" {
    grep -q "ternary\|TERNARY" "$TBEEP_SOURCE"
}

@test "tbeep.c: has binary mode support" {
    grep -q "binary\|BINARY" "$TBEEP_SOURCE"
}

@test "tbeep.c: has frequency parameter support" {
    grep -q "frequency\|freq" "$TBEEP_SOURCE"
}

@test "tbeep.c: has duration parameter support" {
    grep -q "duration\|length" "$TBEEP_SOURCE"
}

@test "tbeep.c: has command line option parsing" {
    grep -q "getopt\|argc\|argv" "$TBEEP_SOURCE"
}

@test "tbeep.c: uses math library for sine approximation" {
    grep -q "math.h\|sin\|sine" "$TBEEP_SOURCE"
}

# ============================================================================
# Makefile tests
# ============================================================================

@test "Makefile: exists" {
    [ -f "$MAKEFILE" ]
}

@test "Makefile: has all target" {
    grep -q "^all:" "$MAKEFILE" || grep -q "^tbeep:" "$MAKEFILE"
}

@test "Makefile: has install target" {
    grep -q "^install:" "$MAKEFILE"
}

@test "Makefile: has uninstall target" {
    grep -q "^uninstall:" "$MAKEFILE"
}

@test "Makefile: has clean target" {
    grep -q "^clean:" "$MAKEFILE"
}

@test "Makefile: compiles tbeep from tbeep.c" {
    grep -q "tbeep.c" "$MAKEFILE"
}

@test "Makefile: links math library (-lm)" {
    grep -q "\-lm" "$MAKEFILE"
}

@test "Makefile: uses gcc compiler" {
    grep -q "gcc\|CC.*gcc\|CC=gcc" "$MAKEFILE" || grep -q "CC =" "$MAKEFILE"
}

# ============================================================================
# Binary tests (if compiled)
# ============================================================================

@test "tbeep: binary exists (if compiled)" {
    skip "Binary only exists after compilation"
    [ -f "$TBEEP_BIN" ]
}

@test "tbeep: binary is executable (if compiled)" {
    skip "Binary only exists after compilation"
    [ -x "$TBEEP_BIN" ]
}

# ============================================================================
# Documentation tests
# ============================================================================

@test "tbeep: source has comments explaining ternary logic" {
    grep -q "ternary.*logic\|3.*state\|three.*state" "$TBEEP_SOURCE"
}

@test "tbeep: source has usage/help information" {
    grep -q "usage\|Usage\|USAGE\|help\|Help" "$TBEEP_SOURCE"
}

# ============================================================================
# Code quality tests
# ============================================================================

@test "tbeep.c: includes error handling" {
    grep -q "perror\|fprintf.*stderr\|error" "$TBEEP_SOURCE"
}

@test "tbeep.c: includes argument validation" {
    grep -q "if.*argc\|validate\|check.*arg" "$TBEEP_SOURCE"
}

@test "tbeep.c: has reasonable file size (< 50KB)" {
    size=$(stat -f%z "$TBEEP_SOURCE" 2>/dev/null || stat -c%s "$TBEEP_SOURCE" 2>/dev/null)
    [ "$size" -lt 51200 ]
}

# ============================================================================
# Feature tests
# ============================================================================

@test "tbeep.c: supports -f flag for frequency" {
    grep -q '"-f"' "$TBEEP_SOURCE" || grep -q "case 'f':" "$TBEEP_SOURCE"
}

@test "tbeep.c: supports -l flag for length/duration" {
    grep -q '"-l"' "$TBEEP_SOURCE" || grep -q "case 'l':" "$TBEEP_SOURCE"
}

@test "tbeep.c: supports -n flag for next beep (sequence)" {
    grep -q '"-n"' "$TBEEP_SOURCE" || grep -q "case 'n':" "$TBEEP_SOURCE" || grep -q "next" "$TBEEP_SOURCE"
}

@test "tbeep.c: supports -b flag for binary mode" {
    grep -q '"-b"' "$TBEEP_SOURCE" || grep -q "case 'b':" "$TBEEP_SOURCE" || grep -q "binary.*mode" "$TBEEP_SOURCE"
}

# ============================================================================
# Integration with beep config
# ============================================================================

@test "config: beep.conf mentions ternary mode" {
    [ -f "$SCRIPT_DIR/config/beep.conf" ]
    grep -q "ternary\|TERNARY\|BEEP_MODE" "$SCRIPT_DIR/config/beep.conf"
}

@test "config: beep.conf has binary as default" {
    [ -f "$SCRIPT_DIR/config/beep.conf" ]
    grep -q 'BEEP_MODE="binary"' "$SCRIPT_DIR/config/beep.conf"
}

@test "config: beep.conf has fallback option" {
    [ -f "$SCRIPT_DIR/config/beep.conf" ]
    grep -q "FALLBACK_TO_BINARY\|fallback" "$SCRIPT_DIR/config/beep.conf"
}
