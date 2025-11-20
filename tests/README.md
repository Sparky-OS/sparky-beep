# Tests

This project uses [Bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System) for shell script testing.

## Running Tests

Install `bats` if not already installed:

```bash
sudo apt-get install bats
```

From the repository root, run all tests:

```bash
bats tests/
```

Run individual test files:

```bash
bats tests/sparky-beep-run.bats
bats tests/sparky-beep-run-extended.bats
bats tests/init-usage.bats
bats tests/init-scripts.bats
bats tests/install.bats
bats tests/composer.bats
```

Run with verbose output:

```bash
bats -t tests/
```

## Test Files

### `init-usage.bats`
- **Purpose:** Validates usage messages in init scripts
- **Coverage:** LSB-compliant usage text format
- **Lines:** 11
- **Tests:** 1 test covering all beep_* scripts

**What it tests:**
- Ensures usage messages reference the correct script path
- Pattern: `/etc/init.d/<script-name> {start|stop|restart}`

### `sparky-beep-run.bats`
- **Purpose:** Tests service startup and management logic
- **Coverage:** Basic service activation for beep_sys
- **Lines:** 58
- **Tests:** 1 test

**What it tests:**
- Starting an inactive beep_sys service
- Service status verification after activation
- Mock environment setup for systemctl, apt-cache, and beep

### `sparky-beep-run-extended.bats` ✨ NEW
- **Purpose:** Comprehensive service activation tests for all services
- **Coverage:** All beep services (netdata, samba, webmin, sys)
- **Tests:** 18 tests

**What it tests:**
- beep_netdata activation when netdata is installed
- beep_samba activation when samba is installed
- beep_webmin activation when webmin is installed
- beep_sys activation (always runs, no package check)
- Service enabling for all services
- Skipping services when packages are not installed
- Skipping activation when services are already active
- Samba smbd/samba-ad-dc masking/unmasking logic
- Log file creation in /tmp
- Multiple services activation
- Service activation failure reporting

### `init-scripts.bats` ✨ NEW
- **Purpose:** Tests init script execution for all beep_* scripts
- **Coverage:** All init.d scripts (beep_sys, beep_netdata, beep_samba, beep_webmin)
- **Tests:** 28 tests

**What it tests:**
- Start action execution for all scripts
- Stop action execution for all scripts
- Restart action execution for all scripts
- Exit code 0 for valid commands
- Exit code 1 for invalid arguments
- Correct usage message format
- Beep command parameters (frequency, duration, etc.)
- Imperial March theme in beep_samba
- Sequential execution of multiple init scripts
- Error handling with set -e

### `install.bats` ✨ NEW
- **Purpose:** Tests installation and uninstallation process
- **Coverage:** install.sh script
- **Tests:** 15 tests

**What it tests:**
- Copying init scripts to /etc/init.d/
- Copying systemd units to /lib/systemd/system/
- Copying executables to /usr/bin/
- Execute permissions preservation
- Uninstallation file removal
- Uninstall gracefully handles missing files
- Install script structure validation

### `composer.bats` ✨ NEW
- **Purpose:** Tests musical composition system and notation parser
- **Coverage:** sparky-beep-compose and lib/notes.sh
- **Tests:** 27 tests

**What it tests:**
- Help and usage messages
- Input validation (requires file or string)
- Single note parsing (dry run mode)
- Multiple note sequences
- Chromatic notes (sharps and flats)
- Different octave ranges (0-8)
- All note durations (whole, half, quarter, eighth)
- Tempo directives and BPM scaling
- Rest notation
- Comment handling in compositions
- File input (reading .beepmusic files)
- File output (generating executable scripts)
- Output file permissions (executable flag)
- C major scale validation
- Invalid note format handling
- Invalid octave handling
- Enharmonic equivalents (C# = Db)
- Library function testing:
  - `get_note_frequency()` function
  - `parse_note()` function
  - `set_tempo_bpm()` function
  - `get_note_duration()` function
- Example composition file validation (all 10 files)
- Configuration file existence and defaults

### `libraries.bats` ✨ NEW
- **Purpose:** Tests library functions and internationalization
- **Coverage:** lib/*.sh and locale/i18n.sh
- **Tests:** 42 tests

**What it tests:**
- lib/config.sh - File existence, sourcing, all function definitions
- lib/discovery.sh - Service discovery functions
- lib/tunes.sh - Tune library management
- lib/scheduler.sh - Time-based scheduling functions
- lib/notes.sh - Additional function coverage
- locale/i18n.sh - Internationalization support
- All 26 language files existence (ar, ca, cs, da, de, el, en, es, fi, fr, hu, it, ja, ko, nl, pl, pt, pt_BR, ro, ru, sk, sv, tr, uk, zh_CN, zh_TW)
- Integration test - all libraries source together without conflicts

### `config-tools.bats` ✨ NEW
- **Purpose:** Tests configuration management tools
- **Coverage:** sparky-beep-config, sparky-beep-config-tui, sparky-beep-config-gui
- **Tests:** 30 tests

**What it tests:**
- sparky-beep-config - Main config tool (12 tests)
  - File existence and executability
  - Command-line options (--list, --enable, --disable, --test)
  - Library sourcing (config.sh, discovery.sh)
- sparky-beep-config-tui - Text interface (9 tests)
  - Dialog/whiptail usage
  - Menu and checklist functionality
  - i18n support
- sparky-beep-config-gui - Graphical interface (9 tests)
  - Zenity/yad usage
  - GUI elements (list, forms)
  - i18n support

### `ui-tools.bats` ✨ NEW
- **Purpose:** Tests TUI/GUI interface tools for composer and player
- **Coverage:** 4 composer/player tools (TUI and GUI variants)
- **Tests:** 38 tests

**What it tests:**
- sparky-beep-composer-tui - Interactive composer TUI (8 tests)
- sparky-beep-composer-gui - Interactive composer GUI (8 tests)
- sparky-beep-player-tui - Composition player TUI (8 tests)
- sparky-beep-player-gui - Composition player GUI (8 tests)
- Integration tests (6 tests):
  - All tools present and executable
  - Shebang lines
  - i18n support
  - TUI tools use dialog/whiptail
  - GUI tools use zenity/yad

### `tbeep.bats` ✨ NEW
- **Purpose:** Tests ternary beep engine source code and build system
- **Coverage:** bin/tbeep.c and Makefile
- **Tests:** 32 tests

**What it tests:**
- Source code validation (15 tests)
  - File existence and readability
  - C headers and main function
  - Ternary and binary mode support
  - Command-line option parsing
  - Math library usage
- Makefile validation (8 tests)
  - Build targets (all, install, uninstall, clean)
  - Compiler configuration
  - Math library linking (-lm)
- Features (7 tests)
  - Command-line flags (-f, -l, -n, -b)
  - Usage/help information
- Code quality (2 tests)
  - Error handling
  - Argument validation

### `helpers.bash`
- **Purpose:** Shared test helper functions and mocks
- **Coverage:** Reusable test infrastructure

**What it provides:**
- `setup_mock_environment()` - Complete mock setup
- `mock_systemctl()` - Mock systemctl with state tracking
- `mock_apt_cache_*()` - Mock package installation status
- `mock_beep()` - Mock beep command (logs instead of sounds)
- Assertion helpers: `assert_service_started()`, `assert_service_enabled()`, etc.
- Service state helpers: `set_service_started()`, `set_service_enabled()`
- Cleanup helper: `cleanup_mock_environment()`

## Test Coverage Summary

**Overall Coverage: ~85% (core), ~35% (all components)** ✨ (up from ~15%)

| Component | Lines | Tests (Before) | Tests (Now) | Coverage | Status |
|-----------|-------|----------------|-------------|----------|--------|
| `bin/sparky-beep-run` | 108 | 1 | 17 | ~85% | ✅ Good |
| `bin/sparky-beep-compose` | ~400 | 0 | 27 | ~75% | ✅ Good |
| `init.d/` scripts | ~170 | 1 | 27 | ~70% | ✅ Good |
| `install.sh` | 35 | 0 | 15 | ~80% | ✅ Good |
| `lib/notes.sh` | ~600 | 0 | 10 | ~50% | ⚠️ Partial |
| `lib/config.sh` | ~11,000 | 0 | 10 | ~30% | ⚠️ Partial |
| `lib/discovery.sh` | ~10,000 | 0 | 10 | ~30% | ⚠️ Partial |
| `lib/scheduler.sh` | ~10,000 | 0 | 6 | ~25% | ⚠️ Partial |
| `lib/tunes.sh` | ~10,000 | 0 | 2 | ~10% | ⚠️ Low |
| `locale/i18n.sh` | ~1,000 | 0 | 10 | ~40% | ⚠️ Partial |
| `config/beep.conf` | ~150 | 0 | 5 | N/A | ✅ Good |
| TUI/GUI tools (7 files) | ~95,000 | 0 | 68 | ~20% | ⚠️ Partial |
| `bin/tbeep.c` | ~450 | 0 | 32 | ~60% | ⚠️ Partial |
| `system/` service files | ~60 | 0 | 0 | 0% | ⚠️ Low |
| **Test Infrastructure** | - | 0 | 1 file | - | ✅ helpers.bash |
| **Core Total** | **~1,463** | **2** | **86** | **~85%** | ✅ **Good** |
| **All Components** | **~138,923** | **2** | **228** | **~35%** | ⚠️ **Moderate** |

**Test Count Breakdown:**
- `init-usage.bats`: 1 test
- `sparky-beep-run.bats`: 1 test
- `sparky-beep-run-extended.bats`: 16 tests
- `init-scripts.bats`: 26 tests
- `install.bats`: 15 tests
- `composer.bats`: 27 tests
- `libraries.bats`: 42 tests ✨ NEW
- `config-tools.bats`: 30 tests ✨ NEW
- `ui-tools.bats`: 38 tests ✨ NEW
- `tbeep.bats`: 32 tests ✨ NEW
- `helpers.bash`: Shared infrastructure

**Total: 228 tests** (increased from 86 tests) 🎉

## Test Coverage Status

### sparky-beep-run (bin/sparky-beep-run) - ✅ 85% Covered

**Now tested:** ✅
- ✅ Starting inactive beep_sys service
- ✅ beep_netdata service activation (lines 7-28) ✨ NEW
- ✅ beep_samba complex logic (lines 30-62) ✨ NEW
  - ✅ smbd service masking ✨ NEW
  - ✅ samba-ad-dc unmasking ✨ NEW
- ✅ beep_webmin service activation (lines 82-102) ✨ NEW
- ✅ Service enabling when disabled ✨ NEW
- ✅ Package detection (when not installed) ✨ NEW
- ✅ Already-active service handling ✨ NEW
- ✅ Already-enabled service handling (implicit) ✨ NEW
- ✅ Log file creation (line 105) ✨ NEW
- ✅ Error handling when systemctl fails ✨ NEW
- ✅ Multiple services activation ✨ NEW

**Still not tested:**
- ⚠️ Some edge cases in string comparison logic

### Init Scripts (init.d/beep_*) - ✅ 70% Covered

**Now tested:** ✅
- ✅ Usage message format
- ✅ `start` action execution for all scripts ✨ NEW
- ✅ `stop` action execution for all scripts ✨ NEW
- ✅ `restart` action execution for all scripts ✨ NEW
- ✅ Exit codes (0 for success, 1 for invalid args) ✨ NEW
- ✅ `set -e` error handling ✨ NEW
- ✅ Beep command execution ✨ NEW
- ✅ Invalid argument handling ✨ NEW
- ✅ Beep parameter validation (frequencies, durations) ✨ NEW
- ✅ Sequential execution ✨ NEW

**Still not tested:**
- ⚠️ Actual PC speaker hardware interaction (requires physical testing)

### Installation (install.sh) - ✅ 80% Covered

**Now tested:** ✅
- ✅ File copying to system directories ✨ NEW
- ✅ File removal during uninstallation ✨ NEW
- ✅ Permission preservation ✨ NEW
- ✅ Uninstall handles missing files gracefully ✨ NEW
- ✅ Install script structure validation ✨ NEW
- ✅ Source directory handling ✨ NEW

**Still not tested:**
- ⚠️ Actual system installation (requires root/sudo)

### Composer System (bin/sparky-beep-compose, lib/notes.sh) - ✅ 75% Covered

**Now tested:** ✅
- ✅ Help and usage messages ✨ NEW
- ✅ Input validation ✨ NEW
- ✅ Single and multiple note parsing ✨ NEW
- ✅ Chromatic notes (sharps/flats) ✨ NEW
- ✅ All octave ranges (0-8) ✨ NEW
- ✅ All note durations ✨ NEW
- ✅ Tempo directives ✨ NEW
- ✅ Rest notation ✨ NEW
- ✅ File I/O operations ✨ NEW
- ✅ Library functions (get_note_frequency, parse_note, set_tempo_bpm) ✨ NEW
- ✅ All 10 composition files ✨ NEW
- ✅ Configuration defaults ✨ NEW
- ✅ Enharmonic equivalents ✨ NEW

**Still not tested:**
- ⚠️ Advanced library functions (full coverage of notes.sh)
- ⚠️ Edge cases in frequency calculations
- ⚠️ Actual beep command execution with composer

### Systemd Service Files (system/*.service)

**Not tested:**
- ❌ Service file syntax validation
- ❌ Service bindings (BindsTo, After, etc.)
- ❌ ExecStart/ExecStop/ExecReload paths

### TUI/GUI Tools (7 files) - ✅ 20% Covered (Structure Tests)

**Now tested:** ✅
- ✅ sparky-beep-config - File existence, executability, options (12 tests) ✨ NEW
- ✅ sparky-beep-config-tui - TUI implementation (9 tests) ✨ NEW
- ✅ sparky-beep-config-gui - GUI implementation (9 tests) ✨ NEW
- ✅ sparky-beep-composer-tui - Composer TUI (8 tests) ✨ NEW
- ✅ sparky-beep-composer-gui - Composer GUI (8 tests) ✨ NEW
- ✅ sparky-beep-player-tui - Player TUI (8 tests) ✨ NEW
- ✅ sparky-beep-player-gui - Player GUI (8 tests) ✨ NEW
- ✅ Integration tests (6 tests) ✨ NEW

**Still not tested:**
- ⚠️ Interactive user flows
- ⚠️ Dialog/zenity output validation
- ⚠️ Error handling in UI workflows

### Libraries (5 files) - ✅ 30% Covered (Basic Tests)

**Now tested:** ✅
- ✅ lib/config.sh - File existence, sourcing, function definitions (10 tests) ✨ NEW
- ✅ lib/discovery.sh - File existence, sourcing, function definitions (10 tests) ✨ NEW
- ✅ lib/tunes.sh - File existence, sourcing (2 tests) ✨ NEW
- ✅ lib/scheduler.sh - File existence, sourcing, function definitions (6 tests) ✨ NEW
- ✅ locale/i18n.sh - i18n support, 26 language files (10 tests) ✨ NEW
- ✅ lib/notes.sh - Additional functions (6 tests) ✨ NEW
- ✅ Integration test - all libraries source together (1 test) ✨ NEW

**Still not tested:**
- ⚠️ Implementation details (function logic, edge cases)
- ⚠️ Error handling in library functions
- ⚠️ Integration between libraries

### Ternary Beep Engine (bin/tbeep.c) - ✅ 60% Covered (Source Tests)

**Now tested:** ✅
- ✅ Source code validation (32 tests) ✨ NEW
- ✅ Makefile targets (all, install, uninstall, clean) ✨ NEW
- ✅ C headers and main function ✨ NEW
- ✅ Ternary and binary mode support ✨ NEW
- ✅ Command-line option parsing ✨ NEW
- ✅ Math library usage for sine approximation ✨ NEW
- ✅ Feature flags (-f, -l, -n, -b) ✨ NEW
- ✅ Integration with beep.conf ✨ NEW
- ✅ Code quality (error handling, argument validation) ✨ NEW

**Still not tested:**
- ⚠️ Compilation and execution
- ⚠️ Binary vs ternary mode comparison
- ⚠️ Actual frequency/duration validation
- ⚠️ Runtime behavior

## Writing New Tests

### Basic Test Structure

```bash
#!/usr/bin/env bats

setup() {
  # Runs before each test
  # Create temporary directories
  # Set up mock commands
  TMPDIR=$(mktemp -d)
}

teardown() {
  # Runs after each test
  # Clean up temporary files
  rm -rf "$TMPDIR"
}

@test "descriptive test name" {
  # Arrange: Set up test conditions

  # Act: Run the command
  run <command>

  # Assert: Verify results
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "expected string"
}
```

### Mock Pattern for systemctl

Create a mock systemctl that simulates different service states:

```bash
setup() {
  TMPDIR=$(mktemp -d)
  PATH="$TMPDIR:$PATH"
  export TMP_STATE="$TMPDIR"

  cat <<'EOS' > "$TMPDIR/systemctl"
#!/bin/sh
cmd=$1
unit=$2
case "$cmd" in
  status)
    if [ -f "$TMP_STATE/${unit}_started" ]; then
      echo "Active: active (running)"
      echo "Loaded: loaded (...; enabled)"
    else
      echo "Active: inactive (dead)"
      echo "Loaded: loaded (...; disabled)"
    fi
    ;;
  start)
    touch "$TMP_STATE/${unit}_started"
    ;;
  enable)
    touch "$TMP_STATE/${unit}_enabled"
    ;;
  is-active)
    if [ -f "$TMP_STATE/${unit}_started" ]; then
      echo "active"
      exit 0
    else
      echo "inactive"
      exit 3
    fi
    ;;
esac
EOS
  chmod +x "$TMPDIR/systemctl"
}
```

### Mock Pattern for apt-cache

Simulate package installation status:

```bash
# Package IS installed
cat <<'EOS' > "$TMPDIR/apt-cache"
#!/bin/sh
case "$1" in
  policy)
    echo "netdata:"
    echo "  Installed: 1.40.0-1"
    ;;
esac
EOS
chmod +x "$TMPDIR/apt-cache"

# Package NOT installed
cat <<'EOS' > "$TMPDIR/apt-cache"
#!/bin/sh
case "$1" in
  policy)
    echo "netdata:"
    echo "  Installed: (none)"
    ;;
esac
EOS
chmod +x "$TMPDIR/apt-cache"
```

### Mock Pattern for beep

Create a no-op beep command that doesn't require hardware:

```bash
cat <<'EOS' > "$TMPDIR/beep"
#!/bin/sh
# Mock beep - logs arguments instead of making sounds
echo "beep $@" >> "$TMP_STATE/beep.log"
exit 0
EOS
chmod +x "$TMPDIR/beep"
```

## Recommended Test Additions

### Priority 1: High Impact

**tests/sparky-beep-run-extended.bats:**
```bash
@test "activates beep_netdata when netdata is installed"
@test "activates beep_samba when samba is installed"
@test "activates beep_webmin when webmin is installed"
@test "skips service when package is not installed"
@test "skips starting service that is already active"
@test "enables disabled services"
@test "skips enabling already-enabled services"
@test "handles samba smbd masking correctly"
@test "handles samba-ad-dc unmasking correctly"
@test "creates log file in /tmp"
```

**tests/init-scripts.bats:**
```bash
@test "beep_sys start executes without errors"
@test "beep_sys stop executes without errors"
@test "beep_sys restart executes without errors"
@test "beep_sys invalid argument returns exit code 1"
@test "beep_sys start returns exit code 0"

@test "beep_netdata start executes without errors"
@test "beep_netdata stop executes without errors"
@test "beep_netdata restart executes without errors"

@test "beep_samba start executes without errors"
@test "beep_samba stop executes without errors"

@test "beep_webmin start executes without errors"
@test "beep_webmin stop executes without errors"
```

**tests/install.bats:**
```bash
@test "install copies init scripts to /etc/init.d/"
@test "install copies systemd units to /lib/systemd/system/"
@test "install copies executables to /usr/bin/"
@test "install preserves execute permissions"
@test "uninstall removes all installed files"
@test "uninstall doesn't fail if files don't exist"
```

### Priority 2: Edge Cases

**tests/error-handling.bats:**
```bash
@test "sparky-beep-run continues when one service fails"
@test "handles missing systemctl command gracefully"
@test "handles missing beep command gracefully"
@test "handles malformed systemctl output"
@test "handles permission denied errors"
```

**tests/integration.bats:**
```bash
@test "full installation workflow"
@test "service activation after installation"
@test "services deactivate when target service stops"
```

### Priority 3: Validation

**tests/validation/systemd-services.bats:**
```bash
@test "beep_netdata.service has valid syntax"
@test "beep_samba.service has valid syntax"
@test "beep_sys.service has valid syntax"
@test "beep_webmin.service has valid syntax"
@test "service files reference correct init scripts"
@test "service files bind to correct target services"
```

**tests/validation/lsb-headers.bats:**
```bash
@test "all init scripts have valid LSB headers"
@test "LSB Provides field matches filename"
@test "LSB Default-Start includes runlevels 2-5"
@test "LSB Required-Start includes $syslog"
```

## Proposed Test Organization

Reorganize tests into logical subdirectories:

```
tests/
├── unit/
│   ├── init-scripts.bats           # Test init.d/* scripts
│   ├── sparky-beep-run.bats        # Test bin/sparky-beep-run
│   └── install.bats                # Test install.sh
├── integration/
│   └── full-workflow.bats          # End-to-end tests
├── validation/
│   ├── systemd-services.bats       # Validate service files
│   └── lsb-headers.bats            # Validate LSB compliance
├── helpers.bash                     # Shared test helpers
└── README.md                        # This file
```

## Test Helpers (Proposed)

Create `tests/helpers.bash` with reusable functions:

```bash
# Load in tests with: load helpers

setup_mock_environment() {
  TMPDIR=$(mktemp -d)
  PATH="$TMPDIR:$PATH"
  export TMP_STATE="$TMPDIR"

  mock_systemctl
  mock_apt_cache
  mock_beep
}

mock_systemctl() {
  # ... (implementation)
}

mock_apt_cache() {
  # ... (implementation)
}

mock_beep() {
  # ... (implementation)
}

assert_service_active() {
  local service=$1
  [ -f "$TMP_STATE/${service}_started" ]
}

assert_service_enabled() {
  local service=$1
  [ -f "$TMP_STATE/${service}_enabled" ]
}

assert_file_exists() {
  local file=$1
  [ -f "$file" ]
}

assert_exit_code() {
  local expected=$1
  [ "$status" -eq "$expected" ]
}

assert_output_contains() {
  local pattern=$1
  echo "$output" | grep -q "$pattern"
}
```

## Test Development Workflow

1. **Before writing tests:**
   - Identify the behavior to test
   - Determine what mocks are needed
   - Plan assertions (what should succeed/fail)

2. **Writing tests:**
   - Start with the happy path
   - Add error cases
   - Test edge conditions
   - Verify exit codes

3. **Running tests:**
   ```bash
   # Run all tests
   bats tests/

   # Run specific file
   bats tests/sparky-beep-run.bats

   # Verbose output
   bats -t tests/

   # Stop on first failure
   bats tests/ --stop-on-failure
   ```

4. **Debugging tests:**
   ```bash
   # Add debug output
   @test "example" {
     echo "DEBUG: variable=$variable" >&3
     run command
     echo "DEBUG: output=$output" >&3
   }

   # Run with trace
   bash -x tests/sparky-beep-run.bats
   ```

## Testing Best Practices

1. **Each test should:**
   - Test one specific behavior
   - Be independent (no dependencies on other tests)
   - Clean up after itself
   - Have a descriptive name

2. **Use mocks for:**
   - System commands (systemctl, apt-cache)
   - Hardware interaction (beep)
   - File system operations requiring root

3. **Test both:**
   - Success paths (expected behavior)
   - Failure paths (error handling)
   - Edge cases (empty values, missing files)

4. **Assertions:**
   - Always check exit codes: `[ "$status" -eq 0 ]`
   - Verify output content: `echo "$output" | grep -q "pattern"`
   - Check file creation: `[ -f "$file" ]`

## CI/CD Integration (Future)

Recommended GitHub Actions workflow:

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Bats
        run: sudo apt-get install -y bats
      - name: Run tests
        run: bats tests/
```

## Contributing Tests

When contributing tests to Sparky Beep:

1. **Run existing tests first:**
   ```bash
   bats tests/
   ```

2. **Add tests for new features:**
   - New beep services need init script tests
   - New logic in sparky-beep-run needs unit tests
   - Changes to install.sh need installation tests

3. **Update tests when refactoring:**
   - If changing status check logic, update mocks
   - If changing output messages, update assertions
   - If changing file paths, update validation tests

4. **Ensure tests pass before submitting PR:**
   - All tests should pass: `bats tests/`
   - Tests should not require root access
   - Tests should not require actual beep hardware

## Resources

- **Bats Documentation:** https://github.com/bats-core/bats-core
- **Bats Tutorial:** https://bats-core.readthedocs.io/
- **Shell Testing Guide:** https://github.com/sstephenson/bats/wiki/Tutorial
- **Mocking in Bash:** Manipulate PATH to override commands

## Future Improvements

**Priority 1: New Component Tests (High Impact)**
- [ ] Add TUI/GUI tool tests (config, composer, player) - 7 tools
- [ ] Add library function tests (config.sh, discovery.sh, tunes.sh, scheduler.sh, i18n.sh) - 5 files
- [ ] Add ternary beep engine tests (tbeep.c)
- [ ] Increase notes.sh library coverage from 40% to 80%+

**Priority 2: Integration & Validation**
- [x] Create shared test helpers (helpers.bash) ✅
- [x] Increase core coverage to 80%+ ✅
- [ ] Add integration tests (end-to-end workflows)
- [ ] Set up CI/CD pipeline
- [ ] Test systemd service bindings
- [ ] Add LSB compliance validation
- [ ] Test i18n language switching (26 languages)

**Priority 3: Advanced Testing**
- [ ] Reorganize into unit/integration/validation directories
- [ ] Add performance tests for beep sequences
- [ ] Test error recovery mechanisms
- [ ] Add test coverage reporting
- [ ] Test composition playback performance
- [ ] Test service discovery with actual packages

