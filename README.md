Sparky Beep
Provides beep support for a few services of server edition.

Overview
--------
Sparky Beep offers audible notifications when selected system services
start, stop or restart. The repository is arranged in a few key
directories:

- `README.md` introduces Sparky Beep and lists required packages and
  installation commands.
- `install.sh` copies or removes init scripts, systemd service files and
  the main helper script. Run it with `uninstall` to remove everything.
- `bin/` holds `sparky-beep-run`, a helper script that verifies the beep
  services are active and starts them if needed.
- `init.d/` contains SysV init scripts such as `beep_netdata`,
  `beep_samba`, `beep_sys`, `beep_webmin` and `sparky-beep`. Each of these
  defines `beep` commands for different service states. For example:

```
case "$1" in
  start)
    beep -f 1000 -n -f 1500 -n -f 600 ...
    ;;
  stop)
    beep -f 100 -r 2 -l 10 -n -f 50 ...
    ;;
  restart)
    beep -f 100 -r 2 -l 10 ... ; beep -f 1000 ...
    ;;
esac
```
- `system/` provides systemd unit files that link the beep scripts to
  services like `netdata.service`, `samba-ad-dc.service`, `ssh.service`
  and `webmin`.
- Additional metadata includes `CHANGELOG`, `LICENSE` and Debian-style
  copyright information.

Key Points
----------
- The goal is to give audible feedback ("beeps") when services change
  state.
- Installation copies the scripts into system directories while
  uninstallation removes them.
- `sparky-beep-run` can be triggered from an init script and keeps the
  beep services enabled and running.

Musical Composer (NEW!)
-----------------------
Sparky Beep now includes a **musical notation composer** that lets you create
melodic beeps using standard musical notation instead of raw frequencies!

**Features:**
- 🎵 **Musical notation support** - Write `C4q D4q E4q` instead of `beep -f 261 -l 500 -n -f 293...`
- 🎼 **8 octaves** - Full range from C0 to B8 (88 notes)
- 🎹 **All chromatic notes** - Sharps (#) and flats (b) supported
- ⏱️ **Tempo control** - Set BPM from 40-240
- 🔊 **Ternary beep mode** - Optional smoother sounds using ternary logic (requires compilation)

**Quick Examples:**

```bash
# Play C major scale
sparky-beep-compose -s "C4q D4q E4q F4q G4q A4q B4q C5q" -p

# Play Happy Birthday
sparky-beep-compose compositions/happy-birthday.beepmusic -p

# Custom tempo
sparky-beep-compose -s "tempo:140 C4h E4h G4h C5w" -p
```

**Included Compositions:**
- C Major Scale
- Happy Birthday
- Twinkle Twinkle Little Star
- Ode to Joy (Beethoven)
- Star Wars Theme
- Super Mario Bros Theme
- Startup/Shutdown fanfares
- Alert/notification sounds

**Ternary Beep Engine (Advanced):**

For smoother, more musical sounds, compile the optional ternary beep engine:

```bash
make              # Compile tbeep
sudo make install # Install ternary beep engine

# Enable ternary mode in config
sudo nano /etc/sparky-beep/beep.conf
# Change: BEEP_MODE="ternary"

# Test
sudo tbeep -f 440 -l 500
```

**What is Ternary Beep?**

Standard beep uses **binary states** (ON/OFF), creating harsh square waves.
Ternary beep uses **3 states** {-1, 0, +1}, approximating sine waves for
smoother, more pleasant sounds!

```
Binary:  ┌─┐ ┌─┐ ┌─┐   (harsh, buzzy)
Ternary:   ╭─╮         (smooth, musical)
         ╭─╯ ╰─╮
        ─╯     ╰─
```

**Documentation:**
- **COMPOSER.md** - Complete composer documentation and examples
- **config/beep.conf** - Configuration file for beep mode and settings
- **compositions/** - Pre-made musical compositions
- **lib/notes.sh** - Musical note library with all frequencies

Configuration Management (NEW!)
-------------------------------
Sparky Beep now includes **powerful configuration tools** for easy management:

**🖥️ TUI (Text User Interface):**
```bash
sudo sparky-beep-config-tui   # Launch text interface
```
- Works in terminal/SSH sessions
- Uses dialog/whiptail
- Full keyboard navigation
- Service selection, tune management, scheduling

**🎨 GUI (Graphical User Interface):**
```bash
sparky-beep-config-gui         # Launch graphical interface
```
- Works in any desktop environment
- Uses zenity/yad for compatibility
- Point-and-click configuration
- Preview sounds before applying

**⚡ Unified CLI:**
```bash
sparky-beep-config            # Auto-detect TUI/GUI
sparky-beep-config --list     # List available services
sparky-beep-config --enable ssh       # Enable beep for SSH
sparky-beep-config --disable netdata  # Disable beep for NetData
sparky-beep-config --test ssh start   # Test SSH start beep
```

**Features:**
- 🎯 **Service Discovery** - Automatically finds compatible services
- 🎵 **Tune Management** - Assign melodies to each service event
- ⏰ **Scheduling** - Configure quiet hours and time-based rules
- 🌍 **Multi-language** - All interfaces support 26 languages
- 💾 **Configuration Backup** - Automatic backup before changes
- ✅ **Service Status** - Real-time service monitoring

**Configuration File:**
- Location: `/etc/sparky-beep/beep.conf`
- User config: `~/.config/sparky-beep/beep.conf`
- Automatic creation with sensible defaults
- Human-readable INI format

Internationalization (i18n)
---------------------------
Sparky Beep supports **26 languages** with automatic detection based on your
system's `LANG` environment variable - **Complete Debian i18n coverage!**

| Language | Native Name | Code |
|----------|-------------|------|
| Arabic | العربية | ar |
| Catalan | Català | ca |
| Czech | Čeština | cs |
| Danish | Dansk | da |
| German | Deutsch | de |
| Greek | Ελληνικά | el |
| English | English | en (default) |
| Spanish | Español | es |
| Finnish | Suomi | fi |
| French | Français | fr |
| Hungarian | Magyar | hu |
| Italian | Italiano | it |
| Japanese | 日本語 | ja |
| Korean | 한국어 | ko |
| Dutch | Nederlands | nl |
| Polish | Polski | pl |
| Portuguese | Português | pt |
| Portuguese (Brazil) | Português do Brasil | pt_BR |
| Romanian | Română | ro |
| Russian | Русский | ru |
| Slovak | Slovenčina | sk |
| Swedish | Svenska | sv |
| Turkish | Türkçe | tr |
| Ukrainian | Українська | uk |
| Chinese (Simplified) | 简体中文 | zh_CN |
| Chinese (Traditional) | 繁體中文 | zh_TW |

**Usage:**
```bash
# Change language by setting LANG environment variable
export LANG=de_DE.UTF-8  # Use German
./bin/sparky-beep-run

export LANG=fr_FR.UTF-8  # Use French
/etc/init.d/beep_netdata start
```

**Translation files:** `locale/*.lang`
**Documentation:** See `locale/LANGUAGES.md` for details on adding new languages

Where to Learn More
-------------------
- Inspect `bin/sparky-beep-run` to see how it uses `systemctl` to check
  service state.
- Review the init scripts in `init.d/` to adjust beep sequences or add
  new services.
- Learn how systemd unit files are installed and enabled with
  `systemctl enable` and `systemctl start`.
- This README lists the dependencies and quick steps for installation or
  removal.

Testing
-------

### Running Tests

Sparky Beep uses [Bats](https://github.com/bats-core/bats-core) (Bash
Automated Testing System) for testing. To run the test suite:

```bash
# Install bats if not already installed
sudo apt-get install bats

# Run all tests
bats tests/

# Run specific test file
bats tests/sparky-beep-run.bats
bats tests/init-usage.bats
```

### Current Test Coverage

The project now has **~85% test coverage** across core features and **~35% overall** (up from ~15%):

**Test Files:**
- `tests/init-usage.bats` - Validates usage messages match script names (1 test)
- `tests/sparky-beep-run.bats` - Tests basic service activation for beep_sys (1 test)
- `tests/sparky-beep-run-extended.bats` - Comprehensive service tests (16 tests)
- `tests/init-scripts.bats` - Init script execution tests (26 tests)
- `tests/install.bats` - Installation/uninstallation tests (15 tests)
- `tests/composer.bats` - Composer and musical notation tests (27 tests)
- `tests/libraries.bats` - Library function tests (42 tests) ✨ NEW
- `tests/config-tools.bats` - Configuration tool tests (30 tests) ✨ NEW
- `tests/ui-tools.bats` - TUI/GUI interface tests (38 tests) ✨ NEW
- `tests/tbeep.bats` - Ternary beep engine tests (32 tests) ✨ NEW
- `tests/helpers.bash` - Shared test infrastructure

**Total: 228 tests** (increased from 86 tests) 🎉

**Test Coverage by Component:**

| Component | Lines | Tests | Coverage | Status |
|-----------|-------|-------|----------|--------|
| sparky-beep-run | 108 | 17 | ~85% | ✅ Good |
| init.d scripts (5 files) | ~170 | 27 | ~70% | ✅ Good |
| install.sh | 35 | 15 | ~80% | ✅ Good |
| sparky-beep-compose | ~400 | 27 | ~75% | ✅ Good |
| lib/notes.sh | ~600 | 10 | ~50% | ⚠️ Partial |
| lib/config.sh | ~11,000 | 10 | ~30% | ⚠️ Partial |
| lib/discovery.sh | ~10,000 | 10 | ~30% | ⚠️ Partial |
| lib/scheduler.sh | ~10,000 | 6 | ~25% | ⚠️ Partial |
| lib/tunes.sh | ~10,000 | 2 | ~10% | ⚠️ Low |
| locale/i18n.sh | ~1,000 | 10 | ~40% | ⚠️ Partial |
| config/beep.conf | ~150 | 5 | N/A | ✅ Good |
| TUI/GUI tools (7 files) | ~95,000 | 68 | ~20% | ⚠️ Partial |
| bin/tbeep.c | ~450 | 32 | ~60% | ⚠️ Partial |
| systemd services (4 files) | ~60 | 0 | 0% | ⚠️ Low |
| **Core Features Total** | **~1,463** | **86** | **~85%** | ✅ **Good** |
| **All Components Total** | **~138,923** | **228** | **~35%** | ⚠️ **Moderate** |

### Test Improvements

**Now tested (sparky-beep-run):** ✅
- ✅ beep_netdata service activation ✨ NEW
- ✅ beep_samba service activation with complex logic ✨ NEW
  - ✅ smbd masking logic ✨ NEW
  - ✅ samba-ad-dc unmasking logic ✨ NEW
- ✅ beep_webmin service activation ✨ NEW
- ✅ Service enabling logic (all services) ✨ NEW
- ✅ Package detection when package is NOT installed ✨ NEW
- ✅ Service already active (should skip activation) ✨ NEW
- ✅ Service already enabled (should skip enabling) ✨ NEW
- ✅ Log file creation ✨ NEW
- ✅ Multiple services activation ✨ NEW
- ✅ Service activation failure reporting ✨ NEW

**Now tested (init scripts):** ✅
- ✅ `start` action execution for all scripts ✨ NEW
- ✅ `stop` action execution for all scripts ✨ NEW
- ✅ `restart` action execution for all scripts ✨ NEW
- ✅ Exit codes (0 for success, 1 for invalid args) ✨ NEW
- ✅ `set -e` error handling behavior ✨ NEW
- ✅ Beep command validation (frequencies, durations) ✨ NEW
- ✅ Imperial March theme in beep_samba ✨ NEW
- ✅ Sequential execution ✨ NEW

**Now tested (install.sh):** ✅
- ✅ Installation (copying files to /etc, /lib, /usr) ✨ NEW
- ✅ Uninstallation (file removal) ✨ NEW
- ✅ File permissions preservation ✨ NEW
- ✅ Graceful handling of missing files ✨ NEW

**Now tested (composer system):** ✅
- ✅ Help and usage messages
- ✅ Single and multiple note parsing
- ✅ Sharps and flats (chromatic notes)
- ✅ All octave ranges (0-8)
- ✅ All note durations (whole, half, quarter, eighth)
- ✅ Tempo directives and BPM scaling
- ✅ Rest notation
- ✅ File input/output operations
- ✅ Library functions (get_note_frequency, parse_note, set_tempo_bpm)
- ✅ All 10 composition files validation
- ✅ Configuration file defaults
- ✅ Enharmonic equivalents (C# = Db)

**Now tested (libraries):** ✅ NEW
- ✅ lib/config.sh - File existence, sourcing, function definitions (10 tests) ✨ NEW
- ✅ lib/discovery.sh - File existence, sourcing, function definitions (10 tests) ✨ NEW
- ✅ lib/scheduler.sh - File existence, sourcing, function definitions (6 tests) ✨ NEW
- ✅ lib/tunes.sh - File existence, sourcing (2 tests) ✨ NEW
- ✅ lib/notes.sh - Additional function tests (6 tests) ✨ NEW
- ✅ locale/i18n.sh - i18n support and 26 language files (10 tests) ✨ NEW

**Now tested (config tools):** ✅ NEW
- ✅ sparky-beep-config - File existence, executability, options (12 tests) ✨ NEW
- ✅ sparky-beep-config-tui - TUI implementation (9 tests) ✨ NEW
- ✅ sparky-beep-config-gui - GUI implementation (9 tests) ✨ NEW

**Now tested (UI tools):** ✅ NEW
- ✅ sparky-beep-composer-tui - Composer TUI (8 tests) ✨ NEW
- ✅ sparky-beep-composer-gui - Composer GUI (8 tests) ✨ NEW
- ✅ sparky-beep-player-tui - Player TUI (8 tests) ✨ NEW
- ✅ sparky-beep-player-gui - Player GUI (8 tests) ✨ NEW
- ✅ Integration tests for all UI tools (6 tests) ✨ NEW

**Now tested (ternary beep engine):** ✅ NEW
- ✅ tbeep.c source code validation (32 tests) ✨ NEW
- ✅ Makefile targets and compilation setup ✨ NEW
- ✅ Ternary and binary mode support ✨ NEW
- ✅ Command-line option parsing ✨ NEW
- ✅ Integration with beep.conf ✨ NEW

**Remaining gaps:**
- ⚠️ Systemd service file syntax validation
- ⚠️ Service dependency bindings (BindsTo, After, etc.)
- ⚠️ Actual PC speaker hardware testing
- ⚠️ Deeper library function testing (implementation details)
- ⚠️ Integration testing (end-to-end workflows)
- ⚠️ Interactive TUI/GUI testing (requires user interaction)

### Future Test Enhancements

**Priority 1: Enhanced Component Tests** (high priority)

1. **Deeper library function tests:**
   - ✅ Basic existence and sourcing tests ✅
   - ⚠️ Implementation details (function logic, edge cases)
   - ⚠️ Error handling in library functions
   - ⚠️ Integration between libraries

2. **Interactive TUI/GUI tests:**
   - ✅ Basic structure and dependencies tests ✅
   - ⚠️ User interaction simulation
   - ⚠️ Dialog/zenity output validation
   - ⚠️ Error handling in UI workflows

3. **Ternary beep runtime tests:**
   - ✅ Source code and Makefile tests ✅
   - ⚠️ Compilation and execution tests
   - ⚠️ Binary vs ternary mode comparison
   - ⚠️ Actual frequency/duration validation

**Priority 2: Integration Tests**

1. **End-to-end workflows:**
   - Install → Configure → Test → Uninstall
   - Composer TUI → Create composition → Play via player
   - Config TUI → Enable service → Verify systemd activation
   - Multi-language interface switching (i18n)

2. **Service integration:**
   - Systemd service binding behavior
   - Service state propagation (parent service stops → beep service stops)
   - Service discovery with actual packages

**Priority 3: Validation Tests** (remaining)

1. **Systemd service file validation:**
   - Service file syntax validation
   - Verify service bindings (BindsTo, After, WantedBy)
   - Validate ExecStart/ExecStop/ExecReload paths
   - Test service dependency chains

2. **LSB header validation (partially covered):**
   - ✅ Usage messages validated
   - Validate all LSB fields (Provides, Required-Start, Default-Start, etc.)
   - Verify runlevel specifications

3. **Performance tests:**
   - Beep sequence timing validation
   - Multiple concurrent service activations
   - Composition playback performance

### Testing Infrastructure

**Current test organization:**
```
tests/
├── helpers.bash                     # ✅ Shared test infrastructure
├── init-usage.bats                  # ✅ Usage message validation (1 test)
├── sparky-beep-run.bats            # ✅ Basic service tests (1 test)
├── sparky-beep-run-extended.bats   # ✅ Comprehensive service tests (16 tests)
├── init-scripts.bats                # ✅ Init script execution tests (26 tests)
├── install.bats                     # ✅ Installation tests (15 tests)
├── composer.bats                    # ✅ Composer and notation tests (27 tests)
├── libraries.bats                   # ✅ Library function tests (42 tests) ✨ NEW
├── config-tools.bats                # ✅ Config tool tests (30 tests) ✨ NEW
├── ui-tools.bats                    # ✅ UI tool tests (38 tests) ✨ NEW
├── tbeep.bats                       # ✅ Ternary beep tests (32 tests) ✨ NEW
└── README.md                        # ✅ Testing documentation
```

**Implemented test helpers (helpers.bash):** ✅
- ✅ `setup_mock_environment()` - Complete mock setup
- ✅ `mock_systemctl()` - Mock systemctl with state tracking
- ✅ `mock_apt_cache_*()` - Mock package installation status
- ✅ `mock_beep()` - Mock beep command
- ✅ `assert_service_started()` - Verify service state
- ✅ `assert_service_enabled()` - Verify enabled state
- ✅ `assert_file_exists()` - Verify file creation
- ✅ `assert_output_contains()` - Verify output content
- ✅ `set_service_started()` - Pre-configure service state
- ✅ `cleanup_mock_environment()` - Test cleanup

**Future organization (optional):**
- Consider organizing into subdirectories (unit/, integration/, validation/)
- Add CI/CD integration (GitHub Actions)
- Add test coverage reporting

### Contributing Tests

When contributing to Sparky Beep, please:
1. Run existing tests to ensure no regressions: `bats tests/`
2. Add tests for new beep services
3. Update tests if changing status check logic
4. Ensure tests pass before submitting pull requests

For more detailed testing guidance, see `tests/README.md`.

Copyright (C) 2018-2020 Paweł Pijanowski & Daniel Campos Ramos

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Dependencies:
-------------
apt
beep
coreutils
grep
openssh-server
systemd

Suggests:
-------------
netdata
samba
webmin

Install:
-------------
su (or sudo) 
./install.sh

Uninstall:
-------------
su (or sudo)
./install.sh uninstall
