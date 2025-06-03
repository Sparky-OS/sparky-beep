#!/usr/bin/env bats

@test "usage text matches script name" {
  for script in init.d/beep_*; do
    service=$(basename "$script")
    usage=$(grep -oE '/etc/init.d/[a-zA-Z0-9_-]+' "$script" | head -n1)
    [ "$usage" = "/etc/init.d/$service" ]
  done
}


