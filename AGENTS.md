# Mn3Sn_3atoms repository instructions

- Read `README.md` for provenance, execution, output behavior, and known limitations.
- `main.m` is the default caller; `mn3sn_default_config.m` and
  `mn3sn_validate_config.m` define the maintained input interface. `mn3sn_run.m`
  binds inputs in a private workspace, runs the existing integration script and
  saves a versioned result. `conf_file.m` supplies factory switch defaults;
  `constantfile.m` supplies constants. `rk4_4llg.m`, `field_eta.m` and
  `LLG_solver.m` retain the numerical path; do not assume scripts are standalone.
- This repository preserves the archived Fig. 5 MATLAB source. Do not silently fix
  numerical or physical behavior during maintenance or publication work.
- Before edits, check `git status --short --branch`; preserve unrelated changes
  and existing source line endings. Commit and push only when authorized.
- Use the installed `spin-dynamics-development` skill for physics, fields,
  torques, solver changes, and scientific validation. Obtain approval of the
  model and implementation scope before substantial source changes.
- Production runs must use `mn3sn_run` (or its `main` caller). It allocates
  a fresh `.sisyphus/runs/` directory or requires a new explicit destination.
  `final.mat` contains only schema-1 `result`; text is written once per run.
  Do not execute numerical scripts directly in the root or publication archive.
  Preserve existing results and keep generated outputs out of Git.
- `benchmark/baseline_manifest.json` owns the explicitly accepted 11-case suite
  and 75 immutable artifacts in `benchmark/baseline/`. Routine commands never
  regenerate or accept references. Missing/corrupt references fail; replacement
  requires explicit review of concrete new artifacts. Historical capture tools
  require the pre-migration source and are not routine baseline-update commands.
- Focused check: MATLAB `addpath('tests','benchmark'); run_all_tests();`.
  For numerical changes also run the analytical/precession and nine MATLAB/C
  checks in `benchmark/README.md`. Use a fresh explicit `--out` for Python
  preparation; do not reuse historical output folders. The full-default 5 ns
  regression is an explicit extended check, not a routine smoke test.
- Compare every saved spin sample and both clocks; preserve normalization, pulse
  indexing, arithmetic order and six-spin state order. `time_s` is physical time;
  `legacy_tt` and text retain historical labels and their separate sampling rules.
  Baseline agreement does not establish validity of untested physics.
- `SOURCE_SHA256SUMS` is the immutable initial-import provenance record, not the
  current regression manifest. For documentation-only checks, inspect commands
  without launching a simulation and verify the nine unchanged distributed files:
  `rg '  (.*\.m|PBSScript)$' SOURCE_SHA256SUMS | rg -v '  (main|field_eta|rk4_4llg)\.m$' | sha256sum -c -`.
  `main.m`, `field_eta.m`, and `rk4_4llg.m` intentionally differ and retain CRLF.
  The complete original manifest also requires original untracked result files;
  never regenerate it to accommodate source changes or missing outputs.
- Check documentation impact, `git diff --stat`, and `git diff --check` before
  completion. Do not modify the original publication archive as a side effect.
- Update `CHANGELOG.md` for meaningful behavior changes or significant fixes, following the global changelog policy. Group related edits into one entry.
