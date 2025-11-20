#!/bin/bash
# Example: How to integrate i18n into Sparky Beep scripts
# This demonstrates the translation system usage

# Source the i18n library
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. "${SCRIPT_DIR}/i18n.sh"

# Example 1: Simple translated message
echo "=== Example 1: Service Active Message ==="
# Without i18n (old way):
# echo "beep_netdata service is active..."

# With i18n (new way):
service_name="beep_netdata"
msg=$(printf "$(t SERVICE_ACTIVE)" "$service_name")
echo "$msg"

# Example 2: Usage message
echo ""
echo "=== Example 2: Usage Message ==="
# Without i18n (old way):
# echo "Use: /etc/init.d/beep_sys {start|stop|restart}"

# With i18n (new way):
echo "$(t USAGE_BEEP_SYS)"

# Example 3: Detect current language
echo ""
echo "=== Example 3: Language Detection ==="
current_lang=$(detect_language)
echo "Detected language: $current_lang"
echo "LANG environment variable: ${LANG:-not set}"

# Example 4: Show all translated messages
echo ""
echo "=== Example 4: All Translated Messages ==="
echo "SERVICE_ACTIVE: $(printf "$(t SERVICE_ACTIVE)" "test_service")"
echo "SERVICE_NOT_ACTIVE: $(printf "$(t SERVICE_NOT_ACTIVE)" "test_service")"
echo "SPARKY_STARTED: $(t SPARKY_STARTED)"
echo "USAGE_BEEP_SYS: $(t USAGE_BEEP_SYS)"

# Example 5: Test with different languages
echo ""
echo "=== Example 5: Testing Multiple Languages ==="
for lang in en de es fr it pl ru ja zh_CN; do
    export LANG="${lang}_XX.UTF-8"
    . "${SCRIPT_DIR}/i18n.sh"  # Reload translations
    msg=$(printf "$(t SERVICE_ACTIVE)" "netdata")
    echo "[$lang] $msg"
done
