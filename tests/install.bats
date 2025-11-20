#!/usr/bin/env bats

setup() {
  # Create a temporary install directory
  INSTALL_ROOT=$(mktemp -d)
  export INSTALL_ROOT

  # Create mock system directories
  mkdir -p "$INSTALL_ROOT/etc/init.d"
  mkdir -p "$INSTALL_ROOT/lib/systemd/system"
  mkdir -p "$INSTALL_ROOT/usr/bin"

  # Create a modified install script that uses our temp directory
  cat <<'EOS' > "$INSTALL_ROOT/install-test.sh"
#!/bin/sh
INSTALL_ROOT="${INSTALL_ROOT:-}"

if [ "$1" = "uninstall" ]; then
	rm -f "$INSTALL_ROOT/etc/init.d/beep_netdata"
	rm -f "$INSTALL_ROOT/etc/init.d/beep_samba"
	rm -f "$INSTALL_ROOT/etc/init.d/beep_sys"
	rm -f "$INSTALL_ROOT/etc/init.d/beep_webmin"
	rm -f "$INSTALL_ROOT/etc/init.d/sparky-beep"
	rm -f "$INSTALL_ROOT/lib/systemd/system/beep_netdata.service"
	rm -f "$INSTALL_ROOT/lib/systemd/system/beep_samba.service"
	rm -f "$INSTALL_ROOT/lib/systemd/system/beep_sys.service"
	rm -f "$INSTALL_ROOT/lib/systemd/system/beep_webmin.service"
	rm -f "$INSTALL_ROOT/usr/bin/sparky-beep-run"
else
	cp init.d/* "$INSTALL_ROOT/etc/init.d/"
	cp system/* "$INSTALL_ROOT/lib/systemd/system/"
	cp bin/* "$INSTALL_ROOT/usr/bin/"
fi
EOS
  chmod +x "$INSTALL_ROOT/install-test.sh"
}

teardown() {
  if [ -n "$INSTALL_ROOT" ] && [ -d "$INSTALL_ROOT" ]; then
    rm -rf "$INSTALL_ROOT"
  fi
}

@test "install copies init scripts to /etc/init.d/" {
  cd "$INSTALL_ROOT"
  run ./install-test.sh

  [ "$status" -eq 0 ]
  [ -f "$INSTALL_ROOT/etc/init.d/beep_netdata" ]
  [ -f "$INSTALL_ROOT/etc/init.d/beep_samba" ]
  [ -f "$INSTALL_ROOT/etc/init.d/beep_sys" ]
  [ -f "$INSTALL_ROOT/etc/init.d/beep_webmin" ]
  [ -f "$INSTALL_ROOT/etc/init.d/sparky-beep" ]
}

@test "install copies systemd units to /lib/systemd/system/" {
  cd "$INSTALL_ROOT"
  run ./install-test.sh

  [ "$status" -eq 0 ]
  [ -f "$INSTALL_ROOT/lib/systemd/system/beep_netdata.service" ]
  [ -f "$INSTALL_ROOT/lib/systemd/system/beep_samba.service" ]
  [ -f "$INSTALL_ROOT/lib/systemd/system/beep_sys.service" ]
  [ -f "$INSTALL_ROOT/lib/systemd/system/beep_webmin.service" ]
}

@test "install copies executables to /usr/bin/" {
  cd "$INSTALL_ROOT"
  run ./install-test.sh

  [ "$status" -eq 0 ]
  [ -f "$INSTALL_ROOT/usr/bin/sparky-beep-run" ]
}

@test "install preserves execute permissions for init scripts" {
  cd "$INSTALL_ROOT"
  run ./install-test.sh

  [ "$status" -eq 0 ]
  [ -x "$INSTALL_ROOT/etc/init.d/beep_netdata" ]
  [ -x "$INSTALL_ROOT/etc/init.d/beep_samba" ]
  [ -x "$INSTALL_ROOT/etc/init.d/beep_sys" ]
  [ -x "$INSTALL_ROOT/etc/init.d/beep_webmin" ]
}

@test "install preserves execute permissions for sparky-beep-run" {
  cd "$INSTALL_ROOT"
  run ./install-test.sh

  [ "$status" -eq 0 ]
  [ -x "$INSTALL_ROOT/usr/bin/sparky-beep-run" ]
}

@test "uninstall removes all init scripts" {
  cd "$INSTALL_ROOT"
  # First install
  ./install-test.sh

  # Then uninstall
  run ./install-test.sh uninstall

  [ "$status" -eq 0 ]
  [ ! -f "$INSTALL_ROOT/etc/init.d/beep_netdata" ]
  [ ! -f "$INSTALL_ROOT/etc/init.d/beep_samba" ]
  [ ! -f "$INSTALL_ROOT/etc/init.d/beep_sys" ]
  [ ! -f "$INSTALL_ROOT/etc/init.d/beep_webmin" ]
  [ ! -f "$INSTALL_ROOT/etc/init.d/sparky-beep" ]
}

@test "uninstall removes all systemd service files" {
  cd "$INSTALL_ROOT"
  # First install
  ./install-test.sh

  # Then uninstall
  run ./install-test.sh uninstall

  [ "$status" -eq 0 ]
  [ ! -f "$INSTALL_ROOT/lib/systemd/system/beep_netdata.service" ]
  [ ! -f "$INSTALL_ROOT/lib/systemd/system/beep_samba.service" ]
  [ ! -f "$INSTALL_ROOT/lib/systemd/system/beep_sys.service" ]
  [ ! -f "$INSTALL_ROOT/lib/systemd/system/beep_webmin.service" ]
}

@test "uninstall removes sparky-beep-run executable" {
  cd "$INSTALL_ROOT"
  # First install
  ./install-test.sh

  # Then uninstall
  run ./install-test.sh uninstall

  [ "$status" -eq 0 ]
  [ ! -f "$INSTALL_ROOT/usr/bin/sparky-beep-run" ]
}

@test "uninstall doesn't fail if files don't exist" {
  cd "$INSTALL_ROOT"
  # Run uninstall without installing first
  run ./install-test.sh uninstall

  # Should succeed even though files don't exist
  [ "$status" -eq 0 ]
}

@test "install script handles missing source directories gracefully" {
  cd "$INSTALL_ROOT"

  # Remove source directories to simulate missing files
  rm -rf init.d system bin

  run ./install-test.sh

  # cp will fail if source doesn't exist, which is expected behavior
  [ "$status" -ne 0 ]
}

# Validate that actual install.sh has correct structure
@test "actual install.sh has uninstall option" {
  run grep -q "uninstall" install.sh
  [ "$status" -eq 0 ]
}

@test "actual install.sh copies from init.d directory" {
  run grep -q "cp init.d/" install.sh
  [ "$status" -eq 0 ]
}

@test "actual install.sh copies from system directory" {
  run grep -q "cp system/" install.sh
  [ "$status" -eq 0 ]
}

@test "actual install.sh copies from bin directory" {
  run grep -q "cp bin/" install.sh
  [ "$status" -eq 0 ]
}

@test "actual install.sh removes files on uninstall" {
  run grep -q "rm -f" install.sh
  [ "$status" -eq 0 ]
}
