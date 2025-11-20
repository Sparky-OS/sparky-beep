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
bats tests/init-usage.bats
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

**Mock pattern:**
```bash
setup() {
  TMPDIR=$(mktemp -d)
  PATH="$TMPDIR:$PATH"
  export TMP_STATE="$TMPDIR"

  # Mock systemctl
  cat <<'EOS' > "$TMPDIR/systemctl"
#!/bin/sh
# Mock implementation
EOS
  chmod +x "$TMPDIR/systemctl"
}
```

## Test Coverage Summary

**Overall Coverage: ~15%**

| Component | Lines | Tests | Coverage | Status |
|-----------|-------|-------|----------|--------|
| `bin/sparky-beep-run` | 108 | 1 | ~25% | ⚠️ Low |
| `init.d/` scripts | ~170 | 1 | ~10% | ⚠️ Low |
| `install.sh` | 35 | 0 | 0% | ❌ None |
| `system/` service files | ~60 | 0 | 0% | ❌ None |
| **Total** | **~373** | **2** | **~15%** | ⚠️ Low |

## Critical Coverage Gaps

### sparky-beep-run (bin/sparky-beep-run)

**Currently tested:**
- ✅ Starting inactive beep_sys service

**Not tested:**
- ❌ beep_netdata service activation (lines 7-28)
- ❌ beep_samba complex logic (lines 30-62)
  - smbd service masking
  - samba-ad-dc unmasking
- ❌ beep_webmin service activation (lines 82-102)
- ❌ Service enabling when disabled
- ❌ Package detection (when not installed)
- ❌ Already-active service handling
- ❌ Already-enabled service handling
- ❌ Log file creation (line 105)
- ❌ Error handling when systemctl fails

### Init Scripts (init.d/beep_*)

**Currently tested:**
- ✅ Usage message format

**Not tested:**
- ❌ `start` action execution
- ❌ `stop` action execution
- ❌ `restart` action execution
- ❌ Exit codes (0 for success, 1 for invalid args)
- ❌ `set -e` error handling
- ❌ Beep command execution
- ❌ Invalid argument handling

### Installation (install.sh)

**Not tested:**
- ❌ File copying to system directories
- ❌ File removal during uninstallation
- ❌ Permission preservation
- ❌ Argument parsing

### Systemd Service Files (system/*.service)

**Not tested:**
- ❌ Service file syntax validation
- ❌ Service bindings (BindsTo, After, etc.)
- ❌ ExecStart/ExecStop/ExecReload paths

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

- [ ] Increase coverage to 80%+
- [ ] Add integration tests
- [ ] Set up CI/CD pipeline
- [ ] Create shared test helpers (helpers.bash)
- [ ] Reorganize into unit/integration/validation
- [ ] Add performance tests for beep sequences
- [ ] Test systemd service bindings
- [ ] Add LSB compliance validation
- [ ] Test error recovery mechanisms
- [ ] Add test coverage reporting

