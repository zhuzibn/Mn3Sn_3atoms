# Accepted deterministic regression

The user accepted the verified 11-case selection on 2026-11-20.
[baseline_manifest.json](baseline_manifest.json) records acceptance, inputs,
source/environment identity and hashes for **75 files (5,463,738 bytes)** in
`baseline/`. These files must accompany a checkout; ordinary checks need no
external historical data. The original [reference_proposal.json](reference_proposal.json)
remains an immutable, explicitly unaccepted historical proposal. It is not the
current acceptance record.

## Run candidates and focused tests

Requirements: MATLAB with Java (tested R2024b Update 1, PCWIN64). From the
repository root, choose unused destinations whose parent exists:

```matlab
addpath('benchmark','tests');
if ~isfolder('.sisyphus'), mkdir('.sisyphus'); end
quick = run_regression(fullfile(pwd,'.sisyphus','candidate-<unique>'),'quick');
report = compare_to_baseline(quick,'quick');
tests = run_all_tests(quick);
% Explicit longer check; not a routine smoke test:
full = run_regression(fullfile(pwd,'.sisyphus','default-<unique>'),'extended');
report = compare_to_baseline(full,'extended');
```

`run_all_tests()` without an argument generates its own fresh quick candidate.
Checks raise errors, so MATLAB `-batch` exits nonzero on failure. Reusing a
candidate destination is an error. Missing or changed references are errors;
there is no automatic capture, acceptance, overwrite or update mode.

`regression_cases.m` fixes the case inventory: ten 20 ps quick cases (historical
pilot, eight fixed driven-state replays, and a 5–15 ps pulse-edge case) plus the
5 ns original-default case. Full-default execution uses the real current factory;
quick runs map the accepted exact inputs, including fixed seed arrays, onto the
same production API. All cases preserve the original 5 fs timestep and stride 50.

The comparator verifies accepted artifact hashes, complete inventory, exact
configuration/effective inputs and initial states, state/component order, units,
solver/text sampling metadata, every sample of all six spins, both clocks, raw
norms, RNG preservation and exact legacy text bytes. Component tolerance is
`<1e-10`, norm error `<1e-12`, and each clock tolerance is
`32*eps(max(abs(reference_time)))`, with exact initial zero. These repository-specific
limits cover the observed historical MATLAB/C discrepancy; actual migrated
MATLAB trajectories agree exactly. Agreement detects change, not physical validity.

Tests use fresh disposable copies for interior-state, clock, input, shape, NaN,
norm, ordering, text and metadata corruption, incomplete inventories and damaged
references. Output tests cover existing destinations, caller independence,
shadowed source rejection, and actual baseline symlinks/junctions. Accepted data
remain read-only. Candidate output includes a `suite.json` inventory and per-case
schema-1 `final.mat`/`result.txt` from `mn3sn_run`.

## Analytical checks without the full figure sweep

GCC and Python 3 standard library are additional prerequisites. In Bash/WSL:

```bash
python3 verification/run_checks.py prepare --out .sisyphus/focused-<unique>
python3 verification/run_checks.py accepted-replays --out .sisyphus/focused-<unique>
```

Then in MATLAB from the repository root:

```matlab
addpath('verification');
check_matlab(fullfile(pwd,'.sisyphus','focused-<unique>'),'full');
```

This tests corrected/archived-control precession with damping 0 and 0.1 at four
resolutions, followed by the pilot and eight accepted MATLAB/C cases. Current
numerical sources execute in isolated copies; fixed pre-migration initializers
and seed/C fixtures supply inputs. `pilot` mode checks only the pilot plus
precession and writes separate `matlab-pilot.csv`/`matlab-checks-pilot.json`.
`full` writes `matlab-full.csv`/`matlab-checks.json`. Existing files are rejected
before simulation, including partial failed runs. Fresh preparation is required
after source changes. The optional 192-case workflow remains in the
[RK4 report](../docs/rk4-verification.md#reproduce).

## Ownership and capture history

Only explicit review of new concrete data can replace an accepted baseline.
Candidate and production runners reject the accepted directory and resolved
aliases. Do not edit reference arrays/manifests to make a comparison pass.
Git attributes preserve exact bytes, including mixed source/fixture line endings.
Copy the full accepted directory and manifest together when transferring them;
`read_baseline` verifies every file before comparison or candidate execution.

The initial capture used two isolated repetitions of unchanged corrected code.
Repeat 1 supplies eleven compact MAT references and eleven text outputs;
source/fixture/tool snapshots and preparation records complete the 75-file set.
Repeat 2, repeated sources, raw legacy workspaces, failed proposals and mutation
fixtures were excluded. All repetitions agreed exactly. Full commands and
measured results are in the [CQ report](../docs/code-quality-verification.md).

`prepare_reference.m` and `check_reference_capture.m` retain the one-time capture
workflow and checks. They require the original pre-migration source hashes and
historical `.sisyphus/rk4-verification-20261029` artifacts. They intentionally do
not accept the migrated production source as a replacement capture input and
are not routine baseline-update commands. Frozen copies under `baseline/tools/`
remain part of accepted provenance; never modify them.
