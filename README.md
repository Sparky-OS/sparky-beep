Sparky Beep
Provides beep support for a few services of sbserver edition.

Overview
--------
Sparky Beep offers audible notifications when selected system services
start, stop or restart. The repository is arranged in a few key
directories:

- `README.md` introduces Sparky Beep and lists required packages and
  installation commands.
- `install.sh` copies or removes init scripts, systemd service files and
  the main helper script. Run it with `uninstall` to remove everything.
- `bin/` holds `sparky-beep-run`, a helper script that verifies the beep
  services are active and starts them if needed.
- `init.d/` contains SysV init scripts such as `beep_netdata`,
  `beep_samba`, `beep_sys`, `beep_webmin` and `sparky-beep`. Each of these
  defines `beep` commands for different service states. For example:

```
case "$1" in
  start)
    beep -f 1000 -n -f 1500 -n -f 600 ...
    ;;
  stop)
    beep -f 100 -r 2 -l 10 -n -f 50 ...
    ;;
  restart)
    beep -f 100 -r 2 -l 10 ... ; beep -f 1000 ...
    ;;
esac
```
- `system/` provides systemd unit files that link the beep scripts to
  services like `netdata.service`, `samba-ad-dc.service`, `ssh.service`
  and `webmin`.
- Additional metadata includes `CHANGELOG`, `LICENSE` and Debian-style
  copyright information.

Key Points
----------
- The goal is to give audible feedback ("beeps") when services change
  state.
- Installation copies the scripts into system directories while
  uninstallation removes them.
- `sparky-beep-run` can be triggered from an init script and keeps the
  beep services enabled and running.

Where to Learn More
-------------------
- Inspect `bin/sparky-beep-run` to see how it uses `systemctl` to check
  service state.
- Review the init scripts in `init.d/` to adjust beep sequences or add
  new services.
- Learn how systemd unit files are installed and enabled with
  `systemctl enable` and `systemctl start`.
- This README lists the dependencies and quick steps for installation or
  removal.

Copyright (C) 2018-2020 Paweł Pijanowski & Daniel Campos Ramos

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Dependencies:
-------------
apt
beep
coreutils
grep
openssh-server
systemd

Suggests:
-------------
netdata
samba
webmin

Install:
-------------
su (or sudo) 
./install.sh

Uninstall:
-------------
su (or sudo)
./install.sh uninstall
