# Mn3Sn_3atoms repository instructions

- Read `README.md` for provenance, execution, output behavior, and known limitations.
- This repository preserves the archived Fig. 5 MATLAB source. Do not silently fix
  numerical or physical behavior during maintenance or publication work.
- Before edits, check `git status --short --branch`; preserve unrelated changes
  and existing source line endings. Commit and push only when authorized.
- Use the installed `spin-dynamics-development` skill for physics, fields,
  torques, solver changes, and scientific validation. Obtain approval of the
  model and implementation scope before substantial source changes.
- Run MATLAB from the repository root. `main.m` overwrites `final.mat` and the
  solver appends `result.txt`. Preserve archived results and use an isolated copy
  for checks; do not run production simulations as routine repository checks.
- `SOURCE_SHA256SUMS` is the immutable initial-import provenance record. A later
  intentional source change may differ from those original hashes.
- There is no accepted automated regression suite. For copy-only changes verify
  hashes; for numerical changes define scoped scientific checks and record actual
  results without claiming complete published reproduction.
- Check documentation impact, `git diff --stat`, and `git diff --check` before
  completion. Do not modify the original publication archive as a side effect.
- Update `CHANGELOG.md` for meaningful behavior changes or significant fixes, following the global changelog policy. Group related edits into one entry.
