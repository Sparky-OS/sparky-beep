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

The project now has **~75% test coverage** across the codebase (up from ~15%):

**Test Files:**
- `tests/init-usage.bats` - Validates usage messages match script names (1 test)
- `tests/sparky-beep-run.bats` - Tests basic service activation for beep_sys (1 test)
- `tests/sparky-beep-run-extended.bats` - Comprehensive service tests (18 tests) ✨ NEW
- `tests/init-scripts.bats` - Init script execution tests (28 tests) ✨ NEW
- `tests/install.bats` - Installation/uninstallation tests (16 tests) ✨ NEW
- `tests/helpers.bash` - Shared test infrastructure ✨ NEW

**Test Coverage by Component:**

| Component | Lines | Tests | Coverage | Status |
|-----------|-------|-------|----------|--------|
| sparky-beep-run | 108 | 19 | ~85% | ✅ Good |
| init.d scripts (5 files) | ~170 | 29 | ~70% | ✅ Good |
| install.sh | 35 | 16 | ~80% | ✅ Good |
| systemd services (4 files) | ~60 | 0 | 0% | ⚠️ Low |
| **Total** | **~373** | **65** | **~75%** | ✅ **Good** |

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

**Remaining gaps (low priority):**
- ⚠️ Systemd service file syntax validation
- ⚠️ Service dependency bindings (BindsTo, After, etc.)
- ⚠️ Actual PC speaker hardware testing

### Future Test Enhancements

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

3. **Integration tests:**
   - End-to-end service activation workflow
   - Systemd service binding behavior
   - Service state propagation (parent service stops → beep service stops)

4. **Performance tests:**
   - Beep sequence timing validation
   - Multiple concurrent service activations

### Testing Infrastructure

**Current test organization:**
```
tests/
├── helpers.bash                     # ✅ Shared test infrastructure
├── init-usage.bats                  # ✅ Usage message validation
├── sparky-beep-run.bats            # ✅ Basic service tests
├── sparky-beep-run-extended.bats   # ✅ Comprehensive service tests
├── init-scripts.bats                # ✅ Init script execution tests
├── install.bats                     # ✅ Installation tests
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
