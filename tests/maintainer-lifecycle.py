#!/usr/bin/python3
"""Run only in a disposable container: real migration, stub systemctl/runner.

Usage: maintainer-lifecycle.py SOURCE OUT [BASELINE_DEBIAN]
Root supplies dpkg's environment; Bats covers the helper unprivileged.
"""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

source, out = map(Path, sys.argv[1:3])
baseline = Path(sys.argv[3]) if len(sys.argv)>3 else None
assert os.geteuid()==0
assert not Path('/run/systemd/system').exists(), 'Disposable container without systemd only'
out.mkdir(parents=True,exist_ok=True)
failed=0


def check(ok,text):
    global failed
    print(('PASS ' if ok else 'FAIL ')+text)
    failed+=not ok


with tempfile.TemporaryDirectory() as temp:
    work=Path(temp)
    work.chmod(0o755)
    for name in ('preinst','postinst','prerm','postrm'):
        content=(baseline/name).read_text() if baseline else subprocess.check_output(['python3',str(source/'debian/render-maintscript.py'),str(source/'debian'/name)],text=True)
        (work/name).write_text(content)
    (work/'systemctl').write_text('''#!/bin/sh
echo "$*" >>"$CALLS"
if [ "$FAIL" = yes ]; then echo "systemctl injected failure: $*" >&2; exit 1; fi
''')
    (work/'logger').write_text('#!/bin/sh\nprintf "%s\\n" "$*" >>"$JOURNAL"\n')
    (work/'dpkg-maintscript-helper').write_text('#!/bin/sh\nexit 0\n')
    for file in work.iterdir(): file.chmod(0o755)
    runner=Path('/usr/bin/sparky-beep-run')
    old_runner=runner.read_bytes() if runner.exists() else None
    runner.write_text('''#!/bin/sh
echo runner >>"$CALLS"
if [ "$FAIL" = yes ]; then echo 'runner injected failure' >&2; exit 1; fi
''')
    runner.chmod(0o755)
    lib=Path('/usr/share/sparky-beep/lib')
    lib.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(source/'lib/config.sh',lib/'config.sh')
    config=Path('/etc/sparky-beep')
    config.mkdir(exist_ok=True)
    (config/'beep.conf').write_text('BEEP_MODE="ternary"\nDEFAULT_TEMPO=60\nDEFAULT_OCTAVE=5\n')
    preenv=dict(os.environ,PATH=f'{work}:/usr/bin:/bin')
    pre=subprocess.run(['sh',str(work/'preinst'),'upgrade','0.2.0'],env=preenv)
    check(pre.returncode==0,'preinst completes')
    check((config/'beep.conf').exists(),'preinst preserves the live conffile')
    check((config/'beep.conf.0.2.1').read_bytes()==(config/'beep.conf').read_bytes(),'preinst copies legacy values for migration')
    try:
        for case in ('works','absent','fails'):
            if case!='absent': Path('/run/systemd/system').mkdir(parents=True,exist_ok=True)
            for name,arg in [('postinst','configure'),('prerm','remove'),('postrm','remove')]:
                calls=work/'calls'; calls.unlink(missing_ok=True)
                journal=work/'journal'; journal.unlink(missing_ok=True)
                env=dict(os.environ,PATH=f'{work}:/usr/bin:/bin',CALLS=str(calls),JOURNAL=str(journal),FAIL='yes' if case=='fails' else 'no',LC_ALL='C.UTF-8')
                p=subprocess.run(['sh',str(work/name),arg],env=env,text=True,capture_output=True)
                prefix=f'{case}-{name}'
                (out/f'{prefix}.stderr').write_text(p.stderr)
                (out/f'{prefix}.stdout').write_text(p.stdout)
                (out/f'{prefix}.exit').write_text(str(p.returncode)+'\n')
                (out/f'{prefix}.journal').write_text(journal.read_text() if journal.exists() else '')
                check(p.returncode==0,f'{prefix}: completes')
                if case=='absent':
                    check(not calls.exists(),f'{prefix}: no service calls')
                    check('deferred until boot' in p.stderr,f'{prefix}: skip said')
                elif case=='fails':
                    check('systemctl injected failure' in p.stderr,f'{prefix}: original error shown')
                    check(journal.exists() and 'systemctl injected failure' in journal.read_text(),f'{prefix}: error journaled')
                    check('Failed: systemctl' in p.stderr,f'{prefix}: closing line names failures')
                    if name=='postinst': check('runner injected failure' in p.stderr,'postinst: runner error shown')
                else:
                    check('Completed: ' in p.stderr and 'Failed: -.' in p.stderr,f'{prefix}: honest success summary')
            if Path('/run/systemd/system').exists(): Path('/run/systemd/system').rmdir()
        converted=(config/'beep.conf').read_text()
        check(all(x in converted for x in ('[general]','beep_mode=ternary','default_tempo=60','default_octave=5')),'migration: old values preserved in INI')
        check((config/'backups/beep.conf.0.2.1').read_text().startswith('BEEP_MODE='),'migration: shell config backup preserved')
    finally:
        if Path('/run/systemd/system').exists(): Path('/run/systemd/system').rmdir()
        if old_runner is None: runner.unlink()
        else: runner.write_bytes(old_runner)
print(f'{failed} failed checks')
sys.exit(bool(failed))
