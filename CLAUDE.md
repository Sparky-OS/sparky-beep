# CLAUDE.md - AI Assistant Guide for Sparky Beep

This document provides comprehensive guidance for AI assistants working on the Sparky Beep codebase.

## Repository Overview

**Sparky Beep** is a Linux system service that provides audible notifications (beeps) when selected system services start, stop, or restart. It's designed for Sparky Linux Server Edition and uses the PC speaker to create distinctive sound patterns for different service state changes.

**Key Facts:**
- Language: Bash/POSIX Shell
- Init System: Hybrid (SysV init scripts + systemd service bindings)
- License: GNU GPL v3
- Test Framework: Bats (Bash Automated Testing System)
- Total Lines of Code: ~378 lines
- Active Maintenance: Yes (accepting contributions via pull requests)

## Directory Structure

```
/home/user/sparky-beep/
├── README.md              # Main project documentation
├── CHANGELOG              # Version history and release notes
├── LICENSE                # GNU General Public License v3
├── copyright              # Debian-style copyright file
├── install.sh             # Installation/uninstallation script (executable)
├── bin/
│   └── sparky-beep-run    # Service startup and status checker (3.5 KB)
├── init.d/                # SysV init scripts (5 scripts)
│   ├── sparky-beep        # Main entry point wrapper (44 bytes)
│   ├── beep_sys           # System/SSH state notifications (518 bytes)
│   ├── beep_samba         # Samba service notifications (3.0 KB, plays Imperial March)
│   ├── beep_netdata       # NetData service notifications (718 bytes)
│   └── beep_webmin        # Webmin service notifications (796 bytes)
├── system/                # Systemd unit files (4 service files)
│   ├── beep_sys.service      # Binds to ssh.service
│   ├── beep_samba.service    # Binds to samba-ad-dc.service
│   ├── beep_netdata.service  # Binds to netdata.service
│   └── beep_webmin.service   # Binds to webmin.service
└── tests/                 # Test suite
    ├── README.md          # Testing documentation
    ├── init-usage.bats    # Init script validation tests
    └── sparky-beep-run.bats # Main script functionality tests
```

## Key Components and Architecture

### 1. Main Service Controller: `bin/sparky-beep-run`

**Location:** `/home/user/sparky-beep/bin/sparky-beep-run`

**Purpose:** Orchestrates beep service startup and monitors service status

**Key Responsibilities:**
- Detects which optional packages are installed (netdata, samba, webmin)
- Checks systemd status of corresponding beep services
- Auto-starts inactive beep services using `systemctl start`
- Auto-enables disabled services using `systemctl enable`
- Provides console feedback on service activation

**Important Code Pattern:**
```bash
# Package detection
PACKNETDATA=`apt-cache policy netdata | head -n2 | tail -n1 | grep [0-9]`

# Only enable if package is installed
if [ "$PACKNETDATA" != "" ]; then
    # Check if service is inactive
    CHECKBEEPNETDATA=`systemctl status beep_netdata | grep inactive`
    if [ -n "$CHECKBEEPNETDATA" ]; then
        systemctl start beep_netdata
    fi
fi
```

**Status Check Pattern:**
- Uses `systemctl status <service> | grep inactive` to detect inactive state
- Uses `systemctl status <service> | grep "Active: active"` to verify activation
- Uses `systemctl status <service> | grep disabled` to detect disabled state

### 2. Init Scripts: `init.d/beep_*`

**Purpose:** Execute actual beep commands when services change state

**All init scripts follow this structure:**
```bash
#!/bin/sh -e

### BEGIN INIT INFO
# Provides: <service-name>
# Required-Start: $syslog
# Required-Stop: $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: <description>
### END INIT INFO

set -e

case "$1" in
  start)
    <beep command sequence>
    ;;
  stop)
    <beep command sequence>
    ;;
  restart)
    <beep command sequence>
    ;;
  *)
    echo "Use: /etc/init.d/<script-name> {start|stop|restart}"
    exit 1
    ;;
esac

exit 0
```

**Beep Command Flags Reference:**
| Flag | Purpose | Example |
|------|---------|---------|
| `-f <freq>` | Frequency in Hz | `-f 1000` |
| `-l <len>` | Length in milliseconds | `-l 350` |
| `-r <reps>` | Repeat count | `-r 2` |
| `-d <delay>` | Delay between repeats (ms) | `-d 100` |
| `-D <delay>` | Delay after beep (ms) | `-D 100` |
| `-n` | Next beep (separator) | `-n` |

**Special Features:**
- `beep_samba`: Plays Star Wars "Imperial March" theme
- `beep_webmin`: Includes frequency sweep effect and Star Trek style beeps

### 3. Systemd Service Files: `system/*.service`

**Purpose:** Bind beep scripts to actual system services using systemd

**Standard Structure:**
```ini
[Unit]
Description=<service description>
After=<target-service>
BindsTo=<target-service>          # Creates hard dependency
ReloadPropagatedFrom=<service>

[Service]
Type=simple
RemainAfterExit=yes               # Keeps service active after execution
ExecStart=/etc/init.d/<script> start
ExecStop=/etc/init.d/<script> stop
ExecReload=/etc/init.d/<script> restart

[Install]
WantedBy=<target-service>
```

**Key Systemd Directives:**
- `BindsTo=`: Creates tight coupling (beep service stops when target stops)
- `ReloadPropagatedFrom=`: Reload events cascade to beep services
- `RemainAfterExit=yes`: Critical for beep service persistence

**Service Bindings:**
| Beep Service | Target Service | Purpose |
|--------------|----------------|---------|
| beep_sys.service | ssh.service | SSH/system state changes |
| beep_samba.service | samba-ad-dc.service | Samba AD DC state changes |
| beep_netdata.service | netdata.service | NetData monitoring state changes |
| beep_webmin.service | webmin | Webmin admin panel state changes |

### 4. Installation Script: `install.sh`

**Location:** `/home/user/sparky-beep/install.sh`

**Installation (default):**
```bash
sudo ./install.sh
```
- Copies init scripts to `/etc/init.d/`
- Copies systemd units to `/lib/systemd/system/`
- Copies executables to `/usr/bin/`

**Uninstallation:**
```bash
sudo ./install.sh uninstall
```
- Removes all installed files from system directories

## Development Workflow

### Git Workflow

**Current Branch:** `claude/claude-md-mi6pd7w4mxs717yp-01VtLSCKSWpEtnZ1eoGV8WYu` (feature branch)

**Branch Naming Convention:**
- Pattern: `codex/<descriptive-name>` or `claude/<session-id>`
- Use lowercase with hyphens
- Examples: `codex/fix-typo-in-sparky-beep-run-script`

**Commit Message Format:**
```
<type>: <message>
<type>(<scope>): <message>
```

**Common Types:**
- `docs:` - Documentation updates
- `fix:` - Bug fixes
- `feat:` - New features
- `test:` - Test additions or modifications
- `refactor:` - Code refactoring without behavior changes

**Examples from History:**
```
c5f58e0 docs: expand README with repo overview
64fb974 Fix inactive grep typos in run script
98e53a9 Fix usage message for beep_webmin
```

### Pull Request Workflow

1. Create feature branch from master
2. Make changes with proper commit messages
3. Push to remote: `git push -u origin <branch-name>`
4. Create pull request (via web interface or ask user to create)
5. Merge to master after review
6. Update CHANGELOG manually for releases

### Release Management

- Versioning: `0.x.y` format (currently at 0.1.11)
- CHANGELOG is manually maintained
- Each version includes date and bullet-pointed changes
- No automated release workflow

## Code Conventions and Patterns

### Shell Script Standards

**Shebang Patterns:**
```bash
#!/bin/bash         # Main sparky-beep-run script (modern features)
#!/bin/sh           # Init scripts (POSIX portability)
#!/bin/sh -e        # Init scripts with strict error handling
#!/usr/bin/env bats # Test files
```

**Error Handling:**
- Init scripts use `set -e` to exit on first error
- Main run script continues execution even if individual services fail
- No explicit error trapping with `trap` commands

**Variable Naming:**
- UPPERCASE for environment variables and command outputs
- Descriptive names: `CHECKBEEPNETDATA`, `PACKNETDATA`, `LOADBEEPNETDATA`
- Local variables should use lowercase (if adding new code)

**Command Substitution:**
- Current codebase uses backticks: `` variable=`command` ``
- When adding new code, prefer modern syntax: `variable=$(command)`
- Keep consistency within the same file

### Status Check Pattern (Critical)

**Standard pattern used throughout `sparky-beep-run`:**
```bash
# Check if service is inactive
CHECK<SERVICE>=`systemctl status <service> | grep inactive`
if [ -n "$CHECK<SERVICE>" ]; then
    systemctl start <service>

    # Verify activation
    CHECK<SERVICE>0=`systemctl status <service> | grep "Active: active"`
    if [ -n "$CHECK<SERVICE>0" ]; then
        echo "<service> is active..."
    else
        echo "<service> is NOT active..."
    fi
fi

# Check if disabled and enable
LOAD<SERVICE>=`systemctl status <service> | grep disabled;`
if [ "$LOAD<SERVICE>" != " " ]; then
    systemctl enable <service>
fi
```

**Important Notes:**
- This pattern is fragile and relies on systemctl output format
- Uses `-n` test for non-empty strings
- When modifying, maintain consistency with existing checks
- Consider using `systemctl is-active <service>` for more robust checks (returns just "active" or "inactive")

### Init Script Conventions

**LSB Header (Required):**
```bash
### BEGIN INIT INFO
# Provides: <service-name>
# Required-Start: $syslog
# Required-Stop: $syslog
# Required-Reload: $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: <description>
### END INIT INFO
```

**Case Statement (Required Structure):**
- Must support: `start`, `stop`, `restart`
- Must include usage message for invalid arguments
- Must exit with code 0 on success, 1 on invalid usage

### Code Style

**Indentation:**
- Mix of tabs and spaces exists in codebase (inconsistent)
- When editing existing files, match surrounding indentation
- For new files, prefer 4 spaces for consistency with tests

**Comments:**
- Use `# comment` with space after hash
- Update date comments when making significant changes
- Example: `# last update 2019/02/23 by pavroo`

**Line Length:**
- No strict limit, but keep beep command sequences readable
- Break long beep sequences with line continuations if needed

## Testing Guidelines

### Test Framework: Bats

**Running Tests:**
```bash
# Install bats if not present
sudo apt-get install bats

# Run all tests
bats tests/

# Run specific test file
bats tests/sparky-beep-run.bats
```

### Test Files

**1. `tests/init-usage.bats`**
- Validates usage messages match script names
- Ensures consistency across all beep_* scripts
- Quick verification test

**2. `tests/sparky-beep-run.bats`**
- Tests service startup logic
- Uses mock systemctl and apt-cache commands
- Verifies service activation flow

### Writing Tests

**Test Structure:**
```bash
setup() {
    # Create temporary environment
    # Set up mock commands
    # Initialize test state
}

@test "descriptive test name" {
    run <command>
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "expected string"
}

teardown() {
    # Clean up temporary files
}
```

**Mock Pattern (from sparky-beep-run.bats):**
```bash
# Mock systemctl
cat > "$TMP_BIN/systemctl" << 'EOF'
#!/bin/sh
case "$1" in
  status)
    if [ -f "$TMP_STATE/beep_sys_started" ]; then
      echo "Active: active"
    else
      echo "inactive"
    fi
    ;;
  start)
    touch "$TMP_STATE/beep_sys_started"
    ;;
esac
EOF
chmod +x "$TMP_BIN/systemctl"
```

### Test Coverage Expectations

When making changes:
1. Run existing tests to ensure no regressions
2. Add tests for new beep services
3. Update tests if changing status check logic
4. Verify tests pass before committing

## Common Tasks and Workflows

### Adding a New Beep Service

**1. Create init script:** `init.d/beep_<servicename>`

```bash
#!/bin/sh -e

### BEGIN INIT INFO
# Provides: beep_<servicename>
# Required-Start: $syslog
# Required-Stop: $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: Beep on <servicename> service state changes
### END INIT INFO

set -e

case "$1" in
  start)
    beep -f 1000 -l 200
    ;;
  stop)
    beep -f 500 -l 200
    ;;
  restart)
    beep -f 500 -l 100 -n -f 1000 -l 100
    ;;
  *)
    echo "Use: /etc/init.d/beep_<servicename> {start|stop|restart}"
    exit 1
    ;;
esac

exit 0
```

**2. Create systemd service:** `system/beep_<servicename>.service`

```ini
[Unit]
Description=Beep on <servicename> service state changes
After=<servicename>.service
BindsTo=<servicename>.service
ReloadPropagatedFrom=<servicename>.service

[Service]
Type=simple
RemainAfterExit=yes
ExecStart=/etc/init.d/beep_<servicename> start
ExecStop=/etc/init.d/beep_<servicename> stop
ExecReload=/etc/init.d/beep_<servicename> restart

[Install]
WantedBy=<servicename>.service
```

**3. Update `bin/sparky-beep-run`:**

Add detection and startup logic for the new service:

```bash
# Check if package installed
PACK<SERVICENAME>=`apt-cache policy <packagename> | head -n2 | tail -n1 | grep [0-9]`

if [ "$PACK<SERVICENAME>" != "" ]; then
    # Check if inactive
    CHECKBEEP<SERVICENAME>=`systemctl status beep_<servicename> | grep inactive`
    if [ -n "$CHECKBEEP<SERVICENAME>" ]; then
        systemctl start beep_<servicename>

        # Verify activation
        CHECKBEEP<SERVICENAME>0=`systemctl status beep_<servicename> | grep "Active: active"`
        if [ -n "$CHECKBEEP<SERVICENAME>0" ]; then
            echo "beep_<servicename> service is active..."
        else
            echo "beep_<servicename> service is NOT active..."
        fi
    fi

    # Enable if disabled
    LOADBEEP<SERVICENAME>=`systemctl status beep_<servicename> | grep disabled;`
    if [ "$LOADBEEP<SERVICENAME>" != " " ]; then
        systemctl enable beep_<servicename>
    fi
fi
```

**4. Update `install.sh` (if needed):**

The wildcard patterns should automatically include new files:
- `init.d/beep_*` includes new init script
- `system/beep_*.service` includes new systemd service

**5. Add tests:** `tests/init-usage.bats` should automatically cover the new script

**6. Update CHANGELOG:**

Add entry for the new service under current version.

**7. Test installation:**
```bash
sudo ./install.sh
systemctl status beep_<servicename>
```

### Modifying Beep Sequences

**Location:** `init.d/beep_<servicename>` files

**To change beep sounds:**
1. Locate the appropriate case branch (start/stop/restart)
2. Modify the beep command parameters
3. Test the sound: `beep -f 1000 -l 200` (manually)
4. Update the init script
5. Test with: `sudo /etc/init.d/beep_<servicename> start`

**Beep Design Tips:**
- Start events: Use ascending frequencies (positive feeling)
- Stop events: Use descending frequencies (completion feeling)
- Restart events: Combine stop and start patterns
- Keep sequences under 2 seconds for user experience
- Test on actual hardware (PC speaker behavior varies)

### Fixing Status Check Issues

**Common Problem:** `sparky-beep-run` not detecting service state correctly

**Debugging:**
```bash
# Check what systemctl actually outputs
systemctl status beep_netdata

# Check what grep matches
systemctl status beep_netdata | grep inactive
systemctl status beep_netdata | grep "Active: active"
systemctl status beep_netdata | grep disabled
```

**Alternative (More Robust):**
```bash
# Instead of grepping status output, use is-active
if ! systemctl is-active --quiet beep_netdata; then
    systemctl start beep_netdata
fi

# Check if enabled
if ! systemctl is-enabled --quiet beep_netdata; then
    systemctl enable beep_netdata
fi
```

### File Locations After Installation

When installed, files are copied to:
- Init scripts: `/etc/init.d/beep_*` and `/etc/init.d/sparky-beep`
- Systemd units: `/lib/systemd/system/beep_*.service`
- Executables: `/usr/bin/sparky-beep-run`

**Important:** When testing changes:
1. Make changes in repository
2. Run `sudo ./install.sh uninstall`
3. Run `sudo ./install.sh` to reinstall
4. Test with `systemctl status beep_<service>`

## Important Notes for AI Assistants

### Critical Considerations

**1. Root Permissions Required:**
- Installation requires root/sudo access
- Systemctl operations require root
- Always remind users to use sudo for installation/testing

**2. System Dependencies:**
- Code assumes systemd is present and active
- Code assumes `beep` utility is installed
- Package detection uses `apt-cache` (Debian/Ubuntu specific)

**3. Fragile Status Parsing:**
- The status check pattern using `grep` is fragile
- Systemd output format could change in future versions
- When suggesting improvements, recommend `systemctl is-active` and `systemctl is-enabled`

**4. Error Handling:**
- `sparky-beep-run` continues execution even if individual services fail
- This is intentional (graceful degradation for missing packages)
- Don't add `set -e` to the main run script

**5. Testing Limitations:**
- Tests use mocks and don't verify actual beep hardware
- Tests don't require root access
- Real testing requires installed system and service activation

### When Making Changes

**Always:**
- Run tests before committing: `bats tests/`
- Update CHANGELOG for significant changes
- Test on actual system if modifying service activation logic
- Preserve LSB headers in init scripts
- Keep existing code style consistent within files

**Never:**
- Remove `set -e` from init scripts
- Change usage message format (tests depend on it)
- Add dependencies without updating README
- Modify systemd binding structure without understanding implications
- Break backward compatibility without major version bump

### Common Pitfalls

**1. Systemd Service Activation:**
```bash
# Wrong: Starting service without checking if target is installed
systemctl start beep_netdata

# Right: Check package first
if [ "$PACKNETDATA" != "" ]; then
    systemctl start beep_netdata
fi
```

**2. Beep Command Syntax:**
```bash
# Wrong: Missing -n separator between beeps
beep -f 1000 -l 200 -f 500 -l 200

# Right: Use -n to separate distinct beeps
beep -f 1000 -l 200 -n -f 500 -l 200
```

**3. Init Script Exit Codes:**
```bash
# Wrong: No exit code
case "$1" in
  start) beep -f 1000 ;;
esac

# Right: Always exit 0 on success, 1 on error
case "$1" in
  start) beep -f 1000 ;;
  *) echo "Use: /etc/init.d/script {start|stop|restart}"; exit 1 ;;
esac
exit 0
```

**4. Variable Comparison:**
```bash
# Existing pattern (maintain consistency):
if [ -n "$VARIABLE" ]; then  # Check if non-empty

# Alternative (both work):
if [ "$VARIABLE" != "" ]; then  # Check if not empty string
```

### Useful References

**File References (for quick navigation):**
- Main controller: `bin/sparky-beep-run`
- Samba beep (largest): `init.d/beep_samba`
- System beep (simplest): `init.d/beep_sys`
- Service example: `system/beep_netdata.service`
- Main tests: `tests/sparky-beep-run.bats`
- Installation: `install.sh:1-30`

**External Documentation:**
- Beep utility: `man beep`
- Systemd unit files: `man systemd.service`
- Systemd bindings: `man systemd.unit` (BindsTo directive)
- LSB Init Scripts: Linux Standard Base specification
- Bats testing: https://github.com/bats-core/bats-core

### Debugging Commands

```bash
# Check service status
systemctl status beep_netdata
systemctl is-active beep_netdata
systemctl is-enabled beep_netdata

# Check what's installed
ls -la /etc/init.d/beep_*
ls -la /lib/systemd/system/beep_*.service
ls -la /usr/bin/sparky-beep-run

# View service logs
journalctl -u beep_netdata
journalctl -u ssh.service  # Check target service

# Test beep manually
beep -f 1000 -l 200

# Check package installation
apt-cache policy netdata
dpkg -l | grep netdata
```

## Version Information

- **Document Version:** 1.0
- **Last Updated:** 2025-11-20
- **Repository Version:** 0.1.11 (as of 2019-02-23)
- **Maintained By:** AI assistants and human contributors

---

This document is maintained to help AI assistants understand and contribute to the Sparky Beep project effectively. When in doubt, prioritize maintaining existing conventions and patterns over introducing new ones.
