# Debian Packaging for Sparky Beep

This directory contains the Debian packaging files for building a `.deb` package of Sparky Beep.

## Target Platform

This package targets **Debian 12 "Bookworm" (stable)** and Debian-based distributions including Sparky Linux.

## Package Information

- **Package Name**: sparky-beep
- **Current Version**: 0.2.0-1
- **Architecture**: any (includes compiled tbeep binary)
- **Section**: admin
- **Priority**: optional
- **Target Distribution**: Debian stable (Bookworm)
- **Maintainer**: Capitain_Jack and Claude

## Requirements

To build the Debian package, you need the following tools installed:

```bash
sudo apt-get install debhelper build-essential
```

- **debhelper** (>= 13): Debian packaging helper tools
- **build-essential**: Compiler and build tools (gcc, make, etc.)
- **gcc**: Required to compile the tbeep binary
- **make**: Required for the build process

## Building the Package

### Method 1: Using Make (Recommended)

The easiest way to build the package is using the provided Makefile target:

```bash
# Build the .deb package
make deb

# The package will be created in the parent directory:
# ../sparky-beep_0.2.0-1_amd64.deb
```

To clean up build artifacts:

```bash
make deb-clean
```

### Method 2: Using dpkg-buildpackage Directly

You can also build the package manually:

```bash
# Build binary-only package (no source)
dpkg-buildpackage -us -uc -b

# Or build with source
dpkg-buildpackage -us -uc
```

Options explained:
- `-us`: Do not sign the source package
- `-uc`: Do not sign the .changes file
- `-b`: Binary-only build (no source package)

## Installing the Package

After building, install the package with:

```bash
sudo dpkg -i ../sparky-beep_0.2.0-1_amd64.deb

# If there are dependency issues, run:
sudo apt-get install -f
```

Or install the dependencies first:

```bash
sudo apt-get install beep systemd bash
sudo dpkg -i ../sparky-beep_0.2.0-1_amd64.deb
```

## Package Contents

The package installs the following files:

### Binaries (`/usr/bin/`)
- `tbeep` - Ternary beep engine (compiled C program)
- `sparky-beep-run` - Main service controller
- `sparky-beep-config` - Configuration interface (auto-detects TUI/GUI)
- `sparky-beep-config-tui` - Text-based configuration interface
- `sparky-beep-config-gui` - Graphical configuration interface
- `sparky-beep-compose` - Melody composition tool
- `sparky-beep-composer-tui` - TUI composition interface
- `sparky-beep-composer-gui` - GUI composition interface
- `sparky-beep-player-tui` - TUI melody player
- `sparky-beep-player-gui` - GUI melody player

### Init Scripts (`/etc/init.d/`)
- `sparky-beep` - Main init script
- `beep_sys` - System/SSH service beep script
- `beep_samba` - Samba service beep script
- `beep_netdata` - NetData service beep script
- `beep_webmin` - Webmin service beep script

### Systemd Services (`/lib/systemd/system/`)
- `beep_sys.service`
- `beep_samba.service`
- `beep_netdata.service`
- `beep_webmin.service`

### Configuration (`/etc/sparky-beep/`)
- `beep.conf.example` - Example configuration file (copied to `beep.conf` on install)

### Shared Files (`/usr/share/sparky-beep/`)
- `lib/*.sh` - Library files (config, discovery, tunes, scheduler, notes)
- `locale/*.lang` - Translation files for 26 languages
- `locale/i18n.sh` - Internationalization library
- `compositions/*.beepmusic` - Built-in melody compositions

## Package Maintenance Scripts

The package includes maintenance scripts that run during installation/removal:

### `postinst` (Post-installation)
- Reloads systemd daemon
- Creates `/etc/sparky-beep/` directory
- Copies example config to `/etc/sparky-beep/beep.conf` if it doesn't exist
- Runs `sparky-beep-run` to discover and enable beep services

### `prerm` (Pre-removal)
- Stops all active beep services
- Disables all beep services

### `postrm` (Post-removal)
- Reloads systemd daemon
- On purge: removes `/etc/sparky-beep/` directory

## Dependencies

### Runtime Dependencies (Required)
- `beep` - PC speaker beep utility
- `systemd` - Init system
- `bash` (>= 4.0) - Shell interpreter

### Suggested Packages (Optional)
- `netdata` - For NetData service monitoring
- `samba` - For Samba service monitoring
- `webmin` - For Webmin service monitoring
- `dialog` or `whiptail` - For TUI interfaces
- `zenity` or `yad` - For GUI interfaces

## Packaging Files Structure

```
debian/
├── changelog           # Version history in Debian format
├── control             # Package metadata and dependencies
├── copyright           # License and copyright information
├── postinst            # Post-installation script
├── prerm               # Pre-removal script
├── postrm              # Post-removal script
├── rules               # Build instructions (Makefile)
├── source/
│   └── format          # Source package format (3.0 native)
└── README.md           # This file
```

## Updating the Package Version

To release a new version:

1. Update the version in `debian/changelog`:
   ```bash
   dch -v 0.2.1-1 "New release"
   # Or manually edit debian/changelog
   ```

2. Follow the Debian changelog format:
   ```
   sparky-beep (0.2.1-1) unstable; urgency=medium

     * Brief description of changes
     * Another change

    -- Capitain_Jack and Claude <sparky-os@example.com>  Wed, 20 Nov 2025 00:00:00 +0000
   ```

3. Update the main `CHANGELOG` file with user-friendly release notes

4. Build and test the new package:
   ```bash
   make deb
   sudo dpkg -i ../sparky-beep_0.2.1-1_amd64.deb
   ```

## Testing the Package

After building, you can test the package contents and metadata:

```bash
# View package information
dpkg-deb --info ../sparky-beep_0.2.0-1_amd64.deb

# List package contents
dpkg-deb --contents ../sparky-beep_0.2.0-1_amd64.deb

# Extract package to inspect
dpkg-deb --extract ../sparky-beep_0.2.0-1_amd64.deb /tmp/test-extract

# Check for lintian issues (Debian package quality checks)
lintian ../sparky-beep_0.2.0-1_amd64.deb
```

## Troubleshooting

### Build Fails: "Unmet build dependencies"

Install the required build dependencies:
```bash
sudo apt-get install debhelper build-essential gcc make
```

### Build Fails: "tbeep compilation error"

Make sure gcc and development tools are installed:
```bash
sudo apt-get install build-essential libc6-dev
```

### Installation Fails: "beep command not found"

Install the beep utility:
```bash
sudo apt-get install beep
```

### Services Not Starting

The beep services are designed to bind to optional system services. They will only activate if the corresponding service (ssh, samba, netdata, webmin) is installed and running.

Check service status:
```bash
systemctl status beep_sys
systemctl status ssh
```

## Debian Policy Compliance

This package follows Debian Policy Manual standards for Debian 12 "Bookworm":
- Debhelper compatibility level: 13 (matches Debian 12 stable)
- Standards-Version: 4.6.2 (Debian 12 policy version)
- Source format: 3.0 (native)
- Build flags: All hardening flags enabled
- License: GPL-3.0+
- Tested on: Debian 12 (Bookworm) and derivatives

## Contributing

When contributing to the Debian packaging:

1. Follow Debian Policy Manual guidelines
2. Test package builds on clean systems
3. Update changelog for all changes
4. Maintain backward compatibility when possible
5. Run lintian to check for packaging issues

## References

- [Debian New Maintainers' Guide](https://www.debian.org/doc/manuals/maint-guide/)
- [Debian Policy Manual](https://www.debian.org/doc/debian-policy/)
- [Debhelper Documentation](https://man7.org/linux/man-pages/man7/debhelper.7.html)
- [dpkg-buildpackage Manual](https://man7.org/linux/man-pages/man1/dpkg-buildpackage.1.html)

## Authors

- **Original Authors**: Paweł "pavroo" Pijanowski, Daniel Campos Ramos
- **Debian Packaging**: Capitain_Jack and Claude (2025)
- **Project**: SparkyOS

## License

The packaging files are licensed under GPL-3.0+, same as the upstream project.
