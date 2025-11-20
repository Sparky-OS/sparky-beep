#!/bin/bash
#
# Musical Note Library for Sparky Beep
# Provides note-to-frequency mappings and utility functions
# last update 2025/11/20 by AI Assistant
#

# Note: Frequencies based on A440 standard tuning
# Reference: https://pages.mtu.edu/~suits/notefreqs.html

# Octave 0
declare -A NOTE_FREQ_0=(
    ["C"]=16.35
    ["C#"]=17.32
    ["Db"]=17.32
    ["D"]=18.35
    ["D#"]=19.45
    ["Eb"]=19.45
    ["E"]=20.60
    ["F"]=21.83
    ["F#"]=23.12
    ["Gb"]=23.12
    ["G"]=24.50
    ["G#"]=25.96
    ["Ab"]=25.96
    ["A"]=27.50
    ["A#"]=29.14
    ["Bb"]=29.14
    ["B"]=30.87
)

# Octave 1
declare -A NOTE_FREQ_1=(
    ["C"]=32.70
    ["C#"]=34.65
    ["Db"]=34.65
    ["D"]=36.71
    ["D#"]=38.89
    ["Eb"]=38.89
    ["E"]=41.20
    ["F"]=43.65
    ["F#"]=46.25
    ["Gb"]=46.25
    ["G"]=49.00
    ["G#"]=51.91
    ["Ab"]=51.91
    ["A"]=55.00
    ["A#"]=58.27
    ["Bb"]=58.27
    ["B"]=61.74
)

# Octave 2
declare -A NOTE_FREQ_2=(
    ["C"]=65.41
    ["C#"]=69.30
    ["Db"]=69.30
    ["D"]=73.42
    ["D#"]=77.78
    ["Eb"]=77.78
    ["E"]=82.41
    ["F"]=87.31
    ["F#"]=92.50
    ["Gb"]=92.50
    ["G"]=98.00
    ["G#"]=103.83
    ["Ab"]=103.83
    ["A"]=110.00
    ["A#"]=116.54
    ["Bb"]=116.54
    ["B"]=123.47
)

# Octave 3
declare -A NOTE_FREQ_3=(
    ["C"]=130.81
    ["C#"]=138.59
    ["Db"]=138.59
    ["D"]=146.83
    ["D#"]=155.56
    ["Eb"]=155.56
    ["E"]=164.81
    ["F"]=174.61
    ["F#"]=185.00
    ["Gb"]=185.00
    ["G"]=196.00
    ["G#"]=207.65
    ["Ab"]=207.65
    ["A"]=220.00
    ["A#"]=233.08
    ["Bb"]=233.08
    ["B"]=246.94
)

# Octave 4 (Middle C = C4)
declare -A NOTE_FREQ_4=(
    ["C"]=261.63
    ["C#"]=277.18
    ["Db"]=277.18
    ["D"]=293.66
    ["D#"]=311.13
    ["Eb"]=311.13
    ["E"]=329.63
    ["F"]=349.23
    ["F#"]=369.99
    ["Gb"]=369.99
    ["G"]=392.00
    ["G#"]=415.30
    ["Ab"]=415.30
    ["A"]=440.00
    ["A#"]=466.16
    ["Bb"]=466.16
    ["B"]=493.88
)

# Octave 5
declare -A NOTE_FREQ_5=(
    ["C"]=523.25
    ["C#"]=554.37
    ["Db"]=554.37
    ["D"]=587.33
    ["D#"]=622.25
    ["Eb"]=622.25
    ["E"]=659.25
    ["F"]=698.46
    ["F#"]=739.99
    ["Gb"]=739.99
    ["G"]=783.99
    ["G#"]=830.61
    ["Ab"]=830.61
    ["A"]=880.00
    ["A#"]=932.33
    ["Bb"]=932.33
    ["B"]=987.77
)

# Octave 6
declare -A NOTE_FREQ_6=(
    ["C"]=1046.50
    ["C#"]=1108.73
    ["Db"]=1108.73
    ["D"]=1174.66
    ["D#"]=1244.51
    ["Eb"]=1244.51
    ["E"]=1318.51
    ["F"]=1396.91
    ["F#"]=1479.98
    ["Gb"]=1479.98
    ["G"]=1567.98
    ["G#"]=1661.22
    ["Ab"]=1661.22
    ["A"]=1760.00
    ["A#"]=1864.66
    ["Bb"]=1864.66
    ["B"]=1975.53
)

# Octave 7
declare -A NOTE_FREQ_7=(
    ["C"]=2093.00
    ["C#"]=2217.46
    ["Db"]=2217.46
    ["D"]=2349.32
    ["D#"]=2489.02
    ["Eb"]=2489.02
    ["E"]=2637.02
    ["F"]=2793.83
    ["F#"]=2959.96
    ["Gb"]=2959.96
    ["G"]=3135.96
    ["G#"]=3322.44
    ["Ab"]=3322.44
    ["A"]=3520.00
    ["A#"]=3729.31
    ["Bb"]=3729.31
    ["B"]=3951.07
)

# Octave 8
declare -A NOTE_FREQ_8=(
    ["C"]=4186.01
    ["C#"]=4434.92
    ["Db"]=4434.92
    ["D"]=4698.63
    ["D#"]=4978.03
    ["Eb"]=4978.03
    ["E"]=5274.04
    ["F"]=5587.65
    ["F#"]=5919.91
    ["Gb"]=5919.91
    ["G"]=6271.93
    ["G#"]=6644.88
    ["Ab"]=6644.88
    ["A"]=7040.00
    ["A#"]=7458.62
    ["Bb"]=7458.62
    ["B"]=7902.13
)

# Note duration mappings (in milliseconds)
# Standard tempo: 120 BPM (beats per minute)
# Quarter note = 500ms at 120 BPM
declare -A NOTE_DURATION=(
    # Standard note durations
    ["whole"]=2000
    ["half"]=1000
    ["quarter"]=500
    ["eighth"]=250
    ["sixteenth"]=125
    ["thirtysecond"]=62

    # Dotted notes (1.5x duration)
    ["dotted_half"]=1500
    ["dotted_quarter"]=750
    ["dotted_eighth"]=375

    # Triplets (2/3 duration)
    ["triplet_half"]=666
    ["triplet_quarter"]=333
    ["triplet_eighth"]=166

    # Shortcuts
    ["w"]=2000
    ["h"]=1000
    ["q"]=500
    ["e"]=250
    ["s"]=125
)

# Rest durations (same as notes)
declare -A REST_DURATION=(
    ["whole"]=2000
    ["half"]=1000
    ["quarter"]=500
    ["eighth"]=250
    ["sixteenth"]=125
    ["rest"]=500  # Default rest
    ["r"]=500     # Shortcut
)

#
# Function: get_note_frequency
# Description: Get frequency for a given note and octave
# Usage: get_note_frequency "C" 4
# Returns: Frequency in Hz
#
get_note_frequency() {
    local note="$1"
    local octave="$2"

    # Validate octave
    if [ "$octave" -lt 0 ] || [ "$octave" -gt 8 ]; then
        echo "ERROR: Octave must be 0-8" >&2
        return 1
    fi

    # Get frequency from appropriate octave array
    local var_name="NOTE_FREQ_${octave}[$note]"
    local freq

    case "$octave" in
        0) freq="${NOTE_FREQ_0[$note]}" ;;
        1) freq="${NOTE_FREQ_1[$note]}" ;;
        2) freq="${NOTE_FREQ_2[$note]}" ;;
        3) freq="${NOTE_FREQ_3[$note]}" ;;
        4) freq="${NOTE_FREQ_4[$note]}" ;;
        5) freq="${NOTE_FREQ_5[$note]}" ;;
        6) freq="${NOTE_FREQ_6[$note]}" ;;
        7) freq="${NOTE_FREQ_7[$note]}" ;;
        8) freq="${NOTE_FREQ_8[$note]}" ;;
    esac

    if [ -z "$freq" ]; then
        echo "ERROR: Unknown note '$note' in octave $octave" >&2
        return 1
    fi

    echo "$freq"
}

#
# Function: get_note_duration
# Description: Get duration for a given note type
# Usage: get_note_duration "quarter"
# Returns: Duration in milliseconds
#
get_note_duration() {
    local duration_type="$1"
    local duration="${NOTE_DURATION[$duration_type]}"

    if [ -z "$duration" ]; then
        echo "ERROR: Unknown duration type '$duration_type'" >&2
        return 1
    fi

    echo "$duration"
}

#
# Function: get_rest_duration
# Description: Get duration for a given rest type
# Usage: get_rest_duration "quarter"
# Returns: Duration in milliseconds
#
get_rest_duration() {
    local duration_type="$1"
    local duration="${REST_DURATION[$duration_type]}"

    if [ -z "$duration" ]; then
        echo "ERROR: Unknown rest type '$duration_type'" >&2
        return 1
    fi

    echo "$duration"
}

#
# Function: parse_note
# Description: Parse a note string like "C4" or "F#5" into note and octave
# Usage: parse_note "C4"
# Returns: "C 4" (note and octave separated by space)
#
parse_note() {
    local note_str="$1"

    # Extract note name (can be 1-2 characters: C, C#, Bb, etc.)
    local note=$(echo "$note_str" | sed -E 's/([A-G][#b]?)[0-9]/\1/')

    # Extract octave (last digit)
    local octave=$(echo "$note_str" | sed -E 's/[A-G][#b]?([0-9])/\1/')

    if [ -z "$note" ] || [ -z "$octave" ]; then
        echo "ERROR: Invalid note format '$note_str'. Use format like 'C4' or 'F#5'" >&2
        return 1
    fi

    echo "$note $octave"
}

#
# Function: scale_tempo
# Description: Scale all note durations by a tempo factor
# Usage: scale_tempo 1.5  # Makes everything 1.5x slower
# Global: Modifies NOTE_DURATION and REST_DURATION arrays
#
scale_tempo() {
    local factor="$1"

    # Scale note durations
    for key in "${!NOTE_DURATION[@]}"; do
        local original="${NOTE_DURATION[$key]}"
        local scaled=$(echo "$original * $factor" | bc | cut -d. -f1)
        NOTE_DURATION[$key]=$scaled
    done

    # Scale rest durations
    for key in "${!REST_DURATION[@]}"; do
        local original="${REST_DURATION[$key]}"
        local scaled=$(echo "$original * $factor" | bc | cut -d. -f1)
        REST_DURATION[$key]=$scaled
    done
}

#
# Function: set_tempo_bpm
# Description: Set tempo in beats per minute (recalculates all durations)
# Usage: set_tempo_bpm 140  # 140 BPM
# Global: Modifies NOTE_DURATION and REST_DURATION arrays
#
set_tempo_bpm() {
    local bpm="$1"

    if [ "$bpm" -lt 40 ] || [ "$bpm" -gt 240 ]; then
        echo "ERROR: BPM must be between 40 and 240" >&2
        return 1
    fi

    # Quarter note duration at given BPM
    # Formula: duration_ms = 60000 / BPM
    local quarter_ms=$(echo "60000 / $bpm" | bc)

    # Recalculate all durations based on quarter note
    NOTE_DURATION["whole"]=$(echo "$quarter_ms * 4" | bc)
    NOTE_DURATION["half"]=$(echo "$quarter_ms * 2" | bc)
    NOTE_DURATION["quarter"]=$quarter_ms
    NOTE_DURATION["eighth"]=$(echo "$quarter_ms / 2" | bc)
    NOTE_DURATION["sixteenth"]=$(echo "$quarter_ms / 4" | bc)
    NOTE_DURATION["thirtysecond"]=$(echo "$quarter_ms / 8" | bc)

    NOTE_DURATION["dotted_half"]=$(echo "$quarter_ms * 3" | bc)
    NOTE_DURATION["dotted_quarter"]=$(echo "$quarter_ms * 1.5" | bc | cut -d. -f1)
    NOTE_DURATION["dotted_eighth"]=$(echo "$quarter_ms * 0.75" | bc | cut -d. -f1)

    NOTE_DURATION["triplet_half"]=$(echo "$quarter_ms * 1.333" | bc | cut -d. -f1)
    NOTE_DURATION["triplet_quarter"]=$(echo "$quarter_ms * 0.666" | bc | cut -d. -f1)
    NOTE_DURATION["triplet_eighth"]=$(echo "$quarter_ms * 0.333" | bc | cut -d. -f1)

    # Shortcuts
    NOTE_DURATION["w"]=${NOTE_DURATION["whole"]}
    NOTE_DURATION["h"]=${NOTE_DURATION["half"]}
    NOTE_DURATION["q"]=${NOTE_DURATION["quarter"]}
    NOTE_DURATION["e"]=${NOTE_DURATION["eighth"]}
    NOTE_DURATION["s"]=${NOTE_DURATION["sixteenth"]}

    # Copy to rest durations
    for key in "${!NOTE_DURATION[@]}"; do
        REST_DURATION[$key]=${NOTE_DURATION[$key]}
    done
}

# Export functions
export -f get_note_frequency
export -f get_note_duration
export -f get_rest_duration
export -f parse_note
export -f scale_tempo
export -f set_tempo_bpm
