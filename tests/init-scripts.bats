#!/usr/bin/env bats

load helpers

setup() {
  setup_mock_environment
}

teardown() {
  cleanup_mock_environment
}

# beep_sys tests
@test "beep_sys start executes without errors" {
  run init.d/beep_sys start
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_sys stop executes without errors" {
  run init.d/beep_sys stop
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_sys restart executes without errors" {
  run init.d/beep_sys restart
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_sys invalid argument returns exit code 1" {
  run init.d/beep_sys invalid
  [ "$status" -eq 1 ]
  assert_output_contains "Use: /etc/init.d/beep_sys"
}

@test "beep_sys start returns exit code 0" {
  run init.d/beep_sys start
  [ "$status" -eq 0 ]
}

@test "beep_sys produces correct usage message" {
  run init.d/beep_sys invalid
  assert_output_contains "{start|stop|restart}"
}

# beep_netdata tests
@test "beep_netdata start executes without errors" {
  run init.d/beep_netdata start
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_netdata stop executes without errors" {
  run init.d/beep_netdata stop
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_netdata restart executes without errors" {
  run init.d/beep_netdata restart
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_netdata invalid argument returns exit code 1" {
  run init.d/beep_netdata invalid
  [ "$status" -eq 1 ]
}

@test "beep_netdata produces correct usage message" {
  run init.d/beep_netdata invalid
  assert_output_contains "Use: /etc/init.d/beep_netdata"
  assert_output_contains "{start|stop|restart}"
}

# beep_samba tests
@test "beep_samba start executes without errors" {
  run init.d/beep_samba start
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_samba stop executes without errors" {
  run init.d/beep_samba stop
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_samba restart executes without errors" {
  run init.d/beep_samba restart
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_samba invalid argument returns exit code 1" {
  run init.d/beep_samba invalid
  [ "$status" -eq 1 ]
}

@test "beep_samba produces correct usage message" {
  run init.d/beep_samba invalid
  assert_output_contains "Use: /etc/init.d/beep_samba"
  assert_output_contains "{start|stop|restart}"
}

# beep_webmin tests
@test "beep_webmin start executes without errors" {
  run init.d/beep_webmin start
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_webmin stop executes without errors" {
  run init.d/beep_webmin stop
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_webmin restart executes without errors" {
  run init.d/beep_webmin restart
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_STATE/beep.log"
}

@test "beep_webmin invalid argument returns exit code 1" {
  run init.d/beep_webmin invalid
  [ "$status" -eq 1 ]
}

@test "beep_webmin produces correct usage message" {
  run init.d/beep_webmin invalid
  assert_output_contains "Use: /etc/init.d/beep_webmin"
  assert_output_contains "{start|stop|restart}"
}

# Verify beep commands are called
@test "beep_sys start calls beep with correct parameters" {
  run init.d/beep_sys start
  [ "$status" -eq 0 ]
  # Check that beep was called with -f 600
  grep -q "beep.*-f 600" "$TMP_STATE/beep.log"
}

@test "beep_netdata start calls beep with frequency sequence" {
  run init.d/beep_netdata start
  [ "$status" -eq 0 ]
  # Check that beep was called with -f 1000 and -f 1500
  grep -q "beep.*-f 1000" "$TMP_STATE/beep.log"
}

@test "beep_samba start plays Imperial March theme" {
  run init.d/beep_samba start
  [ "$status" -eq 0 ]
  # Check for Imperial March frequencies (392 Hz is common)
  grep -q "beep.*-f 392" "$TMP_STATE/beep.log"
}

# Test that multiple beeps can be executed in sequence
@test "all init scripts can run in sequence without errors" {
  run init.d/beep_sys start
  [ "$status" -eq 0 ]

  run init.d/beep_netdata start
  [ "$status" -eq 0 ]

  run init.d/beep_samba start
  [ "$status" -eq 0 ]

  run init.d/beep_webmin start
  [ "$status" -eq 0 ]

  # Verify beep.log has entries from all scripts
  assert_file_exists "$TMP_STATE/beep.log"
  [ "$(wc -l < "$TMP_STATE/beep.log")" -ge 4 ]
}

# Test error handling (set -e behavior)
@test "beep_sys exits on command failure due to set -e" {
  # Replace beep with a failing command
  cat <<'EOS' > "$TMPDIR/beep"
#!/bin/sh
exit 1
EOS
  chmod +x "$TMPDIR/beep"

  run init.d/beep_sys start
  # Should fail because beep fails and set -e is active
  [ "$status" -ne 0 ]
}
