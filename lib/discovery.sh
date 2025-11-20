#!/bin/bash
#
# Sparky Beep Service Discovery Library
# Discovers available system services and their status
# last update 2025/11/20
#

# Arrays to store discovered services
declare -A DISCOVERED_SERVICES
declare -A SERVICE_STATUS
declare -A SERVICE_PACKAGE

# Known service patterns to look for
KNOWN_SERVICES=(
    "ssh:openssh-server"
    "sshd:openssh-server"
    "netdata:netdata"
    "samba:samba"
    "smbd:samba"
    "samba-ad-dc:samba"
    "webmin:webmin"
    "apache2:apache2"
    "nginx:nginx"
    "mysql:mysql-server"
    "mariadb:mariadb-server"
    "postgresql:postgresql"
    "docker:docker.io"
    "redis:redis-server"
    "mongodb:mongodb"
    "elasticsearch:elasticsearch"
    "jenkins:jenkins"
    "gitlab:gitlab"
    "asterisk:asterisk"
    "cups:cups"
    "vsftpd:vsftpd"
    "proftpd:proftpd"
    "bind9:bind9"
    "dhcpd:isc-dhcp-server"
    "nfs-server:nfs-kernel-server"
    "samba:samba"
    "squid:squid"
    "postfix:postfix"
    "dovecot:dovecot-core"
    "lighttpd:lighttpd"
    "tomcat:tomcat9"
)

#
# Function: discover_services
# Description: Discover all available system services
# Usage: discover_services
#
discover_services() {
    local count=0

    # Clear previous discoveries
    DISCOVERED_SERVICES=()
    SERVICE_STATUS=()
    SERVICE_PACKAGE=()

    # Check each known service
    for entry in "${KNOWN_SERVICES[@]}"; do
        IFS=':' read -r service_name package_name <<< "$entry"

        # Check if systemd service exists
        if systemctl list-unit-files | grep -q "^${service_name}.service"; then
            # Check if package is installed
            local installed="false"
            if command -v dpkg >/dev/null 2>&1; then
                if dpkg -l "$package_name" 2>/dev/null | grep -q "^ii"; then
                    installed="true"
                fi
            elif command -v apt-cache >/dev/null 2>&1; then
                if apt-cache policy "$package_name" 2>/dev/null | head -n2 | tail -n1 | grep -q '[0-9]'; then
                    installed="true"
                fi
            fi

            # Get service status
            local status="inactive"
            if systemctl is-active --quiet "$service_name"; then
                status="active"
            fi

            # Store discovery information
            DISCOVERED_SERVICES["$service_name"]="$package_name"
            SERVICE_STATUS["$service_name"]="$status"
            SERVICE_PACKAGE["$service_name"]="$installed"
            ((count++))
        fi
    done

    return $count
}

#
# Function: list_discovered_services
# Description: List all discovered services
# Usage: list_discovered_services
#
list_discovered_services() {
    echo "Discovered Services:"
    echo "===================="

    for service in "${!DISCOVERED_SERVICES[@]}"; do
        local package="${DISCOVERED_SERVICES[$service]}"
        local status="${SERVICE_STATUS[$service]}"
        local installed="${SERVICE_PACKAGE[$service]}"

        printf "%-20s %-20s %-10s %-10s\n" \
            "$service" \
            "$package" \
            "$status" \
            "$installed"
    done | sort
}

#
# Function: get_service_list
# Description: Get a list of all discovered service names
# Usage: get_service_list
#
get_service_list() {
    for service in "${!DISCOVERED_SERVICES[@]}"; do
        echo "$service"
    done | sort
}

#
# Function: get_installed_services
# Description: Get a list of services with installed packages
# Usage: get_installed_services
#
get_installed_services() {
    for service in "${!DISCOVERED_SERVICES[@]}"; do
        if [ "${SERVICE_PACKAGE[$service]}" = "true" ]; then
            echo "$service"
        fi
    done | sort
}

#
# Function: get_active_services
# Description: Get a list of currently active services
# Usage: get_active_services
#
get_active_services() {
    for service in "${!DISCOVERED_SERVICES[@]}"; do
        if [ "${SERVICE_STATUS[$service]}" = "active" ]; then
            echo "$service"
        fi
    done | sort
}

#
# Function: is_service_installed
# Description: Check if a service's package is installed
# Usage: is_service_installed <service_name>
#
is_service_installed() {
    local service="$1"

    if [ -z "${DISCOVERED_SERVICES[$service]}" ]; then
        return 1
    fi

    [ "${SERVICE_PACKAGE[$service]}" = "true" ]
}

#
# Function: is_service_active
# Description: Check if a service is currently active
# Usage: is_service_active <service_name>
#
is_service_active() {
    local service="$1"

    if [ -z "${DISCOVERED_SERVICES[$service]}" ]; then
        return 1
    fi

    [ "${SERVICE_STATUS[$service]}" = "active" ]
}

#
# Function: get_beep_service_name
# Description: Get the corresponding beep service name for a system service
# Usage: get_beep_service_name <service_name>
#
get_beep_service_name() {
    local service="$1"

    # Map known services to their beep equivalents
    case "$service" in
        ssh|sshd)
            echo "beep_sys"
            ;;
        netdata)
            echo "beep_netdata"
            ;;
        samba|smbd|samba-ad-dc)
            echo "beep_samba"
            ;;
        webmin)
            echo "beep_webmin"
            ;;
        *)
            # Generic beep service name
            echo "beep_${service}"
            ;;
    esac
}

#
# Function: has_beep_service
# Description: Check if a beep service exists for a system service
# Usage: has_beep_service <service_name>
#
has_beep_service() {
    local service="$1"
    local beep_service=$(get_beep_service_name "$service")

    # Check if beep service exists
    if [ -f "/etc/init.d/$beep_service" ] || \
       systemctl list-unit-files | grep -q "^${beep_service}.service"; then
        return 0
    fi

    return 1
}

#
# Function: get_services_with_beeps
# Description: Get a list of services that have beep support
# Usage: get_services_with_beeps
#
get_services_with_beeps() {
    for service in "${!DISCOVERED_SERVICES[@]}"; do
        if has_beep_service "$service"; then
            echo "$service"
        fi
    done | sort
}

#
# Function: get_services_without_beeps
# Description: Get a list of services that don't have beep support yet
# Usage: get_services_without_beeps
#
get_services_without_beeps() {
    for service in "${!DISCOVERED_SERVICES[@]}"; do
        if ! has_beep_service "$service"; then
            echo "$service"
        fi
    done | sort
}

#
# Function: get_service_info
# Description: Get detailed information about a service
# Usage: get_service_info <service_name>
#
get_service_info() {
    local service="$1"

    if [ -z "${DISCOVERED_SERVICES[$service]}" ]; then
        echo "ERROR: Service not found: $service" >&2
        return 1
    fi

    echo "Service: $service"
    echo "Package: ${DISCOVERED_SERVICES[$service]}"
    echo "Status: ${SERVICE_STATUS[$service]}"
    echo "Installed: ${SERVICE_PACKAGE[$service]}"
    echo "Beep Service: $(get_beep_service_name "$service")"
    echo "Has Beep Support: $(has_beep_service "$service" && echo "yes" || echo "no")"
}

#
# Function: refresh_service_status
# Description: Refresh the status of all discovered services
# Usage: refresh_service_status
#
refresh_service_status() {
    for service in "${!DISCOVERED_SERVICES[@]}"; do
        # Update status
        local status="inactive"
        if systemctl is-active --quiet "$service"; then
            status="active"
        fi
        SERVICE_STATUS["$service"]="$status"
    done
}

#
# Function: create_beep_service_template
# Description: Create a template for a new beep service
# Usage: create_beep_service_template <service_name> <output_dir>
#
create_beep_service_template() {
    local service="$1"
    local output_dir="${2:-.}"
    local beep_service=$(get_beep_service_name "$service")

    # Create init.d script
    local init_script="${output_dir}/${beep_service}"
    cat > "$init_script" << 'EOF'
#!/bin/sh -e

### BEGIN INIT INFO
# Provides: BEEP_SERVICE_NAME
# Required-Start: $syslog
# Required-Stop: $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: Beep on SERVICE_NAME service state changes
### END INIT INFO

set -e

case "$1" in
  start)
    beep -f 1000 -l 200 -n -f 1500 -l 200
    ;;
  stop)
    beep -f 1500 -l 200 -n -f 1000 -l 200
    ;;
  restart)
    beep -f 500 -l 100 -n -f 1000 -l 100 -n -f 1500 -l 100
    ;;
  *)
    echo "Use: /etc/init.d/BEEP_SERVICE_NAME {start|stop|restart}"
    exit 1
    ;;
esac

exit 0
EOF

    # Replace placeholders
    sed -i "s/BEEP_SERVICE_NAME/$beep_service/g" "$init_script"
    sed -i "s/SERVICE_NAME/$service/g" "$init_script"

    # Create systemd service file
    local systemd_service="${output_dir}/${beep_service}.service"
    cat > "$systemd_service" << EOF
[Unit]
Description=Beep on $service service state changes
After=${service}.service
BindsTo=${service}.service
ReloadPropagatedFrom=${service}.service

[Service]
Type=simple
RemainAfterExit=yes
ExecStart=/etc/init.d/$beep_service start
ExecStop=/etc/init.d/$beep_service stop
ExecReload=/etc/init.d/$beep_service restart

[Install]
WantedBy=${service}.service
EOF

    echo "Created templates:"
    echo "  Init script: $init_script"
    echo "  Systemd service: $systemd_service"
}

# Export functions
export -f discover_services
export -f list_discovered_services
export -f get_service_list
export -f get_installed_services
export -f get_active_services
export -f is_service_installed
export -f is_service_active
export -f get_beep_service_name
export -f has_beep_service
export -f get_services_with_beeps
export -f get_services_without_beeps
export -f get_service_info
export -f refresh_service_status
export -f create_beep_service_template
