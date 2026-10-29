"""Standard-library-only runner; GCC and MATLAB are external prerequisites.

Run from repository root: python3 verification/run_checks.py prepare
Then run check_matlab(output_directory) in MATLAB before the sweep stage.
"""
import csv
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

REPO = Path(__file__).resolve().parents[1]
OUT = REPO / '.sisyphus/rk4-verification-20261029'


def compile_diagnostic(legacy=False):
    exe = OUT / ('legacy' if legacy else 'corrected')
    subprocess.run(['gcc', '-O3', '-std=c11', '-Wall', '-Wextra',
                    '-ffp-contract=off', *(['-DLEGACY_STAGE'] if legacy else []),
                    str(REPO / 'verification/diagnostic.c'), '-lm', '-o', str(exe)], check=True)
    return exe


def run_case(name, seed, field, current, dt=5, legacy=False,
             duration=5, start=1, width=3, seed_file=None):
    path = OUT / (name + '.csv')
    args = [str(OUT / ('legacy' if legacy else 'corrected')), str(path),
            str(seed), str(field * 1e-4), str(current), str(duration),
            str(start), str(width), str(dt)]
    if seed_file:
        args.append(str(seed_file))
    result = subprocess.run(args, check=True, capture_output=True, text=True)
    print(result.stdout.strip(), flush=True)
    return path


def matlab_copy(name, field=0, current=0, seed=210, legacy=False):
    folder = OUT / name
    folder.mkdir(exist_ok=True)
    for p in REPO.glob('*.m'):
        shutil.copy2(p, folder / p.name)
    if legacy:
        p = folder / 'rk4_4llg.m'
        data = p.read_bytes()
        for spin in ('Fe1', 'Fe2', 'Fe3', 'Gd1', 'Gd2', 'Gd3'):
            data = data.replace(f'kk3_{spin}*ts1;'.encode(), f'kk3_{spin}*ts1/2;'.encode())
        p.write_bytes(data)
    source = (REPO / 'main.m').read_text().split('\nrk4_4llg();')[0]
    source = source.replace('clear ;clc;close all;', '').replace('\ntic\n', '\n')
    source = source.replace('runtime=5000e-12;', 'runtime=20e-12;')
    source = source.replace('starttime=1000e-12;', 'starttime=0;')
    source = source.replace('pulsewidth=3000e-12;', 'pulsewidth=runtime;')
    source = source.replace('Hext=[0,0.0250,0];', f'Hext=[0,{field*1e-4:.17g},0];')
    source = source.replace('jc_SOT=50e9;', f'jc_SOT={current:.17g};')
    source = source.replace('inita_theta=210/180*pi;', f'inita_theta={seed}/180*pi;')
    (folder / 'initialize.m').write_text(source)
    return folder


def prepare():
    OUT.mkdir(parents=True, exist_ok=True)
    compile_diagnostic()
    compile_diagnostic(True)
    matlab_copy('analytical_0')
    matlab_copy('analytical_1', legacy=True)
    folder = matlab_copy('pilot')
    path = run_case('pilot_diagnostic', 210, 0, 0, duration=.02, start=0, width=.02)
    shutil.copy2(path, folder / 'diagnostic.csv')
    sources = [*REPO.glob('*.m'), *sorted((REPO / 'verification').glob('*'))]
    hashes = {str(p.relative_to(REPO)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in sources if p.is_file()}
    (OUT / 'source-hashes.json').write_text(json.dumps(hashes, indent=2) + '\n')


def cases():
    for sign, field, current in [('pp',100,5e10),('pm',-100,5e10),
                                 ('mm',-100,-5e10),('mp',100,-5e10)]:
        for seed in (30,90,150,210,270,330):
            yield f'fig2_{sign}_{seed}', seed, field, current
    for field in (175,200,225,250,275,300,325,350,375,400,450,500):
        yield f'fig5_{field}', 210, field, 5e10
    for sign, current in [('p',5e10),('m',-5e10)]:
        for seed in (30,90,150,210,270,330):
            yield f'fig5_1000{sign}_{seed}', seed, 1000, current


def sweep():
    gate = json.loads((OUT / 'matlab-checks.json').read_text())
    assert gate['crosschecks']['pilot'] < 1e-10
    # Independent child processes write distinct files. Collect every failure.
    with ThreadPoolExecutor(max_workers=8) as pool:
        jobs=[]
        for name, seed, field, current in cases():
            jobs.append(pool.submit(run_case,name+'_legacy',seed,field,current,legacy=True))
            for dt in (5,2.5,1.25):
                jobs.append(pool.submit(run_case,name+f'_dt{dt}',seed,field,current,dt=dt))
        for job in jobs:
            job.result()


def replays():
    selected = [('pp','fig2_pp_270',100,5e10),('pm','fig2_pm_270',-100,5e10),
                ('mm','fig2_mm_270',-100,-5e10),('mp','fig2_mp_270',100,-5e10),
                ('275','fig5_275',275,5e10),('300','fig5_300',300,5e10),
                ('1000p','fig5_1000p_210',1000,5e10),
                ('1000m','fig5_1000m_210',1000,-5e10)]
    for label, name, field, current in selected:
        folder = matlab_copy('replay_'+label, field, current)
        replay_start = 1.02e-9 if label.startswith('1000') else 1.5e-9
        with (OUT / (name+'_dt5.csv')).open() as f:
            rows = list(csv.reader(f))
        index = next(i for i,row in enumerate(rows) if abs(float(row[1])-replay_start)<1e-18)
        row = rows[index]
        spin = [float(x) for x in row[2:]]
        seed_file = folder / 'seed.csv'
        with seed_file.open('w') as f:
            csv.writer(f).writerows([[spin[i],spin[i+6],spin[i+12]] for i in range(6)])
        path = run_case('replay_'+label+'_diagnostic', 210, field, current,
                        duration=.02, start=0, width=.02, seed_file=seed_file)
        with path.open() as f:
            replay = list(csv.reader(f))
        discrepancy = max(abs(float(x)-float(y))
                          for a,b in zip(replay,rows[index:index+len(replay)])
                          for x,y in zip(a[2:],b[2:]))
        assert discrepancy < 1e-14, (label, discrepancy)
        shutil.copy2(path, folder / 'diagnostic.csv')


if __name__ == '__main__':
    {'prepare':prepare, 'sweep':sweep, 'replays':replays}[sys.argv[1]]()
