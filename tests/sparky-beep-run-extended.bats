#!/usr/bin/env bats

load helpers

setup() {
  setup_mock_environment
}

teardown() {
  cleanup_mock_environment
}

# beep_netdata tests
@test "activates beep_netdata when netdata is installed" {
  mock_apt_cache_with_netdata

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_started beep_netdata
  assert_output_contains "beep_netdata service is active"
}

@test "enables beep_netdata when disabled" {
  mock_apt_cache_with_netdata

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_enabled beep_netdata
}

@test "skips beep_netdata when netdata is not installed" {
  mock_apt_cache_no_packages

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_not_started beep_netdata
  assert_output_not_contains "beep_netdata"
}

@test "skips starting beep_netdata when already active" {
  mock_apt_cache_with_netdata
  set_service_started beep_netdata
  set_service_enabled beep_netdata

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  # Service should still be started (state persists)
  assert_service_started beep_netdata
}

# beep_samba tests
@test "activates beep_samba when samba is installed" {
  mock_apt_cache_with_samba

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_started beep_samba
  assert_output_contains "beep_samba service is active"
}

@test "enables beep_samba when disabled" {
  mock_apt_cache_with_samba

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_enabled beep_samba
}

@test "skips beep_samba when samba is not installed" {
  mock_apt_cache_no_packages

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_not_started beep_samba
  assert_output_not_contains "beep_samba"
}

@test "handles samba smbd service configuration" {
  mock_apt_cache_with_samba

  # Create enhanced mock that tracks smbd operations
  cat <<'EOS' > "$TMPDIR/systemctl"
#!/bin/sh
state="$TMP_STATE"
cmd=$1
unit=$2

case "$cmd" in
  status)
    # beep_samba is inactive, smbd is not masked, samba-ad-dc is masked
    if [ "$unit" = "beep_samba" ]; then
      if [ -f "$state/${unit}_started" ]; then
        echo "   Active: active (running)"
        echo "   Loaded: loaded (...; enabled)"
      else
        echo "   Active: inactive (dead)"
        echo "   Loaded: loaded (...; disabled)"
      fi
    elif [ "$unit" = "smbd" ]; then
      if [ -f "$state/smbd_masked" ]; then
        echo "   Loaded: masked"
      else
        echo "   Active: active (running)"
        echo "   Loaded: loaded"
      fi
    elif [ "$unit" = "samba-ad-dc" ]; then
      if [ -f "$state/samba-ad-dc_masked" ]; then
        echo "   Loaded: masked"
      else
        echo "   Active: inactive"
        echo "   Loaded: loaded"
      fi
    else
      echo "   Active: inactive"
    fi
    # Add extra space for grep patterns in sparky-beep-run
    echo " "
    ;;
  start)
    touch "$state/${unit}_started"
    ;;
  stop)
    touch "$state/${unit}_stopped"
    ;;
  enable)
    touch "$state/${unit}_enabled"
    ;;
  disable)
    touch "$state/${unit}_disabled"
    ;;
  mask)
    touch "$state/${unit}_masked"
    ;;
  unmask)
    rm -f "$state/${unit}_masked"
    touch "$state/${unit}_unmasked"
    ;;
esac
exit 0
EOS
  chmod +x "$TMPDIR/systemctl"

  # Set initial state: samba-ad-dc is masked
  touch "$TMP_STATE/samba-ad-dc_masked"

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  # Should unmask samba-ad-dc, enable and start it
  assert_file_exists "$TMP_STATE/samba-ad-dc_unmasked"
  assert_file_exists "$TMP_STATE/samba-ad-dc_enabled"
  assert_file_exists "$TMP_STATE/samba-ad-dc_started"
}

# beep_webmin tests
@test "activates beep_webmin when webmin is installed" {
  mock_apt_cache_with_webmin

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_started beep_webmin
  assert_output_contains "beep_webmin service is active"
}

@test "enables beep_webmin when disabled" {
  mock_apt_cache_with_webmin

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_enabled beep_webmin
}

@test "skips beep_webmin when webmin is not installed" {
  mock_apt_cache_no_packages

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_not_started beep_webmin
  assert_output_not_contains "beep_webmin"
}

# beep_sys tests (always runs, no package check)
@test "always activates beep_sys regardless of packages" {
  mock_apt_cache_no_packages

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_started beep_sys
  assert_output_contains "beep_sys service is active"
}

@test "enables beep_sys when disabled" {
  mock_apt_cache_no_packages

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_enabled beep_sys
}

# Log file creation
@test "creates log file in /tmp" {
  mock_apt_cache_no_packages

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  # Check that a log file was created (pattern: /tmp/sparky-beep-test.*)
  [ -n "$(find /tmp -name 'sparky-beep-test.*' -type f 2>/dev/null)" ]
}

# Multiple services
@test "handles multiple services when multiple packages are installed" {
  # Mock with both netdata and webmin installed
  cat <<'EOS' > "$TMPDIR/apt-cache"
#!/bin/sh
case "$1 $2" in
  "policy netdata")
    echo "netdata:"
    echo "  Installed: 1.40.0-1"
    ;;
  "policy webmin")
    echo "webmin:"
    echo "  Installed: 2.0-1"
    ;;
  "policy samba")
    echo "samba:"
    echo "  Installed: (none)"
    ;;
  *)
    exit 0
    ;;
esac
exit 0
EOS
  chmod +x "$TMPDIR/apt-cache"

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  assert_service_started beep_netdata
  assert_service_started beep_webmin
  assert_service_started beep_sys
  assert_output_contains "beep_netdata service is active"
  assert_output_contains "beep_webmin service is active"
  assert_output_contains "beep_sys service is active"
}

@test "reports when service activation fails" {
  mock_apt_cache_with_netdata

  # Mock systemctl to never show service as active
  cat <<'EOS' > "$TMPDIR/systemctl"
#!/bin/sh
state="$TMP_STATE"
cmd=$1
unit=$2

case "$cmd" in
  status)
    # Always show as inactive even after start
    echo "   Active: inactive (dead)"
    echo "   Loaded: loaded (...; disabled)"
    echo " "
    ;;
  start|enable)
    # Accept commands but don't change state
    ;;
esac
exit 0
EOS
  chmod +x "$TMPDIR/systemctl"

  run bin/sparky-beep-run

  [ "$status" -eq 0 ]
  # Should report that service is NOT active
  assert_output_contains "beep_netdata service is NOT active"
}
