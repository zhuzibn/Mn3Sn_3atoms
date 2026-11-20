# Retained trajectory storage verification

The user approved revision 1 of the CQ-03 plan on 2026-11-20. The implementation
keeps only the current six spins, RK scratch and requested output rows in
`rk4_4llg.m`. Unused full-length diagnostic histories were removed after tracing
their consumers. Field/RHS functions, constants, defaults, pulse/time arrays,
normalization and arithmetic order are unchanged. Public MAT samples, physical
and legacy clocks, and legacy text bytes retain their previous conventions.

The scientific specification and unresolved R1 material attribution remain in
[the API verification report](code-quality-verification.md). This is a storage
change to that existing six-vector model, not new physical validation.

## Evidence and procedure

Fresh evidence is under
`D:/Git_control/spin_dynamics/.sisyphus/cq-followup-20261120-v1/`.
`Mn3Sn_3atoms/approved-plan.md` preserves the full approved specification;
`Mn3Sn_3atoms/before/` preserves pre-change root MATLAB bytes.
The accepted baseline was read only. Runtime: MATLAB R2024b Update 1, Windows CPU.

1. `capture_three_before.m` captured four short dense controls and ran all ten
   quick cases against accepted data. Every saved component matched exactly.
2. `check_three_retention.m` ran `check_retained_storage` against those captures,
   the ten-case quick regression and `run_all_tests(candidate)`. All passed.
   The focused report is
   `.sisyphus/cq-tests-f49c88de-7f44-48c0-84a5-904af8cc92b3/test-report.json`.
3. The final `finish_three_checks.m` repeated the retention check with a fifth
   nondivisible-tail case, ran the analytical/MATLAB-C checks, measured actual
   allocated arrays in disposable source copies, and ran the full default 5 ns
   regression. The 20,000 saved rows matched the accepted trajectory exactly.

The independent retention check uses 2, 17, 18 and 19 nominal steps, strides
1, 4 and 50, minimum runtime, multiple retained rows, an unsaved final tail and
a stride larger than the run. All six vectors and both clocks match dense
stride-one subsets exactly. Legacy text matches exact expected bytes and the
four pre-change captures. The check is available as:

```matlab
addpath('tests');
check_retained_storage(); % self-contained dense/subsample comparison
% To also replay this task's unchanged dense captures:
check_retained_storage('D:/Git_control/spin_dynamics/.sisyphus/cq-followup-20261120-v1/Mn3Sn_3atoms/dense-edges.mat');
```

The independent C fixtures were prepared with:

```bash
python3 verification/run_checks.py prepare --out .sisyphus/cq03-followup-focused-v1
python3 verification/run_checks.py accepted-replays --out .sisyphus/cq03-followup-focused-v1
```

`check_matlab(...,'full')` passed all nine MATLAB/C cases (maximum component
error `8.8922395416342215e-12`). Undamped observed RK4 orders were
3.99613, 3.99903, 3.99976; damped orders were 3.99775, 3.99984, 4.00016.
Archived defective-integrator controls still failed the fourth-order gate.
The nine-file import-preservation command in AGENTS.md also passed.
Logs: `three-retention.log`, `three-full.log`; final full comparison:
`Mn3Sn_3atoms/extended-comparison.mat`. A read-only independent review checked
indexing, text cadence, unchanged arithmetic and preserved source line endings.

## Memory scope

The default allocation probe stopped immediately before integration and recorded
actual `whos` arrays in disposable old/new source copies. State plus discarded
diagnostic histories occupied **312,000,000 bytes before**, compared with
**2,880,144 bytes after** for retained state and rolling vectors (about 99.1%
less). Results are in `allocation-before-result/allocations.mat` and
`allocation-after-result/allocations.mat` under the project task folder.
This is an array-allocation measurement, not total process peak memory or a
speedup claim. Time/pulse arrays remain unchanged. The full publication sweep
was not rerun; no equations or accepted artifacts were changed.
