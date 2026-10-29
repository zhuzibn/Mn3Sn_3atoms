# Mn3Sn_3atoms repository instructions

- Read `README.md` for provenance, execution, output behavior, and known limitations.
- `main.m` is the entry script; `conf_file.m` holds switches and
  `constantfile.m` holds constants. The integration path is `rk4_4llg.m`,
  `field_eta.m`, and `LLG_solver.m`. Several files share the script workspace;
  do not assume they are standalone functions.
- This repository preserves the archived Fig. 5 MATLAB source. Do not silently fix
  numerical or physical behavior during maintenance or publication work.
- Before edits, check `git status --short --branch`; preserve unrelated changes
  and existing source line endings. Commit and push only when authorized.
- Use the installed `spin-dynamics-development` skill for physics, fields,
  torques, solver changes, and scientific validation. Obtain approval of the
  model and implementation scope before substantial source changes.
- Run MATLAB from the directory containing `main.m` and its companion `.m`
  files. `main.m` overwrites `final.mat` and the solver appends `result.txt`.
  Preserve archived results and use an isolated source copy for checks, as
  shown in `README.md`; do not run production simulations as routine repository
  checks. Keep generated outputs out of Git.
- `SOURCE_SHA256SUMS` is the immutable initial-import provenance record. A later
  intentional source change may differ from those original hashes.
- There is no accepted automated regression suite. For copy-only changes verify
  hashes; for numerical changes define scoped scientific checks and record actual
  results without claiming complete published reproduction.
- For documentation-only changes, cross-check commands and file descriptions
  against the source without launching a simulation. From the repository root,
  verify the 12 distributed source files with
  `rg '  (.*\.m|PBSScript)$' SOURCE_SHA256SUMS | sha256sum -c -`.
  The full checksum manifest also requires the two original, untracked result
  files; do not regenerate the manifest to accommodate missing or new outputs.
- Check documentation impact, `git diff --stat`, and `git diff --check` before
  completion. Do not modify the original publication archive as a side effect.
- Update `CHANGELOG.md` for meaningful behavior changes or significant fixes, following the global changelog policy. Group related edits into one entry.
