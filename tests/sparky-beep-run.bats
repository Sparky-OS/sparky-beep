#!/usr/bin/env bats

setup() {
  TMPDIR=$(mktemp -d)
  PATH="$TMPDIR:$PATH"
  export TMP_STATE="$TMPDIR"

  cat <<'EOS' > "$TMPDIR/systemctl"
#!/bin/sh
state="$TMP_STATE/beep_sys_started"
cmd=$1
unit=$2
case "$cmd" in
  status)
    if [ -f "$state" ]; then
      echo "Active: active (running)"
      echo "Loaded: loaded (/etc/systemd/system/$unit.service; enabled)"
    else
      echo "Active: inactive (dead)"
      echo "Loaded: loaded (/etc/systemd/system/$unit.service; disabled)"
    fi
    ;;
  start)
    touch "$state"
    ;;
  enable)
    :
    ;;
  *)
    :
    ;;
esac
EOS
  chmod +x "$TMPDIR/systemctl"

  cat <<'EOS' > "$TMPDIR/apt-cache"
#!/bin/sh
exit 0
EOS
  chmod +x "$TMPDIR/apt-cache"

  cat <<'EOS' > "$TMPDIR/beep"
#!/bin/sh
exit 0
EOS
  chmod +x "$TMPDIR/beep"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "starts inactive beep_sys service" {
  run bin/sparky-beep-run
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "beep_sys service is active"
}

