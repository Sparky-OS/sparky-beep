#!/bin/sh
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

if [ "$1" = "uninstall" ]; then
	# Remove init scripts
	rm -f /etc/init.d/beep_netdata
	rm -f /etc/init.d/beep_samba
	rm -f /etc/init.d/beep_sys
	rm -f /etc/init.d/beep_webmin
	rm -f /etc/init.d/sparky-beep

	# Remove systemd services
	rm -f /lib/systemd/system/beep_netdata.service
	rm -f /lib/systemd/system/beep_samba.service
	rm -f /lib/systemd/system/beep_sys.service
	rm -f /lib/systemd/system/beep_webmin.service

	# Remove executables
	rm -f /usr/bin/sparky-beep-run
	rm -f /usr/bin/sparky-beep-compose
	rm -f /usr/bin/sparky-beep-composer-tui
	rm -f /usr/bin/sparky-beep-composer-gui
	rm -f /usr/bin/sparky-beep-player-tui
	rm -f /usr/bin/sparky-beep-player-gui
	rm -f /usr/bin/sparky-beep-config
	rm -f /usr/bin/sparky-beep-config-tui
	rm -f /usr/bin/sparky-beep-config-gui
	rm -f /usr/bin/tbeep

	# Remove shared data
	rm -rf /usr/share/sparky-beep/locale
	rm -rf /usr/share/sparky-beep/lib
	rm -rf /usr/share/sparky-beep/compositions

	# Remove configuration
	rm -f /etc/sparky-beep/beep.conf
	rm -rf /etc/sparky-beep/backups
	rmdir /etc/sparky-beep 2>/dev/null || true

	#rm -f /etc/xdg/autostart/sparky-beep-run.desktop
else
	# Install init scripts
	cp init.d/* /etc/init.d/

	# Install systemd services
	cp system/* /lib/systemd/system/

	# Install executables (skip .c source files)
	cp bin/sparky-beep-run /usr/bin/
	cp bin/sparky-beep-compose /usr/bin/
	cp bin/sparky-beep-composer-tui /usr/bin/
	cp bin/sparky-beep-composer-gui /usr/bin/
	cp bin/sparky-beep-player-tui /usr/bin/
	cp bin/sparky-beep-player-gui /usr/bin/
	cp bin/sparky-beep-config /usr/bin/
	cp bin/sparky-beep-config-tui /usr/bin/
	cp bin/sparky-beep-config-gui /usr/bin/
	chmod +x /usr/bin/sparky-beep-config*
	chmod +x /usr/bin/sparky-beep-composer*
	chmod +x /usr/bin/sparky-beep-player*
	[ -f bin/tbeep ] && cp bin/tbeep /usr/bin/ || true

	# Install locale files
	mkdir -p /usr/share/sparky-beep/locale
	cp locale/*.lang locale/*.sh /usr/share/sparky-beep/locale/
	cp locale/*.md /usr/share/sparky-beep/locale/ 2>/dev/null || true

	# Install library files
	mkdir -p /usr/share/sparky-beep/lib
	cp lib/*.sh /usr/share/sparky-beep/lib/

	# Install compositions
	mkdir -p /usr/share/sparky-beep/compositions
	cp compositions/*.beepmusic /usr/share/sparky-beep/compositions/ 2>/dev/null || true

	# Install configuration
	mkdir -p /etc/sparky-beep
	if [ ! -f /etc/sparky-beep/beep.conf ]; then
		cp config/beep.conf /etc/sparky-beep/
	else
		echo "Preserving existing /etc/sparky-beep/beep.conf"
		echo "New configuration available in config/beep.conf"
	fi

	#cp etc/* /etc/xdg/autostart/

	echo ""
	echo "=========================================="
	echo "Sparky Beep installation complete!"
	echo "=========================================="
	echo ""
	echo "Configuration Tools:"
	echo "  sparky-beep-config      - Auto-detect interface (TUI/GUI)"
	echo "  sparky-beep-config-tui  - Text user interface"
	echo "  sparky-beep-config-gui  - Graphical user interface"
	echo ""
	echo "Composer Tools:"
	echo "  sparky-beep-composer-tui  - Interactive music composer (TUI)"
	echo "  sparky-beep-composer-gui  - Interactive music composer (GUI)"
	echo ""
	echo "Player Tools:"
	echo "  sparky-beep-player-tui    - Music player (TUI)"
	echo "  sparky-beep-player-gui    - Music player (GUI)"
	echo ""
	echo "Quick Commands:"
	echo "  sparky-beep-config --list              - List available services"
	echo "  sparky-beep-config --enable <service>  - Enable beep for service"
	echo "  sparky-beep-config --test ssh start    - Test beep sound"
	echo ""
	echo "Optional: Compile and install ternary beep engine:"
	echo "  make"
	echo "  sudo make install"
	echo ""
	echo "Test the composer:"
	echo "  sparky-beep-compose -s \"C4q D4q E4q F4q\" -p"
	echo "  sparky-beep-composer-tui    # Interactive composer"
	echo "  sparky-beep-player-tui      # Play compositions"
	echo ""
fi
