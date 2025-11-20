#!/bin/bash
# Test helpers for Sparky Beep tests
# Load in tests with: load helpers

# Setup mock environment with systemctl, apt-cache, and beep
setup_mock_environment() {
  TMPDIR=$(mktemp -d)
  PATH="$TMPDIR:$PATH"
  export TMP_STATE="$TMPDIR"

  mock_systemctl
  mock_apt_cache_no_packages
  mock_beep
}

# Mock systemctl with state tracking
mock_systemctl() {
  cat <<'EOS' > "$TMPDIR/systemctl"
#!/bin/sh
state="$TMP_STATE"
cmd=$1
unit=$2

case "$cmd" in
  status)
    if [ -f "$state/${unit}_started" ]; then
      echo "● $unit"
      echo "   Loaded: loaded (/lib/systemd/system/$unit; enabled)"
      echo "   Active: active (running) since $(date)"
    else
      echo "● $unit"
      if [ -f "$state/${unit}_enabled" ]; then
        echo "   Loaded: loaded (/lib/systemd/system/$unit; enabled)"
      else
        echo "   Loaded: loaded (/lib/systemd/system/$unit; disabled)"
      fi
      echo "   Active: inactive (dead)"
    fi
    ;;
  start)
    touch "$state/${unit}_started"
    ;;
  stop)
    rm -f "$state/${unit}_started"
    ;;
  enable)
    touch "$state/${unit}_enabled"
    ;;
  disable)
    rm -f "$state/${unit}_enabled"
    ;;
  mask)
    touch "$state/${unit}_masked"
    ;;
  unmask)
    rm -f "$state/${unit}_masked"
    ;;
  is-active)
    if [ -f "$state/${unit}_started" ]; then
      echo "active"
      exit 0
    else
      echo "inactive"
      exit 3
    fi
    ;;
  is-enabled)
    if [ -f "$state/${unit}_enabled" ]; then
      echo "enabled"
      exit 0
    else
      echo "disabled"
      exit 1
    fi
    ;;
  *)
    exit 0
    ;;
esac
exit 0
EOS
  chmod +x "$TMPDIR/systemctl"
}

# Mock apt-cache with no packages installed
mock_apt_cache_no_packages() {
  cat <<'EOS' > "$TMPDIR/apt-cache"
#!/bin/sh
case "$1 $2" in
  "policy netdata"|"policy samba"|"policy webmin")
    pkg=$(echo "$2")
    echo "$pkg:"
    echo "  Installed: (none)"
    ;;
  *)
    exit 0
    ;;
esac
exit 0
EOS
  chmod +x "$TMPDIR/apt-cache"
}

# Mock apt-cache with netdata installed
mock_apt_cache_with_netdata() {
  cat <<'EOS' > "$TMPDIR/apt-cache"
#!/bin/sh
case "$1 $2" in
  "policy netdata")
    echo "netdata:"
    echo "  Installed: 1.40.0-1"
    ;;
  "policy samba"|"policy webmin")
    pkg=$(echo "$2")
    echo "$pkg:"
    echo "  Installed: (none)"
    ;;
  *)
    exit 0
    ;;
esac
exit 0
EOS
  chmod +x "$TMPDIR/apt-cache"
}

# Mock apt-cache with samba installed
mock_apt_cache_with_samba() {
  cat <<'EOS' > "$TMPDIR/apt-cache"
#!/bin/sh
case "$1 $2" in
  "policy samba")
    echo "samba:"
    echo "  Installed: 4.15.0-1"
    ;;
  "policy netdata"|"policy webmin")
    pkg=$(echo "$2")
    echo "$pkg:"
    echo "  Installed: (none)"
    ;;
  *)
    exit 0
    ;;
esac
exit 0
EOS
  chmod +x "$TMPDIR/apt-cache"
}

# Mock apt-cache with webmin installed
mock_apt_cache_with_webmin() {
  cat <<'EOS' > "$TMPDIR/apt-cache"
#!/bin/sh
case "$1 $2" in
  "policy webmin")
    echo "webmin:"
    echo "  Installed: 2.0-1"
    ;;
  "policy netdata"|"policy samba")
    pkg=$(echo "$2")
    echo "$pkg:"
    echo "  Installed: (none)"
    ;;
  *)
    exit 0
    ;;
esac
exit 0
EOS
  chmod +x "$TMPDIR/apt-cache"
}

# Mock beep command (no-op, logs to file)
mock_beep() {
  cat <<'EOS' > "$TMPDIR/beep"
#!/bin/sh
# Mock beep - logs arguments instead of making sounds
echo "beep $@" >> "$TMP_STATE/beep.log"
exit 0
EOS
  chmod +x "$TMPDIR/beep"
}

# Assertion: Check if service was started
assert_service_started() {
  local service=$1
  [ -f "$TMP_STATE/${service}_started" ]
}

# Assertion: Check if service was enabled
assert_service_enabled() {
  local service=$1
  [ -f "$TMP_STATE/${service}_enabled" ]
}

# Assertion: Check if service was masked
assert_service_masked() {
  local service=$1
  [ -f "$TMP_STATE/${service}_masked" ]
}

# Assertion: Check if service was not started
assert_service_not_started() {
  local service=$1
  [ ! -f "$TMP_STATE/${service}_started" ]
}

# Assertion: Check if service was not enabled
assert_service_not_enabled() {
  local service=$1
  [ ! -f "$TMP_STATE/${service}_enabled" ]
}

# Assertion: Check file exists
assert_file_exists() {
  local file=$1
  [ -f "$file" ]
}

# Assertion: Check exit code
assert_exit_code() {
  local expected=$1
  [ "$status" -eq "$expected" ]
}

# Assertion: Check output contains pattern
assert_output_contains() {
  local pattern=$1
  echo "$output" | grep -q "$pattern"
}

# Assertion: Check output does not contain pattern
assert_output_not_contains() {
  local pattern=$1
  ! echo "$output" | grep -q "$pattern"
}

# Set service as already started
set_service_started() {
  local service=$1
  touch "$TMP_STATE/${service}_started"
}

# Set service as already enabled
set_service_enabled() {
  local service=$1
  touch "$TMP_STATE/${service}_enabled"
}

# Cleanup mock environment
cleanup_mock_environment() {
  if [ -n "$TMPDIR" ] && [ -d "$TMPDIR" ]; then
    rm -rf "$TMPDIR"
  fi
}
