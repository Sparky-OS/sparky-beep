#!/usr/bin/python3
"""Embed removal-safe diagnostics and translations in a maintainer script."""
import ast
from pathlib import Path
import shlex
import sys

root = Path(__file__).resolve().parent.parent
keys = ('MSG_MAINT_FAILURE', 'MSG_MAINT_SKIP', 'MSG_MAINT_SUMMARY')
languages = {}
for file in sorted((root / 'locale').glob('*.lang')):
    messages = {}
    for line in file.read_text().splitlines():
        name, sep, value = line.partition('=')
        if sep and name in keys:
            messages[name] = ast.literal_eval(value)
    assert set(messages) == set(keys), (file, messages)
    assert [messages[k].count('%s') for k in keys] == [3, 1, 4], file
    languages[file.stem] = messages
lines = ['case "$beep_locale" in']
for lang in sorted(languages, key=lambda name: (-len(name), name)):
    if lang == 'en':
        continue
    lines.append(f'    {lang}*)')
    lines += [f'        {k}={shlex.quote(languages[lang][k])}' for k in keys]
    lines.append('        ;;')
lines.append('    *)')
lines += [f'        {k}={shlex.quote(languages["en"][k])}' for k in keys]
lines += ['        ;;', 'esac']
helper = (root / 'debian/maintscript.sh').read_text().replace('#TRANSLATIONS#', '\n'.join(lines))
script = Path(sys.argv[1]).read_text()
print(script.replace('#SPARKY-BEEP-MAINTSCRIPT#', helper), end='')
