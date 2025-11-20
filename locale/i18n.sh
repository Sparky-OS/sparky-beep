#!/bin/bash
# Sparky Beep Internationalization Library
# Provides translation support for user-facing messages

# Detect system language from LANG environment variable
detect_language() {
  local lang="${LANG:-en_US.UTF-8}"
  # Extract language code (e.g., "en" from "en_US.UTF-8")
  echo "${lang%%_*}"
}

# Load translation file for detected language
load_translations() {
  local lang=$(detect_language)
  local script_dir="$(dirname "$(readlink -f "$0")")"
  local locale_dir="${script_dir}/../locale"

  # If running from /usr/bin, use system locale directory
  if [ "$(dirname "$0")" = "/usr/bin" ]; then
    locale_dir="/usr/share/sparky-beep/locale"
  fi

  local trans_file="${locale_dir}/${lang}.lang"

  # Fallback to English if translation file doesn't exist
  if [ ! -f "$trans_file" ]; then
    trans_file="${locale_dir}/en.lang"
  fi

  # Source translation file if it exists
  if [ -f "$trans_file" ]; then
    . "$trans_file"
  fi
}

# Translation function - returns translated string or key if not found
t() {
  local key="$1"
  local var_name="MSG_${key}"
  eval echo "\${${var_name}:-${key}}"
}

# Initialize translations
load_translations
