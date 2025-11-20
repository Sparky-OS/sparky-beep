# Sparky Beep Composer Documentation

The Sparky Beep Composer system enables you to create musical PC speaker notifications using standard musical notation instead of raw frequency commands.

## Table of Contents

1. [Overview](#overview)
2. [Components](#components)
3. [Musical Notation Format](#musical-notation-format)
4. [Command Line Usage](#command-line-usage)
5. [Beep Modes: Binary vs Ternary](#beep-modes-binary-vs-ternary)
6. [Composition Files](#composition-files)
7. [Integration with Init Scripts](#integration-with-init-scripts)
8. [Examples](#examples)
9. [Configuration](#configuration)
10. [Troubleshooting](#troubleshooting)

---

## Overview

The Sparky Beep Composer system consists of three main components:

1. **Musical Note Library** (`lib/notes.sh`) - Defines note-to-frequency mappings
2. **Beep Composer** (`bin/sparky-beep-compose`) - Translates musical notation to beep commands
3. **Ternary Beep Engine** (`bin/tbeep`) - Optional C program for smoother, more musical sounds

### Why Use the Composer?

**Before (raw beep commands):**
```bash
# Hard to read and modify
beep -f 261 -l 500 -n -f 293 -l 500 -n -f 329 -l 500 -n -f 349 -l 500
```

**After (musical notation):**
```bash
# Easy to read and compose
sparky-beep-compose -s "C4q D4q E4q F4q" -p
```

---

## Components

### 1. Musical Note Library (`lib/notes.sh`)

Provides comprehensive musical note definitions:

- **8+ octaves** of notes (C0 - B8)
- **All chromatic notes** (sharps and flats: C#, Db, etc.)
- **Note durations** (whole, half, quarter, eighth, sixteenth)
- **Tempo control** (BPM support)
- **Helper functions** for note parsing and frequency lookup

**Key Features:**
- Based on A440 standard tuning
- Supports both sharp (#) and flat (b) notation
- Includes dotted notes and triplets
- Tempo scaling from 40-240 BPM

### 2. Beep Composer (`bin/sparky-beep-compose`)

The main command-line tool for composing music.

**Capabilities:**
- Parse musical notation from files or command-line strings
- Generate compatible beep commands for binary or ternary modes
- Set custom tempo (BPM)
- Play compositions immediately or save to files
- Support for rests and complex rhythms

### 3. Ternary Beep Engine (`bin/tbeep`)

Optional C program that uses ternary logic for smoother sounds.

**How It Works:**
- Uses 3 states instead of 2: **{-1, 0, +1}**
- Approximates sine waves instead of square waves
- Creates more pleasant, musical tones
- Reduces harmonic harshness

**Compilation:**
```bash
make              # Compile tbeep
sudo make install # Install to /usr/bin/tbeep
```

---

## Musical Notation Format

### Note Format

**Syntax:** `<note><octave><duration>`

**Examples:**
- `C4q` - C in octave 4, quarter note
- `F#5h` - F sharp in octave 5, half note
- `Bb3e` - B flat in octave 3, eighth note
- `r:q` - Quarter rest (silence)

**Alternate Syntax:** `<note><octave>:<duration>`
- `C4:q` - Same as `C4q`
- `F#5:h` - Same as `F#5h`

### Notes

All chromatic notes are supported:
- **Natural notes:** C, D, E, F, G, A, B
- **Sharps:** C#, D#, F#, G#, A#
- **Flats:** Db, Eb, Gb, Ab, Bb

**Enharmonic equivalents** (same frequency):
- C# = Db
- D# = Eb
- F# = Gb
- G# = Ab
- A# = Bb

### Octaves

Range: **0-8**

| Octave | Description | Example Notes |
|--------|-------------|---------------|
| 0-2 | Very low | Sub-bass range |
| 3 | Low | Bass range |
| 4 | **Middle** | Contains Middle C (C4) |
| 5 | High | Treble range |
| 6-8 | Very high | Upper treble |

**Middle C is C4** (261.63 Hz)

### Durations

| Symbol | Name | Relative Length |
|--------|------|-----------------|
| `w` | Whole note | 4 beats |
| `h` | Half note | 2 beats |
| `q` | Quarter note | 1 beat |
| `e` | Eighth note | 1/2 beat |
| `s` | Sixteenth note | 1/4 beat |

**Full names also supported:**
- `whole`, `half`, `quarter`, `eighth`, `sixteenth`

**Dotted notes:**
- `dotted_half`, `dotted_quarter`, `dotted_eighth`

**Triplets:**
- `triplet_half`, `triplet_quarter`, `triplet_eighth`

### Rests

**Syntax:** `r:<duration>` or `r<duration>`

**Examples:**
- `r:q` - Quarter rest
- `r:h` - Half rest
- `r:w` - Whole rest

### Tempo

**Directive:** `tempo:<BPM>`

**Example:**
```
tempo:120  # Set tempo to 120 beats per minute
```

**Tempo Ranges:**
- 40-60 BPM - Largo (very slow)
- 60-80 BPM - Adagio (slow)
- 80-100 BPM - Andante (walking pace)
- 100-120 BPM - Moderato (moderate)
- 120-140 BPM - Allegro (fast)
- 140-180 BPM - Vivace (very fast)
- 180-240 BPM - Presto (extremely fast)

### Comments

Lines starting with `#` are comments:
```
# This is a comment
tempo:120  # Inline comments also work
C4q D4q    # C and D quarter notes
```

---

## Command Line Usage

### Basic Syntax

```bash
sparky-beep-compose [OPTIONS] <file>
sparky-beep-compose [OPTIONS] -s "<notation>"
```

### Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-s, --string "<notation>"` | Compose from string instead of file |
| `-e, --execute` | Execute composition immediately |
| `-p, --play` | Play composition after generating |
| `-t, --tempo <bpm>` | Set tempo in BPM (default: 120) |
| `-m, --mode <mode>` | Set beep mode: binary or ternary |
| `-o, --output <file>` | Output beep commands to file |
| `-d, --dry-run` | Show generated commands without playing |

### Examples

**Play C major scale:**
```bash
sparky-beep-compose -s "C4q D4q E4q F4q G4q A4q B4q C5q" -p
```

**Play from file:**
```bash
sparky-beep-compose compositions/happy-birthday.beepmusic -p
```

**Set custom tempo:**
```bash
sparky-beep-compose -s "tempo:80 C4h D4h E4h F4h" -p
```

**Generate beep commands to file:**
```bash
sparky-beep-compose -s "C4q E4q G4q" -o /tmp/chord.sh
chmod +x /tmp/chord.sh
sudo /tmp/chord.sh
```

**Dry run (show commands without playing):**
```bash
sparky-beep-compose -s "C4q D4q E4q" -d
# Output: beep -f 261 -l 500 -n -f 293 -l 500 -n -f 329 -l 500
```

**Use ternary mode:**
```bash
sparky-beep-compose -s "C4q D4q E4q" -m ternary -p
# Requires tbeep to be installed
```

---

## Beep Modes: Binary vs Ternary

### Binary Mode (Default)

Uses standard `beep` command with **2 states**: ON/OFF

**Characteristics:**
- ✅ Compatible with all systems
- ✅ No compilation required
- ✅ Fast and simple
- ❌ Harsh square wave sound
- ❌ Strong odd harmonics (buzzy sound)

**Waveform:**
```
  ┌─┐ ┌─┐ ┌─┐
──┘ └─┘ └─┘ └──  (Square wave)
```

**Use Cases:**
- Simple alerts and notifications
- Maximum compatibility
- Quick beeps

### Ternary Mode (Advanced)

Uses `tbeep` command with **3 states**: {-1, 0, +1}

**Characteristics:**
- ✅ Smoother, more musical sound
- ✅ Approximates sine waves
- ✅ Reduced harmonic harshness
- ✅ Better for melodies
- ❌ Requires compilation
- ❌ Needs root access for PC speaker control

**Waveform:**
```
    ╭─╮
  ╭─╯ ╰─╮
──╯     ╰──  (Approximated sine wave)
```

**Use Cases:**
- Musical compositions
- Pleasant startup/shutdown sounds
- Multi-note melodies

### Enabling Ternary Mode

**1. Compile tbeep:**
```bash
cd /home/user/sparky-beep
make
sudo make install
```

**2. Configure ternary mode:**
```bash
sudo nano /etc/sparky-beep/beep.conf
# Change: BEEP_MODE="binary"
# To:     BEEP_MODE="ternary"
```

**3. Test:**
```bash
sudo tbeep -f 440 -l 500
```

### Comparison Example

**Binary mode (harsh square wave):**
```bash
beep -f 440 -l 500
# Buzzy, electronic sound
```

**Ternary mode (smooth sine approximation):**
```bash
sudo tbeep -f 440 -l 500
# Warmer, more musical sound
```

---

## Composition Files

Composition files use the `.beepmusic` extension.

### File Format

```
# Comments start with #
# Tempo directive (optional)
tempo:<BPM>

# Notes and rests
<note><duration> <note><duration> ...

# Multiple lines allowed
<note><duration>
<note><duration>
```

### Example: C Major Scale

**File:** `c-major-scale.beepmusic`
```
# C Major Scale
tempo:120

# Ascending
C4q D4q E4q F4q G4q A4q B4q C5h

# Descending
C5q B4q A4q G4q F4q E4q D4q C4h
```

### Example: Happy Birthday

**File:** `happy-birthday.beepmusic`
```
# Happy Birthday
tempo:100

# Happy birthday to you
C4e C4e D4q C4q F4q E4h

# Happy birthday to you
C4e C4e D4q C4q G4q F4h

# Happy birthday dear <name>
C4e C4e C5q A4q F4q E4q D4h

# Happy birthday to you
Bb4e Bb4e A4q F4q G4q F4w
```

### Included Compositions

The following compositions are included in `compositions/`:

| File | Description | Tempo |
|------|-------------|-------|
| `c-major-scale.beepmusic` | Basic scale exercise | 120 BPM |
| `happy-birthday.beepmusic` | Birthday song | 100 BPM |
| `twinkle-twinkle.beepmusic` | Children's song | 100 BPM |
| `startup-fanfare.beepmusic` | System startup sound | 140 BPM |
| `shutdown-melody.beepmusic` | System shutdown sound | 90 BPM |
| `error-alert.beepmusic` | Error notification | 160 BPM |
| `success-notification.beepmusic` | Success chime | 120 BPM |
| `ode-to-joy.beepmusic` | Beethoven's 9th theme | 120 BPM |
| `mario-theme.beepmusic` | Super Mario Bros | 180 BPM |
| `star-wars-theme.beepmusic` | Star Wars main theme | 108 BPM |

**Location after installation:**
```
/usr/share/sparky-beep/compositions/
```

---

## Integration with Init Scripts

### Method 1: Using Composition Files

```bash
#!/bin/sh -e
### BEGIN INIT INFO
# ...
### END INIT INFO

case "$1" in
  start)
    sparky-beep-compose /usr/share/sparky-beep/compositions/startup-fanfare.beepmusic -e
    ;;
  stop)
    sparky-beep-compose /usr/share/sparky-beep/compositions/shutdown-melody.beepmusic -e
    ;;
esac
```

### Method 2: Inline Notation

```bash
#!/bin/sh -e
### BEGIN INIT INFO
# ...
### END INIT INFO

case "$1" in
  start)
    sparky-beep-compose -s "tempo:140 C4e E4e G4q C5e" -e
    ;;
  stop)
    sparky-beep-compose -s "tempo:90 C5q G4q E4q C4h" -e
    ;;
esac
```

### Method 3: Fallback to Standard Beep

```bash
#!/bin/sh -e
### BEGIN INIT INFO
# ...
### END INIT INFO

if command -v sparky-beep-compose >/dev/null 2>&1; then
    # Use composer
    sparky-beep-compose -s "C4q E4q G4q" -e
else
    # Fallback to standard beep
    beep -f 261 -l 500 -n -f 329 -l 500 -n -f 392 -l 500
fi
```

### Complete Example

See `init.d/beep_example_composer` for a complete example.

---

## Examples

### Simple Melodies

**Twinkle Twinkle Little Star (first line):**
```bash
sparky-beep-compose -s "C4q C4q G4q G4q A4q A4q G4h" -p
```

**Mary Had a Little Lamb:**
```bash
sparky-beep-compose -s "E4q D4q C4q D4q E4q E4q E4h" -p
```

**Ode to Joy (opening):**
```bash
sparky-beep-compose -s "E4q E4q F4q G4q G4q F4q E4q D4q C4q C4q D4q E4q E4q D4e D4h" -p
```

### Chords and Harmonies

**C Major Chord (arpeggio):**
```bash
sparky-beep-compose -s "C4e E4e G4e C5e G4e E4e C4h" -p
```

**Ascending Power Chords:**
```bash
sparky-beep-compose -s "C3e C4e r:e D3e D4e r:e E3e E4e r:e F3e F4e r:e G3e G4e" -p
```

### Alert Sounds

**Error Alert (urgent, non-annoying):**
```bash
sparky-beep-compose -s "tempo:160 E5s E5s r:s C4s C4s r:s E5s E5s r:s C4s C4s r:s E5q" -p
```

**Success Notification:**
```bash
sparky-beep-compose -s "C4e E4e G4e C5q" -p
```

**Warning (descending):**
```bash
sparky-beep-compose -s "tempo:140 G5e F5e E5e D5e C5e" -p
```

### System Sounds

**Boot Up:**
```bash
sparky-beep-compose -s "tempo:140 C3e E3e G3e C4h r:q C4e E4e G4e C5h" -p
```

**Shutdown:**
```bash
sparky-beep-compose -s "tempo:80 C5e G4e E4e C4w" -p
```

**Restart:**
```bash
sparky-beep-compose -s "tempo:160 C4s E4s G4s C5s r:e C5s G4s E4s C4s" -p
```

### Musical Scales

**Chromatic Scale (all 12 notes):**
```bash
sparky-beep-compose -s "C4s C#4s D4s D#4s E4s F4s F#4s G4s G#4s A4s A#4s B4s C5q" -p
```

**Pentatonic Scale:**
```bash
sparky-beep-compose -s "C4q D4q E4q G4q A4q C5h" -p
```

**Blues Scale:**
```bash
sparky-beep-compose -s "C4q Eb4q F4q F#4q G4q Bb4q C5h" -p
```

---

## Configuration

### Configuration File

**Location:** `/etc/sparky-beep/beep.conf`

**Key Settings:**

```bash
# Beep mode: binary or ternary
BEEP_MODE="binary"

# Beep command path
BEEP_COMMAND="beep"

# Default tempo (BPM)
DEFAULT_TEMPO=120

# Default octave
DEFAULT_OCTAVE=4

# Enable compositions
ENABLE_COMPOSITIONS="yes"

# Composition directory
COMPOSITION_DIR="/usr/share/sparky-beep/compositions"

# Fallback to binary if ternary unavailable
FALLBACK_TO_BINARY="yes"
```

### Changing Beep Mode

**Enable ternary mode:**
```bash
sudo nano /etc/sparky-beep/beep.conf
# Change BEEP_MODE="binary" to BEEP_MODE="ternary"
```

**Verify tbeep is installed:**
```bash
which tbeep
# Should output: /usr/bin/tbeep
```

### Setting Default Tempo

```bash
sudo nano /etc/sparky-beep/beep.conf
# Change DEFAULT_TEMPO=120 to desired BPM
```

### Creating Custom Compositions

**1. Create composition file:**
```bash
nano ~/my-composition.beepmusic
```

**2. Write musical notation:**
```
# My Custom Composition
tempo:120

C4q D4q E4q F4q
G4q A4q B4q C5h
```

**3. Test:**
```bash
sparky-beep-compose ~/my-composition.beepmusic -p
```

**4. Install system-wide (optional):**
```bash
sudo cp ~/my-composition.beepmusic /usr/share/sparky-beep/compositions/
```

---

## Troubleshooting

### Common Issues

**1. "Command not found: sparky-beep-compose"**

**Solution:**
```bash
# Reinstall sparky-beep
cd /home/user/sparky-beep
sudo ./install.sh
```

**2. "Cannot find notes library"**

**Solution:**
```bash
# Ensure lib/notes.sh is installed
ls -la /usr/share/sparky-beep/lib/notes.sh

# If missing, reinstall
sudo ./install.sh
```

**3. "tbeep: Permission denied"**

**Solution:**
```bash
# tbeep requires root access for PC speaker
sudo tbeep -f 440 -l 500

# Or use binary mode instead
sparky-beep-compose -s "A4q" -m binary -p
```

**4. "No sound / Silent beeps"**

**Possible causes:**
- PC speaker disabled in BIOS
- Using laptop without PC speaker (need external USB beeper)
- PulseAudio/ALSA conflict

**Solution:**
```bash
# Check if beep utility works
sudo beep -f 440 -l 500

# Load PC speaker kernel module
sudo modprobe pcspkr

# Check if module is loaded
lsmod | grep pcspkr
```

**5. "Composition plays too fast/slow"**

**Solution:**
```bash
# Override tempo with -t option
sparky-beep-compose file.beepmusic -t 80 -p  # Slower
sparky-beep-compose file.beepmusic -t 160 -p # Faster
```

**6. "ERROR: Unknown note"**

**Solution:**
- Check note format: Must be `C4q` or `C#4q` (sharp) or `Bb4q` (flat)
- Verify octave is 0-8
- Verify duration is valid (w, h, q, e, s)

**Example corrections:**
- ❌ `C` → ✅ `C4q` (need octave and duration)
- ❌ `C9q` → ✅ `C8q` (octave 9 doesn't exist)
- ❌ `Cx4q` → ✅ `C#4q` (use # for sharp, not x)

### Debug Mode

**Enable verbose output:**
```bash
# Add debug output to sparky-beep-compose
export DEBUG=1
sparky-beep-compose -s "C4q D4q E4q" -d
```

**Check generated beep commands:**
```bash
# Use --dry-run to see what would be executed
sparky-beep-compose -s "C4q D4q E4q" -d
# Output shows exact beep command that would run
```

### Testing

**Test individual components:**

```bash
# 1. Test note library
source /usr/share/sparky-beep/lib/notes.sh
get_note_frequency "C" 4  # Should output: 261.63

# 2. Test composer (dry run)
sparky-beep-compose -s "C4q" -d

# 3. Test beep command
sudo beep -f 261 -l 500

# 4. Test tbeep (if installed)
sudo tbeep -f 261 -l 500
```

---

## Advanced Usage

### Custom Ternary Patterns

Edit `bin/tbeep.c` to modify ternary sine approximation:

```c
// Change pattern_length for different smoothness
const int pattern_length = 24;  // More states = smoother (default: 12)
```

Recompile:
```bash
make clean
make
sudo make install
```

### Harmonic Control

Future enhancement: Add harmonic coefficient control to ternary beep.

**Concept:**
```bash
# Hypothetical syntax for harmonic control
tbeep -f 440 -l 500 --harmonics "1,0,-1,0,1"
# = fundamental + inverted 3rd + 5th harmonic
```

### Integration with K3D (Future)

The composer can integrate with procedural audio systems:

```python
# Hypothetical K3D integration
from sparky_beep import BeepComposer

composer = BeepComposer()
harmonics = k3d_galaxy_star["audio_concept"]["rpn_harmonics"]

# Generate beep composition from K3D harmonics
composition = composer.from_harmonics(harmonics)
composition.play()
```

---

## License

Copyright (C) 2025 Sparky Beep Project

Licensed under GNU General Public License v3.

---

**Happy composing!** 🎵
