#!/usr/bin/env bats

setup() {
    SRC=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
    WORK=$(mktemp -d)
    export WORK
    printf '#!/bin/sh\nprintf "%%s\\n" "$*" >>"$WORK/journal"\n' >"$WORK/logger"
    chmod +x "$WORK/logger"
    export PATH="$WORK:$PATH"
    # Rendering the helper alone exercises the same embedded code as postrm.
    printf '#SPARKY-BEEP-MAINTSCRIPT#\n' >"$WORK/template"
    python3 "$SRC/debian/render-maintscript.py" "$WORK/template" >"$WORK/helper"
}

teardown() { rm -rf "$WORK"; }

@test "maintscript failure keeps command error and repair on terminal and journal" {
    run sh -c '. "$1"; beep_step sh -c "echo injected-error >&2; exit 7"; beep_summary configure' sh "$WORK/helper"
    [ "$status" -eq 0 ]
    [[ "$output" == *injected-error* ]]
    [[ "$output" == *'status 7'* ]]
    [[ "$output" == *'Completed: -. Failed:'* ]]
    grep -q injected-error "$WORK/journal"
}

@test "maintscript success and defer are different in the closing summary" {
    run sh -c '. "$1"; beep_step true; beep_defer "systemctl daemon-reload"; beep_summary configure' sh "$WORK/helper"
    [ "$status" -eq 0 ]
    [[ "$output" == *'Completed: true. Failed: -. Deferred: systemctl daemon-reload.'* ]]
}

@test "maintscript has every existing language embedded after removal" {
    for file in "$SRC"/locale/*.lang; do
        lang=${file##*/}; lang=${lang%.lang}
        run env LC_ALL= LANGUAGE="$lang" LANG=en_US.UTF-8 sh -c '. "$1"; beep_step false; beep_summary remove' sh "$WORK/helper"
        [ "$status" -eq 0 ]
        [[ "$output" == *false* ]]
        [[ "$output" != *MSG_MAINT* ]]
    done
}

@test "maintscript journal failure is visible and does not undo dpkg completion" {
    printf '#!/bin/sh\necho journal-injected-error >&2\nexit 1\n' >"$WORK/logger"
    run sh -c '. "$1"; beep_step false; beep_summary purge' sh "$WORK/helper"
    [ "$status" -eq 0 ]
    [[ "$output" == *journal-injected-error* ]]
}

@test "runner propagates failed systemctl actions to its maintainer script" {
    printf '#!/bin/sh\necho injected-systemctl-error >&2\nexit 1\n' >"$WORK/systemctl"
    printf '#!/bin/sh\necho "  Installed: (none)"\n' >"$WORK/apt-cache"
    chmod +x "$WORK/systemctl" "$WORK/apt-cache"
    run bash "$SRC/bin/sparky-beep-run"
    [ "$status" -eq 1 ]
    [[ "$output" == *injected-systemctl-error* ]]
}
