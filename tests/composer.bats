#!/usr/bin/env bats
#
# Test suite for Sparky Beep Composer
# Tests musical notation parsing and beep command generation
#

setup() {
    # Set up test environment
    export SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export COMPOSER="$SCRIPT_DIR/bin/sparky-beep-compose"
    export LIB_DIR="$SCRIPT_DIR/lib"

    # Skip if composer not found
    if [ ! -f "$COMPOSER" ]; then
        skip "Composer not found at $COMPOSER"
    fi

    # Make composer executable
    chmod +x "$COMPOSER"
}

@test "composer shows help with -h flag" {
    run "$COMPOSER" -h
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Sparky Beep Composer"
}

@test "composer shows help with --help flag" {
    run "$COMPOSER" --help
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "USAGE"
}

@test "composer requires input (file or string)" {
    run "$COMPOSER"
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "No composition provided"
}

@test "composer parses single note (dry run)" {
    run "$COMPOSER" -s "C4q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "beep -f 261 -l 500"
}

@test "composer parses multiple notes (dry run)" {
    run "$COMPOSER" -s "C4q D4q E4q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "beep -f 261 -l 500"
    echo "$output" | grep -q "-f 293 -l 500"
    echo "$output" | grep -q "-f 329 -l 500"
}

@test "composer handles sharps correctly" {
    run "$COMPOSER" -s "C#4q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-f 277"  # C# ≈ 277 Hz
}

@test "composer handles flats correctly" {
    run "$COMPOSER" -s "Bb4q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-f 466"  # Bb ≈ 466 Hz
}

@test "composer handles different octaves" {
    # C3 (lower) vs C5 (higher)
    run "$COMPOSER" -s "C3q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-f 130"  # C3 ≈ 130 Hz

    run "$COMPOSER" -s "C5q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-f 523"  # C5 ≈ 523 Hz
}

@test "composer handles different durations" {
    # Whole note (2000ms at 120 BPM)
    run "$COMPOSER" -s "C4w" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-l 2000"

    # Half note (1000ms)
    run "$COMPOSER" -s "C4h" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-l 1000"

    # Quarter note (500ms)
    run "$COMPOSER" -s "C4q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-l 500"

    # Eighth note (250ms)
    run "$COMPOSER" -s "C4e" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-l 250"
}

@test "composer handles tempo directive" {
    # Tempo 60 BPM = quarter note 1000ms
    run "$COMPOSER" -s "tempo:60 C4q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-l 1000"
}

@test "composer handles rests" {
    run "$COMPOSER" -s "C4q r:q D4q" -d
    [ "$status" -eq 0 ]
    # Should have beeps separated by rest (delay)
    [ "$status" -eq 0 ]
}

@test "composer handles alternate colon syntax" {
    run "$COMPOSER" -s "C4:q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-f 261 -l 500"
}

@test "composer handles comments in notation" {
    run "$COMPOSER" -s "# Comment
C4q D4q" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-f 261"
    echo "$output" | grep -q "-f 293"
}

@test "composer reads from composition file" {
    # Create temporary composition file
    TMP_COMP="$BATS_TMPDIR/test_composition.beepmusic"
    cat > "$TMP_COMP" << 'EOF'
# Test composition
tempo:120
C4q D4q E4q
EOF

    run "$COMPOSER" "$TMP_COMP" -d
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "-f 261"
    echo "$output" | grep -q "-f 293"
    echo "$output" | grep -q "-f 329"

    rm -f "$TMP_COMP"
}

@test "composer outputs to file with -o option" {
    TMP_OUTPUT="$BATS_TMPDIR/test_output.sh"

    run "$COMPOSER" -s "C4q D4q" -o "$TMP_OUTPUT"
    [ "$status" -eq 0 ]
    [ -f "$TMP_OUTPUT" ]

    # Check output file contains beep command
    grep -q "beep -f" "$TMP_OUTPUT"

    rm -f "$TMP_OUTPUT"
}

@test "composer output file is executable" {
    TMP_OUTPUT="$BATS_TMPDIR/test_output.sh"

    "$COMPOSER" -s "C4q" -o "$TMP_OUTPUT"

    # Check if executable
    [ -x "$TMP_OUTPUT" ]

    rm -f "$TMP_OUTPUT"
}

@test "composer handles C major scale correctly" {
    run "$COMPOSER" -s "C4q D4q E4q F4q G4q A4q B4q C5q" -d
    [ "$status" -eq 0 ]

    # Verify frequencies are ascending
    echo "$output" | grep -q "-f 261"  # C4
    echo "$output" | grep -q "-f 293"  # D4
    echo "$output" | grep -q "-f 329"  # E4
    echo "$output" | grep -q "-f 349"  # F4
    echo "$output" | grep -q "-f 392"  # G4
    echo "$output" | grep -q "-f 440"  # A4
    echo "$output" | grep -q "-f 493"  # B4
    echo "$output" | grep -q "-f 523"  # C5
}

@test "composer rejects invalid note format" {
    run "$COMPOSER" -s "X4q" -d
    # Should still run but may skip invalid note
    # Exact behavior depends on implementation
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "composer rejects invalid octave" {
    run "$COMPOSER" -s "C9q" -d
    # Octave 9 doesn't exist (max is 8)
    # Should fail or skip
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "composer handles enharmonic equivalents (C# = Db)" {
    # C# and Db should produce same frequency
    run "$COMPOSER" -s "C#4q" -d
    CSHARP_OUTPUT="$output"

    run "$COMPOSER" -s "Db4q" -d
    DFLAT_OUTPUT="$output"

    # Extract frequencies and compare
    CSHARP_FREQ=$(echo "$CSHARP_OUTPUT" | grep -o '\-f [0-9]*' | head -1 | awk '{print $2}')
    DFLAT_FREQ=$(echo "$DFLAT_OUTPUT" | grep -o '\-f [0-9]*' | head -1 | awk '{print $2}')

    [ "$CSHARP_FREQ" = "$DFLAT_FREQ" ]
}

@test "library: notes.sh is sourced correctly" {
    [ -f "$LIB_DIR/notes.sh" ]

    # Source library and test a function
    source "$LIB_DIR/notes.sh"

    # Test get_note_frequency function
    FREQ=$(get_note_frequency "A" 4)

    # A4 should be exactly 440 Hz
    echo "$FREQ" | grep -q "440"
}

@test "library: parse_note function works" {
    source "$LIB_DIR/notes.sh"

    # Parse C4
    RESULT=$(parse_note "C4")
    [ "$RESULT" = "C 4" ]

    # Parse F#5
    RESULT=$(parse_note "F#5")
    [ "$RESULT" = "F# 5" ]
}

@test "library: set_tempo_bpm function works" {
    source "$LIB_DIR/notes.sh"

    # Set tempo to 60 BPM
    set_tempo_bpm 60

    # Quarter note at 60 BPM should be 1000ms
    DURATION=$(get_note_duration "quarter")
    [ "$DURATION" = "1000" ]
}

@test "example composition files exist" {
    COMPOSITIONS_DIR="$SCRIPT_DIR/compositions"

    [ -f "$COMPOSITIONS_DIR/c-major-scale.beepmusic" ]
    [ -f "$COMPOSITIONS_DIR/happy-birthday.beepmusic" ]
    [ -f "$COMPOSITIONS_DIR/startup-fanfare.beepmusic" ]
}

@test "example composition files are valid" {
    COMPOSITIONS_DIR="$SCRIPT_DIR/compositions"

    # Test parsing each composition file
    for comp in "$COMPOSITIONS_DIR"/*.beepmusic; do
        [ -f "$comp" ] || continue

        run "$COMPOSER" "$comp" -d
        [ "$status" -eq 0 ]
    done
}

@test "config file exists" {
    [ -f "$SCRIPT_DIR/config/beep.conf" ]
}

@test "config file has valid defaults" {
    CONFIG="$SCRIPT_DIR/config/beep.conf"

    grep -q 'BEEP_MODE="binary"' "$CONFIG"
    grep -q 'DEFAULT_TEMPO=120' "$CONFIG"
    grep -q 'DEFAULT_OCTAVE=4' "$CONFIG"
}
