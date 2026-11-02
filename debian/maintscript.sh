# Embedded at package build time: postrm runs after our installed files are gone.
# Policy 6.5 guarantees only Essential packages here. logger's own errors stay
# visible if the journal is unavailable. This server tool never uses the desktop.
beep_locale=${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}
case "$beep_locale" in C|C.*|POSIX) beep_locale=en ;; *) beep_locale=${LANGUAGE:-$beep_locale} ;; esac
beep_locale=${beep_locale%%:*}
#TRANSLATIONS#
beep_done=
beep_failed=
beep_deferred=

beep_log() {
    beep_message=$1
    printf 'sparky-beep: %s\n' "$beep_message" >&2
    logger --socket-errors=on -t sparky-beep -- "$beep_message" || :
}

beep_step() {
    if beep_output=$("$@" 2>&1); then
        [ -z "$beep_output" ] || printf '%s\n' "$beep_output" >&2
        beep_done="${beep_done}${beep_done:+; }$*"
    else
        beep_status=$?
        [ -z "$beep_output" ] || printf '%s\n' "$beep_output" >&2
        beep_failed="${beep_failed}${beep_failed:+; }$* ($beep_status)"
        beep_message=$(printf "$MSG_MAINT_FAILURE" "$*" "$beep_status" "$*")
        beep_log "$beep_message${beep_output:+
$beep_output}"
    fi
    # ORDER 358 package behavior, not a Policy exception: finish dpkg after
    # reporting the failed activation. debhelper 14.5's own
    # /usr/share/debhelper/autoscripts/postinst-systemd-restart uses
    # systemctl --system daemon-reload >/dev/null || true
    # We keep the command's output on the terminal and in the journal instead.
    return 0
}

beep_defer() {
    beep_deferred="${beep_deferred}${beep_deferred:+; }$*"
    beep_log "$(printf "$MSG_MAINT_SKIP" "$*")"
}

beep_summary() {
    beep_log "$(printf "$MSG_MAINT_SUMMARY" "$*" "${beep_done:--}" "${beep_failed:--}" "${beep_deferred:--}")"
}
