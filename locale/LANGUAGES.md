# Sparky Beep - Supported Languages

Sparky Beep supports internationalization (i18n) with automatic language detection based on your system's `LANG` environment variable.

## Supported Languages

Sparky Beep includes translations for the following Debian-supported languages:

| Language Code | Language Name | Native Name | Status |
|--------------|---------------|-------------|--------|
| `cs` | Czech | Čeština | ✅ Complete |
| `de` | German | Deutsch | ✅ Complete |
| `en` | English | English | ✅ Complete (Default) |
| `es` | Spanish | Español | ✅ Complete |
| `fr` | French | Français | ✅ Complete |
| `it` | Italian | Italiano | ✅ Complete |
| `ja` | Japanese | 日本語 | ✅ Complete |
| `nl` | Dutch | Nederlands | ✅ Complete |
| `pl` | Polish | Polski | ✅ Complete |
| `pt` | Portuguese | Português | ✅ Complete |
| `ru` | Russian | Русский | ✅ Complete |
| `sv` | Swedish | Svenska | ✅ Complete |
| `tr` | Turkish | Türkçe | ✅ Complete |
| `uk` | Ukrainian | Українська | ✅ Complete |
| `zh_CN` | Chinese (Simplified) | 简体中文 | ✅ Complete |

**Total: 15 languages**

## How Language Detection Works

1. Sparky Beep reads your system's `LANG` environment variable
2. Extracts the language code (e.g., `de` from `de_DE.UTF-8`)
3. Loads the corresponding translation file from `/usr/share/sparky-beep/locale/`
4. Falls back to English (`en`) if the translation file doesn't exist

## Changing Language

You can change the language used by Sparky Beep by setting the `LANG` environment variable:

```bash
# Use German
export LANG=de_DE.UTF-8
systemctl restart beep_sys

# Use French
export LANG=fr_FR.UTF-8
./bin/sparky-beep-run

# Use Japanese
export LANG=ja_JP.UTF-8
/etc/init.d/beep_netdata start
```

## File Format

Each language file (e.g., `de.lang`) contains shell variable definitions:

```bash
# Service status messages
MSG_SERVICE_ACTIVE="%s service is active..."
MSG_SERVICE_NOT_ACTIVE="%s service is NOT active..."
MSG_SPARKY_STARTED="sparky-beep started"

# Usage messages
MSG_USAGE_BEEP_SYS="Use: /etc/init.d/beep_sys {start|stop|restart}"
MSG_USAGE_BEEP_NETDATA="Use: /etc/init.d/beep_netdata {start|stop|restart}"
MSG_USAGE_BEEP_SAMBA="Use: /etc/init.d/beep_samba {start|stop|restart}"
MSG_USAGE_BEEP_WEBMIN="Use: /etc/init.d/beep_webmin {start|stop|restart}"
```

## Adding a New Language

To add support for a new language:

1. Create a new language file: `locale/<lang_code>.lang`
2. Copy the English template:
   ```bash
   cp locale/en.lang locale/xx.lang
   ```
3. Translate all `MSG_*` variable values
4. Keep variable names unchanged (e.g., `MSG_SERVICE_ACTIVE`)
5. Maintain the same format for `%s` placeholders
6. Save with UTF-8 encoding
7. Test with: `LANG=xx_XX.UTF-8 ./bin/sparky-beep-run`

## Translation Guidelines

When translating:

- **Preserve placeholders**: `%s` will be replaced with service names
- **Keep technical terms**: Keep `start`, `stop`, `restart` unchanged
- **Match tone**: Messages should be informative but brief
- **Use UTF-8**: Ensure the file is saved with UTF-8 encoding
- **Test thoroughly**: Run all services with your translation

## Adding More Debian Languages

Additional Debian-supported languages that could be added:

| Language Code | Language Name | Native Name |
|--------------|---------------|-------------|
| `ar` | Arabic | العربية |
| `ca` | Catalan | Català |
| `da` | Danish | Dansk |
| `el` | Greek | Ελληνικά |
| `fi` | Finnish | Suomi |
| `hu` | Hungarian | Magyar |
| `ko` | Korean | 한국어 |
| `pt_BR` | Portuguese (Brazil) | Português do Brasil |
| `ro` | Romanian | Română |
| `sk` | Slovak | Slovenčina |
| `zh_TW` | Chinese (Traditional) | 繁體中文 |

## Technical Implementation

### i18n Library

The internationalization system is implemented in `locale/i18n.sh`:

- **Language detection**: Automatic based on `$LANG`
- **Fallback mechanism**: Defaults to English if translation not found
- **Translation function**: `t(key)` returns translated string
- **Loading mechanism**: Sources `.lang` files dynamically

### Integration

Scripts that support i18n:
- `bin/sparky-beep-run` - Main service controller
- `init.d/beep_*` - All init scripts

### Installation

During installation, locale files are copied to:
```
/usr/share/sparky-beep/locale/
```

## Contributing Translations

We welcome community translations! To contribute:

1. Fork the repository
2. Create a new language file following the guidelines above
3. Test your translation thoroughly
4. Submit a pull request with:
   - The new `.lang` file
   - Your name in the file header
   - Update to this LANGUAGES.md file

## Translation Status

All current translations are complete and tested. Translations were created following Debian localization standards and common terminology used in system administration.

## Resources

- **Debian i18n**: https://www.debian.org/international/
- **GNU gettext**: https://www.gnu.org/software/gettext/
- **POSIX Locales**: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap07.html

## License

All translation files are released under the same license as Sparky Beep (GNU GPL v3).

---

**Contributors**: If you've contributed translations, please add your name here:
- Paweł Pijanowski (Polish)
- Daniel Campos Ramos
- Community contributors

For questions about translations, please open an issue on GitHub.
