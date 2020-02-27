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
	rm -f /etc/init.d/beep_netdata
	rm -f /etc/init.d/beep_samba
	rm -f /etc/init.d/beep_sys
	rm -f /etc/init.d/beep_webmin
	rm -f /etc/init.d/sparky-beep
	rm -f /lib/systemd/system/beep_netdata.service
	rm -f /lib/systemd/system/beep_samba.service
	rm -f /lib/systemd/system/beep_sys.service
	rm -f /lib/systemd/system/beep_webmin.service
	rm -f /usr/bin/sparky-beep-run
	#rm -f /etc/xdg/autostart/sparky-beep-run.desktop
else
	cp init.d/* /etc/init.d/
	cp system/* /lib/systemd/system/
	cp bin/* /usr/bin/
	#cp etc/* /etc/xdg/autostart/
fi
