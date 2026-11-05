#!/bin/bash
# ORDER 346f-5 and 346f-6 (U40): the configuration and the tune library must be confirmed before the sound tools go on.
# Run as an ordinary user (root ignores file permissions): tests/init-failure.sh TREE
# TREE holds bin/, lib/, locale/ and compositions/ side by side (the source tree, or an installed package laid out that way).
# Zenity and whiptail are stubs that record their arguments and answer "cancel", so no screen is needed.
set -u
tree=$(cd "${1:?tree}" && pwd)
work=$(mktemp -d)
trap 'chmod -R u+rwx "$work" 2>/dev/null; rm -rf "$work"' EXIT
mkdir -p "$work/stubs"
for s in zenity whiptail dialog yad; do
	cat > "$work/stubs/$s" <<STUB
#!/bin/sh
echo "$s \$*" >> "\$CALLS"
exit 1
STUB
	chmod +x "$work/stubs/$s"
done
pass=0; fail=0
check() { # description condition-exit-status
	if [ "$2" -eq 0 ]; then pass=$((pass+1)); echo "PASS $1"; else fail=$((fail+1)); echo "FAIL $1"; fi
}
expect="could not be loaded"
run() { # script [arguments] ; uses $home -> sets rc, err, calls
	export CALLS="$work/calls"; : > "$CALLS"
	local script=$1; shift
	HOME=$home PATH="$work/stubs:$PATH" LANG=C timeout "${tmo:-20}" "$tree/bin/$script" "$@" >"$work/out" 2>"$work/err" </dev/null
	rc=$?
}
for script in sparky-beep-player-gui sparky-beep-player-tui sparky-beep-composer-gui sparky-beep-composer-tui sparky-beep-config-gui sparky-beep-config-tui; do
	library=0; case $script in sparky-beep-player-*|sparky-beep-config-*) library=1 ;; esac
	# normal path: unchanged, reaches the program's own window, says nothing about the sound configuration
	home=$work/home-ok-$script; mkdir -p "$home"
	# the configuration tools list every service first, which takes about a minute on a full system
	case $script in sparky-beep-config-*) tmo=150 ;; *) tmo=20 ;; esac
	run $script
	tmo=20
	grep -q "$expect" "$work/err"; check "$script normal: no failure message" $((! $?))
	[ -s "$CALLS" ]; check "$script normal: reaches its window" $?
	# A: the configuration folder cannot be created (HOME is a file)
	home=$work/home-a-$script; : > "$home"
	run $script
	grep -q "$expect" "$work/err"; check "$script config folder: says the sound configuration could not be loaded" $?
	[ "$rc" -eq 1 ]; check "$script config folder: stops, exit 1 (got $rc)" $?
	! grep -qE 'zenity (--list|--entry|--question)|whiptail .*--(menu|inputbox|yesno)' "$CALLS"; check "$script config folder: no program window with defaults" $?
	grep -qE 'could not be loaded' "$CALLS"; check "$script config folder: the message is shown in the program's dialog" $?
	# B: the configuration file exists but cannot be read
	home=$work/home-b-$script; mkdir -p "$home"
	run $script
	cfg=$(find "$home" -name beep.conf | head -n 1)
	if [ -n "$cfg" ]; then chmod 000 "$cfg"; run $script; fi
	grep -q "cannot be read" "$work/err"; check "$script unreadable config: the reason is named" $?
	[ "$rc" -eq 1 ]; check "$script unreadable config: stops, exit 1 (got $rc)" $?
	chmod 600 "$cfg" 2>/dev/null
	# C: the tune library has a folder that cannot be read (player only; the composer does not load the library)
	if [ $library -eq 1 ]; then
		home=$work/home-c-$script; mkdir -p "$home/.local/share/sparky-beep/compositions"
		chmod 000 "$home/.local/share/sparky-beep/compositions"
		run $script
		grep -q "Tune folder cannot be read" "$work/err"; check "$script unreadable tune folder: the reason is named" $?
		[ "$rc" -eq 1 ]; check "$script unreadable tune folder: stops, exit 1 (got $rc)" $?
		chmod 700 "$home/.local/share/sparky-beep/compositions"
	fi
done
# The command line tool (ORDER 346f-6): each command that reads the configuration stops the same way.
# label|arguments|library
for spec in "enable|--enable nosuchservice|0" "disable|--disable nosuchservice|0" "test|--test nosuchservice start|1"; do
	label=${spec%%|*}; rest=${spec#*|}; args=${rest%|*}; library=${spec##*|}
	script=sparky-beep-config
	home=$work/home-ok-cli-$label; mkdir -p "$home"
	run $script $args
	grep -q "$expect" "$work/err"; check "$script $label normal: no failure message" $((! $?))
	home=$work/home-a-cli-$label; : > "$home"
	run $script $args
	grep -q "$expect" "$work/err"; check "$script $label config folder: says the sound configuration could not be loaded" $?
	[ "$rc" -eq 1 ]; check "$script $label config folder: stops, exit 1 (got $rc)" $?
	! grep -q "not found\|Playing" "$work/out" "$work/err"; check "$script $label config folder: goes no further" $?
	home=$work/home-b-cli-$label; mkdir -p "$home"
	run $script $args
	cfg=$(find "$home" -name beep.conf | head -n 1)
	if [ -n "$cfg" ]; then chmod 000 "$cfg"; run $script $args; fi
	grep -q "cannot be read" "$work/err"; check "$script $label unreadable config: the reason is named" $?
	[ "$rc" -eq 1 ]; check "$script $label unreadable config: stops, exit 1 (got $rc)" $?
	chmod 600 "$cfg" 2>/dev/null
	if [ $library -eq 1 ]; then
		home=$work/home-c-cli-$label; mkdir -p "$home/.local/share/sparky-beep/compositions"
		chmod 000 "$home/.local/share/sparky-beep/compositions"
		run $script $args
		grep -q "Tune folder cannot be read" "$work/err"; check "$script $label unreadable tune folder: the reason is named" $?
		[ "$rc" -eq 1 ]; check "$script $label unreadable tune folder: stops, exit 1 (got $rc)" $?
		chmod 700 "$home/.local/share/sparky-beep/compositions"
	fi
done
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
