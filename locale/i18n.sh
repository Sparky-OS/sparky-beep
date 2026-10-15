#!/bin/bash
# Sparky Beep Internationalization Library
# Provides translation support for user-facing messages

# Detect system language from LANG environment variable
detect_language() {
  local lang="${LANG:-en_US.UTF-8}"
  # Extract language code (e.g., "en" from "en_US.UTF-8")
  echo "${lang%%_*}"
}

# Language with territory, e.g. "pt_BR" from "pt_BR.UTF-8" (pt_BR, zh_CN and zh_TW have their own files)
detect_language_territory() {
  local lang="${LANG:-en_US.UTF-8}"
  lang="${lang%%.*}"
  echo "${lang%%@*}"
}

# Load translation file for detected language
load_translations() {
  local lang=$(detect_language)
  # The .lang files sit beside this file (locale/ in the tree, /usr/share/sparky-beep/locale installed)
  local locale_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

  local trans_file="${locale_dir}/$(detect_language_territory).lang"

  # Then the bare language, then English
  if [ ! -f "$trans_file" ]; then
    trans_file="${locale_dir}/${lang}.lang"
  fi
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
  local key="${1#MSG_}"
  local var_name="MSG_${key}"
  eval echo "\${${var_name}:-${key}}"
}

# Initialize translations
load_translations
