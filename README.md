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

The project currently has **~15% test coverage** across the codebase:

**Existing Tests:**
- `tests/init-usage.bats` - Validates usage messages match script names
- `tests/sparky-beep-run.bats` - Tests basic service activation for beep_sys

**Test Coverage by Component:**

| Component | Lines | Tests | Coverage |
|-----------|-------|-------|----------|
| sparky-beep-run | 108 | 1 | ~25% |
| init.d scripts (5 files) | ~170 | 1 | ~10% |
| install.sh | 35 | 0 | 0% |
| systemd services (4 files) | ~60 | 0 | 0% |
| **Total** | **~373** | **2** | **~15%** |

### Test Coverage Gaps

**Critical gaps in sparky-beep-run (bin/sparky-beep-run):**
- ❌ beep_netdata service activation (lines 7-28)
- ❌ beep_samba service activation with complex logic (lines 30-62)
  - smbd masking logic
  - samba-ad-dc unmasking logic
- ❌ beep_webmin service activation (lines 82-102)
- ❌ Service enabling logic (all services)
- ❌ Package detection when package is NOT installed
- ❌ Service already active (should skip activation)
- ❌ Service already enabled (should skip enabling)
- ❌ Log file creation (line 105)

**Critical gaps in init scripts (init.d/beep_*):**
- ❌ `start` action execution
- ❌ `stop` action execution
- ❌ `restart` action execution
- ❌ Exit codes (0 for success, 1 for invalid args)
- ❌ `set -e` error handling behavior
- ❌ Beep command validation

**Critical gaps in install.sh:**
- ❌ Installation (copying files to /etc, /lib, /usr)
- ❌ Uninstallation (file removal)
- ❌ File permissions preservation

**Critical gaps in systemd service files:**
- ❌ Service file syntax validation
- ❌ Service dependency bindings (BindsTo, After, etc.)
- ❌ ExecStart/ExecStop/ExecReload commands

### Recommended Test Improvements

**Priority 1: High Impact Tests**

1. **Complete sparky-beep-run coverage:**
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
   ```

2. **Init script execution tests:**
   ```bash
   @test "beep_sys start executes without errors"
   @test "beep_sys stop executes without errors"
   @test "beep_sys restart executes without errors"
   @test "beep_sys invalid argument returns exit code 1"
   # Repeat for all beep_* scripts
   ```

3. **Install script tests:**
   ```bash
   @test "install copies all files to correct locations"
   @test "install preserves execute permissions"
   @test "uninstall removes all installed files"
   @test "uninstall doesn't fail if files don't exist"
   ```

**Priority 2: Edge Cases and Error Handling**

4. **Error condition tests:**
   ```bash
   @test "sparky-beep-run continues when one service fails"
   @test "handles missing systemctl command"
   @test "handles missing beep command"
   @test "handles malformed systemctl output"
   ```

5. **Integration tests:**
   ```bash
   @test "full installation workflow"
   @test "service activation after installation"
   @test "systemd service bindings work correctly"
   ```

**Priority 3: Validation Tests**

6. **Systemd service file validation:**
   ```bash
   @test "beep_netdata.service has valid syntax"
   @test "service files reference correct init scripts"
   ```

7. **LSB header validation:**
   ```bash
   @test "all init scripts have valid LSB headers"
   @test "LSB Provides field matches filename"
   ```

### Testing Infrastructure Improvements

**Recommended test organization:**
```
tests/
├── unit/
│   ├── init-scripts.bats
│   ├── sparky-beep-run.bats
│   └── install.bats
├── integration/
│   └── full-workflow.bats
├── validation/
│   ├── systemd-services.bats
│   └── lsb-headers.bats
└── helpers.bash
```

**Test helpers to create:**
- `setup_mock_environment()` - Reusable mock setup for systemctl, apt-cache
- `assert_service_active()` - Verify service state
- `assert_file_exists()` - Verify installation
- Enhanced mocks to support more systemctl states and scenarios

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
