#!/usr/bin/env bats
#
# The tools as the package installs them: /usr/bin beside /usr/share/sparky-beep.
# Each test here failed on the 0.2.0 tree (2026-10-14).
#

setup() {
  SRC_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  ROOT=$(mktemp -d)
  export SRC_ROOT ROOT
  mkdir -p "$ROOT/usr/bin" "$ROOT/usr/share/sparky-beep"
  cp "$SRC_ROOT"/bin/sparky-beep-* "$ROOT/usr/bin/"
  cp -r "$SRC_ROOT/lib" "$SRC_ROOT/locale" "$SRC_ROOT/compositions" "$ROOT/usr/share/sparky-beep/"
  # the fake /usr has a lib/ too, as the real one does
  mkdir -p "$ROOT/usr/lib"
  export HOME="$ROOT"
  export LANG=C.UTF-8
}

teardown() {
  [ -n "$ROOT" ] && [ -d "$ROOT" ] && rm -rf "$ROOT"
}

@test "installed sparky-beep-compose finds notes.sh in /usr/share/sparky-beep" {
  # the tool looks in $(dirname /usr/bin)/lib first, then /usr/share/sparky-beep/lib
  run env PATH="$ROOT/usr/bin:$PATH" bash -c 'cd "$ROOT/usr/bin" && sed "s|/usr/share/sparky-beep|$ROOT/usr/share/sparky-beep|" sparky-beep-compose > compose.test && bash compose.test -s "C4q" -d'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q -- "-f 261 -l 500"
}

@test "installed sparky-beep-config prints translated usage, not MSG_ keys" {
  run bash -c 'cd "$ROOT/usr/bin" && sed "s|/usr/share/sparky-beep|$ROOT/usr/share/sparky-beep|" sparky-beep-config > config.test && bash config.test --help'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Usage: "
  ! echo "$output" | grep -q "MSG_CLI"
}

@test "installed sparky-beep-config shows the version in Polish from LANG" {
  run bash -c 'cd "$ROOT/usr/bin" && sed "s|/usr/share/sparky-beep|$ROOT/usr/share/sparky-beep|" sparky-beep-config > config.test && LANG=pl_PL.UTF-8 bash config.test --version'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "$(grep '^MSG_VERSION=' "$SRC_ROOT/locale/pl.lang" | sed 's/^MSG_VERSION="//; s/ %s"$//')"
}

@test "composer keeps sharps: C#4 is 277 Hz, not a comment" {
  run "$SRC_ROOT/bin/sparky-beep-compose" -s "C#4q Db4q" -d
  [ "$status" -eq 0 ]
  echo "$output" | grep -q -- "-f 277 -l 500 -n -f 277 -l 500"
}

@test "composer still drops comments" {
  run "$SRC_ROOT/bin/sparky-beep-compose" -s "C4q # a comment C5q" -d
  [ "$status" -eq 0 ]
  echo "$output" | grep -q -- "-f 261 -l 500"
  ! echo "$output" | grep -q -- "-f 523"
}

@test "LANG=pt_BR loads pt_BR.lang, not pt.lang" {
  run bash -c 'cd "$ROOT/usr/bin" && sed "s|/usr/share/sparky-beep|$ROOT/usr/share/sparky-beep|" sparky-beep-config > config.test && LANG=pt_BR.UTF-8 bash config.test --help'
  [ "$status" -eq 0 ]
  expected=$(grep '^MSG_CLI_DESCRIPTION=' "$SRC_ROOT/locale/pt_BR.lang" | sed 's/^MSG_CLI_DESCRIPTION="//; s/"$//')
  [ -n "$expected" ]
  echo "$output" | grep -qF "$expected"
}

@test "LANG=zh_CN loads zh_CN.lang" {
  run bash -c 'cd "$ROOT/usr/bin" && sed "s|/usr/share/sparky-beep|$ROOT/usr/share/sparky-beep|" sparky-beep-config > config.test && LANG=zh_CN.UTF-8 bash config.test --help'
  [ "$status" -eq 0 ]
  expected=$(grep '^MSG_CLI_DESCRIPTION=' "$SRC_ROOT/locale/zh_CN.lang" | sed 's/^MSG_CLI_DESCRIPTION="//; s/"$//')
  [ -n "$expected" ]
  echo "$output" | grep -qF "$expected"
}

@test "LANG=fr_CA falls back to fr.lang" {
  run bash -c 'cd "$ROOT/usr/bin" && sed "s|/usr/share/sparky-beep|$ROOT/usr/share/sparky-beep|" sparky-beep-config > config.test && LANG=fr_CA.UTF-8 bash config.test --help'
  [ "$status" -eq 0 ]
  expected=$(grep '^MSG_CLI_DESCRIPTION=' "$SRC_ROOT/locale/fr.lang" | sed 's/^MSG_CLI_DESCRIPTION="//; s/"$//')
  echo "$output" | grep -qF "$expected"
}
