#!/usr/bin/env bats
#
# One INI file at /etc/sparky-beep/beep.conf: the composer reads it through lib/config.sh,
# and a shell-format file from 0.2.0/0.2.1 is converted once. Each test failed on 0.2.1.
#

setup() {
  SRC_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  COMPOSER="$SRC_ROOT/bin/sparky-beep-compose"
  WORK=$(mktemp -d)
  export SRC_ROOT COMPOSER WORK HOME="$WORK"
}

teardown() {
  [ -n "$WORK" ] && [ -d "$WORK" ] && rm -rf "$WORK"
}

@test "composer takes default_tempo from the INI file (-c)" {
  printf '[general]\nbeep_mode=binary\ndefault_tempo=60\n' > "$WORK/beep.conf"
  run "$COMPOSER" -c "$WORK/beep.conf" -s "C4q" -d
  [ "$status" -eq 0 ]
  echo "$output" | grep -q -- "-f 261 -l 1000"
}

@test "composer takes beep_mode from the INI file" {
  printf '[general]\nbeep_mode=ternary\n' > "$WORK/beep.conf"
  run "$COMPOSER" -c "$WORK/beep.conf" -s "C4q" -d
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "mode: ternary"
}

@test "the shipped config/beep.conf is INI and gives the documented defaults" {
  grep -q '^\[general\]' "$SRC_ROOT/config/beep.conf"
  ! grep -q '^BEEP_MODE=' "$SRC_ROOT/config/beep.conf"
  run "$COMPOSER" -c "$SRC_ROOT/config/beep.conf" -s "C4q" -d
  [ "$status" -eq 0 ]
  echo "$output" | grep -q -- "-f 261 -l 500"
  echo "$output" | grep -q "mode: binary"
}

@test "a 0.2.1 shell-format file is read and rewritten as INI" {
  printf '# old format\nBEEP_MODE="ternary"\nDEFAULT_TEMPO=60\nDEFAULT_OCTAVE=4\n' > "$WORK/beep.conf"
  run "$COMPOSER" -c "$WORK/beep.conf" -s "C4q" -d
  [ "$status" -eq 0 ]
  echo "$output" | grep -q -- "-f 261 -l 1000"
  echo "$output" | grep -q "mode: ternary"
  grep -q '^\[general\]' "$WORK/beep.conf"
  grep -q '^beep_mode=ternary' "$WORK/beep.conf"
  grep -q '^default_tempo=60' "$WORK/beep.conf"
  grep -q '^beep_samba=true|imperial-march|default|default' "$WORK/beep.conf"
  ! grep -q '^BEEP_MODE=' "$WORK/beep.conf"
}

@test "a read-only shell-format file is read but left alone" {
  printf 'BEEP_MODE="binary"\nDEFAULT_TEMPO=60\n' > "$WORK/beep.conf"
  chmod 444 "$WORK/beep.conf"
  run "$COMPOSER" -c "$WORK/beep.conf" -s "C4q" -d
  [ "$status" -eq 0 ]
  echo "$output" | grep -q -- "-l 1000"
  grep -q '^BEEP_MODE=' "$WORK/beep.conf"
}

@test "migrate_shell_config writes the INI to a destination (the package upgrade path)" {
  printf 'BEEP_MODE="ternary"\nDEFAULT_TEMPO=60\n' > "$WORK/beep.conf.0.2.1"
  run bash -c ". '$SRC_ROOT/lib/config.sh'; BACKUP_DIR='$WORK/backups'; migrate_shell_config '$WORK/beep.conf.0.2.1' '$WORK/beep.conf'"
  [ "$status" -eq 0 ]
  grep -q '^beep_mode=ternary' "$WORK/beep.conf"
  grep -q '^default_tempo=60' "$WORK/beep.conf"
  grep -q '^BEEP_MODE=' "$WORK/beep.conf.0.2.1"
}

@test "lib/config.sh writes default_tempo and default_octave and reads them back" {
  run bash -c ". '$SRC_ROOT/lib/config.sh'; CONFIG_PATH='$WORK/new.conf'; BACKUP_DIR='$WORK/backups'; create_default_config; DEFAULT_TEMPO=; load_config '$WORK/new.conf'; echo \"tempo=\$DEFAULT_TEMPO octave=\$DEFAULT_OCTAVE\""
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "tempo=120 octave=4"
}

@test "bash can source nothing of it: the INI is not shell, and nothing sources it any more" {
  ! grep -q 'source "\$CONFIG_FILE"' "$COMPOSER"
}
